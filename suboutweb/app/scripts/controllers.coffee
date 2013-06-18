subout.run(($rootScope, $location, $appBrowser, $numberFormatter, $timeout,
  Opportunity, Company, Favorite, User, FileUploaderSignature, AuthToken, Region, Bid) ->

  $rootScope.stars = [1,2,3,4,5]
  d = new Date()
  $rootScope.years = [d.getFullYear()..1970]

  salt =(key)->
    return $rootScope.api_token + "_" + key
     
  $rootScope.filterRegionsOnHome = null
  $rootScope.filterRegionsOnBuybid = null

  $rootScope.filterRegionsOnHome = $.cookie(salt("filterRegionsOnHome"))
  $rootScope.filterRegionsOnHome = [] if $rootScope.filterRegionsOnHome == null

  $rootScope.$watch "filterRegionsOnHome", (v1, v2)->
    if v1 != null
      $.cookie(salt("filterRegionsOnHome"), $rootScope.filterRegionsOnHome)

  $('#modal').on('hidden', () ->
    $scope = angular.element(document).scope()
    $scope.modal = ''
    $rootScope.opportunity = null
    modalElement = $('#modal-stage')
    modalScope = angular.element(modalElement.find('.ng-scope')).scope()
    modalScope.$destroy() if modalScope
    modalElement.html('')
    $('.loading-animation').removeClass('loading')
    unless($scope.$$phase) then $scope.$apply()
  )

  if $appBrowser.isReallyOld()
    window.location = "/upgrade_browser.html"
    return

  $rootScope.isOldBrowser = $appBrowser.isOld()

  $rootScope.validateNumber = (value) ->
    /^\d+$/.test(value)

  $rootScope.validateOptionalNumber = (value) ->
    return true unless value
    /^\d*$/.test(value)

  $rootScope.userSignedIn = ->
    return false if $location.path() == '/sign_in'
    return true if $rootScope.token?.authorized or $.cookie(AuthToken)

  $rootScope.isMobile = $appBrowser.isMobile()
  #$rootScope.isMobile = true
  $rootScope.isPhone = $appBrowser.isPhone()

  $rootScope.currentPath = ->
    $location.path()

  $rootScope.setModal = (url) ->
    $rootScope.modal = url

  $rootScope.closeModal = () ->
    $('#modal').modal("hide")

  $rootScope.signOut = ->
    $.removeCookie(AuthToken)
    window.location = "#/sign_in"
    window.location.reload(true)

  $rootScope.TRIP_TYPES = [
    "One way",
    "Round trip",
    "Over the road"
  ]

  $rootScope.PAYMENT_METHODS = [
    "Visa",
    "MasterCard",
    "Discover",
    "American Express",
    "Check/Money Order",
    "Company Check",
    "Bank/Wire Transfer",
    "Invoice",
    "Paypal"
  ]

  $rootScope.VEHICLE_TYPES = [
    "Sedan",
    "Limo",
    "Party Bus",
    "Limo Bus",
    "Mini Bus",
    "Motorcoach",
    "Double Decker Motorcoach",
    "Executive Coach",
    "Sleeper Bus",
    "School Bus"
  ]

  $rootScope.NOTIFICATION_TYPES = [
    {name: "Opportunity Post", type: "email", code: "opportunity-new" },
    {name: "Opportunity Expired", type: "email", code: "opportunity-expire" },
    {name: "Opportunity Win", type: "email", code: "opportunity-win" },
    {name: "New Bid", type: "email", code: "bid-new" },
    {name: "Update Product", type: "email", code: "account-update-product" },
    {name: "Account Locked", type: "email", code: "account-locked" },
    {name: "Expired Card", type: "email", code: "account-expired-card" },
    {name: "Opportunity Post", type: "mobile", code: "mobile-opportunity-new" }
  ]

  $rootScope.ALL_REGIONS = {
    "Alabama":"AL",
    "Alaska":"AK",
    "Arizona":"AZ",
    "Arkansas":"AR",
    "California":"CA",
    "Colorado":"CO",
    "Connecticut":"CT",
    "Delaware":"DE",
    "District of Columbia":"DC",
    "Florida":"FL",
    "Georgia":"GA",
    "Hawaii":"HI",
    "Idaho":"ID",
    "Illinois":"IL",
    "Indiana":"IN",
    "Iowa":"IA",
    "Kansas":"KS",
    "Kentucky":"KY",
    "Louisiana":"LA",
    "Maine":"ME",
    "Maryland":"MD",
    "Massachusetts":"MA",
    "Michigan":"MI",
    "Minnesota":"MN",
    "Missouri":"MO",
    "Mississippi":"MS",
    "Montana":"MT",
    "Nebraska":"NE",
    "Nevada":"NV",
    "New Hampshire":"NH",
    "New Jersey":"NJ",
    "New Mexico":"NM",
    "New York":"NY",
    "North Carolina":"NC",
    "North Dakota":"ND",
    "Ohio":"OH",
    "Oklahoma":"OK",
    "Oregon":"OR",
    "Pennsylvania":"PA",
    "Rhode Island":"RI",
    "South Carolina":"SC",
    "South Dakota":"SD",
    "Tennessee":"TN",
    "Texas":"TX",
    "Utah":"UT",
    "Vermont":"VT",
    "Virginia":"VA",
    "Washington":"WA",
    "West Virginia":"WV",
    "Wisconsin":"WI",
    "Wyoming":"WY"
  }

  REGION_NAMES = (p for p of $rootScope.ALL_REGIONS)
  $rootScope.allRegions = REGION_NAMES.slice(0)

  $rootScope.setupFileUploader = ->
    $fileUploader = $("input.cloudinary-fileupload[type=file]")
    return unless $fileUploader.length > 0

    $fileUploader.hide()
    FileUploaderSignature.get {}, (data) ->
      $fileProgressBar = $('#progress .bar')
      $fileUploader.attr('data-form-data', JSON.stringify(data))
      $fileUploader.show()
      $fileUploader.cloudinary_fileupload
        progress: (e, data) ->
          progress = parseInt(data.loaded / data.total * 100, 10)
          $fileProgressBar.css 'width', progress + '%'

      previewUrl = (data) ->
        $.cloudinary.url data.result.public_id,
          format: data.result.format,
      setImageUpload = (data) ->
        $("form .image-preview").attr('src', previewUrl(data)).show()
        $("form .file-upload-public-id").val(data.result.public_id)

      progressImageUpload = (element, progressing) ->
        $('form btn-primary').prop('disabled', !progressing)
        $fileProgressBar.toggle(progressing)
        $(element).toggle(!progressing)

      $fileUploader.off 'fileuploadstart'
      $fileUploader.on 'fileuploadstart', (e, data) ->
        progressImageUpload(this, true)

      $fileUploader.off 'cloudinarydone'
      $fileUploader.on 'cloudinarydone', (e, data) ->
        progressImageUpload(this, false)
        if data.result.resource_type isnt "image"
          alert("Sorry, only images are supported.")
        else
          setImageUpload(data)

  $rootScope.displaySettings = (selectedTab = "user-login")->
    $rootScope.selectedTab = selectedTab
    $rootScope.setModal(suboutPartialPath('settings.html'))
    $rootScope.setupFileUploader()

  $rootScope.displayNewBidForm = (opportunity) ->
    unless $rootScope.company.dot_number
      $rootScope.setModal(suboutPartialPath('dot-required.html'))
      return
    if $rootScope.company.payment_state is 'failure'
      $rootScope.setModal(suboutPartialPath('update-credit-card.html'))
      return
    if opportunity.ada_required and !$rootScope.company.has_ada_vehicles
      $rootScope.setModal(suboutPartialPath('ada-required.html'))
      return
    $rootScope.bid = {
      amount: Opportunity.defaultBidAmountFor(opportunity)
    }
    $rootScope.setOpportunity(opportunity)
    $rootScope.setModal(suboutPartialPath('bid-new.html'))
    $rootScope.$broadcast('modalOpened')

  $rootScope.displayNewOpportunityForm = ->
    $rootScope.setModal(suboutPartialPath('opportunity-form.html'))
    $rootScope.setupFileUploader()

  $rootScope.displayNewFavoriteForm = () ->
    $rootScope.$broadcast('clearNewFavoriteForm')
    $rootScope.setModal(suboutPartialPath('add-new-favorite.html'))

  $rootScope.setOpportunity = (opportunity) ->
    $rootScope.opportunity = Opportunity.get
      api_token: $rootScope.token.api_token
      opportunityId: opportunity._id

  $rootScope.cloneOpportunity = (opportunity) ->
    $rootScope.opportunity = angular.copy(opportunity)
    for property in ["_id", "start_date", "start_time", "end_date", "end_time", "tracking_id"]
      delete $rootScope.opportunity[property]
    $rootScope.opportunity.clone = true


  $rootScope.displayRating = (rating)->
    alert("Not implemented yet, I think that it should display popup with rating details.")

  $rootScope.addToFavorites = (company) ->
    $rootScope.notice = null
    Favorite.save(
      {
        supplier_id: company._id,
        api_token: $rootScope.token.api_token
      },
      {},
      () ->
        company.favoriting_buyer_ids ||= []
        company.favoriting_buyer_ids.push $rootScope.company._id

        $rootScope.notice = "Successfully added to favorites."
        $timeout ->
          $rootScope.notice = null
          $("#modal").modal "hide"
        , 2000
      )
  $rootScope.displayCompanyProfile = (company_id) ->
    Company.get
      api_token: $rootScope.token.api_token
      companyId: company_id
    ,(company)->
      $rootScope.other_company = company
      $rootScope.setModal(suboutPartialPath('company-profile.html'))

  $rootScope.dateOptions = {dateFormat: 'mm/dd/yy'}
  $rootScope.errorMessages = (errors) ->
    result = []
    $.each errors, (key, errors) ->
      field = _.str.humanize(key)
      $.each errors, (i, error) ->
        if key is "base"
          result.push _.str.humanize(error)
        else
          result.push "#{field} #{error}"
    result

  $rootScope.alertError = (errors) ->
    errorMessages = $rootScope.errorMessages(errors)
    $alertError = $("<div class='alert alert-error'></div>")
    close = '<a class="close" data-dismiss="alert" href="#">&times;</a>'
    $alertError.append close
    for errorMessage in errorMessages
      $alertError.append "<p>#{errorMessage}</p>"
    $alertError

  $rootScope.alertInfo = (messages) ->
    $alertInfo = $("<div class='alert alert-info'></div>")
    close = '<a class="close" data-dismiss="alert" href="#">&times;</a>'
    $alertInfo.append close
    for info in messages
      $alertInfo.append "<p>#{info}</p>"
    $alertInfo

  $rootScope.winOpportunityNow = (opportunity) ->
    unless $rootScope.company.dot_number
      $rootScope.setModal(suboutPartialPath('dot-required.html'))
      $("#modal").modal("show")
      return
    return unless confirm("Win it now price is $#{$numberFormatter.format(opportunity.win_it_now_price, 2)}. Do you want to proceed?")
    bid = {amount: opportunity.win_it_now_price}
    Bid.save
      bid: bid
      api_token: $rootScope.token.api_token
      opportunityId: opportunity._id
    , ->
      jQuery("#modal").modal "hide"
    , (content) ->
      alert("An error occured on your bid!\n" + $rootScope.errorMessages(content.data.errors).join("\n"))
)

