$(document).ready(function(){

  var scrollCallback = function () {
    var header = $('.header'),
        scrollTop = $(window).scrollTop();
        bodyColor = $('body').css('background-color');

    if (scrollTop > 0) {
      header.css('border-style', 'solid');
      header.css('border-color', $('.table-bordered').css('border-color'));
      header.css('border-width', '0px 0px 1px 0px');
      header.css('background-color', bodyColor);
    }
    else {
      header.css('border-width', '0px');
    }
  };

  $(window).bind('scroll', scrollCallback);
  scrollCallback();
  $('[data-toggle="tooltip"]').tooltip();

  var clipboard = new Clipboard('.btn-clipboard');
  clipboard.on('success', function(e) {
    e.clearSelection();
  });

  $('#CollapseAll').on('click', function () {
    $('.panel').each(function () {
      var collapse = $(this).children('.panel-collapse');
      if(collapse.hasClass('collapse in')) {
        var h2Title = $(this).children('.panel-heading').children('.collapsed');
        h2Title.click();
      }    
    });
  });

  $('#ExpandAll').on('click', function () {
    $('.panel').each(function () {
      var collapse = $(this).children('.panel-collapse');
      if (!collapse.hasClass('collapse in')) {
        var h2Title = $(this).children('.panel-heading').children('.expanded');
        h2Title.click();
      }    
    });
  });

  $('.anchor-link').click(function (e) {
    e.preventDefault();
    var offset = $($(this).attr('href')).offset();
    $('html, body').animate({ scrollTop: offset.top - $('.header').outerHeight() }, 'fast');
  });

  $(window).resize(function(){
    var curHeight = $(".header").height() + 65;
    $('.content').css('padding-top', curHeight + 'px');
  });

});

var sectionsLoad = function (window, $) {

  $('.panel').each(function () {
    var heading = $(this).children('.panel-heading');
    heading.click(function (event) {
      if ($(event.target).is('h2,h4')
         || $(event.target).hasClass('expanded')
         || $(event.target).hasClass('collapsed')) {
        var parentPanel = $(this).parent();
        parentPanel.children('.panel-collapse').collapse('toggle');
        $(this).children('.expanded').toggle();
        $(this).children('.collapsed').toggle();
      }
    });
  });
};

var loadEvent = function () {
  sectionsLoad(window, jQuery);
};
if (window.addEventListener) {
  window.addEventListener('load', loadEvent, false);
}
else if (window.attachEvent) {
  window.attachEvent('onload', loadEvent);
}