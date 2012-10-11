'use strict';

/* Services */

angular.module('suboutServices', ['ngResource']).
    factory('Opportunity', function($resource){
        return $resource('/api/v1/auctions/:opportunityId', {}, {});
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
        return $resource('/apis/filters.json', {}, {
            query: {method:'GET', params:{}, isArray:true}
        });
    }).
    factory('Tag', function($resource){
        return $resource('/apis/tags.json', {}, {
            query: {method:'GET', params:{}, isArray:true}
        });
    }).
    factory("Test", function($resource){
        
        return $resource('/opportunities.json', {}, {
            create: {method:'POST', params:{ }, isArray:true},
        });
    });