WelcomePrelaunchCtrl = (AuthToken) ->
  $.removeCookie(AuthToken)

OpportunityFormCtrl = ($scope, $rootScope, $location, Auction) ->
  $scope.types = [
    "Vehicle Needed",
    "Vehicle for Hire",
    "Special",
    "Emergency",
    "Buy or Sell Parts and Vehicles"
  ]

  successUpdate = ->
    if $rootScope.isMobile
      $location.path('/dashboard')
    else
      jQuery("#modal").modal "hide"

  $scope.save = ->
    opportunity = $scope.opportunity
    opportunity.bidding_ends = $('#opportunity_ends').val()
    opportunity.start_date = $('#opportunity_start_date').val()
    opportunity.end_date = $('#opportunity_end_date').val()
    opportunity.image_id = $('#opportunity_image_id').val()
    # ui-mask removes colon(:)
    opportunity.start_time = $("#opportunity_start_time").val()
    opportunity.end_time = $("#opportunity_end_time").val()

    showErrors = (errors) ->
     
      if $rootScope.isMobile
        alert $rootScope.errorMessages(errors).join('\n')
      else
        $alertError = $rootScope.alertError(errors)
        $("#modal form .alert-error").remove()
        $("#modal form").append($alertError)
        $("#modal .modal-body").scrollTop($("#modal form").height())

    if opportunity._id
      Auction.update
        opportunityId: opportunity._id
        opportunity: opportunity
        api_token: $rootScope.token.api_token
      , (data) ->
        $rootScope.$emit('refreshOpportunity', opportunity)
        successUpdate()
      , (content) ->
        showErrors(content.data.errors)
    else
      Auction.save
        opportunity: opportunity
        api_token: $rootScope.token.api_token
      , (data) ->
        successUpdate()
      , (content) ->
        showErrors(content.data.errors)

  $scope.setOpportunityForwardAuction = ->
    type = $scope.opportunity.type
    if type is "Vehicle Needed"
      $scope.opportunity.forward_auction = false
    else if type is "Vehicle for Hire"
      $scope.opportunity.forward_auction = true

