//All time is converted to seconds for easier comparison

$(document).on('page:load ready', function(){

  //https://eonasdan.github.io/bootstrap-datetimepicker/
  $('#research_session_start_datetime').datetimepicker({
    format: 'YYYY-MM-DD hh:mm A',
    stepping: 15
  });

  // initialize bloodhound engine
  var searchSelector = 'input#invitees-typeahead';

  //filters out tags that are already in the list
  var filter = function(suggestions) {
    var current_people = $('.invitees a').map(function(index,el){
      return Number(el.id.replace(/^(person-)/,''));
    });
    return $.grep(suggestions, function(suggestion) {
        return $.inArray(suggestion.id,current_people) === -1;
    });
  };


  var bloodhound = new Bloodhound({
    datumTokenizer: function (d) {
      return Bloodhound.tokenizers.whitespace(d.value);
    },
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    remote: {
      url:'/search/index_ransack.json?q[nav_bar_search_cont]=%QUERY',
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

    $.ajax({
      url: '/sessions/'+research_session_id+'/add_person/'+datum.id,
      data: {type: cart_type },
      dataType: "script",
      success: function(){
        $(searchSelector).val('');
      }
    })
  });


});

