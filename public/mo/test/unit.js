'use strict';

describe("controllers", function() {
  beforeEach(module("subout"));
  describe("AppCtrl", function() {
    it("should populate the regions into the scope", inject(function($rootScope, $controller, $location) {
      var $scope, ctrl;
      $scope = $rootScope.$new();
      ctrl = $controller("AppCtrl", {
        $scope: $scope,
        $rootScope: $rootScope,
        $location: $location
      });
      expect($rootScope.ALL_REGIONS).not.to.equal(null);
      return expect($rootScope.ALL_REGIONS['Georgia']).not.to.equal(null);
    }));
    return it("should prepare a signout link", inject(function($rootScope, $controller, $location) {
      var $scope, ctrl;
      $scope = $rootScope.$new();
      ctrl = $controller("AppCtrl", {
        $scope: $scope,
        $rootScope: $rootScope,
        $location: $location
      });
      return expect($rootScope.signOut).not.to.equal(null);
    }));
  });
  return describe("OpportunityCtrl", function() {
    return it("should have a working controller", inject(function($rootScope, $controller, $location) {
      var $scope, ctrl;
      $scope = $rootScope.$new();
      ctrl = $controller("OpportunityCtrl", {
        $scope: $scope,
        $rootScope: $rootScope,
        $location: $location
      });
      return expect($scope.opportunities).not.to.equal(null);
    }));
  });
});