BidNewCtrl = ($scope, $rootScope, Bid) ->
  $scope.hideAlert = ->
    $scope.errors = null

  $scope.$on 'modalOpened', ->
    $scope.hideAlert()

  $scope.validateReserveAmount = (value) ->
    return true if isNaN(value)
    value = parseFloat(value)
    if $scope.opportunity.reserve_amount
      if $scope.opportunity.forward_auction
        $scope.opportunity.reserve_amount <= value
      else
        $scope.opportunity.reserve_amount >= value
    else
      true

  $scope.validateAutoBiddingLimit = (value) ->
    return true if isNaN(value)
    value = parseFloat(value)
    if $scope.bid.amount
      if $scope.opportunity.forward_auction
        $scope.bid.amount <= value
      else
        $scope.bid.amount >= value
    else
      true

  $scope.validateWinItNowPrice = (value) ->
    return true if isNaN(value)
    value = parseFloat(value)
    if $scope.opportunity.win_it_now_price
      if $scope.opportunity.forward_auction
        $scope.opportunity.win_it_now_price > value
      else
        $scope.opportunity.win_it_now_price < value
    else
      true

  $scope.save = ->
    Bid.save
      bid: $scope.bid
      api_token: $rootScope.token.api_token
      opportunityId: $rootScope.opportunity._id
    , (data) ->
      $rootScope.company.today_bids_count += 1
      jQuery("#modal").modal "hide"
    , (content) ->
      $scope.errors = $rootScope.errorMessages(content.data.errors)

MyBidCtrl = ($scope, $rootScope, MyBid, $location, soPagination) ->
  $scope.my_bids = []
  $scope.pages = []
  $scope.startPage = 1
  $scope.page = $location.search().page || 1
  $scope.endPage = 1
  $scope.maxPage = 1

  
  $scope.setPage = (page) ->
    soPagination.setPage($scope, page)

  $scope.loadMoreBids = (page = 1) ->
    soPagination.paginate($scope, MyBid, page, {}, (scope, data) -> { results: data.bids } )


  $scope.loadMoreBids($scope.page)

FavoritesCtrl = ($scope, $rootScope, Favorite) ->
  $scope.favoriteCompanies = Favorite.query(api_token: $rootScope.token.api_token)

  $scope.removeFavorite = (company) ->
    Favorite.delete
      api_token: $rootScope.token.api_token
      favoriteId: company._id
      ->
        index = _.indexOf($scope.favoriteCompanies, company)
        $scope.favoriteCompanies.splice(index, 1)


