'use strict';

/* Controllers */

function AppController($scope, $location, $http, $filter, Token, Company){
   if (($scope.user == undefined || $scope.user.authorized != 'true') && $location.path() != 'sign_in') {
     $location.path('sign_in');
   }

    $scope.modal = '';
    $scope.setModal = function(url)
    {
        $scope.modal = url;
    }
}

function OpportunityNewCtrl($scope, $location, Opportunity, Test, Filter, Tag, Company) {

    $scope.opportunity = Opportunity.read({opportunityId: 'new'});


    $scope.submit = function(){

        var oppModel = new Opportunity();
        oppModel.opportunity = $scope.opportunity;
        oppModel.auth_token = $scope.token.auth_token;
        oppModel.$create(function(data){
            alert("New Opportunity was created.")
        });

    }
}

function OpportunityCtrl($scope, $location, Opportunity) {
     $scope.opportunities = Opportunity.query();
}

function DashboardCtrl($scope, $rootScope, $location, Event, Filter, Tag, Company) {
   $scope.events = Event.query({api_token: $rootScope.user.api_token});
   //$scope.filters = Filter.query();
   //$scope.tags = Tag.query();

   $scope.query = "";
   $scope.filter = null;


   $scope.searchByFilter = function(input) {
        if(!$scope.filter) return true;
        return evaluation(input, $scope.filter.evaluation);
      };

   $scope.searchByQuery = function(input) {
        if(!$scope.query) return true;

        var reg = new RegExp($scope.query.toLowerCase());
        return reg.test(input.name.toLowerCase()) || reg.test(input.seats);
      };

   $scope.searchByTag = function(input) {

        var activeCount = 0;
        for(var i=0; i<$scope.tags.length; i++){

            if($scope.tags[i].active){
                activeCount++;
                var reg = new RegExp($scope.tags[i].name.toLowerCase());
                if(reg.test(input.tags.toLowerCase())){

                    continue;
                }else{
                    return false;
                }
            }
        }
        return true;
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
  $scope.opportunity = Opportunity.get({opportunityId: $routeParams.opportunityId});
}

function SignInCtrl($scope, $rootScope, $location, Token, Company) {
  $scope.signIn = function() {
    Token.save({email:$scope.user.email, password:$scope.user.password}, function(user){
      $rootScope.user = user;
      if (user.authorized == "true") {
        $scope.company = Company.get({companyId:user.company_id});
        $location.path('dashboard');
      }
      else{
        $scope.message = "Invalid username or password!"
      }
    });
  }
}

