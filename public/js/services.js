'use strict';

/* Services */

angular.module('suboutServices', ['ngResource']).
    factory('Opportunity', function($resource){
        
        return $resource('/apis/opportunities:format1/:opportunityId:format2', {}, {
            query: {method: 'GET', params:{ format1:".json" }, isArray:true },
            create: {method:'POST', params:{ format1:".json" }},
            read: {method:'GET', params:{ format2:".json" }},
            update: { method: 'PUT' },
            destroy: { method: 'DELETE' }
        });
    }).
    factory('Company', function($resource){
        return $resource('/apis/companies/:companyId.json', {}, {
            query: {method:'GET', params:{companyId:'all'}, isArray:true}
        });
    }).
    factory('Token', function($resource){
        return $resource('/apis/token.json', {}, {
            query: {method:'GET', params:{}, isArray:false}
        });
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