NewFavoriteCtrl = ($scope, $rootScope, $route, $location, Favorite, Company, FavoriteInvitation, soValidateEmail) ->
  $scope.companyNotFound = false
  $scope.showInvitation = false
  $scope.foundCompanies = []
  $scope.invitation = {}

  successUpdate = ->
    if $rootScope.isMobile
      $location.path('/favorites')
    else
      $rootScope.closeModal()

  $scope.addToFavorites = (company) ->
    Favorite.save(
      {
        supplier_id: company._id,
        api_token: $rootScope.token.api_token
      },
      {},
      ->
        $route.reload()
        successUpdate()
    )

  $scope.findSupplier = ->
    if $scope.supplierQuery == $rootScope.company.email
      return true
    $scope.foundCompanies = Company.search(
      {
        query: $scope.supplierQuery
        api_token: $rootScope.token.api_token
        action: "search"
      },
      (companies) ->
        companies = _.reject(companies, (c)->
          return c._id == $rootScope.company._id
        )

        $scope.companyNotFound = companies.length is 0
        if $scope.companyNotFound
          $scope.showInvitation = true
          $scope.invitation.supplier_email = $scope.supplierQuery
          $scope.invitation.message = "#{$rootScope.company.name} would like to add you as a favorite supplier on SubOut."
        else
          $scope.showInvitation = false
    )

    #$scope.showInvitationForm = ->
      #$scope.showInvitation = true
      #$scope.invitation.supplier_email = $scope.supplierQuery
      #$scope.invitation.message = "#{$rootScope.company.name} would like to add you as a favorite supplier on SubOut."

    $scope.sendInvitation = ->
      FavoriteInvitation.save
        favorite_invitation: $scope.invitation
        api_token: $rootScope.token.api_token
      , ->
        successUpdate()

AvailableOpportunityCtrl = ($scope, $rootScope, $location, Opportunity, $filter, soPagination) ->
  $scope.filterDepatureDate = null
  $scope.opportunities = []
  $scope.pages = []
  $scope.page = $location.search().page || 1
  $scope.endPage = 1
  $scope.maxPage = 1
  $scope.filterVehicleType = null
  $scope.filterTripType = null
  $scope.filterRegions = $rootScope.filterRegionsOnBuybid
  $scope.sortItems = [
    {
      value: "created_at,asc"
      label: "Created (ascending)"
    },
    {
      value: "created_at,desc"
      label: "Created (descending)"
    },
    {
      value: "bidding_ends_at,asc"
      label: "Ends (ascending)"
    },
    {
      value: "bidding_ends_at,desc"
      label: "Ends (descending)"
    }
  ]

  $rootScope.$watch "company.regions.length", ()->
    $scope.filterRegions = angular.copy($rootScope.company.regions)

  availableToCurrentCompany = (opportunity) ->
    opportunity.buyer_id != $rootScope.company._id

  $rootScope.channel.bind 'event_created', (event) ->
    affectedOpp = _.find $scope.paginated_results, (opportunity) ->
      opportunity._id is event.eventable._id

    if availableToCurrentCompany(event.eventable)
      if affectedOpp and event.eventable.status is 'In progress'
        Opportunity.get
          api_token: $rootScope.token.api_token
          opportunityId: event.eventable._id
        , (opportunity) ->
          $scope.paginated_results[$scope.paginated_results.indexOf(affectedOpp)] = opportunity
      else
        # opportunity is ended or canceled
        $scope.reloadOpportunities()
    else if affectedOpp
      # the region of the opprotunity is changed to unsubscribed region
      $scope.reloadOpportunities()

  $scope.loadMoreOpportunities = (page = 1) ->
    soPagination.paginate($scope, Opportunity, page,
      {
        sort_by: $scope.sortBy
        sort_direction: $scope.sortDirection
        start_date: $filter('date')($scope.filterDepatureDate, "yyyy-MM-dd")
        vehicle_type: $scope.filterVehicleType
        trip_type: $scope.filterTripType
        regions: $scope.filterRegions
      },
      (scope, data) -> { results: data.opportunities } )

  $scope.setPage = (page) ->
    soPagination.setPage($scope, page)

  $scope.reloadOpportunities = ->
    $scope.loadMoreOpportunities($scope.page)

  $scope.sortOpportunities = (sortBy) ->
    if $scope.sortBy == sortBy
      if $scope.sortDirection == "asc" then $scope.sortDirection = "desc" else $scope.sortDirection = "asc"
    else
      $scope.sortDirection = "asc"
      $scope.sortBy = sortBy
    $scope.reloadOpportunities()

  $scope.sortMobileOpportunity = ->
    sortOptions = $scope.sortOption.split(",")
    $scope.sortBy = sortOptions[0]
    $scope.sortDirection = sortOptions[1]
    $scope.reloadOpportunities()

  $scope.dateOptions = {dateFormat: 'mm/dd/yy'}

  $scope.sortOpportunities('bidding_ends_at')

  $scope.$watch "filterDepatureDate",(oldValue, newValue) ->
    if(oldValue != newValue)
      $scope.loadMoreOpportunities(1)
  $scope.$watch "filterVehicleType", (oldValue, newValue) ->
    if(oldValue != newValue)
      $scope.loadMoreOpportunities(1)
  $scope.$watch "filterTripType", (oldValue, newValue) ->
    if(oldValue != newValue)
      $scope.loadMoreOpportunities(1)
  $scope.$watch "filterRegions", (oldValue, newValue) ->
    if(oldValue != newValue)
      $rootScope.filterRegionsOnBuybid = $scope.filterRegions
      $scope.loadMoreOpportunities(1)

