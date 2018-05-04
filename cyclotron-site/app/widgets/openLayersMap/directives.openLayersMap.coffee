#
cyclotronDirectives.directive 'map', ($window) ->
    {
        restrict: 'C'
        #scope:
        
        link: (scope, element, attrs) ->
            map = null
            createMap = ->
                if not map?
                    #create map layers
                    mapLayers = []
                    _.each scope.layersToAdd, (layer) ->
                        options = scope.layerOptions[layer.type] #olClass, sources
                        layerConfig = {}
                        if layer.source?
                            configObj = if layer.source.configuration? then _.jsEval layer.source.configuration else {}
                            layerConfig.source = new options.sources[layer.source.name].srcClass(configObj)
                        mapLayers.push new options.olClass(layerConfig)

                    #create map view
                    mapView = new ol.View({
                        center: ol.proj.fromLonLat scope.center, 'EPSG:3857'
                        zoom: scope.zoom
                    })

                    #create map
                    map = new ol.Map({
                        target: attrs.id
                        layers: mapLayers
                        view: mapView
                    })
                    
                    #if there are overlays, create them and add them to the map
                    circleOverlay = new ol.Overlay({
                        position: ol.proj.fromLonLat scope.center, 'EPSG:3857'
                        positioning: 'center-center'
                        element: document.getElementById('circle-overlay')
                    })
                    map.addOverlay circleOverlay

                    #if there are controls, create them and add them to the map
                    
                    console.log 'finished'
                else
                    map.updateSize()
            
            createMap()
            
            #scope.$watch 'sliderconfig', (sliderconfig) ->
            
            # Update on window resizing
            resizeFunction = _.debounce createMap, 100, { leading: false, maxWait: 300 }
            $(window).on 'resize', resizeFunction

            # Cleanup
            scope.$on '$destroy', ->
                $(window).off 'resize', resizeFunction
                map = null
                #sliderElement.noUiSlider.destroy()
            
            return
    }
