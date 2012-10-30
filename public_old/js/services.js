'use strict';

/* Services */

angular.module('suboutServices', ['ngResource']).
    factory('Opportunity', function($resource){
        return $resource('/api/v1/auctions/:opportunityId', {}, {});
    }).
    factory('MyBid', function($resource){
        return $resource('/api/v1/bids', {}, {});
    }).
    factory('Bid', function($resource){
        return $resource('/api/v1/opportunities/:opportunityId/bids', {opportunityId:'@opportunityId'}, {
            create: {method:'POST', params:{}, isArray:true}
        });
    }).
    factory('Event', function($resource){
        return $resource('/api/v1/events/:eventId', {}, {});
    }).
    factory('Company', function($resource){
        return $resource('/api/v1/companies/:companyId.json', {}, {
            query: {method:'GET', params:{companyId:'all'}, isArray:true}
        });
    }).
    factory('Token', function($resource){
        return $resource('/api/v1/tokens', {}, {});
    }).
    factory('Filter', function($resource){
        return $resource('/api/v1/filters.json', {}, {
            query: {method:'GET', params:{}, isArray:true}
        });
    }).
    factory('Tag', function($resource){
        return $resource('/api/v1/tags.json', {}, {
            query: {method:'GET', params:{}, isArray:true}
        });
    }).
    factory("OpportunityTest", function($resource){
        
        return $resource('/api/v1/opportunities.json', {}, {});
    });
