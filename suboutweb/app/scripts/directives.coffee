subout.directive "relativeTime", ->
  link: (scope, element, iAttrs) ->
    variable = iAttrs["relativeTime"]
    scope.$watch variable, ->
      $(element).timeago() if $(element).attr('title') isnt ""

subout.directive "whenScrolled", ->
  (scope, element, attr) ->
    fn = ->
      if $(window).scrollTop() > $(document).height() - $(window).height() - 50
        scope.$apply(attr.whenScrolled)

    scope.$on('$routeChangeStart', ->
      fn = ->
      return null
    )

    $(window).scroll ->
      fn()

subout.directive "salesInfoMessages", ($rootScope) ->
  link: (scope, iElement, iAttrs) ->
    variable = iAttrs["salesInfoMessages"]
    scope.$watch variable, ->
      messages = scope[variable]
      if messages and messages.length > 0
        $rootScope.salesInfoMessageIdx = ($rootScope.salesInfoMessageIdx || 0) % messages.length
        iElement.text(messages[$rootScope.salesInfoMessageIdx])
        $rootScope.salesInfoMessageIdx += 1
