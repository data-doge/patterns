$(document).on('page:load turbolinks:load ready', function() {
  console.log('running research_sessions.js');
  // on add is clicked, find all adds, filter unique, then click them all
  $('#add_all').click(function() {
    $('.remove_fields').click();
    $('.add-to-session').click();
  });

  $('#remove_all').click(function() {
    $('.remove_fields').click();
  });


  //https://eonasdan.github.io/bootstrap-datetimepicker/
  $('#research_session_start_datetime').datetimepicker({
    format: 'YYYY-MM-DD hh:mm A',
    stepping: 15,
    maxDate: moment().add(60, 'days') // 30 days from the current day
  });

  // initialize bloodhound engine
  var searchSelector = 'input#invitees-typeahead';

  //filters out tags that are already in the list
  var filter = function(suggestions) {
    var current_people = $('.invitees a').map(function(index, el) {
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

