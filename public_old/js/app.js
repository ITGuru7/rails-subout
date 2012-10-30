'use strict';

/* App Module */

var subout = angular.module('subout', ['ui','suboutFilters', 'suboutServices']).
  config(['$routeProvider', function($routeProvider) {
  $routeProvider.
      when('/sign_in', {templateUrl: 'partials/sign_in.html', controller: SignInCtrl}).
      when('/dashboard', {templateUrl: 'partials/dashboard.html',   controller: DashboardCtrl}).
      when('/opportunity/:opportunityId', {templateUrl: 'partials/opportunity-detail.html', controller: OpportunityDetailCtrl}).
      otherwise({redirectTo: '/dashboard'});
}]);

jQuery.timeago.settings.allowFuture = true;