OpportunityCtrl = ($scope, $rootScope, $location, Auction, soPagination) ->
  $scope.opportunities = []
  $scope.pages = []
  $scope.startPage = 1
  $scope.page = $location.search().page || 1
  $scope.sortBy = $location.search().sort_by || "created_at"
  $scope.sortDirection = $location.search().sort_direction || "desc"
  $scope.query = $location.search().query
  $scope.endPage = 1
  $scope.maxPage = 1

  #filterWithQuery = (value) ->
    #reg = new RegExp($scope.opportunityQuery.toLowerCase())
    #return true if value and reg.test(value.toLowerCase())

  #$scope.opportunityFilter = (item) ->
    #return true unless $scope.opportunityQuery
    #return true if filterWithQuery(item.reference_number)
    #return true if filterWithQuery(item.type)
    #return true if filterWithQuery(item.name)
    #return true if filterWithQuery(item.description)
    #return true if item.winner and filterWithQuery(item.winner.name)
    #false

  $scope.fullTextSearch = (event) ->
    if $scope.query and $scope.query isnt ""
      query = $scope.query
    else
      query = null
    $location.search(page: 1, sort_by: $scope.sortBy, sort_direction: $scope.sortDirection, query: query)

  $scope.loadMoreOpportunities = (page = 1) ->
    soPagination.paginate($scope, Auction, page,
      {
        sort_by: $scope.sortBy
        sort_direction: $scope.sortDirection
        query: $scope.query
      },
      (scope, data) -> { results: data.opportunities } )

  $scope.setPage = (page) ->
    soPagination.setPage($scope, page)

  $scope.sortOpportunities = (sortBy) ->
    if $scope.sortBy == sortBy
      if $scope.sortDirection == "asc" then $scope.sortDirection = "desc" else $scope.sortDirection = "asc"
    else
      $scope.sortDirection = "desc"
      $scope.sortBy = sortBy
    $location.search(page: 1, sort_by: $scope.sortBy, sort_direction: $scope.sortDirection, query: $scope.query)

  $scope.loadMoreOpportunities($scope.page)

OpportunityDetailCtrl = ($rootScope, $scope, $routeParams, $location, $timeout, Bid, Auction, Opportunity, Comment, MyBid) ->
  fiveMinutes = 5 * 60 * 1000
  updateFiveMinutesAgo = ->
    $scope.fiveMinutesAgo = new Date().getTime() - fiveMinutes
    $timeout updateFiveMinutesAgo, 5000
  updateFiveMinutesAgo()

  reloadOpportunity = ->
    $scope.opportunity = Opportunity.get
      api_token: $rootScope.token.api_token
      opportunityId: $routeParams.opportunity_reference_number
    , (content) ->
      # success
      true
    , (content) ->
      alert("Record not found")
      $location.path("/dashboard")

  reloadOpportunity()

  $rootScope.channel.bind 'event_created', (event) ->
    reloadOpportunity() if event.eventable._id is $scope.opportunity._id

  $rootScope.$on 'refreshOpportunity', (e, _opportunity) ->
    $scope.opportunity = _opportunity

  $scope.hideAlert = ->
    $scope.errors = null

  $scope.cancelOpportunity = ->
    return unless confirm("Are you sure to cancel your opportunity?")
    Auction.cancel(
      {
        opportunityId: $scope.opportunity._id,
        action: 'cancel',
        api_token: $rootScope.token.api_token
      }
      , {}
      , (content) ->
        $location.path "dashboard"
      , (content) ->
        $scope.errors = $rootScope.errorMessages(content.data.errors)
    )

  $scope.selectWinner = (bid) ->
    Auction.select_winner(
      {
        opportunityId: $scope.opportunity._id,
        action: 'select_winner',
        bid_id: bid._id,
        api_token: $rootScope.token.api_token
      }
      , {}
      , (content) ->
        reloadOpportunity()
      , (content) ->
        $scope.errors = $rootScope.errorMessages(content.data.errors)
    )

  $scope.hideAlert = ->
    $scope.errors = null

  $scope.addComment = ->
    $scope.hideAlert()
    Comment.save
      comment: $scope.comment
      api_token: $rootScope.token.api_token
      opportunityId: $scope.opportunity._id
    , (content) ->
      $scope.hideAlert()
      $scope.opportunity.comments.push(content)
      $scope.comment.body = ""
    , (content) ->
      $scope.errors = $rootScope.errorMessages(content.data.errors)

  $scope.cancelBid = (bid) ->
    return unless confirm("Are you sure to cancel your bid?")
    MyBid.cancel(
      {
        bidId: bid._id
        action: 'cancel',
        api_token: $rootScope.token.api_token
      }
      , (content) ->
        reloadOpportunity()
      , (content) ->
        alert($rootScope.errorMessages(content.data.errors).join("\n"))
    )

