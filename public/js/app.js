var subout;

subout = angular.module("subout", ["ui", "suboutFilters", "suboutServices"]).config([
  "$routeProvider", function($routeProvider) {
    return $routeProvider.when("/sign_in", {
      templateUrl: "partials/sign_in.html",
      controller: SignInCtrl
    }).when("/dashboard", {
      templateUrl: "partials/dashboard.html",
      controller: DashboardCtrl
    }).when("/opportunities/:opportunityId", {
      templateUrl: "partials/opportunity-detail.html",
      controller: OpportunityDetailCtrl
    }).otherwise({
      redirectTo: "/dashboard"
    });
  }
]);

jQuery.timeago.settings.allowFuture = true;

angular.element(document).ready(function($http, $templateCache) {
  $http.get('/partials/header.html', {
    cache: $templateCache
  });
  return angular.bootstrap(document, ['subout']);
});
var AppCtrl, BidNewCtrl, DashboardCtrl, MyBidCtrl, OpportunityCtrl, OpportunityDetailCtrl, OpportunityNewCtrl, SignInCtrl;

AppCtrl = function($scope, $rootScope, $location) {
  var _ref;
  if (!((_ref = $rootScope.user) != null ? _ref.authorized : void 0) && $location.path() !== "sign_in") {
    $location.path("sign_in");
  }
  $rootScope.setModal = function(url) {
    return $rootScope.modal = url;
  };
  $rootScope.signOut = function() {
    return window.location.reload();
  };
  return $rootScope.setOpportunity = function(opportunity) {
    return $rootScope.opportunity = opportunity;
  };
};

OpportunityNewCtrl = function($scope, $rootScope, $location, Opportunity) {
  $scope.types = ["Bus Needed", "Emergency", "Parts", "Dead Head"];
  return $scope.save = function() {
    var newOpportunity;
    newOpportunity = $scope.opportunity;
    return Opportunity.save({
      opportunity: newOpportunity,
      api_token: $rootScope.user.api_token
    }, function(data) {
      return jQuery("#modal").modal("hide");
    });
  };
};

BidNewCtrl = function($scope, $rootScope, $location, Bid) {
  return $scope.save = function() {
    return Bid.save({
      bid: $scope.bid,
      api_token: $rootScope.user.api_token,
      opportunityId: $rootScope.opportunity._id
    }, function(data) {
      return jQuery("#modal").modal("hide");
    });
  };
};

MyBidCtrl = function($scope, $rootScope, $location, MyBid) {
  return $scope.my_bids = MyBid.query({
    api_token: $rootScope.user.api_token
  });
};

OpportunityCtrl = function($scope, $rootScope, $location, Opportunity) {
  return $scope.opportunities = Opportunity.query({
    api_token: $rootScope.user.api_token
  });
};

DashboardCtrl = function($scope, $rootScope, Event, Filter, Tag, Bid) {
  $scope.filters = Filter.query();
  $scope.tags = Tag.query();
  $scope.query = "";
  $scope.filter = null;
  $scope.tag = null;
  $scope.opportunity = null;
  $scope.winOpportunityNow = function(opportunity) {
    var bid;
    bid = {
      amount: opportunity.win_it_now_price
    };
    return Bid.save({
      bid: bid,
      api_token: $rootScope.user.api_token,
      opportunityId: opportunity._id
    });
  };
  $scope.events = Event.query({
    api_token: $rootScope.user.api_token
  }, function(data) {
    var channel;
    channel = $rootScope.pusher.subscribe('event');
    channel.bind('created', function(event) {
      $scope.events.unshift(event);
      return $scope.$apply();
    });
    return jQuery("time.relative-time").timeago();
  });
  $scope.searchByFilter = function(input) {
    if (!$scope.filter) {
      return true;
    }
    return evaluation(input.eventable, $scope.filter.evaluation);
  };
  $scope.searchByQuery = function(input) {
    var reg;
    if (!$scope.query) {
      return true;
    }
    reg = new RegExp($scope.query.toLowerCase());
    return reg.test(input.name.toLowerCase()) || reg.test(input.seats);
  };
  $scope.searchByTag = function(input) {
    var reg;
    if (!$scope.tag) {
      return true;
    }
    reg = new RegExp($scope.tag.name.toLowerCase());
    if (reg.test(input.eventable.name.toLowerCase())) {
      return true;
    }
    return false;
  };
  $scope.setFilter = function(filter) {
    var i;
    i = 0;
    while (i < $scope.filters.length) {
      if ($scope.filters[i] !== filter) {
        $scope.filters[i].active = false;
      }
      i++;
    }
    filter.active = !filter.active;
    if (filter.active) {
      $scope.filter = filter;
    } else {
      $scope.filter = null;
    }
    return $scope.query = "";
  };
  return $scope.setTag = function(tag) {
    var i;
    i = 0;
    while (i < $scope.tags.length) {
      if ($scope.tags[i] !== tag) {
        $scope.tags[i].active = false;
      }
      i++;
    }
    tag.active = !tag.active;
    if (tag.active) {
      $scope.tag = tag;
    } else {
      $scope.tag = null;
    }
    return $scope.query = "";
  };
};

