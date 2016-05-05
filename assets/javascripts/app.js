// assets/javascripts/app.js

//= require_tree .

/* global moment, jQuery */
(function init($) {
  // define numeric risk level values for sorting
  var riskLevels = {
    Low: 0,
    Medium: 1,
    High: 2
  };

  // Format <time> elements
  $('.js-time-human-readable').each(function formatTime() {
    $(this).text(moment().calendar($(this).attr('datetime'), {
      sameDay: '[today at] LT',
      lastDay: '[yesterday at] LT',
      lastWeek: '[last] dddd [at] LT'
    }));
  });

  // Make tables sortable
  $('.js-table-sortable').stupidtable({
    // custom sort for data-sort="risk"
    risk: function sortRisk(a, b) {
      return riskLevels[a] - riskLevels[b];
    }
  });

  // Apply default sort to columns
  $('.js-default-sort').stupidsort();
}(jQuery));