DashboardCtrl = ($scope, $rootScope, $location, Company, Event, Filter, Tag, Bid, Favorite, Opportunity, $filter) ->
  $scope.$location = $location
  $scope.filters = Filter.query(api_token: $rootScope.token.api_token)
  $scope.query = $location.search().q
  $scope.filter = null
  $scope.opportunity = null
  $scope.events = []
  $scope.regionFilterOptions = $rootScope.allRegions
  $scope.filterRegions = $rootScope.filterRegionsOnHome

  Company.query
    api_token: $rootScope.token.api_token
  , (data) ->
    $scope.companies = data

  $scope.loadMoreEvents = ->
    return if $scope.noMoreEvents or $scope.loading

    $scope.loading = true

    queryOptions = angular.copy($location.search())
    queryOptions.api_token = $rootScope.token.api_token
    queryOptions.regions = $scope.filterRegions

    queryOptions.page = $scope.currentPage

    Event.query queryOptions
    , (data) ->
      if data.length is 0
        $scope.noMoreEvents = true
        $scope.loading = false
      else
        angular.forEach data, (event) ->
          $scope.events.push(event)
        $scope.loading = false
        $scope.currentPage += 1

  $scope.refreshEvents = (callback) ->
    $scope.events = []
    $scope.currentPage = 1
    $scope.noMoreEvents = false
    $scope.loadMoreEvents()
    if callback
      callback()

  updatePreviousEvents = (event) ->
    opportunity = event.eventable
    _.each $scope.events, (prevEvent) ->
      prevOpportunity = prevEvent.eventable
      if prevOpportunity._id is opportunity._id
        prevOpportunity.canceled = opportunity.canceled
        prevOpportunity.bidable = opportunity.bidable

  $scope.refreshEvents ->
    if($rootScope.channel)
      $rootScope.channel.bind 'event_created', (event) ->
        if $rootScope.company.canSeeEvent(event) and $scope.matchFilters(event)
          $scope.events.unshift event
          updatePreviousEvents(event)
          $scope.$apply()

  $scope.matchFilters = (event) ->
    return $scope.filterEventType(event) and
    $scope.filterRegion(event) and
    $scope.filterOpportunityType(event) and
    $scope.filterFullText(event) and
    $scope.filterCompany(event)

  $scope.filterEventType = (event) ->
    event_type = $location.search().event_type
    return true unless event_type
    event.action.type is event_type

  $scope.filterRegion = (event) ->
    region = $location.search().region
    return true unless region
    region in event.regions

  $scope.filterOpportunityType = (event) ->
    opportunity_type = $location.search().opportunity_type
    return true unless opportunity_type
    event.eventable.type is opportunity_type

  $scope.filterFullText = (event) ->
    query = $location.search().q
    return true unless query

    eventable = event.eventable

    if query.indexOf("#") is 0
      "##{eventable.reference_number}" is query
    else
      reg = new RegExp(query)
      text = (eventable.name + ' ' + eventable.description).toLowerCase()
      reg.test(text)

  $scope.filterCompany = (event) ->
    actor_id = $location.search().company_id
    return true unless actor_id
    event.actor._id is actor_id

  setRegionFilter = ->
    regions = angular.copy($scope.filterRegions)
    if ($scope.regionFilter)
      regions.push $scope.regionFilter
      $scope.filterRegions = regions
      

  getRegionFilterOptions = ->
    _.difference($rootScope.allRegions, $scope.filterRegions)

  $scope.$watch "filterRegions", ()->
    $rootScope.filterRegionsOnHome = angular.copy($scope.filterRegions)
    $scope.regionFilterOptions = getRegionFilterOptions()
    $scope.refreshEvents()

  $scope.regionFilter = $location.search().region
  $scope.$watch "regionFilter", setRegionFilter

  $scope.setOpportunityTypeFilter = (opportunity_type) ->
    if $location.search().opportunity_type == opportunity_type
      $location.search('opportunity_type', null)
    else
      $location.search('opportunity_type', opportunity_type)
    $scope.refreshEvents()

  $scope.setEventType = (eventType) ->
    if $location.search().event_type == eventType
      $location.search('event_type', null)
    else
      $location.search('event_type', eventType)
    $scope.refreshEvents()

  $scope.eventTypeLabel = (eventType) ->
    if eventType == "opportunity_created"
      "Created"
    else if eventType == "bid_created"
      "New Bid"
    else if eventType == "opportunity_bidding_won"
      "Bidding Won"
    else if eventType == "opportunity_canceled"
      "Canceled"
    else
      "Unknown"

  $scope.companyName = (companyId) ->
    company = _.find($scope.companies, (company) -> company._id == companyId)
    if company then _.str.trim(company.abbreviated_name) else companyId

  $scope.actionDescription = (action) ->
    switch action.type
      when "bid_created"
        "received bid #{$filter('soCurrency')(action.details.amount)}"
      when "bid_canceled"
        "received bid cancelation #{$filter('soCurrency')(action.details.amount)}"
      else
        "#{action.type.split('_').pop()}"

  $scope.toggleEvent = (event) ->
    event.selected = !event.selected
    if event.selected and event.eventable._id
      event.eventable = Opportunity.get
        api_token: $rootScope.token.api_token
        opportunityId: event.eventable._id
      , ->
        setTimeout (-> $(".relative_time").timeago()), 1

  $scope.fullTextSearch = (event) ->
    if $scope.query and $scope.query isnt ""
      query = $scope.query
    else
      query = null
    $location.search('q', query)
    $scope.refreshEvents()

  $scope.refNumSearch = (ref_num) ->
    $scope.query = '#' + ref_num
    $scope.fullTextSearch()

  $scope.hasAnyFilter = ->
    return true if $scope.filterRegions.length > 0
    not _.isEmpty($location.search())

  $scope.filterValue = if $rootScope.isMobile then '' else null

  $scope.clearFilters = ->
    $scope.query = ""
    $scope.regionFilter = $scope.filterValue
    $scope.filterRegions = []
    $location.search({})
    $scope.refreshEvents()
  
  $scope.clearRegionFilter = ->
    $rootScope.company.regions = []

  $scope.removeRegionFilter = (region)->
    $scope.filterRegions = _.reject($scope.filterRegions, (item) -> region is item)

  $rootScope.$watch ()->
    return $location.absUrl()
  ,(newPath, oldPath)->
    $scope.query = $location.search().q
    $scope.refreshEvents()