OpportunityDetailCtrl = function($rootScope, $scope, $routeParams, Bid, Opportunity) {
  $scope.opportunity = $rootScope.opportunity;
  $scope.bids = Bid.query({
    opportunityId: $scope.opportunity._id,
    api_token: $rootScope.user.api_token
  });
  return $scope.selectWinner = function(bid) {
    return Opportunity.select_winner({
      opportunityId: $scope.opportunity._id,
      action: 'select_winner',
      bid_id: bid._id,
      api_token: $rootScope.user.api_token
    }, {}, function() {
      return jQuery("#modal").modal("hide");
    });
  };
};

SignInCtrl = function($scope, $rootScope, $location, Token, Company) {
  $scope.email = "suboutdev@gmail.com";
  $scope.password = "sub0utd3v";
  return $scope.signIn = function() {
    return Token.save({
      email: $scope.email,
      password: $scope.password
    }, function(user) {
      $rootScope.user = user;
      if (user.authorized) {
        $rootScope.pusher = new Pusher(user.pusher_key);
        $rootScope.company = Company.get({
          companyId: user.company_id,
          api_token: user.api_token
        });
        return $location.path("dashboard");
      } else {
        return $scope.message = "Invalid username or password!";
      }
    });
  };
};

subout.directive("relativeTime", function() {
  return {
    link: function(scope, element, attr) {
      return scope.$watch("event", function(val) {
        return $(element).timeago();
      });
    }
  };
});
var Evaluators, evaluation;

angular.module("suboutFilters", []).filter("timestamp", function() {
  return function(input) {
    return new Date(input).getTime();
  };
});

evaluation = function(input, evaluation) {
  var evaluator;
  evaluator = Evaluators[evaluation.type];
  if ($.isFunction(evaluator)) {
    return evaluator(input, evaluation);
  } else {
    alert("Evaluator doesn't exist.");
    return true;
  }
};

Evaluators = {};

Evaluators.range = function(input, evaluation) {
  var property;
  property = input[evaluation.property];
  if (property) {
    return (property >= evaluation.params.min) && (property <= evaluation.params.max);
  } else {
    return true;
  }
};

Evaluators.today = function(input, evaluation) {
  var current_day, current_time, property, property_day;
  property = input[evaluation.property];
  if (property) {
    current_time = new Date().getTime();
    current_day = parseInt(current_time / (3600 * 24 * 1000));
    property_day = parseInt(property / (3600 * 24 * 1000));
    return current_day === property_day;
  } else {
    return true;
  }
};

Evaluators.compare = function(input, evaluation) {
  var compare, property;
  property = input[evaluation.property];
  if (property) {
    compare = "'" + property + "'      " + evaluation.params.operator + "      '" + evaluation.params.value + "'";
    return eval_(compare);
  } else {
    return true;
  }
};

Evaluators.like = function(input, evaluation) {
  var property, reg;
  property = input[evaluation.property];
  if (property) {
    reg = new RegExp(evaluation.params.value.toLowerCase());
    return reg.test(property.toLowerCase());
  } else {
    return true;
  }
};
var api_path;

api_path = "/api/v1";

angular.module("suboutServices", ["ngResource"]).factory("Opportunity", function($resource) {
  return $resource("" + api_path + "/auctions/:opportunityId/:action", {
    opportunityId: '@opportunityId'
  }, {
    select_winner: {
      method: "PUT"
    }
  });
}).factory("MyBid", function($resource) {
  return $resource("" + api_path + "/bids", {}, {});
}).factory("Bid", function($resource) {
  return $resource("" + api_path + "/opportunities/:opportunityId/bids", {
    opportunityId: "@opportunityId"
  });
}).factory("Event", function($resource) {
  return $resource("" + api_path + "/events/:eventId", {}, {});
}).factory("Company", function($resource) {
  return $resource("" + api_path + "/companies/:companyId.json", {}, {
    query: {
      method: "GET",
      params: {
        companyId: "all"
      },
      isArray: true
    }
  });
}).factory("Token", function($resource) {
  return $resource("" + api_path + "/tokens", {}, {});
}).factory("Filter", function($resource) {
  return $resource("" + api_path + "/filters.json", {}, {
    query: {
      method: "GET",
      params: {},
      isArray: true
    }
  });
}).factory("Tag", function($resource) {
  return $resource("" + api_path + "/tags.json", {}, {
    query: {
      method: "GET",
      params: {},
      isArray: true
    }
  });
}).factory("OpportunityTest", function($resource) {
  return $resource("" + api_path + "/opportunities.json", {}, {});
});
