'use strict';

/* Controllers */

function AppController($scope, $rootScope, $location, $http, $filter, Token, Company) {
    if (($scope.user == undefined || $scope.user.authorized != 'true') && $location.path() != 'sign_in') {
        $location.path('sign_in');
    }

    $rootScope.setModal = function(url) {
        $rootScope.modal = url;
    }
}

function OpportunityNewCtrl($scope, $rootScope, $location, Opportunity, Test, Filter, Tag, Company) {
    $scope.submit = function() {
        var newOpportunity = $scope.opportunity;
        Opportunity.save({opportunity:newOpportunity, api_token:$rootScope.user.api_token});
    }
}

function OpportunityCtrl($scope, $rootScope, $location, Opportunity) {
    $scope.opportunities = Opportunity.query();
}

function DashboardCtrl($scope, $rootScope, $location, Opportunity, OpportunityTest, Filter, Tag, Company) {
    $scope.opportunities = OpportunityTest.query({
        api_token : $rootScope.user.api_token
    });
    
    $scope.filters = Filter.query();
    $scope.tags = Tag.query();

    $scope.query = "";
    $scope.filter = null;
    $scope.tag = null;

    $scope.searchByFilter = function(input) {
        if (!$scope.filter)
            return true;
        return evaluation(input, $scope.filter.evaluation);
    };

    $scope.searchByQuery = function(input) {
        if (!$scope.query)
            return true;

        var reg = new RegExp($scope.query.toLowerCase());
        return reg.test(input.name.toLowerCase()) || reg.test(input.seats);
    };

    $scope.searchByTag = function(input) {
        if (!$scope.tag)
            return true;
            
        var reg = new RegExp($scope.tag.name.toLowerCase());
        if (reg.test(input.tags.toLowerCase())) {

            return true;
        }
        return false;
    };

    $scope.setFilter = function(filter) {
        for (var i = 0; i < $scope.filters.length; i++) {
            if($scope.filters[i]!=filter)
            {
                $scope.filters[i].active = false;
            }
        }
        filter.active = !filter.active;
        if(filter.active)
        {
            $scope.filter = filter;
        }else{
            $scope.filter = null;
        }
       
        $scope.query = "";
    }

    $scope.setTag = function(tag) {
        for (var i = 0; i < $scope.tags.length; i++) {
            if($scope.tags[i]!=tag)
            {
                $scope.tags[i].active = false;
            }
            
        }
        tag.active = !tag.active;
        if(tag.active)
        {
            $scope.tag = tag;
        }else{
            $scope.tag = null;
        }
        
        $scope.query = "";

    }
}

function OpportunityDetailCtrl($scope, $routeParams, Opportunity) {
    $scope.opportunity = Opportunity.get({
        opportunityId : $routeParams.opportunityId
    });
}

function SignInCtrl($scope, $rootScope, $location, Token, Company) {
    $scope.email = "suboutdev@gmail.com";
    $scope.password = "sub0utd3v";
    $scope.signIn = function() {

        Token.save({
            email : $scope.email,
            password : $scope.password
        }, function(user) {
            $rootScope.user = user;
            if (user.authorized == "true") {
                $rootScope.company = Company.get({
                    companyId : user.company_id
                });
                $location.path('dashboard');
            } else {
                $scope.message = "Invalid username or password!"
            }
        });
    }
}

