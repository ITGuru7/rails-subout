'use strict';

/* Controllers */

function DashboardCtrl($scope, $location, Opportunity, Company) {
  $scope.opportunities = Opportunity.query();
  $scope.company = Company.get({companyId:"503026b08859aed418000004"});
}

function OpportunityDetailCtrl($scope, $routeParams, Opportunity) {
  $scope.opportunity = Opportunity.get({opportunityId: $routeParams.opportunityId}, function(opportunity) {
    $scope.name = opportunity.name;
  });
}

function AppController($scope, $location, Token){
	$scope.header = 'partials/header.html';
	$scope.token = Token.get({email:'suboutdev@gmail.com', password:'sub0utd3v' });
}