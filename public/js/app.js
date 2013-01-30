var subout;

$.cookie.json = true;

$.cookie.defaults.expires = 7;

subout = angular.module("subout", ["ui", "suboutFilters", "suboutServices", "ngCookies"]);

subout.run([
  '$rootScope', '$appVersioning', '$location', function($rootScope, $versioning, $location) {
    return $rootScope.$on('$routeChangeStart', function(scope, next, current) {
      if (current && $versioning.isMarkedForReload()) {
        window.location = $location.path();
        return window.location.reload();
      }
    });
  }
]);

subout.config([
  "$routeProvider", "$httpProvider", function($routeProvider, $httpProvider) {
    $httpProvider.responseInterceptors.push('myHttpInterceptor');
    return $routeProvider.when("/sign_in", {
      templateUrl: "partials/sign_in.html",
      controller: SignInCtrl
    }).when("/sign_up", {
      templateUrl: "partials/sign_up.html",
      controller: SignUpCtrl
    }).when("/password/new", {
      templateUrl: "partials/password-new.html",
      controller: NewPasswordCtrl
    }).when("/password/edit", {
      templateUrl: "partials/password-edit.html",
      controller: "EditPasswordCtrl"
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
      templateUrl: "partials/welcome-prelaunch.html",
      controller: WelcomePrelaunchCtrl
    }).otherwise({
      redirectTo: "/dashboard"
    });
  }
]);

subout.value('ui.config', {
  select2: {
    allowClear: true
  }
});

subout.value('AuthToken', 'auth_token_v2');

$.timeago.settings.allowFuture = true;

$.cloudinary.config({
  "cloud_name": "subout"
});

angular.element(document).ready(function() {
  return angular.bootstrap(document, ['subout']);
});
var AppCtrl, BidNewCtrl, CompanyProfileCtrl, DashboardCtrl, FavoritesCtrl, MyBidCtrl, NewFavoriteCtrl, NewPasswordCtrl, OpportunityCtrl, OpportunityDetailCtrl, OpportunityFormCtrl, SettingCtrl, SignInCtrl, SignUpCtrl, WelcomePrelaunchCtrl,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

