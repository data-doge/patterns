// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.

// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require jquery.turbolinks
//= require fastclick/fastclick
//= require best_in_place
//= require twitter/bootstrap
//= require twitter/typeahead.min
//= require holder
//= require tokenfield/bootstrap-tokenfield.js
//= require jquery.validate
//= require jquery.validate.additional-methods
//= require moment/moment.min
//= require datepicker/bootstrap-datetimepicker.min
//= require fullcalendar/fullcalendar.min
//= require jquery-touchswipe/jquery.touchSwipe.min
//= require cable
//= require_tree .
//= require jquery.mask

$(document).on('turbolinks:load',function() {
  $.jMaskGlobals.watchDataMask = true;
  
  FastClick.attach(document.body);  
  /* Activating Best In Place */
  jQuery(".best_in_place").best_in_place();

  var show_ajax_message = function(msg, type) {
    var cssClass = type === 'error' ? 'alert-error' : 'alert-success'
    var html ='<div class="alert ' + cssClass + '">';
    html +='<button type="button" class="close" data-dismiss="alert">&times;</button>';
    html += msg +'</div>';
    //fade_flash();
    $("#notifications").html(html);
  };


  reloadWithTurbolinks = (function () {
    var scrollPosition

    function reload () {
      scrollPosition = [window.scrollX, window.scrollY]
      Turbolinks.visit(window.location.toString(), { action: 'replace' })
    }

    document.addEventListener('turbolinks:load', function () {
      if (scrollPosition) {
        window.scrollTo.apply(window, scrollPosition)
        scrollPosition = null
      }
    })

    return reload
  })()

  $(document).ajaxComplete(function(event, request) {
    var msg = request.getResponseHeader('X-Message');
    var type = request.getResponseHeader('X-Message-Type');

    if (type !== null) {
      show_ajax_message(msg, type);
    }
  });
});
