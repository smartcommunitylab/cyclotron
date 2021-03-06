#
cyclotronDirectives.directive 'map', ($window, $timeout, $compile, parameterPropagationService, openLayersService, logService) ->
    {
        restrict: 'C'
        scope:
            mapConfig: '='
            layerOptions: '='
            sourceOfParams: '='
            wmsSections: '='
            featureParams: '='
            widgetId: '='
            controlOptions: '='
            genericEventHandlers: '='
            widgetName: '='
        
        link: (scope, element, attrs) ->
            map = null
            currentMapConfig = null

            #handle generic parameters
            if scope.genericEventHandlers?.widgetSelection?
                handler = scope.genericEventHandlers.widgetSelection.handler
                jqueryElem = $(element).closest('.dashboard-widget')
                handler jqueryElem, scope.genericEventHandlers.widgetSelection.paramName, scope.widgetName

            resize = ->
                #TODO improve
                if map?
                    map.updateSize()
            
            createOverlays = (overlaysToCreate) ->
                if not overlaysToCreate? then overlaysToCreate = scope.mapConfig.overlays
                $timeout ->
                    for overlay in overlaysToCreate
                        overlayElem = document.getElementById overlay.id

                        if overlay.template?
                            content = $compile(overlay.template)(scope)
                            angular.element(overlayElem).append content
                        
                        overlayElem.addEventListener 'click', ->
                            group = this.getAttribute('group')
                            if scope.mapConfig.groups[group].currentOverlay == this.id
                                #either nothing happens or reset scope.mapConfig.groups[group].currentOverlay to ''
                            else
                                scope.mapConfig.groups[group].currentOverlay = this.id
                                #broadcast parameter change if needed
                                if scope.sourceOfParams
                                    parameterPropagationService.parameterBroadcaster scope.widgetId, 'clickOnOverlay', scope.mapConfig.groups[group].currentOverlay, group
                        
                        #add overlay to map
                        config =
                            id: overlay.id
                            element: overlayElem
                        if overlay.position? then config.position = ol.proj.fromLonLat(overlay.position)
                        if overlay.positioning? then config.positioning = overlay.positioning
                        map.addOverlay(new ol.Overlay(config))
            
            createMap = ->
                if not map?
                    console.log 'creating map'
                    #create map layers: each layer is structured as {type: string, source: {name: string, configuration: string}}
                    mapLayers = []
                    _.each scope.mapConfig.layersToAdd, (layer) ->
                        options = scope.layerOptions[layer.type]
                        layerConfig = {}
                        if layer.source?
                            configObj = if layer.source.configuration? then _.jsEval(_.jsExec layer.source.configuration) else {}
                            layerConfig.source = new options.sources[layer.source.name].srcClass(configObj)
                        
                        if layer.styleFunction?
                            styleFunction = _.jsEval layer.styleFunction
                            if _.isFunction(styleFunction) then layerConfig.style = styleFunction

                        mapLayers.push new options.olClass(layerConfig)

                    #create map view
                    mapView = new ol.View({
                        center: ol.proj.fromLonLat scope.mapConfig.center
                        zoom: scope.mapConfig.zoom
                        projection: (if scope.mapConfig.projection? then scope.mapConfig.projection else undefined)
                    })

                    #create map
                    map = new ol.Map({
                        target: attrs.id
                        layers: mapLayers
                        view: mapView
                        controls: []
                    })

                    if scope.wmsSections?
                        #Since the function map.forEachLayerAtPixel produces a CORS error for ImageWMS layers, instead of using it to
                        #find which layer was clicked, feature info is retrieved for each layer whose source is of type ImageWMS
                        map.on 'singleclick', (event) ->
                            console.log 'handling singleclick'
                            _.each mapLayers, (layer) ->
                                source = layer.getSource()
                                if source instanceof ol.source.ImageWMS
                                    _.each scope.wmsSections, (section) ->
                                        #retrieve param LAYERS from source
                                        sourceLayers = source.getParams().LAYERS

                                        #check if it includes section
                                        if sourceLayers.includes section
                                            successCallback = (featureInfo) ->
                                                #if there is some feature, store feature info in the parameter
                                                console.log 'features?', featureInfo.features
                                                if featureInfo.features?.length > 0
                                                    parameterPropagationService.parameterBroadcaster scope.widgetId, 'clickOnWMSLayer', featureInfo, section
                                            
                                            #call getFeatureInfoJson
                                            openLayersService.getFeatureInfoJson(source, section, event.coordinate, mapView.getResolution(), mapView.getProjection()).then(successCallback)
                                            .catch (error) ->
                                                logService.error 'An error occurred while retrieving feature info: ' + error + '. Dashboard configuration may be incorrect.'
                    
                    #handle feature selection
                    if scope.featureParams?
                        if scope.featureParams.length == 1
                            selectedFeature = null
                            map.on 'singleclick', (event) ->
                                map.forEachFeatureAtPixel event.pixel, (feature) ->
                                    #if another feature was selected, deselect it
                                    if selectedFeature != null
                                        selectedFeature.setStyle(undefined)
                                    
                                    #set feature as selected
                                    selectedFeature = feature
                                    selectedStyle = if $window.Cyclotron.featureSelectStyleFunction? then $window.Cyclotron.featureSelectStyleFunction(feature) else undefined
                                    feature.setStyle(selectedStyle)

                                    featureProperties = {}
                                    props = feature.getProperties()

                                    #clone feature properties excluding geometry to avoid exceeding max call stack size
                                    _.each _.keys(props), (key) ->
                                        if key != 'geometry'
                                            featureProperties[key] = props[key]
                                    
                                    parameterPropagationService.parameterBroadcaster scope.widgetId, 'selectVectorFeature', featureProperties
                        else
                            #selection of feature of specific layer, every featureParams element has layerIndex
                            currentFeatures = {}
                            _.each scope.featureParams, (fp) ->
                                currentFeatures[''+fp.layerIndex] = null
                            
                            map.on 'singleclick', (event) ->
                                map.forEachFeatureAtPixel event.pixel, (feature, layer) ->
                                    layerIdx = mapLayers.indexOf layer

                                    if currentFeatures[''+layerIdx] != undefined
                                        #if another feature was selected for the same layer, deselect it
                                        if currentFeatures[''+layerIdx] != null
                                            oldFeature = currentFeatures[''+layerIdx]
                                            oldFeature.setStyle(undefined)

                                        #store feature at corresponding layer index
                                        currentFeatures[''+layerIdx] = feature

                                        #store feature properties in the corresponding parameter
                                        featureProperties = {}
                                        props = feature.getProperties()
                                        #clone feature properties excluding geometry to avoid exceeding max call stack size
                                        _.each _.keys(props), (key) ->
                                            if key != 'geometry'
                                                featureProperties[key] = props[key]

                                        parameterPropagationService.parameterBroadcaster scope.widgetId, 'selectVectorFeature', featureProperties, ''+layerIdx
                                    
                                    #style all selected features
                                    _.each _.keys(currentFeatures), (key) ->
                                        if currentFeatures[key] != null
                                            selectedStyle = if $window.Cyclotron.featureSelectStyleFunction? then $window.Cyclotron.featureSelectStyleFunction(feature) else undefined
                                            feature.setStyle(selectedStyle)
                        ###
                        selectedFeatures = new ol.Collection([], {unique: true})
                        select = new ol.interaction.Select({
                            style: if $window.Cyclotron.featureSelectStyleFunction? then $window.Cyclotron.featureSelectStyleFunction else undefined
                            features: selectedFeatures
                        })
                        map.addInteraction select

                        if scope.featureParams.length == 1
                            #single feature selection
                            select.on 'select', (event) ->
                                feature = selectedFeatures.getArray()[0]
                                featureProperties = {}
                                props = feature.getProperties()

                                #clone feature properties excluding geometry to avoid exceeding max call stack size
                                _.each _.keys(props), (key) ->
                                    if key != 'geometry'
                                        featureProperties[key] = props[key]
                                
                                parameterPropagationService.parameterBroadcaster scope.widgetId, 'selectVectorFeature', featureProperties
                        else
                            #selection of feature of specific layer, every featureParams element has layerIndex
                            currentFeatures = {}
                            _.each scope.featureParams, (fp) ->
                                currentFeatures[''+fp.layerIndex] = null

                            select.on 'select', (event) ->
                                if selectedFeatures.getLength() > 0
                                    #get first selected feature (there may be more if shift is used to select them)
                                    feature = selectedFeatures.getArray()[0]
                                    layerIdx = mapLayers.indexOf select.getLayer(feature)

                                    if currentFeatures[''+layerIdx] != undefined
                                        #store feature at corresponding layer index
                                        currentFeatures[''+layerIdx] = feature

                                        #store feature properties in the corresponding parameter
                                        featureProperties = {}
                                        props = feature.getProperties()
                                        #clone feature properties excluding geometry to avoid exceeding max call stack size
                                        _.each _.keys(props), (key) ->
                                            if key != 'geometry'
                                                featureProperties[key] = props[key]

                                        parameterPropagationService.parameterBroadcaster scope.widgetId, 'selectVectorFeature', featureProperties, ''+layerIdx
                                    
                                #reset collection to keep selected also current features of other layers
                                selectedFeatures.clear()
                                _.each _.keys(currentFeatures), (key) ->
                                    if currentFeatures[key] != null
                                        selectedFeatures.push currentFeatures[key]
                        ###

                    #if there are overlays, create them and add them to the map
                    if scope.mapConfig.overlays? and scope.mapConfig.overlays.length > 0
                        createOverlays()

                    #if there are controls, create them and add them to the map
                    if scope.mapConfig.controls? and scope.mapConfig.controls.length > 0
                        _.each scope.mapConfig.controls, (control) ->
                            map.addControl(new scope.controlOptions[control]())

                else
                    map.updateSize()

            #if layer source has changed (i.e. because it is parametric), update it on the map
            updateLayers = (newConfig) ->
                _.each newConfig.layersToAdd, (layer, index) ->
                    if layer.source?.configuration? and not
                            _.isEqual(layer.source.configuration, currentMapConfig.layersToAdd[index].source.configuration)
                        currentLayer = map.getLayers().getArray()[index]
                        configObj = _.jsEval(_.jsExec layer.source.configuration)
                        newSource = new scope.layerOptions[layer.type].sources[layer.source.name].srcClass(configObj)
                        currentLayer.setSource(newSource)
                currentMapConfig.layersToAdd = _.cloneDeep newConfig.layersToAdd

            #if overlay content has changed (i.e. because it is parametric), update it on the map
            updateOverlays = (newConfig) ->
                if map.getOverlays().getLength() == 0
                    #map has no overlay yet (i.e. overlays are provided by a datasource which has just finished executing)
                    createOverlays()
                    currentMapConfig.overlays = _.cloneDeep newConfig.overlays
                else
                    _.each newConfig.overlays, (overlay, index) ->
                        currentOverl = _.find currentMapConfig.overlays, {id: overlay.id}
                        if currentOverl?
                            #remove old template from overlay element to avoid duplication
                            angular.element(document.getElementById(overlay.id)).empty()
                            ###
                            Note: currently overlays already existing are re-added to the map creating duplicates (non visible)
                            that do not seem to affect map behavior. Decommenting the following line would avoid such duplicates
                            but cause the correct overlay HTML elements to become null in some cases.
                            ###
                            #map.removeOverlay map.getOverlayById(overlay.id)
                    
                    #remove old overlays, if any
                    overlaysToRemove = _.filter currentMapConfig.overlays, (ov) ->
                        return _.findIndex(newConfig.overlays, { id: ov.id }) == -1
                    
                    _.each overlaysToRemove, (ov) ->
                        map.removeOverlay map.getOverlayById(ov.id)
                    
                    #(re)create the new overlays
                    createOverlays(newConfig.overlays)
                    
                    currentMapConfig.overlays = _.cloneDeep newConfig.overlays
            
            scope.$watch('mapConfig', (mapConfig, oldMapConfig) ->
                return unless mapConfig
                if map?
                    #check each property to find what is different and update the map accordingly
                    for key in _.keys(mapConfig)
                        if not _.isEqual(mapConfig[key], currentMapConfig[key])
                            switch key
                                when 'zoom' then map.getView().setZoom(mapConfig.zoom)
                                when 'center' then map.getView().setCenter(ol.proj.fromLonLat(mapConfig.center))
                                when 'layersToAdd' then updateLayers(mapConfig)
                                when 'overlays' then updateOverlays(mapConfig)
                else
                    currentMapConfig = _.cloneDeep mapConfig
                    createMap()
            , true)
            
            # Update on window resizing
            resizeFunction = _.debounce resize, 100, { leading: false, maxWait: 300 }
            $(window).on 'resize', resizeFunction

            # Cleanup
            scope.$on '$destroy', ->
                $(window).off 'resize', resizeFunction
                map.setTarget(null)
                map = null
            
            return
    }
