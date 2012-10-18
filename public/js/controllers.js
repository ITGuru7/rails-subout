'use strict';

/* Controllers */

function AppController($scope, $rootScope, $location, $http, $filter, Token, Company) {
    if (($scope.user == undefined || $scope.user.authorized != 'true') && $location.path() != 'sign_in') {
        $location.path('sign_in');
    }

    $rootScope.setModal = function(url) {
        $rootScope.modal = url;
    }
    
    $rootScope.signOut = function(){
        $rootScope.user = null;
        $rootScope.company = null;
        $location.path('sign_in');
    }
    
    $rootScope.setOpportunity = function(opportunity)
    {
        $rootScope.opportunity = opportunity;
    }
    
    
}

function OpportunityNewCtrl($scope, $rootScope, $location, Opportunity, Company) {
    $scope.types = ["Bus Needed", "Emergency", "Parts", "Dead Head"];
    $scope.save = function() {
        var newOpportunity = $scope.opportunity;
        Opportunity.save({opportunity:newOpportunity, api_token:$rootScope.user.api_token}, function(data){
            $location.path('/dashboard/refresh');
            jQuery('#modal').modal('hide');    
        });
        
    }
}

function BidNewCtrl($scope, $rootScope, $location, Bid)
{
    $scope.save = function() {
        var newBid = $scope.bid;
        Bid.create({bid:newBid, api_token:$rootScope.user.api_token, opportunityId: $rootScope.opportunity._id}, function(data){
            $location.path('/dashboard/refresh');
            jQuery('#modal').modal('hide');    
        });
        
    }
}

function OpportunityCtrl($scope, $rootScope, $location, Opportunity) {
    $scope.opportunities = Opportunity.query();
}

function DashboardCtrl($scope, $rootScope, $location, Event, Opportunity, OpportunityTest, Filter, Tag, Company) {
    $scope.events = Event.query({
        api_token : $rootScope.user.api_token
    });
    
    function loadEvents()
    {
        setTimeout(function(){
            Event.query({
                api_token : $rootScope.user.api_token
            }, function(events){
                if(events[0]['_id']!=$scope.events[0]['_id'])
                {
                    $scope.events = events;
                }    
            });
            
            loadEvents(); 
        
        }, 10 * 1000);
        
    }
    
    loadEvents();
    
    $scope.filters = Filter.query();
    $scope.tags = Tag.query();

    $scope.query = "";
    $scope.filter = null;
    $scope.tag = null;
    $scope.opportunity = null;

    $scope.searchByFilter = function(input) {
        if (!$scope.filter)
            return true;
        return evaluation(input.eventable, $scope.filter.evaluation);
    };

    $scope.searchByQuery = function(input) {
        if (!$scope.query)
            return true;

        var reg = new RegExp($scope.query.toLowerCase());
        return reg.test(input.name.toLowerCase()) || reg.test(input.seats);
    };

    /*$scope.searchByQuery = function() {
        return function(input) {
            
            Opportunity.get({
                opportunityId : input
            });
            return input + ".png";
        }
    };*/

    $scope.searchByTag = function(input) {
        //input: event for now
        
        if (!$scope.tag)
            return true;
            
        var reg = new RegExp($scope.tag.name.toLowerCase());
        if (reg.test(input.eventable.name.toLowerCase())) {

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
                    companyId : user.company_id,
                    api_token : user.api_token
                });
                $location.path('dashboard');
            } else {
                $scope.message = "Invalid username or password!"
            }
        });
    }
}

