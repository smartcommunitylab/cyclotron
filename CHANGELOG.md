# 1.36.0 (08/04/2016)

## Features

 - Dashboard Performance: optimized dashboard and widget performance

 - Animations: Enabled assorted animations across Cyclotron, e.g. transitioning accordions, slide-in dialogs.

 - Dashboard Sidebar: Show/Hide Widgets: added a master toggle to show or hide all widgets

## Bug Fixes

 - Number Widget: improved auto-scaling algorithm to avoid situations with overlapping or truncated text

# 1.35.0 (07/21/2016)

## Features

 - Header Widget: Added built-in Parameter editing to the Header Widget, standardizing a common use-case for many Dashboards. Supports editing via textbox, checkbox, dropdown, list of links, datetime, date, or time. Dropdowns or link lists can be populating using results from a Data Source.  Datetime/date/time types feature a UI date time picker, or can be edited manually.

 - Widget Help Tooltips: Added new, optional help text to each Widget, which appears in a tooltip over a question mark icon in the top-right corner of the Widget. Useful to provide users some context or more information about the data being displayed.

 - Upgraded Modernizer to 3.3.1 and tweaked feature selection.

## Bug Fixes

 - Fixed issues with Incompatible Browser message appearing in Chrome when zooming in.

# 1.34.0 (07/07/2016)

## Features

 - Dashboard Sidebar: Added a new sidebar with a toolbar of relevent links, ability to show/hide Widgets, and space for Dashboard-defined content to appear. Dashboards can use this space to provide useful information about the data or visualizations, or to add controls, filters, etc.

 - Cyclotron.functions.forceUpdate: Added method to manually trigger an Angular.js digest cycle.

 - Upgraded Moment.js to 2.13.0

## Bug Fixes

 - Dashboard Performance: improved dashboard performance across the board

 - Table Widget: fixed broken Freeze Headers functionality

 - Header Widget: when displaying page name in the header, value was always blank

 - Fixed Numeral formatting errors with non-numeric strings; added unit tests

# 1.33.0 (06/23/2016)

## Features

 - JavaScript API for hiding/showing Widgets: Added API for changing the visibility of Widgets at runtime. Changes to Widget visibility is remembered across sessions by the user's browser.

# 1.32.0 (06/09/2016)

## Features

 - Number Widget: Extended auto-sizing of numbers to up to 4 numbers per widget.

 - Header Widget: New Widget with basic functionality for displaying simple headers at the top of Dashboards.

 - Table Widget: Added click event handler: can provide a JavaScript function that gets executed when a table cell is clicked.

 - Grid Layout Adjustments: Added new Page layout properties for adding/subtracting height or width from the dimensions of the page when calculating grid dimensions. This is useful for allowing a header to have a fixed
 height, while sizing the remaining widgets to fit the browser window.

## Bug Fixes

 - Number Widget: fixed flicker when a Data Source refreshes and content is redrawn.

# 1.31.0 (05/26/2016)

## Features

 - Table Widget: Added optional pagination--can automatically or manually specify the number of rows displayed per page. Improves performance when displaying large Data Sources.
 
 - Number Widget: Added Click event handler: can provide a JavaScript function that gets executed when the Number is clicked.

 - Dashboard Controls: Added an option to disable the UI controls completely

## Bug Fixes

 - Elasticsearch: Fixed error handling for HTTP status code 400

 - _.flattenObject: Fixed premature return when handling false values

## Breaking Changes

 - Removed overrides to the Highcharts' dateFormats property

# 1.30.0 (05/12/2016)

## Features

 - Annotation Chart: Added option to handle time range change events

 - Annotation Chart: enabled undocumented lineDashStyle property for series

# 1.29.0 (04/28/2016)

## Features

 - Elasticsearch Data Source: submits searches to Elasticsearch and parses the results. Optionally supports AWS IAM request signing to enable use with AWS Elasticsearch service

 - Backward Dashboard Rotation: enabled rotating Dashboards backwards from the current page without requiring forward rotation beforehand

## Bug Fixes

 - Cyclotron logo link: fixed instances when clicking would not redirect to the Home page

 - Revision History: fixed failures when viewing very large Revision Histories by adding a MongoDB index

# 1.28.0 (04/14/2016)

