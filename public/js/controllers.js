'use strict';

/* Controllers */

function AppController($scope, $location, $http, Token, Company){
    
    $http.get('apis/token.json').success(function(data) {
        $scope.token = data;
        $scope.company = Company.get({companyId:data.company._id});
    });
    
    $scope.modal = '';
    $scope.setModal = function(url)
    {
        $scope.modal = url;
    }
  
}

function OpportunityNewCtrl($scope, $location, Opportunity, Filter, Tag, Company) {

}

function OpportunityCtrl($scope, $location, Opportunity) {
     $scope.opportunities = Opportunity.query();
}

function DashboardCtrl($scope, $location, Opportunity, Filter, Tag, Company) {
   $scope.opportunities = Opportunity.query();
   $scope.filters = Filter.query();
   $scope.tags = Tag.query();
   
   $scope.query = "";
   $scope.filter = null;
   $scope.tag = null;
   
   $scope.searchByFilter = function(input) {
        if(!$scope.filter) return true;
        return evaluation(input, $scope.filter.evaluation);
      };
      
   $scope.searchByQuery = function(input) {
        if(!$scope.query) return true;
        
        var reg = new RegExp($scope.query.toLowerCase());
        return reg.test(input.name.toLowerCase()) || reg.test(input.seats);
      };
        
   $scope.setFilter = function(filter){
           
           for(var i=0; i<$scope.filters.length; i++)
           {
               $scope.filters[i].active = false;
           }
           
           filter.active = !filter.active;
           $scope.filter = filter;
           $scope.query = "";
        }
        
   $scope.setTag = function(tag){ 
           tag.active = !tag.active;
        }
}

function OpportunityDetailCtrl($scope, $routeParams, Opportunity) {
  $scope.opportunity = Opportunity.get({opportunityId: $routeParams.opportunityId}, function(opportunity) {
    $scope.name = opportunity.name;
  });
}
