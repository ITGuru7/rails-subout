'use strict';


subout.directive('relativeTime', function() {
  return {
    link: function (scope, element, attr) {
      scope.$watch('event', function (val) {
        $(element).timeago();
      })}
  }
});
