'use strict';

/* Services */

angular.module('suboutServices', ['ngResource']).
    factory('Opportunity', function($resource){

        return $resource('/apis/opportunities/:opportunityId.json', {}, {
            query: {method:'GET', params:{opportunityId:'all'}, isArray:true}
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
    });
