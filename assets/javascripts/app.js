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
    var time = $(this).attr('datetime');
    var displayText = moment(time).fromNow();
    $(this).text(displayText);
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
