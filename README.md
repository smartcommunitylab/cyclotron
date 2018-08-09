# Cyclotron

Extension of [Expedia's Cyclotron](https://github.com/ExpediaInceCommercePlatform/cyclotron) with new widgets, data sources and security based on Smart Community's Authentication and Authorization Control Module (AAC).

## New Features

* Widgets: Time Slider (based on noUiSlider), OpenLayers Map (based on OpenLayers), Google Charts (based on Google Charts)

* Data Sources: OData

* Parameter-based interaction between dashboard components

## Requirements

* AAC ([installation instructions](https://github.com/smartcommunitylab/AAC) )
* Node.js
* MongoDB (2.6+) ([installation instructions](http://docs.mongodb.org/manual/installation/))

## Installation

Note that the detailed installation procedure is only summarized here and is better described on [Expedia's page](https://github.com/ExpediaInceCommercePlatform/cyclotron).

1. Clone this repository and ensure that MongoDB is running.

2. Install the REST API and create the configuration file `cyclotron-svc/config/config.js`. Paste in it the content of `sample.config.js`, which contains the configurable properties of the API, such as MongoDB instance and AAC endpoints.

3. Install Cyclotron website.

## API Configuration with AAC

Open `cyclotron-svc/config/config.js` and update the properties according to your needs (remember to configure the same properties in the website config file, e.g. the API server URL. To use AAC as authentication provider, be sure to set the following properties with the correct AAC URLs:

    enableAuth: true
    authProvider: 'AAC'
    oauth: {
        userProfileEndpoint: 'http://localhost:8080/aac/basicprofile/me'
        userRolesEndpoint: 'http://localhost:8080/aac/userroles/me'
        scopes: 'profile.basicprofile.me,user.roles.me'
        tokenValidityEndpoint: 'http://localhost:8080/aac/resources/access'
        tokenInfoEndpoint: 'http://localhost:8080/aac/resources/token'
        tokenRolesEndpoint: 'http://localhost:8080/aac/userroles/token'
        apikeyCheckEndpoint: 'http://localhost:8080/aac/apikeycheck'
        parentSpace: 'components/cyclotron'
    }

Do the same with `cyclotron-svc/config/config.js`. Be sure to set the following properties under `authentication`:

    enable: true
    authProvider: 'aac'
    authorizationURL: 'http://localhost:8080/aac/eauth/authorize'
    clientID: ''
    callbackDomain: 'http://localhost:8088'
    scopes: 'profile.basicprofile.me user.roles.me'
    userProfileEndpoint: 'http://localhost:8080/aac/basicprofile/me'
    tokenValidityEndpoint: 'http://localhost:8080/aac/resources/access'







4. Start the service in node:

        node app.js

### Website

4. Build and run the service:

        gulp server

5. Update the configuration file at `_public/js/conf/configService.js` as needed.  Gulp automatically populates this file from `sample.configService.js` if it does not exist.
