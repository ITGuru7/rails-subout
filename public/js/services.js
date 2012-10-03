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
            query: {method:'GET', params:{email:'suboutdev@gmail.com', password:'sub0utd3v' }, isArray:false}
        });
    });
