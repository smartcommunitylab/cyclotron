###
# Copyright (c) 2013-2015 the original author or authors.
#
# Licensed under the MIT License (the "License");
# you may not use this file except in compliance with the License. 
# You may obtain a copy of the License at
#
#     http://www.opensource.org/licenses/mit-license.php
#
# Unless required by applicable law or agreed to in writing, 
# software distributed under the License is distributed on an 
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, 
# either express or implied. See the License for the specific 
# language governing permissions and limitations under the License. 
###

#
# Html Widget
#
# Displays raw HTML, optionally repeating over a Data Source.
# Options:
# {
#     <See help>
# }
#
# If the Data Source is not used, the HTML will be output once.  If it is provided, the 
# html property is treated as a repeater, while the preHtml and postHtml are rendered only once.
#
# Title is optional, but can be used to give the same style title as other widgets.

cyclotronApp.controller 'HtmlWidget', ($scope, $element, $timeout, dashboardService, dataService, parameterPropagationService) ->
    firstLoad = true
    #check parameters
    $scope.randomId = '' + Math.floor(Math.random()*1000)
    parameterPropagationService.checkParameterSubscription $scope
    parameterPropagationService.checkGenericParams $scope

    if $scope.genericEventHandlers?.widgetSelection?
        handler = $scope.genericEventHandlers.widgetSelection.handler
        jqueryElem = $($element).closest('.dashboard-widget')
        handler jqueryElem, $scope.genericEventHandlers.widgetSelection.paramName, $scope.widget.name


    #substitute any parameter placeholders in the configuration
    widgetWithoutPlaceholders = parameterPropagationService.substitutePlaceholders $scope

    prepareHtml = () ->
        $scope.htmlStrings = []

        if widgetWithoutPlaceholders.preHtml?
            $scope.preHtml = _.jsExec widgetWithoutPlaceholders.preHtml

        if widgetWithoutPlaceholders.postHtml?
            $scope.postHtml = _.jsExec widgetWithoutPlaceholders.postHtml
    
    prepareHtml()

    $scope.reload = ->
        $scope.dataSource.execute(true)

    # Load Data Source
    dsDefinition = dashboardService.getDataSource $scope.dashboard, widgetWithoutPlaceholders
    $scope.dataSource = dataService.get dsDefinition
    
    # Initialize
    if $scope.dataSource?
        $scope.dataVersion = 0
        $scope.widgetContext.loading = true

        # Data Source (re)loaded
        $scope.$on 'dataSource:' + dsDefinition.name + ':data', (event, eventData) ->
            return unless eventData.version > $scope.dataVersion
            $scope.dataVersion = eventData.version

            $scope.widgetContext.dataSourceError = false
            $scope.widgetContext.dataSourceErrorMessage = null

            data = eventData.data[dsDefinition.resultSet].data
            data = $scope.filterAndSortWidgetData(data)

            # Check for no data
            if $scope.widgetContext.nodata == true
                $scope.htmlStrings = []
            else
                dataCopy = _.cloneDeep data
                _.each dataCopy, (row, index) -> row.__index = index

                # Compile HTML template with rows
                $scope.htmlStrings = _.map dataCopy, _.partial(_.compile, widgetWithoutPlaceholders.html)

                if $scope.preHtml?
                    $scope.htmlStrings.unshift $scope.preHtml
                if $scope.postHtml?
                    $scope.htmlStrings.push $scope.postHtml

            $scope.widgetContext.loading = false

        # Data Source error
        $scope.$on 'dataSource:' + dsDefinition.name + ':error', (event, data) ->
            $scope.widgetContext.dataSourceError = true
            $scope.widgetContext.dataSourceErrorMessage = data.error
            $scope.widgetContext.nodata = null
            $scope.widgetContext.loading = false
            $scope.htmlStrings = []

        # Data Source loading
        $scope.$on 'dataSource:' + dsDefinition.name + ':loading', ->
            $scope.widgetContext.loading = true
        
        # Initialize the Data Source
        $scope.dataSource.init dsDefinition

    else 
        # Override the widget feature of exporting data, since there is no data
        $scope.widgetContext.allowExport = false

        # Check for hardcoded HTML
        buildStrings = ->
            $scope.htmlStrings.push $scope.preHtml if $scope.preHtml?
            $scope.htmlStrings.push _.jsExec widgetWithoutPlaceholders.html
            $scope.htmlStrings.push $scope.postHtml if $scope.postHtml?

        $scope.loadWidget = ->
            #update configuration with new parameter values
            ###if not firstLoad
                widgetWithoutPlaceholders = parameterPropagationService.substitutePlaceholders $scope
                prepareHtml()

            if widgetWithoutPlaceholders.html?
                # Ensure that HTML content is updated
                if firstLoad then buildStrings() else $timeout(buildStrings)###
            
            if firstLoad
                if widgetWithoutPlaceholders.html? then buildStrings()
            else
                widgetWithoutPlaceholders = parameterPropagationService.substitutePlaceholders $scope
                if widgetWithoutPlaceholders.html?
                    $timeout ->
                        prepareHtml()
                        buildStrings()
            
            firstLoad = false
        
        $scope.loadWidget()