## Features

 - Persistent Parameters: added an option to persist the value of a parameter in the browser's storage. Any value changes are persisted automatically, and will be restored the next time the user opens the Dashboard
 
 - Search: added sort parameters to URL, paging for results

 - Browse Dashboards: added a new link to see the top liked dashboards; new search filter "is:liked"

 - Dashboard History: shows revision history and compares different revisions against each other

 - Dashboard Editor: Added button to view Dashboard without enabling Live mode

 - Data Sources: Added Error Handler option; able to modify errors messages that occur before displaying them to the user

 - Example JavaScript Data Source Dashboard: new example dashboard added

 - Clock Widget: improved presentation; fixed bug with Live mode

 - QR Code Widget: Generate and display QR codes

 - New User Welcome Message: added a configurable message that appears on a user's first visit to the Home/Search Results pages

 - Help page: added search, deeplinks to specific topics

 - Analytics: now displays the number of unique UIDs used in the past month to view Dashboards

## Bug Fixes

 - Table Widget: "sortBy" property doesn't work

# 1.27.0 (03/17/2016)

## Features

 - Annotation Chart: built-in support for editing annotations.  Annotations are stored in CyclotronData and can be shared between different charts.

 - CyclotronData: HTTP and JavaScript API for storing simple data directly in Cyclotron.  A new Data Source makes it easy to load from CyclotronData into Widgets.  Limited to 16MB

 - Analytics: Add number of unique, active “likes” on the Analytics page; enable additional statistics like average number of tags, editors, viewers per Dashboard

 - Angular.js upgraded to 1.4.x branch.

 ## Bug Fixes

  - Table Widget: numeralformat properties does not support inline JS unless used in a rule

# 1.26.0 (03/03/2016)

## Features

 - Like button always visible: instead of hiding when logged out, the clicking the Like button will prompt the user to login.

## Bug Fixes

 - Logout and Like button no longer shown when authentication is disabled

# 1.25.0 (02/18/2016)

## Features

 - Image Widget: added a new Widget for displaying images.

 - YouTube Widget: added a new Widget for displaying YouTube videos.

 - Data Source Broadcasting: rewrote all Data Sources and Widgets to communicate using global events.  This resolves memory leaks and performance degredation due to unremoved callbacks.

 - Improved logging, and added a configurable property to enable debug logging (globally)

## Bug Fixes

 - Removed unique constraint on email field for Users

## Breaking Changes

 - The Data Source api method 'getData()' has been deprecated.  Any custom Widgets should be rewritten to follow the new event-based messaging pattern.  Any custom Data Sources which use the Data Source Factory (recommended) will automatically use the new pattern.

# 1.24.0 (02/04/2016)

## Features

 - Scrolling Dashboards: Dashboards now automatically scroll if the Widgets on a page exceed the size of the browser.  If the Widgets on a page fit without overflowing, the Dashboard will appear as before without any scrollbars.  This replaces the previous behavior of fitting the page to the browser window, and hiding any overflowing content.

 - Likes: Added the ability for logged-in users to like (and unlike) dashboards.  Users can search for dashboards they liked, or sort search results by the number of likes

 - Sortable Search Results: The Dashboard Search results can be sorted using various keys such as Name, Tags, Visits, Likes, etc.

 - Advanced Search Filters: Dashboards can be searched using several new search filters: "is:deleted", "include:deleted", "likedby:<user>", "lastupdatedby:<user>".

## Bug Fixes

 - Data Sources must be created with unique names

 - Navigating through Cyclotron pages using browser back button does not work
 
 - Annotation Chart: annotationsWidth property in AnnotationChart widget should be a numerical field instead of a string

# 1.23.0 (01/21/2016)

## Features

 - Annotation Chart Widget: New Widget added, based on Google's Annotation Chart control.  Great for creating time-series line charts with or without annotated labels on the data.

 - Analytics API Improvements: added ?max property to most of the endpoints.

 - User API Improvements: collecting Department/Division property from Active Directory.

 - Highcharts upgraded to 4.2.0

## Bug Fixes

 - Fullscreen Graphs Won’t Scale Vertically

 - Chart Widget: Highcharts Property Linked Across Widgets

 - Login Fails for Service Accounts without Department/Division

# 1.22.0 (11/12/2015)

## Features

 - Chart Widget: Drilldown chart support added

 - Highcharts upgraded to 4.1.9

 - Node.js 4.0 support and testing

## Bug Fixes

 - Global Analytics: sort by page views descending.

 - Data Source Placement - Moved the Data Source property to the top of each Widget type (below title) for consistency.

# 1.20.0 (10/15/2015)

## Features

 - Initial public release of Cyclotron