SettingCtrl = ($scope, $rootScope, $location, Token, Company, User, Product, GatewaySubscription, $config) ->
  $scope.userProfile = angular.copy($rootScope.user)
  $scope.companyProfile = angular.copy($rootScope.company)

  $scope.suboutBasicSubscriptionUrl = $config.suboutBasicSubscriptionUrl()
  $scope.suboutProSubscriptionUrl = $config.suboutProSubscriptionUrl()
  $scope.subscription = null
  $scope.additional_price = 0

  $rootScope.selectedTab = "user-login" unless $rootScope.selectedTab
  token = $rootScope.token
  
  updateAdditionalPrice = ()->
    if $scope.companyProfile.vehicles.length > 2
      $scope.additional_price = ($scope.companyProfile.vehicles.length - 2) * 49.99 * 100
    else
      $scope.additional_price = 0

  updateSelectedRegions = ->
    $scope.companyProfile.regions ||= []
    $scope.companyProfile.allRegions = {}
    for region in $rootScope.allRegions
      $scope.companyProfile.allRegions[region] = region in $scope.companyProfile.regions
  updateSelectedRegions()

  updateSelectedNotifications = ->
    for t in $rootScope.NOTIFICATION_TYPES
      t.enabled = true if $rootScope.company.hasNotificationItem(t.code)
  updateSelectedNotifications()

  $scope.setNotification = (t)->
    t.enabled = !t.enabled
    
  updateCompanyAndCompanyProfile = (company) ->
    $rootScope.company = company
    $scope.companyProfile = angular.copy(company)
    updateSelectedRegions()

  Product.get
    productHandle: 'subout-basic-service'
    api_token: $rootScope.token.api_token
    (data) ->
      $scope.subout_basic_product = data.product

  Product.get
    productHandle: 'subout-pro-service'
    api_token: $rootScope.token.api_token
    (data) ->
      $scope.subout_pro_product = data.product
      updateAdditionalPrice()

  GatewaySubscription.get
    subscriptionId: $rootScope.company.subscription_id
    api_token: $rootScope.token.api_token
    (subscription) ->
      $scope.subscription = subscription
    (error) ->
      $scope.subscription = null

  $rootScope.setupFileUploader()

  successUpdate = ->
    if $rootScope.isMobile
      $location.path('/dashboard')
    else
      $rootScope.closeModal()

  $scope.saveUserProfile = ->
    $scope.userProfileError = ""

    if $scope.userProfile.password is $scope.userProfile.password_confirmation
      User.update
        userId: $rootScope.user._id
        user: $scope.userProfile
        api_token: $rootScope.token.api_token
        (user) ->
          $scope.userProfile.password = ''
          $scope.userProfile.current_password = ''
          $rootScope.user = $scope.userProfile
          successUpdate()
        (error) ->
          $scope.userProfileError = "Invalid password or email!"
    else
      $scope.userProfileError =
        "The new password and password confirmation are not identical."

  
  $scope.saveFavoritedRegions = ->
    finalRegions = []

    for region, isEnabled of $scope.companyProfile.allRegions
      finalRegions.push(region) if !!isEnabled
    $scope.companyProfile.regions = finalRegions
    Company.update_regions
      companyId: $rootScope.company._id
      company: $scope.companyProfile
      api_token: $rootScope.token.api_token
      action: "update_regions"
      (company) ->
        updateCompanyAndCompanyProfile(company)
        successUpdate()
      (error) ->
        $scope.companyProfileError = "Sorry, invalid inputs. Please try again."

  $scope.saveCompanyProfile = ->
    $scope.companyProfileError = ""

    $scope.companyProfile.logo_id = $("#company_logo_id").val()

    finalNotifications = []
    for t in $rootScope.NOTIFICATION_TYPES
      finalNotifications.push(t.code) if t.enabled
    $scope.companyProfile.notification_items = finalNotifications

    Company.update
      companyId: $rootScope.company._id
      company: $scope.companyProfile
      api_token: $rootScope.token.api_token
      (company) ->
        updateCompanyAndCompanyProfile(company)
        successUpdate()
      (error) ->
        $scope.companyProfileError = "Sorry, invalid inputs. Please try again."

  $scope.updateProduct = (product) ->
    return unless confirm("Are you sure?")

    Company.update_product
      companyId: $rootScope.company._id
      product: product
      api_token: $rootScope.token.api_token
      action: "update_product"
      (company) ->
        updateCompanyAndCompanyProfile(company)
        successUpdate()
      (error) ->
        $scope.companyProfileError = "Sorry, invalid inputs. Please try again."

  vehicleTypeOptions = ->
    _.difference($scope.VEHICLE_TYPES, $scope.companyProfile.vehicle_types)

  $scope.vehicleTypeOptions = vehicleTypeOptions()

  $scope.addVehicleType = ->
    $scope.companyProfile.vehicle_types ||= []
    $scope.companyProfile.vehicle_types.push($scope.newVehicleType)
    $scope.newVehicleType = ""
    $scope.vehicleTypeOptions = vehicleTypeOptions()

  $scope.saveVehicles = ->
    Company.update_vehicles
      companyId: $rootScope.company._id
      company: $scope.companyProfile
      api_token: $rootScope.token.api_token
      action: "update_vehicles"
      (company) ->
        updateCompanyAndCompanyProfile(company)
        successUpdate()
      (error) ->
        $scope.companyProfileError = "Sorry, invalid inputs. Please try again."


  $scope.addVehicle = (vehicle)->
    $scope.companyProfile.vehicles.push(vehicle)
    updateAdditionalPrice()

  $scope.removeVehicle = (vehicle) ->
    $scope.companyProfile.vehicles = _.reject($scope.companyProfile.vehicles, (item) -> vehicle is item)
    updateAdditionalPrice()

  $scope.removeVehicleType = (vehicle_type) ->
    $scope.companyProfile.vehicle_types = _.reject($scope.companyProfile.vehicle_types, (item) -> vehicle_type is item)
    $scope.vehicleTypeOptions = vehicleTypeOptions()

  paymentMethodOptions = ->
    _.difference($scope.PAYMENT_METHODS, $scope.companyProfile.payment_methods)

  $scope.paymentMethodOptions = paymentMethodOptions()

  $scope.addPaymentMethod = ->
    $scope.companyProfile.payment_methods ||= []
    $scope.companyProfile.payment_methods.push($scope.newPaymentMethod)
    $scope.newPaymentMethod = ""
    $scope.paymentMethodOptions = paymentMethodOptions()

  $scope.removePaymentMethod = (payment_method) ->
    $scope.companyProfile.payment_methods = _.reject($scope.companyProfile.payment_methods, (item) -> payment_method is item)
    $scope.paymentMethodOptions = paymentMethodOptions()

