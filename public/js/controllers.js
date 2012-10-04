'use strict';

/* Controllers */

function DashboardCtrl($scope, $location, Opportunity, Company) {
  $scope.opportunities = Opportunity.query();
  //$scope.company = Company.get({companyId:"503026b08859aed418000004"});
}

function OpportunityDetailCtrl($scope, $routeParams, Opportunity) {
  $scope.opportunity = Opportunity.get({opportunityId: $routeParams.opportunityId}, function(opportunity) {
    $scope.name = opportunity.name;
  });
}

function AppController($scope, $location, $http, Token, Company){
	$scope.header = 'partials/header.html';
	$http.get('apis/token.json').success(function(data) {
        $scope.token = data;
        $scope.company = Company.get({companyId:data._id.$oid});
    });
  
}