jQuery(document).ready(function($){

  $(".help_menu").on('click', 'a', function () {
    $("#terminal_help").slideToggle();
    return false;
  });

  $("#terminal_help").on('click', function () {
    $(this).slideToggle();
  });

});
