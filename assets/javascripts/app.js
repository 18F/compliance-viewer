// assets/javascripts/app.js

//= require_tree .

(function($) {

  //Format <time> elements
  $('.js-time-human-readable').each(function (){
    $(this).text(moment().calendar($(this).attr('datetime'), {
      sameDay: '[today at] LT',
      lastDay: '[yesterday at] LT',
      lastWeek: '[last] dddd [at] LT'
    }));
  });

  //Make tables sortable
  $('.js-table-sortable').stupidtable();

})(jQuery);
