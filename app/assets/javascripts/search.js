$(document).on('turbolinks:load', function() {

  $("#export-to-twilio-form-toggle").click(function() {
    $("#export-to-twilio-form").toggle();
    return false;
  });

  $("#export-to-mailchimp-form-toggle").click(function() {
    $("#export-to-mailchimp-form").toggle();
    return false;
  });

 
  $("#q_phone_number_eq").mask("+19999999999");
  // $("#q_phone_number_eq").on("blur", function() {
  //     var last = $(this).val().substr( $(this).val().indexOf("-") + 1 );

  //     if( last.length == 5 ) {
  //         var move = $(this).val().substr( $(this).val().indexOf("-") + 1, 1 );

  //         var lastfour = last.substr(1,4);

  //         var first = $(this).val().substr( 0, 9 );

  //         $(this).val( first + move + '-' + lastfour );
  //     }
  // });
  // validating our search fields
  $("#search-form").validate({
    rules: {
      "email_address": {
        email: true
      },
      "phone_number": {
        phoneUS: true
      },
      "postal_code":{
        zipcodeUS: true
      }
    }
  });
});

