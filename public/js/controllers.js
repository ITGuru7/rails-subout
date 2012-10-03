'use strict';

/* Controllers */

function DashboardCtrl($scope, $location, Opportunity) {
  $scope.opportunities = Opportunity.query();
  $scope.orderProp = 'age';
  
}

function OpportunityDetailCtrl($scope, $routeParams, Opportunity) {
  $scope.opportunity = Opportunity.get({opportunityId: $routeParams.opportunityId}, function(opportunity) {
    $scope.name = opportunity.name;
  });
}

function AppController($scope, $location){
	$scope.header = 'partials/header.html';
}