'use strict';

/* App Module */

var subout = angular.module('subout', ['ui','suboutFilters', 'suboutServices']).
  config(['$routeProvider', function($routeProvider) {
  $routeProvider.
      when('/dashboard', {templateUrl: 'partials/dashboard.html',   controller: DashboardCtrl}).
      when('/opportunity/:opportunityId', {templateUrl: 'partials/opportunity-detail.html', controller: OpportunityDetailCtrl}).
      otherwise({redirectTo: '/dashboard'});
}]);

