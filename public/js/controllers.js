'use strict';

/* Controllers */

function AppController($scope, $location, $http, Token, Company){
    
    $http.get('apis/token.json').success(function(data) {
        $scope.token = data;
        $scope.company = Company.get({companyId:data.company._id});
    });
  
}

function DashboardCtrl($scope, $location, Opportunity, Filter, Tag, Company) {
   $scope.opportunities = Opportunity.query();
   $scope.filters = Filter.query();
   $scope.tags = Tag.query();
   
   $scope.query = "";
   $scope.filter = null;
   
   $scope.searchByFilter = function(input) {
        if(!$scope.filter) return true;
        return (input.seats>$scope.filter.seats_min) && (input.seats<$scope.filter.seats_max);
      };
      
   $scope.searchByQuery = function(input) {
        if(!$scope.query) return true;
        
        var reg = new RegExp($scope.query.toLowerCase());
        return reg.test(input.name.toLowerCase()) || reg.test(input.seats);
      };
        
   $scope.setFilter = function(filter){
           $scope.filter = filter; 
           $scope.query = "";
        }
   $scope.setTag = function(tag, obj){ 
           tag.active = !tag.active;
           jQuery(obj).addClass("label");
        }
}

function OpportunityDetailCtrl($scope, $routeParams, Opportunity) {
  $scope.opportunity = Opportunity.get({opportunityId: $routeParams.opportunityId}, function(opportunity) {
    $scope.name = opportunity.name;
  });
}