SignInCtrl = ($scope, $rootScope, $location,
  Token, Company, User, AuthToken, Authorize, Setting) ->
  $.removeCookie(AuthToken)
  $scope.marketing_message = Setting.get
    key: "marketing_message"

  $scope.signIn = ->
    Token.save {email: $scope.email, password: $scope.password}, (token) ->
      if token.authorized
        promise = Authorize.authenticate(token)
        promise.then ->
          if $rootScope.redirectToPath
            $location.path($rootScope.redirectToPath)
          else
            $location.path "dashboard"
      else
        $scope.message = token.message

NewPasswordCtrl = ($scope, $rootScope, $location, $timeout,
  Password, AuthToken) ->
  $.removeCookie(AuthToken)

  $scope.hideAlert = ->
    $scope.notice = null
    $scope.errors = null

  $scope.requestResetPassword = ->
    $scope.hideAlert()

    Password.save {user: $scope.user}
    , ->
      $scope.user.email = null
      $scope.notice = "You will receive an email with instructions" +
        " about how to reset your password in a few minutes."
      $timeout ->
        $scope.notice = null
      , 2000
    , (content) ->
      $scope.errors = $rootScope.errorMessages(content.data.errors)

SignUpCtrl = ($scope, $rootScope, $routeParams, $location,
  Token, Company, FavoriteInvitation, GatewaySubscription, AuthToken, Authorize) ->
  $.removeCookie(AuthToken)

  $scope.company = {}
  $scope.user = {}

  $rootScope.setupFileUploader()

  if $routeParams.invitation_id
    FavoriteInvitation.get
      invitationId: $routeParams.invitation_id
    , (invitation) ->
      $scope.user.email = invitation.supplier_email
      $scope.company.email = invitation.supplier_email
      $scope.company.name = invitation.supplier_name
      $scope.company.created_from_invitation_id = invitation._id
    , ->
      $location.path("/sign_in").search({})
  else if $routeParams.subscription_id
    GatewaySubscription.get
      subscriptionId: $routeParams.subscription_id
    , (subscription) ->
      $scope.user.email = subscription.email
      $scope.company.email = subscription.email
      $scope.company.name = subscription.organization
      #$scope.company.gateway_subscription_id = subscription._id
      $scope.company.chargify_id = subscription.subscription_id
    , ->
      $location.path("/sign_in").search({})
  else if $routeParams.chargify_id
    $scope.company.chargify_id = $routeParams.chargify_id
  else
    $location.path("/sign_in")

  $scope.hideAlert = ->
    $scope.errors = null

  $scope.signUp = ->
    $scope.company.users_attributes = { "0": $scope.user }
    $scope.company.logo_id = $("#company_logo_id").val()

    Company.save
      company: $scope.company
    , ->
      $scope.errors = null
      Token.save { email: $scope.user.email, password: $scope.user.password }, (token) ->
        Authorize.authenticate(token).then ->
          $location.path("/dashboard").search({})
    , (content) ->
      $scope.errors = $rootScope.errorMessages(content.data.errors)
      $("body").scrollTop(0)

CompanyDetailCtrl = ($rootScope, $location, $routeParams, $scope, $timeout,  Favorite, Company, Rating) ->

  $scope.validateRate = (value) ->
    value != 0

  $scope.rating =
    communication: ""
    ease_of_payment: ""
    editable: false
    like_again: ""
    over_all_experience: ""
    punctuality: ""

  company_id = $routeParams.company_id
  $location.path("/dashboard") unless company_id

  $scope.detailed_company = Company.get
    api_token: $rootScope.token.api_token
    companyId: company_id
  ,(company)->
    $scope.rating = company.ratingFromCompany($rootScope.company)
  ,(error)->
    $location.path("/dashboard")

  $scope.updateRating = ->
    Rating.update
      ratingId: $scope.rating._id
      rating: $scope.rating
      api_token: $rootScope.token.api_token
    , (data) ->
      $location.search(reload: new Date().getTime())
    , (content) ->
      console.log "rating update failed"

CompanyProfileCtrl = ($rootScope, $location, $routeParams, $scope, $timeout,  Favorite, Company, Rating) ->
  return true

HelpCtrl = ()->
  return true
