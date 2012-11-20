
window.subout = angular.module("subout", ["ui", "suboutFilters", "suboutServices"]).config([
  "$routeProvider", function($routeProvider) {
    return $routeProvider.when("/sign_in", {
      templateUrl: "partials/sign_in.html",
      controller: SignInCtrl
    }).when("/sign_up", {
      templateUrl: "partials/sign_up.html",
      controller: SignUpCtrl
    }).when("/dashboard", {
      templateUrl: "partials/dashboard.html",
      controller: DashboardCtrl
    }).when("/bids", {
      templateUrl: "partials/bids.html",
      controller: MyBidCtrl
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
  return angular.bootstrap(document, ['subout']);
});
var AppCtrl, BidNewCtrl, CompanyProfileCtrl, DashboardCtrl, FavoritesCtrl, MyBidCtrl, NewFavoriteCtrl, OpportunityCtrl, OpportunityDetailCtrl, OpportunityFormCtrl, SettingCtrl, SignInCtrl, SignUpCtrl;

AppCtrl = function($scope, $rootScope, $location, Opportunity, Bid, Company, Auction) {
  var _ref;
  if (!((_ref = $rootScope.user) != null ? _ref.authorized : void 0)) {
    if (["/sign_up", "/sign_in"].indexOf($location.path()) === -1) {
      $location.path("/sign_in");
    }
  }
  $rootScope.setModal = function(url) {
    return $rootScope.modal = url;
  };
  $rootScope.closeModal = function() {
    return $('#modal').modal("hide");
  };
  $rootScope.signOut = function() {
    return window.location.reload();
  };
  $rootScope.setOpportunities = function() {
    return $rootScope.opportunities = Auction.query({
      api_token: $rootScope.token.api_token
    });
  };
  $rootScope.setOpportunity = function(opportunity) {
    return $rootScope.opportunity = Opportunity.get({
      api_token: $rootScope.token.api_token,
      opportunityId: opportunity._id
    });
  };
  $rootScope.setOtherCompanyViaId = function(company_id) {
    return $rootScope.other_company = Company.get({
      api_token: $rootScope.token.api_token,
      companyId: company_id
    });
  };
  return $rootScope.dateOptions = {
    dateFormat: 'dd/mm/yy'
  };
};

OpportunityFormCtrl = function($scope, $rootScope, $location, Auction) {
  $scope.types = ["Vehicle Needed", "Vehicle for Hire", "Special", "Emergency", "Part"];
  return $scope.save = function() {
    var opportunity;
    opportunity = $scope.opportunity;
    opportunity.bidding_ends = $('#opportunity_ends').val();
    opportunity.start_date = $('#opportunity_start_date').val();
    opportunity.end_date = $('#opportunity_end_date').val();
    if (opportunity._id) {
      return Auction.update({
        opportunityId: opportunity._id,
        opportunity: opportunity,
        api_token: $rootScope.token.api_token
      }, function(data) {
        return jQuery("#modal").modal("hide");
      });
    } else {
      return Auction.save({
        opportunity: opportunity,
        api_token: $rootScope.token.api_token
      }, function(data) {
        return jQuery("#modal").modal("hide");
      });
    }
  };
};

BidNewCtrl = function($scope, $rootScope, Bid) {
  return $scope.save = function() {
    return Bid.save({
      bid: $scope.bid,
      api_token: $rootScope.token.api_token,
      opportunityId: $rootScope.opportunity._id
    }, function(data) {
      return jQuery("#modal").modal("hide");
    }, function(error) {
      return $scope.errorMessage = error.data.errors.amount[0];
    });
  };
};

MyBidCtrl = function($scope, $rootScope, MyBid) {
  return $scope.my_bids = MyBid.query({
    api_token: $rootScope.token.api_token
  });
};

FavoritesCtrl = function($scope, $rootScope, Favorite) {
  $scope.favoriteCompanies = Favorite.query({
    api_token: $rootScope.token.api_token
  });
  return $scope.removeFavorite = function(company) {
    return Favorite["delete"]({
      api_token: $rootScope.token.api_token,
      favoriteId: company._id
    }, function() {
      var index;
      index = $scope.favoriteCompanies.indexOf(company);
      return $scope.favoriteCompanies.splice(index, 1);
    });
  };
};

NewFavoriteCtrl = function($scope, $rootScope, Favorite, Company, FavoriteInvitation) {
  $scope.invitation = {};
  $scope.addToFavorites = function(company) {
    return Favorite.save({
      supplier_id: company._id,
      api_token: $rootScope.token.api_token
    }, {}, function() {
      return jQuery("#modal").modal("hide");
    });
  };
  return $scope.findSupplier = function() {
    Company.search({
      email: $scope.supplierEmail,
      api_token: $rootScope.token.api_token,
      action: "search"
    }, {}, function(company) {
      $scope.showCompany = true;
      $scope.companyNotFound = false;
      return $scope.foundCompany = company;
    }, function(error) {
      $scope.showCompany = false;
      return $scope.companyNotFound = true;
    });
    $scope.showInvitationForm = function() {
      $scope.showInvitation = true;
      $scope.invitation.supplier_email = $scope.supplierEmail;
      return $scope.invitation.message = "" + $rootScope.company.name + " would like to add you as a favorite supplier on Subout.";
    };
    return $scope.sendInvitation = function() {
      return FavoriteInvitation.save({
        favorite_invitation: $scope.invitation,
        api_token: $rootScope.token.api_token
      }, function() {
        return jQuery("#modal").modal("hide");
      });
    };
  };
};

OpportunityCtrl = function($scope, $rootScope, $location, Auction) {};

OpportunityDetailCtrl = function($rootScope, $scope, $routeParams, Bid, Auction) {
  $scope.cancelOpportunity = function() {
    return Auction.cancel({
      opportunityId: $scope.opportunity._id,
      action: 'cancel',
      api_token: $rootScope.token.api_token
    }, {}, function() {
      return jQuery("#modal").modal("hide");
    });
  };
  return $scope.selectWinner = function(bid) {
    return Auction.select_winner({
      opportunityId: $rootScope.opportunity._id,
      action: 'select_winner',
      bid_id: bid._id,
      api_token: $rootScope.token.api_token
    }, {}, function() {
      return jQuery("#modal").modal("hide");
    });
  };
};

DashboardCtrl = function($scope, $rootScope, Event, Filter, Tag, Bid, Opportunity) {
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
      api_token: $rootScope.token.api_token,
      opportunityId: opportunity._id
    });
  };
  $scope.events = Event.query({
    api_token: $rootScope.token.api_token
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
  $scope.setTag = function(tag) {
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
  $scope.actionDescription = function(action) {
    switch (action.type) {
      case "bid_created":
        return "bids $" + action.details.amount + " on";
      default:
        return action.type.split('_').pop();
    }
  };
  return $scope.toggleEvent = function(event) {
    event.selected = !event.selected;
    if (event.selected) {
      return event.eventable = Opportunity.get({
        api_token: $rootScope.token.api_token,
        opportunityId: event.eventable._id
      });
    }
  };
};

SettingCtrl = function($scope, $rootScope, $location, Token, Company, User) {
  $scope.userProfile = $rootScope.user;
  $scope.companyProfile = $rootScope.company;
  $scope.saveUserProfile = function() {
    $scope.userProfileError = "";
    $scope.userProfileMessage = "";
    if ($scope.userProfile.password === $scope.userProfile.password_confirmation) {
      return User.update({
        userId: $rootScope.user._id,
        user: $scope.userProfile,
        api_token: $rootScope.token.api_token
      }, function(user) {
        $scope.userProfile.password = '';
        $scope.userProfile.current_password = '';
        $rootScope.user = $scope.userProfile;
        return $scope.userProfileMessage = "Saved successfully";
      }, function(error) {
        return $scope.userProfileError = "Invalid password or email!";
      });
    } else {
      return $scope.userProfileError = "The new password and password confirmation are not identical.";
    }
  };
  return $scope.saveCompanyProfile = function() {
    $scope.companyProfileError = "";
    $scope.companyProfileMessage = "";
    return Company.update({
      companyId: $rootScope.company._id,
      company: $scope.companyProfile,
      api_token: $rootScope.token.api_token
    }, function(company) {
      $rootScope.company = $scope.companyProfile;
      return $scope.companyProfileMessage = "Saved successfully";
    }, function(error) {
      return $scope.companyProfileError = "Sorry, invalid inputs. Please try again.";
    });
  };
};

SignInCtrl = function($scope, $rootScope, $location, Token, Company, User) {
  $scope.email = "suboutdev@gmail.com";
  $scope.password = "password";
  return $scope.signIn = function() {
    return Token.save({
      email: $scope.email,
      password: $scope.password
    }, function(token) {
      $rootScope.token = token;
      if (token.authorized) {
        $rootScope.pusher = new Pusher(token.pusher_key);
        $rootScope.company = Company.get({
          companyId: token.company_id,
          api_token: token.api_token
        });
        $rootScope.user = User.get({
          userId: token.user_id,
          api_token: token.api_token
        });
        return $location.path("dashboard");
      } else {
        return $scope.message = "Invalid username or password!";
      }
    });
  };
};

SignUpCtrl = function($scope, $rootScope, $routeParams, $location, Token, Company, FavoriteInvitation) {
  $scope.company = {};
  $scope.user = {};
  FavoriteInvitation.get({
    invitationId: $routeParams.invitation_id
  }, function(invitation) {
    $scope.company.email = invitation.supplier_email;
    $scope.company.name = invitation.supplier_name;
    return $scope.company.created_from_invitation_id = invitation._id;
  }, function() {
    return $location.path("/sign_in").search({});
  });
  return $scope.signUp = function() {
    $scope.user.email = $scope.company.email;
    $scope.company.users_attributes = {
      "0": $scope.user
    };
    return Company.save({
      company: $scope.company
    }, function() {
      return $location.path("/sign_in").search({});
    }, function(response) {
      return $scope.errorMessage = response.data.errors.join("<br />");
    });
  };
};

CompanyProfileCtrl = function($rootScope, $scope, Favorite) {
  return $scope.addToFavorites = function(company) {
    return Favorite.save({
      supplier_id: company._id,
      api_token: $rootScope.token.api_token
    }, {}, function() {
      return jQuery("#modal").modal("hide");
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

angular.module("suboutServices", ["ngResource"]).factory("Auction", function($resource) {
  return $resource("" + api_path + "/auctions/:opportunityId/:action", {
    opportunityId: '@opportunityId',
    action: '@action'
  }, {
    select_winner: {
      method: "PUT"
    },
    cancel: {
      method: "PUT"
    },
    update: {
      method: "PUT"
    }
  });
}).factory("Opportunity", function($resource) {
  return $resource("" + api_path + "/opportunities/:opportunityId", {}, {});
}).factory("MyBid", function($resource) {
  return $resource("" + api_path + "/bids", {}, {});
}).factory("Bid", function($resource) {
  return $resource("" + api_path + "/opportunities/:opportunityId/bids", {
    opportunityId: "@opportunityId"
  }, {});
}).factory("Event", function($resource) {
  return $resource("" + api_path + "/events/:eventId", {}, {});
}).factory("Company", function($resource) {
  return $resource("" + api_path + "/companies/:companyId/:action", {
    companyId: '@companyId',
    action: '@action'
  }, {
    query: {
      method: "GET",
      params: {
        companyId: "all"
      },
      isArray: true
    },
    update: {
      method: "PUT"
    },
    search: {
      method: "GET",
      action: "search"
    }
  });
}).factory("Token", function($resource) {
  return $resource("" + api_path + "/tokens", {}, {});
}).factory("User", function($resource) {
  return $resource("" + api_path + "/users/:userId.json", {
    userId: '@userId'
  }, {
    update: {
      method: "PUT"
    }
  });
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
}).factory("Favorite", function($resource) {
  return $resource("" + api_path + "/favorites/:favoriteId", {}, {});
}).factory("FavoriteInvitation", function($resource) {
  return $resource("" + api_path + "/favorite_invitations/:invitationId", {}, {});
});