AppCtrl = function($scope, $rootScope, $location, $appBrowser, Opportunity, Company, User, FileUploaderSignature, AuthToken, Region) {
  var REGION_NAMES, p;
  $('#modal').on('hidden', function() {
    $scope = angular.element(document).scope();
    $scope.modal = null;
    if (!$scope.$$phase) {
      return $scope.$apply();
    }
  });
  if ($appBrowser.isReallyOld()) {
    window.location = "/upgrade_browser.html";
    return;
  }
  $rootScope.isOldBrowser = $appBrowser.isOld();
  $rootScope.currentPath = function() {
    return $location.path();
  };
  $rootScope.userSignedIn = function() {
    var _ref;
    if (((_ref = $rootScope.token) != null ? _ref.authorized : void 0) || $.cookie(AuthToken)) {
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
    $rootScope.user = User.get({
      userId: token.user_id,
      api_token: token.api_token
    });
    return $rootScope.REGION_PRICES = Region.query({
      api_token: token.api_token
    });
  };
  $rootScope.setModal = function(url) {
    return $rootScope.modal = url;
  };
  $rootScope.closeModal = function() {
    return $('#modal').modal("hide");
  };
  $rootScope.signOut = function() {
    $.removeCookie(AuthToken);
    window.location = "#/sign_in";
    return window.location.reload(true);
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
    var $fileUploader;
    $fileUploader = $("input.cloudinary-fileupload[type=file]");
    if (!($fileUploader.length > 0)) {
      return;
    }
    $fileUploader.hide();
    return FileUploaderSignature.get({}, function(data) {
      var $fileProgressBar, previewUrl, progressImageUpload, setImageUpload;
      $fileProgressBar = $('#progress .bar');
      $fileUploader.attr('data-form-data', JSON.stringify(data));
      $fileUploader.show();
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
        $("form .image-preview").attr('src', previewUrl(data)).show();
        return $("form .file-upload-public-id").val(data.result.public_id);
      };
      progressImageUpload = function(element, progressing) {
        $('form btn-primary').prop('disabled', !progressing);
        $fileProgressBar.toggle(progressing);
        return $(element).toggle(!progressing);
      };
      $fileUploader.off('fileuploadstart');
      $fileUploader.on('fileuploadstart', function(e, data) {
        return progressImageUpload(this, true);
      });
      $fileUploader.off('cloudinarydone');
      return $fileUploader.on('cloudinarydone', function(e, data) {
        progressImageUpload(this, false);
        if (data.result.resource_type !== "image") {
          return alert("Sorry, only images are supported.");
        } else {
          return setImageUpload(data);
        }
      });
    });
  };
  $rootScope.displaySettings = function() {
    $rootScope.setModal('partials/settings.html');
    return $rootScope.setupFileUploader();
  };
  $rootScope.displayNewBidForm = function(opportunity) {
    $rootScope.bid = {};
    $rootScope.setOpportunity(opportunity);
    $rootScope.setModal('partials/bid-new.html');
    return $rootScope.$broadcast('modalOpened');
  };
  $rootScope.displayNewOpportunityForm = function() {
    $rootScope.setModal('partials/opportunity-form.html');
    return $rootScope.setupFileUploader();
  };
  $rootScope.displayNewFavoriteForm = function() {
    return $rootScope.setModal('partials/add-new-favorite.html');
  };
  $rootScope.setOpportunity = function(opportunity) {
    return $rootScope.opportunity = Opportunity.get({
      api_token: $rootScope.token.api_token,
      opportunityId: opportunity._id
    });
  };
  $rootScope.displayCompanyProfile = function(company_id) {
    $rootScope.other_company = Company.get({
      api_token: $rootScope.token.api_token,
      companyId: company_id
    });
    return $rootScope.setModal('partials/company-profile.html');
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
        if (key === "base") {
          return result.push(_.str.humanize(error));
        } else {
          return result.push("" + field + " " + error);
        }
      });
    });
    return result;
  };
  $rootScope.alertError = function(errors) {
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
  return $rootScope.alertInfo = function(messages) {
    var $alertInfo, close, info, _i, _len;
    $alertInfo = $("<div class='alert alert-info'></div>");
    close = '<a class="close" data-dismiss="alert" href="#">&times;</a>';
    $alertInfo.append(close);
    for (_i = 0, _len = messages.length; _i < _len; _i++) {
      info = messages[_i];
      $alertInfo.append("<p>" + info + "</p>");
    }
    return $alertInfo;
  };
};

WelcomePrelaunchCtrl = function(AuthToken) {
  return $.removeCookie(AuthToken);
};

OpportunityFormCtrl = function($scope, $rootScope, $location, Auction) {
  $scope.types = ["Vehicle Needed", "Vehicle for Hire", "Special", "Emergency", "Buy or Sell Parts and Vehicles"];
  return $scope.save = function() {
    var opportunity, showErrors;
    opportunity = $scope.opportunity;
    opportunity.bidding_ends = $('#opportunity_ends').val();
    opportunity.start_date = $('#opportunity_start_date').val();
    opportunity.end_date = $('#opportunity_end_date').val();
    opportunity.image_id = $('#opportunity_image_id').val();
    opportunity.start_time = $("#opportunity_start_time").val();
    opportunity.end_time = $("#opportunity_end_time").val();
    showErrors = function(errors) {
      var $alertError;
      $("#modal form .alert-error").remove();
      $alertError = $rootScope.alertError(errors);
      $("#modal form").append($alertError);
      return $("#modal .modal-body").scrollTop($("#modal form").height());
    };
    if (opportunity._id) {
      return Auction.update({
        opportunityId: opportunity._id,
        opportunity: opportunity,
        api_token: $rootScope.token.api_token
      }, function(data) {
        $rootScope.$emit('refreshOpportunity', opportunity);
        return jQuery("#modal").modal("hide");
      }, function(content) {
        return showErrors(content.data.errors);
      });
    } else {
      return Auction.save({
        opportunity: opportunity,
        api_token: $rootScope.token.api_token
      }, function(data) {
        return jQuery("#modal").modal("hide");
      }, function(content) {
        return showErrors(content.data.errors);
      });
    }
  };
};

