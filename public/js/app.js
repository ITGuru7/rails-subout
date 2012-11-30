var subout;

subout = angular.module("subout", ["ui", "suboutFilters", "suboutServices", "ngCookies"]);

subout.config([
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
    }).when("/opportunities", {
      templateUrl: "partials/opportunities.html",
      controller: OpportunityCtrl
    }).when("/opportunities/:opportunityId", {
      templateUrl: "partials/opportunity-detail.html",
      controller: OpportunityDetailCtrl
    }).when("/favorites", {
      templateUrl: "partials/favorites.html",
      controller: FavoritesCtrl
    }).when("/welcome-prelaunch", {
      templateUrl: "partials/welcome-prelaunch.html"
    }).otherwise({
      redirectTo: "/dashboard"
    });
  }
]);

subout.run(function($templateCache, $http) {
  return $http.get('partials/opportunity-form.html', {
    cache: $templateCache
  });
});

$.timeago.settings.allowFuture = true;

$.cloudinary.config({
  "cloud_name": "subout"
});

angular.element(document).ready(function() {
  return angular.bootstrap(document, ['subout']);
});
var AppCtrl, BidNewCtrl, CompanyProfileCtrl, DashboardCtrl, FavoritesCtrl, MyBidCtrl, NewFavoriteCtrl, OpportunityCtrl, OpportunityDetailCtrl, OpportunityFormCtrl, SettingCtrl, SignInCtrl, SignUpCtrl;

