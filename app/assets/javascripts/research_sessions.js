$(document).on('page:load turbolinks:load ready', function() {
  
  // on add is clicked, find all adds, filter unique, then click them all
  
  //https://eonasdan.github.io/bootstrap-datetimepicker/
  $('#research_session_start_datetime').datetimepicker({
    format: 'YYYY-MM-DD hh:mm A',
    stepping: 15,
    maxDate: moment().add(60, 'days') // 30 days from the current day
  });

  // initialize bloodhound engine
  var searchSelector = 'input#invitees-typeahead';

  // called from card_activation_mini
  add_card_activation = function(el){
    // this is a horrible hack
    var card_data = $(el).data();
    card_data.reason = $('#card-actionvation-reason-' + card_data.cardActivationId).val();
    
    var myform = document.getElementById("new_gift_card");
    $('input[name="gift_card[reason]"]').val(card_data.reason);
    $('input[name="gift_card[proxy_id]"]').val(card_data.sequenceNumber);
    $('input[name="gift_card[gift_card_number]"]').val(card_data.giftCardNumber);
    $('input[name="gift_card[batch_id]"]').val(card_data.batchId);
    $('input[name="gift_card[expiration_date]"]').val(card_data.expirationDate);
    $('input[name="gift_card[card_activation_id]"]').val(card_data.cardActivationId);
    $('input[name="amount"]').val(card_data.amount);
    $('#add-gift-card-button').click();
  }
  //filters out tags that are already in the list
  var filter = function(suggestions) {
    var current_people = $('.current-cart a').map(function(index, el) {
      return Number(el.id.replace(/^(person-)/, ''));
    });
    return $.grep(suggestions, function(suggestion) {
        return $.inArray(suggestion.id, current_people) === -1;
    });
  };

  var bloodhound = new Bloodhound({
    datumTokenizer: function(d) {
      return Bloodhound.tokenizers.whitespace(d.value);
    },
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    remote: {
      url: '/search/index_ransack.json?q[nav_bar_search_cont]=%QUERY',
      wildcard: '%QUERY',
      filter: filter,
      limit: 20,
      cache: false
    }
  });
  bloodhound.initialize();

  // initialize typeahead widget and hook it up to bloodhound engine
  // #typeahead is just a text input
  $(searchSelector).typeahead(null, {
    name: 'People',
    displayKey: 'name',
    source: bloodhound.ttAdapter()
  });

  $(searchSelector).on('typeahead:selected', function(obj, datum){ //datum
    var cart_type = 'full';
    if ($('#mini-cart').length != 0) {
      cart_type = 'mini'
    };

    $.getScript({
      url: '/sessions/' + research_session_id + '/add_person/' + datum.id,
      success: function() {
        $(searchSelector).val('');
        $('#dynamic-invitation-panel').load('/sessions/' + research_session_id + '/invitations_panel.html');
      }
    })
  });


});