BidNewCtrl = function($scope, $rootScope, Bid) {
  $scope.$on('modalOpened', function() {
    return $scope.hideErrorMessage();
  });
  $scope.hideErrorMessage = function() {
    return $scope.errors = null;
  };
  return $scope.save = function() {
    return Bid.save({
      bid: $scope.bid,
      api_token: $rootScope.token.api_token,
      opportunityId: $rootScope.opportunity._id
    }, function(data) {
      return jQuery("#modal").modal("hide");
    }, function(content) {
      return $scope.errors = $rootScope.errorMessages(content.data.errors);
    });
  };
};

MyBidCtrl = function($scope, $rootScope, MyBid, Authorize) {
  if (!Authorize.check()) {
    return;
  }
  return $scope.my_bids = MyBid.query({
    api_token: $rootScope.token.api_token
  });
};

FavoritesCtrl = function($scope, $rootScope, Favorite, Authorize) {
  if (!Authorize.check()) {
    return;
  }
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

OpportunityCtrl = function($scope, $rootScope, $location, Auction, Authorize) {
  var filterWithQuery;
  if (!Authorize.check()) {
    return;
  }
  $scope.opportunities = Auction.query({
    api_token: $rootScope.token.api_token
  });
  filterWithQuery = function(value) {
    var reg;
    reg = new RegExp($scope.opportunityQuery.toLowerCase());
    if (value && reg.test(value.toLowerCase())) {
      return true;
    }
  };
  return $scope.opportunityFilter = function(item) {
    if (!$scope.opportunityQuery) {
      return true;
    }
    if (filterWithQuery(item.reference_number)) {
      return true;
    }
    if (filterWithQuery(item.type)) {
      return true;
    }
    if (filterWithQuery(item.name)) {
      return true;
    }
    if (filterWithQuery(item.description)) {
      return true;
    }
    if (item.winner && filterWithQuery(item.winner.name)) {
      return true;
    }
    return false;
  };
};

OpportunityDetailCtrl = function($rootScope, $scope, $routeParams, $location, Bid, Auction, Opportunity, Authorize) {
  if (!Authorize.check()) {
    return;
  }
  $scope.opportunity = Opportunity.get({
    api_token: $rootScope.token.api_token,
    opportunityId: $routeParams.opportunity_reference_number
  });
  $rootScope.$on('refreshOpportunity', function(e, _opportunity) {
    return $scope.opportunity = _opportunity;
  });
  $scope.hideErrorMessage = function() {
    return $scope.errors = null;
  };
  $scope.cancelOpportunity = function() {
    return Auction.cancel({
      opportunityId: $scope.opportunity._id,
      action: 'cancel',
      api_token: $rootScope.token.api_token
    }, {}, function(content) {
      return $location.path("dashboard");
    }, function(content) {
      return $scope.errors = $rootScope.errorMessages(content.data.errors);
    });
  };
  return $scope.selectWinner = function(bid) {
    return Auction.select_winner({
      opportunityId: $scope.opportunity._id,
      action: 'select_winner',
      bid_id: bid._id,
      api_token: $rootScope.token.api_token
    }, {}, function(content) {
      return $scope.opportunity = Opportunity.get({
        api_token: $rootScope.token.api_token,
        opportunityId: $scope.opportunity._id
      });
    }, function(content) {
      return $scope.errors = $rootScope.errorMessages(content.data.errors);
    });
  };
};

DashboardCtrl = function($scope, $rootScope, $location, Company, Event, Filter, Tag, Bid, Favorite, Opportunity, Authorize) {
  var setCompanyFilter, setRegionFilter, updatePreviousEvents;
  if (!Authorize.check()) {
    return;
  }
  $scope.$location = $location;
  $scope.filters = Filter.query({
    api_token: $rootScope.token.api_token
  });
  $scope.favoriteCompanies = Favorite.query({
    api_token: $rootScope.token.api_token
  });
  $scope.query = $location.search().q;
  $scope.filter = null;
  $scope.opportunity = null;
  Company.query({
    api_token: $rootScope.token.api_token
  }, function(data) {
    return $scope.companies = data;
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
        $scope.loading = false;
        return $scope.currentPage += 1;
      }
    });
  };
  $scope.refreshEvents = function(callback) {
    $scope.events = [];
    $scope.currentPage = 1;
    $scope.noMoreEvents = false;
    $scope.loadMoreEvents();
    if (callback) {
      return callback();
    }
  };
  updatePreviousEvents = function(event) {
    var opportunity;
    opportunity = event.eventable;
    return _.each($scope.events, function(prevEvent) {
      var prevOpportunity;
      prevOpportunity = prevEvent.eventable;
      if (prevOpportunity._id === opportunity._id) {
        prevOpportunity.canceled = opportunity.canceled;
        return prevOpportunity.bidable = opportunity.bidable;
      }
    });
  };
  $scope.refreshEvents(function() {
    var channel;
    channel = $rootScope.pusher.subscribe('global');
    channel.bind('event_created', function(event) {
      if ($rootScope.company.canSeeEvent(event) && $scope.matchFilters(event)) {
        $scope.events.unshift(event);
        updatePreviousEvents(event);
        return $scope.$apply();
      }
    });
    channel.bind('added_to_favorites', function(favorite) {
      if ($rootScope.company._id === favorite.supplier_id) {
        return $rootScope.company.addFavoriteBuyerId(favorite.company_id);
      }
    });
    return channel.bind('removed_from_favorites', function(favorite) {
      if ($rootScope.company._id === favorite.supplier_id) {
        return $rootScope.company.removeFavoriteBuyerId(favorite.company_id);
      }
    });
  });
  $scope.matchFilters = function(event) {
    return $scope.filterEventType(event) && $scope.filterRegion(event) && $scope.filterOpportunityType(event) && $scope.filterFullText(event) && $scope.filterCompany(event);
  };
  $scope.filterEventType = function(event) {
    var event_type;
    event_type = $location.search().event_type;
    if (!event_type) {
      return true;
    }
    return event.action.type === event_type;
  };
  $scope.filterRegion = function(event) {
    var region;
    region = $location.search().region;
    if (!region) {
      return true;
    }
    return __indexOf.call(event.regions, region) >= 0;
  };
  $scope.filterOpportunityType = function(event) {
    var opportunity_type;
    opportunity_type = $location.search().opportunity_type;
    if (!opportunity_type) {
      return true;
    }
    return event.eventable.type === opportunity_type;
  };
  $scope.filterFullText = function(event) {
    var eventable, query, reg, text;
    query = $location.search().q;
    if (!query) {
      return true;
    }
    eventable = event.eventable;
    if (query.indexOf("#") === 0) {
      return ("#" + eventable.reference_number) === query;
    } else {
      reg = new RegExp(query);
      text = (eventable.name + ' ' + eventable.description).toLowerCase();
      return reg.test(text);
    }
  };
  $scope.filterCompany = function(event) {
    var actor_id;
    actor_id = $location.search().company_id;
    if (!actor_id) {
      return true;
    }
    return event.actor._id === actor_id;
  };
  $scope.setFavoriteFilter = function(company_id) {
    return $scope.companyFilter = company_id;
  };
  setRegionFilter = function() {
    if ($scope.regionFilter) {
      $location.search('region', $scope.regionFilter);
    } else {
      $location.search('region', null);
    }
    return $scope.refreshEvents();
  };
  setCompanyFilter = function() {
    if ($scope.companyFilter) {
      $location.search('company_id', $scope.companyFilter);
    } else {
      $location.search('company_id', null);
    }
    return $scope.refreshEvents();
  };
  $scope.$watch("regions", function() {
    $scope.regionFilter = $location.search().region;
    $scope.$watch("regionFilter", setRegionFilter);
    $scope.companyFilter = $location.search().company_id;
    return $scope.$watch("companyFilter", setCompanyFilter);
  });
  $scope.setOpportunityTypeFilter = function(opportunity_type) {
    if ($location.search().opportunity_type === opportunity_type) {
      $location.search('opportunity_type', null);
    } else {
      $location.search('opportunity_type', opportunity_type);
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
  $scope.eventTypeLabel = function(eventType) {
    if (eventType === "opportunity_created") {
      return "Created";
    } else if (eventType === "bid_created") {
      return "New Bid";
    } else if (eventType === "opportunity_bidding_won") {
      return "Bidding Won";
    } else if (eventType === "opportunity_canceled") {
      return "Canceled";
    } else {
      return "Unknown";
    }
  };
  $scope.companyName = function(companyId) {
    var company;
    company = _.find($scope.companies, function(company) {
      return company._id === companyId;
    });
    if (company) {
      return _.str.trim(company.abbreviated_name);
    } else {
      return companyId;
    }
  };
  $scope.actionDescription = function(action) {
    switch (action.type) {
      case "bid_created":
        return "received bid $" + action.details.amount;
      default:
        return "" + (action.type.split('_').pop());
    }
  };
  $scope.toggleEvent = function(event) {
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
  $scope.fullTextSearch = function(event) {
    var query;
    if ($scope.query && $scope.query !== "") {
      query = $scope.query;
    } else {
      query = null;
    }
    $location.search('q', query);
    return $scope.refreshEvents();
  };
  $scope.refNumSearch = function(ref_num) {
    $scope.query = '#' + ref_num;
    return $scope.fullTextSearch();
  };
  $scope.hasAnyFilter = function() {
    return !_.isEmpty($location.search());
  };
  return $scope.clearFilters = function() {
    $scope.query = "";
    $scope.companyFilter = null;
    $scope.regionFilter = null;
    $location.search({});
    return $scope.refreshEvents();
  };
};

SettingCtrl = function($scope, $rootScope, $location, Token, Company, User) {
  var region, _i, _len, _ref;
  $scope.userProfile = angular.copy($rootScope.user);
  $scope.companyProfile = angular.copy($rootScope.company);
  console.log($rootScope.company);
  $scope.companyProfile.allRegions = {};
  _ref = $scope.companyProfile.regions;
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    region = _ref[_i];
    $scope.companyProfile.allRegions[region] = true;
  }
  $scope.regionPrice = function(region_name) {
    region = _.find($rootScope.REGION_PRICES, function(item) {
      return item.name === region_name;
    });
    if (region) {
      return region.price;
    } else {
      return 0;
    }
  };
  $scope.updateTotalPrice = function() {
    var is_enabled, totalPrice, _ref1;
    totalPrice = 0;
    _ref1 = $scope.companyProfile.allRegions;
    for (region in _ref1) {
      is_enabled = _ref1[region];
      if (is_enabled) {
        totalPrice += $scope.regionPrice(region);
      }
    }
    $scope.totalPrice = totalPrice;
    return totalPrice;
  };
  $scope.totalPrice = $scope.updateTotalPrice();
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
  $scope.saveLicensedRegions = function() {
    var finalRegions, isEnabled, _ref1;
    finalRegions = [];
    _ref1 = $scope.companyProfile.allRegions;
    for (region in _ref1) {
      isEnabled = _ref1[region];
      if (!!isEnabled) {
        finalRegions.push(region);
      }
    }
    delete $scope.companyProfile.allRegions;
    $scope.companyProfile.regions = finalRegions;
    return Company.update_regions({
      companyId: $rootScope.company._id,
      company: $scope.companyProfile,
      api_token: $rootScope.token.api_token,
      action: "update_regions"
    }, function(company) {
      $rootScope.company = $scope.companyProfile;
      return $rootScope.closeModal();
    }, function(error) {
      return $scope.companyProfileError = "Sorry, invalid inputs. Please try again.";
    });
  };
  $scope.saveCompanyProfile = function() {
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
  return $scope.upgradeToNationalPlan = function() {
    return Company.update_product({
      companyId: $rootScope.company._id,
      product: "subout-national-service",
      api_token: $rootScope.token.api_token,
      action: "update_product"
    }, function(company) {
      $rootScope.company = Company.get({
        companyId: $rootScope.token.company_id,
        api_token: $rootScope.token.api_token
      }, function(company) {
        if (company.state_by_state_subscriber) {
          return $rootScope.regions = company.regions;
        }
      });
      return $rootScope.closeModal();
    }, function(error) {
      return $scope.companyProfileError = "Sorry, invalid inputs. Please try again.";
    });
  };
};

SignInCtrl = function($scope, $rootScope, $location, Token, Company, User, AuthToken) {
  $.removeCookie(AuthToken);
  return $scope.signIn = function() {
    return Token.save({
      email: $scope.email,
      password: $scope.password
    }, function(token) {
      $rootScope.token = token;
      if (token.authorized) {
        $.cookie(AuthToken, token);
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

NewPasswordCtrl = function($scope, $rootScope, $location, $timeout, Password, AuthToken) {
  $.removeCookie(AuthToken);
  $scope.hideAlert = function() {
    $scope.notice = null;
    return $scope.errors = null;
  };
  return $scope.requestResetPassword = function() {
    $scope.hideAlert();
    return Password.save({
      user: $scope.user
    }, function() {
      $scope.user.email = null;
      $scope.notice = "You will receive an email with instructions" + " about how to reset your password in a few minutes.";
      return $timeout(function() {
        return $scope.notice = null;
      }, 2000);
    }, function(content) {
      return $scope.errors = $rootScope.errorMessages(content.data.errors);
    });
  };
};

SignUpCtrl = function($scope, $rootScope, $routeParams, $location, Token, Company, FavoriteInvitation, GatewaySubscription, AuthToken) {
  $.removeCookie(AuthToken);
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
      return $location.path("/sign_in").search({});
    }, function(response) {
      return $scope.errorMessage = response.data.errors.join("<br />");
    });
  };
};

CompanyProfileCtrl = function($rootScope, $scope, $timeout, Favorite) {
  return $scope.addToFavorites = function(company) {
    $scope.notice = null;
    return Favorite.save({
      supplier_id: company._id,
      api_token: $rootScope.token.api_token
    }, {}, function() {
      company.favoriting_buyer_ids || (company.favoriting_buyer_ids = []);
      company.favoriting_buyer_ids.push($rootScope.company._id);
      $scope.notice = "Successfully added to favorites.";
      return $timeout(function() {
        $scope.notice = null;
        return $("#modal").modal("hide");
      }, 2000);
    });
  };
};

(function() {
  var applyScopeHelpers;
  applyScopeHelpers = function($scope, $rootScope, $location, $routeParams, $timeout, Password, AuthToken) {
    $scope.hideAlert = function() {
      $scope.notice = null;
      return $scope.errors = null;
    };
    return $scope.resetPassword = function() {
      $scope.hideAlert();
      $scope.user.reset_password_token = $routeParams.reset_password_token;
      return Password.update({
        user: $scope.user
      }, function() {
        $scope.notice = "Your password is reset successfully";
        $scope.password = null;
        $scope.password_confirmation = null;
        return $timeout(function() {
          $scope.notice = null;
          return $location.path("sign_in").search({});
        }, 2000);
      }, function(content) {
        return $scope.errors = $rootScope.errorMessages(content.data.errors);
      });
    };
  };
  return subout.controller('EditPasswordCtrl', function($scope, $rootScope, $routeParams, $location, $timeout, Password, AuthToken) {
    $.removeCookie(AuthToken);
    return applyScopeHelpers($scope, $rootScope, $location, $routeParams, $timeout, Password, AuthToken);
  });
})();

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
}).factory("Region", function($resource) {
  return $resource("" + api_path + "/regions", {}, {});
}).factory("Bid", function($resource) {
  return $resource("" + api_path + "/opportunities/:opportunityId/bids", {
    opportunityId: "@opportunityId"
  }, {});
}).factory("Event", function($resource) {
  var Event;
  Event = $resource("" + api_path + "/events/:eventId", {}, {});
  Event.prototype.isBidableBy = function(company) {
    return this.eventable.bidable && this.eventable.buyer_id !== company._id;
  };
  return Event;
}).factory("Company", function($resource, $rootScope) {
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
    },
    update_regions: {
      method: "PUT",
      action: "update_regions"
    },
    update_product: {
      method: "PUT",
      action: "update_product"
    }
  });
  Company.prototype.regionNames = function() {
    if (this.state_by_state_subscriber) {
      return this.regions.join(', ');
    } else {
      return "Nationwide";
    }
  };
  Company.prototype.canBeAddedAsFavorite = function(company) {
    var _ref;
    if (this._id === company._id) {
      return false;
    }
    if (!this.favoriting_buyer_ids) {
      return false;
    }
    return !(_ref = company._id, __indexOf.call(this.favoriting_buyer_ids, _ref) >= 0);
  };
  Company.prototype.canSeeEvent = function(event) {
    var _ref;
    if (!event.eventable.for_favorites_only) {
      return true;
    }
    if (event.eventable.buyer_id === this._id) {
      return true;
    }
    return _ref = event.eventable.buyer_id, __indexOf.call(this.favoriting_buyer_ids, _ref) >= 0;
  };
  Company.prototype.isLicensedToBidOnOpportunityOf = function(event) {
    var _ref, _ref1, _ref2;
    if (!this.state_by_state_subscriber) {
      return true;
    }
    if (_ref = event.eventable.start_region, __indexOf.call(this.regions, _ref) >= 0) {
      return true;
    }
    if (_ref1 = event.eventable.end_region, __indexOf.call(this.regions, _ref1) >= 0) {
      return true;
    }
    if (_ref2 = event.eventable.buyer_id, __indexOf.call(this.favoriting_buyer_ids, _ref2) >= 0) {
      return true;
    }
    return false;
  };
  Company.prototype.canCancelOrEdit = function(opportunity) {
    if (!opportunity.status) {
      return false;
    }
    if (opportunity.bids.length > 0) {
      return false;
    }
    if (this._id !== opportunity.buyer._id) {
      return false;
    }
    return opportunity.status === 'In progress';
  };
  Company.prototype.removeFavoriteBuyerId = function(buyerId) {
    return this.favoriting_buyer_ids = _.without(this.favoriting_buyer_ids, buyerId);
  };
  Company.prototype.addFavoriteBuyerId = function(buyerId) {
    return this.favoriting_buyer_ids.push(buyerId);
  };
  return Company;
}).factory("Token", function($resource) {
  return $resource("" + api_path + "/tokens", {}, {});
}).factory("Password", function($resource) {
  return $resource("" + api_path + "/passwords", {}, {
    update: {
      method: "PUT",
      params: {}
    }
  });
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
}).factory("Authorize", function($rootScope, $location, AuthToken) {
  return {
    check: function() {
      var token, _ref;
      if ((_ref = $rootScope.token) != null ? _ref.authorized : void 0) {
        return true;
      }
      if (token = $.cookie(AuthToken)) {
        $rootScope.token = token;
        $rootScope.signedInSuccess(token);
        return true;
      }
      $rootScope.redirectToPath = $location.path();
      $location.path("/sign_in");
      return false;
    }
  };
}).factory("$appVersioning", function() {
  return {
    _version: 0,
    _deploy: 0,
    isAppVersionUpToDate: function(version) {
      var v;
      version = parseFloat(version);
      v = this.getAppVersion();
      if (v > 0 && version !== v) {
        return false;
      }
      this.setAppVersion(version);
      return true;
    },
    isDeployTimestampUpToDate: function(deploy) {
      var d;
      deploy = parseInt(deploy);
      d = this.getDeployTimestamp();
      if (d > 0 && deploy !== d) {
        return false;
      }
      this.setDeployTimestamp(deploy);
      return true;
    },
    getAppVersion: function() {
      return this._version;
    },
    setAppVersion: function(v) {
      return this._version = v;
    },
    getDeployTimestamp: function() {
      return this._deploy;
    },
    setDeployTimestamp: function(d) {
      return this._deploy = d;
    },
    markForReload: function() {
      return this._reload = true;
    },
    isMarkedForReload: function() {
      return this._reload === true;
    }
  };
}).factory("$appBrowser", function() {
  return {
    isReallyOld: function() {
      return ($.browser.msie && $.browser.version < 8) || ($.browser.firefox && $.browser.version < 4);
    },
    isOld: function() {
      return ($.browser.msie && $.browser.version < 9) || ($.browser.firefox && $.browser.version < 5);
    }
  };
}).factory("myHttpInterceptor", function($q, $appVersioning, $rootScope) {
  return function(promise) {
    return promise.then((function(response) {
      var deploy, mime, payloadData, version;
      mime = "application/json; charset=utf-8";
      if (response.headers()["content-type"] === mime) {
        payloadData = response.data ? response.data.payload : null;
        if (payloadData) {
          version = response.data.version;
          if (!$appVersioning.isAppVersionUpToDate(version)) {
            $rootScope.signOut();
            return;
          }
          deploy = response.data.deploy;
          if (!$appVersioning.isDeployTimestampUpToDate(deploy)) {
            $appVersioning.markForReload();
          }
          if (!payloadData) {
            return $q.reject(response);
          }
          response.data = payloadData;
        }
      }
      return response;
    }), function(response) {
      return $q.reject(response);
    });
  };
});