AppCtrl = function($scope, $rootScope, $location, $cookieStore, Opportunity, Company, User, FileUploaderSignature) {
  var publicPages, token, _ref;
  $rootScope.currentPath = function() {
    return $location.path();
  };
  $rootScope.userSignedIn = function() {
    var _ref;
    if (((_ref = $rootScope.user) != null ? _ref.authorized : void 0) || $cookieStore.get('token')) {
      return true;
    }
  };
  $rootScope.signedInSuccess = function(token) {
    $rootScope.pusher = new Pusher(token.pusher_key);
    $rootScope.company = Company.get({
      companyId: token.company_id,
      api_token: token.api_token
    }, function(company) {
      if (company.regions !== 'all') {
        return $rootScope.allRegions = company.regions;
      }
    });
    return $rootScope.user = User.get({
      userId: token.user_id,
      api_token: token.api_token
    });
  };
  publicPages = ["/sign_up", "/sign_in", "/welcome-prelaunch"];
  if (!((_ref = $rootScope.user) != null ? _ref.authorized : void 0)) {
    if ($cookieStore.get('token')) {
      token = $cookieStore.get('token');
      $rootScope.token = token;
      $rootScope.signedInSuccess(token);
    } else if (publicPages.indexOf($location.path()) === -1) {
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
    $cookieStore.remove('token');
    return window.location.reload();
  };
  $rootScope.allRegions = ["Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut", "Delaware", "District of Columbia", "Florida", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire", "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming"];
  $rootScope.setupFileUploader = function() {
    return FileUploaderSignature.get({}, function(data) {
      var $fileProgressBar, $fileUploader, previewUrl, progressImageUpload, setImageUpload;
      $fileProgressBar = $('#progress .bar');
      $fileUploader = $("input.cloudinary-fileupload[type=file]");
      $fileUploader.attr('data-form-data', JSON.stringify(data));
      $fileUploader.cloudinary_fileupload({
        progress: function(e, data) {
          var progress;
          progress = parseInt(data.loaded / data.total * 100, 10);
          return $fileProgressBar.css('width', progress + '%');
        }
      });
      previewUrl = function(data) {
        return $.cloudinary.url(data.result.public_id, {
          format: data.result.format,
          crop: 'scale',
          width: 200
        });
      };
      setImageUpload = function(data) {
        $("form .image-preview").attr('src', previewUrl(data));
        return $("form .file-upload-public-id").val(data.result.public_id);
      };
      progressImageUpload = function(element, progressing) {
        $('form btn-primary').prop('disabled', !progressing);
        $fileProgressBar.toggle(progressing);
        return $(element).toggle(!progressing);
      };
      $fileUploader.bind('fileuploadstart', function(e, data) {
        return progressImageUpload(this, true);
      });
      return $fileUploader.bind('cloudinarydone', function(e, data) {
        progressImageUpload(this, false);
        return setImageUpload(data);
      });
    });
  };
  $rootScope.displayNewOpportunityForm = function() {
    $rootScope.setModal('partials/opportunity-form.html');
    return $rootScope.setupFileUploader();
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
  $scope.regions = $rootScope.allRegions;
  return $scope.save = function() {
    var opportunity;
    opportunity = $scope.opportunity;
    opportunity.bidding_ends = $('#opportunity_ends').val();
    opportunity.start_date = $('#opportunity_start_date').val();
    opportunity.end_date = $('#opportunity_end_date').val();
    opportunity.image_id = $('#opportunity_image_id').val();
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

NewFavoriteCtrl = function($scope, $rootScope, $route, Favorite, Company, FavoriteInvitation) {
  $scope.invitation = {};
  $scope.addToFavorites = function(company) {
    return Favorite.save({
      supplier_id: company._id,
      api_token: $rootScope.token.api_token
    }, {}, function() {
      $route.reload();
      return $rootScope.closeModal();
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
        return $rootScope.closeModal();
      });
    };
  };
};

OpportunityCtrl = function($scope, $rootScope, Auction) {
  return $scope.opportunities = Auction.query({
    api_token: $rootScope.token.api_token
  });
};

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
  var updateRegionSelectBox;
  $scope.filters = Filter.query();
  $scope.query = "";
  $scope.filter = null;
  $scope.regionFilter = "All My Regions";
  $scope.opportunity = null;
  updateRegionSelectBox = function() {
    $scope.regions = $rootScope.allRegions.slice(0);
    return $scope.regions.unshift("All My Regions");
  };
  $scope.regions = updateRegionSelectBox();
  $rootScope.$watch("allRegions", updateRegionSelectBox);
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
      if ($rootScope.company.hasSubscribedRegion(event.eventable.region)) {
        $scope.events.unshift(event);
        return $scope.$apply();
      }
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
    return reg.test(input.eventable.name.toLowerCase());
  };
  $scope.searchByEventType = function(event) {
    if (!$scope.eventType) {
      return true;
    }
    return event.action.type === $scope.eventType;
  };
  $scope.searchByRegion = function(event) {
    if ($scope.regionFilter === "All My Regions") {
      return true;
    }
    return event.eventable.region === $scope.regionFilter;
  };
  $scope.setEventType = function(eventType) {
    if ($scope.eventType === eventType) {
      return $scope.eventType = null;
    } else {
      return $scope.eventType = eventType;
    }
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
  $scope.actionDescription = function(action) {
    switch (action.type) {
      case "bid_created":
        return "recieved bid $" + action.details.amount + " from";
      default:
        return "" + (action.type.split('_').pop()) + " by";
    }
  };
  return $scope.toggleEvent = function(event) {
    event.selected = !event.selected;
    if (event.selected && event.eventable._id) {
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

SignInCtrl = function($scope, $rootScope, $location, $cookieStore, Token, Company, User) {
  $scope.email = "suboutdev@gmail.com";
  $scope.password = "password";
  return $scope.signIn = function() {
    return Token.save({
      email: $scope.email,
      password: $scope.password
    }, function(token) {
      $rootScope.token = token;
      if (token.authorized) {
        $cookieStore.put('token', token);
        $rootScope.signedInSuccess(token);
        return $location.path("dashboard");
      } else {
        return $scope.message = token.message;
      }
    });
  };
};

SignUpCtrl = function($scope, $rootScope, $routeParams, $location, Token, Company, FavoriteInvitation, GatewaySubscription) {
  $scope.company = {};
  $scope.user = {};
  $rootScope.setupFileUploader();
  if ($routeParams.invitation_id) {
    FavoriteInvitation.get({
      invitationId: $routeParams.invitation_id
    }, function(invitation) {
      $scope.user.email = invitation.supplier_email;
      $scope.company.email = invitation.supplier_email;
      $scope.company.name = invitation.supplier_name;
      return $scope.company.created_from_invitation_id = invitation._id;
    }, function() {
      return $location.path("/sign_in").search({});
    });
  } else if ($routeParams.subscription_id) {
    GatewaySubscription.get({
      subscriptionId: $routeParams.subscription_id
    }, function(subscription) {
      $scope.user.email = subscription.email;
      $scope.company.email = subscription.email;
      $scope.company.name = subscription.organization;
      return $scope.company.gateway_subscription_id = subscription._id;
    }, function() {
      return $location.path("/sign_in").search({});
    });
  } else {
    $location.path("/sign_in");
  }
  return $scope.signUp = function() {
    $scope.company.users_attributes = {
      "0": $scope.user
    };
    $scope.company.logo_id = $("#company_logo_id").val();
    return Company.save({
      company: $scope.company
    }, function() {
      return $location.path("/welcome-prelaunch").search({});
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
var Evaluators, evaluation, module;

module = angular.module("suboutFilters", []);

module.filter("timestamp", function() {
  return function(input) {
    return new Date(input).getTime();
  };
});

module.filter("websiteUrl", function() {
  return function(url) {
    if (/^https?/i.test(url)) {
      return url;
    } else {
      return "http://" + url;
    }
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
var api_path,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

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
  var Company;
  Company = $resource("" + api_path + "/companies/:companyId/:action", {
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
  Company.prototype.regionNames = function() {
    if (this.state_by_state_subscriber) {
      return this.regions.join(', ');
    } else {
      return "Nationwide";
    }
  };
  Company.prototype.hasSubscribedRegion = function(region) {
    return !this.state_by_state_subscriber || __indexOf.call(this.regions, region) >= 0;
  };
  return Company;
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
}).factory("GatewaySubscription", function($resource) {
  return $resource("" + api_path + "/gateway_subscriptions/:subscriptionId", {}, {});
}).factory("FileUploaderSignature", function($resource) {
  return $resource("" + api_path + "/file_uploader_signatures/new", {}, {});
});
