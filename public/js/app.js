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
      controller: DashboardCtrl,
      reloadOnSearch: false
    }).when("/bids", {
      templateUrl: "partials/bids.html",
      controller: MyBidCtrl
    }).when("/opportunities", {
      templateUrl: "partials/opportunities.html",
      controller: OpportunityCtrl
    }).when("/opportunities/:opportunity_reference_number", {
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

$.timeago.settings.allowFuture = true;

$.cloudinary.config({
  "cloud_name": "subout"
});

angular.element(document).ready(function() {
  return angular.bootstrap(document, ['subout']);
});
var AppCtrl, BidNewCtrl, CompanyProfileCtrl, DashboardCtrl, FavoritesCtrl, MyBidCtrl, NewFavoriteCtrl, OpportunityCtrl, OpportunityDetailCtrl, OpportunityFormCtrl, SettingCtrl, SignInCtrl, SignUpCtrl,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

AppCtrl = function($scope, $rootScope, $location, $cookieStore, Opportunity, Company, User, FileUploaderSignature) {
  var REGION_NAMES, p, publicPages, token, _ref, _ref1;
  $rootScope.currentPath = function() {
    return $location.path();
  };
  $rootScope.userSignedIn = function() {
    var _ref;
    if (((_ref = $rootScope.token) != null ? _ref.authorized : void 0) || $cookieStore.get('token')) {
      return true;
    }
  };
  $rootScope.signedInSuccess = function(token) {
    $rootScope.pusher = new Pusher(token.pusher_key);
    $rootScope.company = Company.get({
      companyId: token.company_id,
      api_token: token.api_token
    }, function(company) {
      if (company.state_by_state_subscriber) {
        return $rootScope.regions = company.regions;
      }
    });
    return $rootScope.user = User.get({
      userId: token.user_id,
      api_token: token.api_token
    });
  };
  publicPages = ["/sign_up", "/sign_in", "/welcome-prelaunch"];
  if (!((_ref = $rootScope.token) != null ? _ref.authorized : void 0)) {
    if (_ref1 = $location.path(), __indexOf.call(publicPages, _ref1) >= 0) {
      $cookieStore.remove('token');
    } else if (token = $cookieStore.get('token')) {
      $rootScope.token = token;
      $rootScope.signedInSuccess(token);
    } else {
      $rootScope.redirectToPath = $location.path();
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
  $rootScope.ALL_REGIONS = {
    "Alabama": "AL",
    "Alaska": "AK",
    "Arizona": "AZ",
    "Arkansas": "AR",
    "California": "CA",
    "Colorado": "CO",
    "Connecticut": "CT",
    "Delaware": "DE",
    "District of Columbia": "DC",
    "Florida": "FL",
    "Georgia": "GA",
    "Hawaii": "HI",
    "Idaho": "ID",
    "Illinois": "IL",
    "Indiana": "IN",
    "Iowa": "IA",
    "Kansas": "KS",
    "Kentucky": "KY",
    "Louisiana": "LA",
    "Maine": "ME",
    "Maryland": "MD",
    "Massachusetts": "MA",
    "Michigan": "MI",
    "Minnesota": "MN",
    "Missouri": "MO",
    "Mississippi": "MS",
    "Montana": "MT",
    "Nebraska": "NE",
    "Nevada": "NV",
    "New Hampshire": "NH",
    "New Jersey": "NJ",
    "New Mexico": "NM",
    "New York": "NY",
    "North Carolina": "NC",
    "North Dakota": "ND",
    "Ohio": "OH",
    "Oklahoma": "OK",
    "Oregon": "OR",
    "Pennsylvania": "PA",
    "Rhode Island": "RI",
    "South Carolina": "SC",
    "South Dakota": "SD",
    "Tennessee": "TN",
    "Texas": "TX",
    "Utah": "UT",
    "Vermont": "VT",
    "Virginia": "VA",
    "Washington": "WA",
    "West Virginia": "WV",
    "Wisconsin": "WI",
    "Wyoming": "WY"
  };
  REGION_NAMES = (function() {
    var _results;
    _results = [];
    for (p in $rootScope.ALL_REGIONS) {
      _results.push(p);
    }
    return _results;
  })();
  $rootScope.regions = REGION_NAMES.slice(0);
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
  $rootScope.displayNewBidForm = function(opportunity) {
    $rootScope.bid = {};
    $rootScope.setOpportunity(opportunity);
    return $rootScope.setModal('partials/bid-new.html');
  };
  $rootScope.displayNewOpportunityForm = function(opportunity) {
    $rootScope.setModal('partials/opportunity-form.html');
    return $rootScope.setupFileUploader();
  };
  $rootScope.displayNewFavoriteForm = function() {
    $rootScope.$broadcast('clearNewFavoriteForm');
    return $rootScope.setModal('partials/add-new-favorite.html');
  };
  $rootScope.clearOpportunity = function() {
    $("form .image-preview").attr('src', '');
    $("form .alert-content").empty();
    $("form .alert-error").hide();
    return $rootScope.opportunity = {};
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
  $rootScope.dateOptions = {
    dateFormat: 'mm/dd/yy'
  };
  $rootScope.errorMessages = function(errors) {
    var result;
    result = [];
    $.each(errors, function(key, errors) {
      var field;
      field = _.str.humanize(key);
      return $.each(errors, function(i, error) {
        return result.push("" + field + " " + error);
      });
    });
    return result;
  };
  return $rootScope.alertError = function(errors) {
    var $alertError, close, errorMessage, errorMessages, _i, _len;
    errorMessages = $rootScope.errorMessages(errors);
    $alertError = $("<div class='alert alert-error'></div>");
    close = '<a class="close" data-dismiss="alert" href="#">&times;</a>';
    $alertError.append(close);
    for (_i = 0, _len = errorMessages.length; _i < _len; _i++) {
      errorMessage = errorMessages[_i];
      $alertError.append("<p>" + errorMessage + "</p>");
    }
    return $alertError;
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
    opportunity.image_id = $('#opportunity_image_id').val();
    if (opportunity._id) {
      return Auction.update({
        opportunityId: opportunity._id,
        opportunity: opportunity,
        api_token: $rootScope.token.api_token
      }, function(data) {
        $rootScope.$emit('refreshOpportunity', opportunity);
        return jQuery("#modal").modal("hide");
      }, function(content) {
        var $alertError;
        $("#modal form .alert-error").remove();
        $alertError = $rootScope.alertError(content.data.errors);
        return $("#modal form").prepend($alertError);
      });
    } else {
      return Auction.save({
        opportunity: opportunity,
        api_token: $rootScope.token.api_token
      }, function(data) {
        return jQuery("#modal").modal("hide");
      }, function(content) {
        var $alertError;
        $("#modal form .alert-error").remove();
        $alertError = $rootScope.alertError(content.data.errors);
        return $("#modal form").prepend($alertError);
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
  $scope.$on('clearNewFavoriteForm', function() {
    $scope.supplierEmail = '';
    $scope.showCompany = false;
    $scope.showInvitation = false;
    return $scope.companyNotFound = false;
  });
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

OpportunityCtrl = function($scope, $rootScope, $location, Auction) {
  return $scope.opportunities = Auction.query({
    api_token: $rootScope.token.api_token
  });
};

OpportunityDetailCtrl = function($rootScope, $scope, $routeParams, $location, Bid, Auction, Opportunity) {
  $scope.opportunity = Opportunity.get({
    api_token: $rootScope.token.api_token,
    opportunityId: $routeParams.opportunity_reference_number
  });
  $rootScope.$on('refreshOpportunity', function(e, _opportunity) {
    console.log('fresh');
    return $scope.opportunity = _opportunity;
  });
  $scope.cancelOpportunity = function() {
    return Auction.cancel({
      opportunityId: $scope.opportunity._id,
      action: 'cancel',
      api_token: $rootScope.token.api_token
    }, {}, function() {
      return $location.path("dashboard");
    });
  };
  return $scope.selectWinner = function(bid) {
    return Auction.select_winner({
      opportunityId: $scope.opportunity._id,
      action: 'select_winner',
      bid_id: bid._id,
      api_token: $rootScope.token.api_token
    }, {}, function() {
      return $scope.opportunity = Opportunity.get({
        api_token: $rootScope.token.api_token,
        opportunityId: $scope.opportunity._id
      });
    });
  };
};

DashboardCtrl = function($scope, $rootScope, $location, Company, Event, Filter, Tag, Bid, Favorite, Opportunity) {
  var setRegionFilter, updateRegionSelectBox;
  $scope.$location = $location;
  $scope.filters = Filter.query({
    api_token: $rootScope.token.api_token
  });
  $scope.favoriteCompanies = Favorite.query({
    api_token: $rootScope.token.api_token
  });
  $scope.query = "";
  $scope.filter = null;
  $scope.regionFilter = "All";
  $scope.favoriteFilter = "";
  $scope.opportunity = null;
  updateRegionSelectBox = function() {
    $scope.regions = $rootScope.regions.slice(0);
    return $scope.regions.unshift("All");
  };
  $scope.regions = updateRegionSelectBox();
  $rootScope.$watch("regions", updateRegionSelectBox);
  $scope.companies = Company.query({
    api_token: $rootScope.token.api_token
  });
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
  $scope.loadMoreEvents = function() {
    var queryOptions;
    if ($scope.noMoreEvents || $scope.loading) {
      return;
    }
    $scope.loading = true;
    $scope.currentPage += 1;
    queryOptions = angular.copy($location.search());
    queryOptions.api_token = $rootScope.token.api_token;
    queryOptions.page = $scope.currentPage;
    return Event.query(queryOptions, function(data) {
      if (data.length === 0) {
        $scope.noMoreEvents = true;
        return $scope.loading = false;
      } else {
        angular.forEach(data, function(event) {
          return $scope.events.push(event);
        });
        return $scope.loading = false;
      }
    });
  };
  $scope.refreshEvents = function(callback) {
    $scope.events = [];
    $scope.currentPage = 0;
    $scope.noMoreEvents = false;
    $scope.loadMoreEvents();
    if (callback) {
      return callback();
    }
  };
  $scope.refreshEvents(function() {
    var channel;
    channel = $rootScope.pusher.subscribe('event');
    return channel.bind('created', function(event) {
      if ($rootScope.company.canSeeEvent(event)) {
        $scope.events.unshift(event);
        return $scope.$apply();
      }
    });
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
  $scope.searchByRegion = function(event) {
    var _ref;
    if ($scope.regionFilter === "All") {
      return true;
    }
    return _ref = $scope.regionFilter, __indexOf.call(event.regions, _ref) >= 0;
  };
  $scope.searchByCompanyName = function(input) {
    var reg;
    if (!$scope.companyNameFilter) {
      return true;
    }
    if (!(input.eventable.buyer_name && input.eventable.buyer_abbreviated_name)) {
      return false;
    }
    reg = new RegExp($scope.companyNameFilter.toLowerCase());
    return reg.test(input.eventable.buyer_name.toLowerCase()) || reg.test(input.eventable.buyer_abbreviated_name.toLowerCase());
  };
  $scope.searchByFavorite = function(event) {
    if ($scope.favoriteFilter === "") {
      return true;
    }
    return $scope.favoriteFilter === event.eventable_company_id;
  };
  $scope.setFavoriteFilter = function(company_id) {
    if ($scope.favoriteFilter === company_id) {
      return $scope.favoriteFilter = "";
    } else {
      return $scope.favoriteFilter = company_id;
    }
  };
  setRegionFilter = function() {
    if ($location.search().region === $scope.regionFilter || $scope.regionFilter === 'All') {
      $location.search('region', null);
    } else {
      $location.search('region', $scope.regionFilter);
    }
    return $scope.refreshEvents();
  };
  $scope.$watch("regionFilter", setRegionFilter);
  $scope.setOpportunityTypeFilter = function(filter) {
    if ($location.search().opportunity_type === filter.name) {
      $location.search('opportunity_type', null);
    } else {
      $location.search('opportunity_type', filter.name);
    }
    return $scope.refreshEvents();
  };
  $scope.setEventType = function(eventType) {
    if ($location.search().event_type === eventType) {
      $location.search('event_type', null);
    } else {
      $location.search('event_type', eventType);
    }
    return $scope.refreshEvents();
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
      }, function() {
        return setTimeout((function() {
          return $(".relative_time").timeago();
        }), 1);
      });
    }
  };
};

SettingCtrl = function($scope, $rootScope, $location, Token, Company, User) {
  $scope.userProfile = $rootScope.user;
  $scope.companyProfile = $rootScope.company;
  $rootScope.setupFileUploader();
  $scope.saveUserProfile = function() {
    $scope.userProfileError = "";
    if ($scope.userProfile.password === $scope.userProfile.password_confirmation) {
      return User.update({
        userId: $rootScope.user._id,
        user: $scope.userProfile,
        api_token: $rootScope.token.api_token
      }, function(user) {
        $scope.userProfile.password = '';
        $scope.userProfile.current_password = '';
        $rootScope.user = $scope.userProfile;
        return $rootScope.closeModal();
      }, function(error) {
        return $scope.userProfileError = "Invalid password or email!";
      });
    } else {
      return $scope.userProfileError = "The new password and password confirmation are not identical.";
    }
  };
  return $scope.saveCompanyProfile = function() {
    $scope.companyProfileError = "";
    $scope.companyProfile.logo_id = $("#company_logo_id").val();
    return Company.update({
      companyId: $rootScope.company._id,
      company: $scope.companyProfile,
      api_token: $rootScope.token.api_token
    }, function(company) {
      $rootScope.company = $scope.companyProfile;
      return $rootScope.closeModal();
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
        if ($rootScope.redirectToPath) {
          return $location.path($rootScope.redirectToPath);
        } else {
          return $location.path("dashboard");
        }
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

subout.directive("whenScrolled", function() {
  return function(scope, element, attr) {
    return $(window).scroll(function() {
      if ($(window).scrollTop() > $(document).height() - $(window).height() - 50) {
        return scope.$apply(attr.whenScrolled);
      }
    });
  };
});
var Evaluators, evaluation, module;

module = angular.module("suboutFilters", []);

module.filter("timestamp", function() {});

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
  Company.prototype.canSeeEvent = function(event) {
    var _ref;
    if (event.eventable_company_id === this._id) {
      return true;
    }
    if (_ref = event.eventable_company_id, __indexOf.call(this.favoriting_buyer_ids, _ref) >= 0) {
      return true;
    }
    return !event.eventable.for_favorites_only && this.subscribedRegions(event.regions);
  };
  Company.prototype.subscribedRegions = function(regions) {
    var region;
    if (this.regions === "all") {
      return true;
    }
    return ((function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = regions.length; _i < _len; _i++) {
        region = regions[_i];
        if (__indexOf.call(this.regions, region) >= 0) {
          _results.push(region);
        }
      }
      return _results;
    }).call(this)).length > 0;
  };
  Company.prototype.canBidOn = function(opportunity) {
    return opportunity.bidable && opportunity.buyer_id !== this._id;
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
