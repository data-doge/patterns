$(document).on('ready page:load',function() {
  // a typeahead that adds people to the card.
  // interacts with cocoon to do nested forms
  // does both big and mini-cart

  added_person = {};

    // initialize bloodhound engine
  var searchSelector = 'input#cart-typeahead';

  //filters out tags that are already in the list
  var filter = function(suggestions) {9
    var current_people = $('#mini-cart tr').map(function(index,el){
      return Number(el.id.replace(/^(cart-)/,''));
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
      url: '/cart/add/' + datum.id,
      data: {type: cart_type },
      dataType: "script",
      success: function() {
        $(searchSelector).val('');
      }
    });
  });


  if ($('#mini-cart').length != 0) {
    $(".add_fields").hide();
    $('.add-to-session').on('click', function(el) {

      added_person = {full_name: $(this).data('fullname'),
                        person_id: $(this).data('personid')};
      $('a.add_fields').click();
    });

    $('form').on('cocoon:before-insert', function(e, insertedItem) {
      var pid = added_person.person_id;
      // horrible, horrible hack to prevent duplicates. why?
      window.inserted_people = window.inserted_people || [];
      if ($.inArray(pid, window.inserted_people) === -1) {
        window.inserted_people.push(pid);
      } else {
        e.preventDefault();
      }
    });

    $('form').on('cocoon:after-insert', function(e, inserted_item) {
      $(inserted_item).find('.person-name').each(function() {
        $(this).text(added_person.full_name);
      });

      $(inserted_item).find('input[type=hidden]').each(function() {
        $(this).val(added_person.person_id);
        $('.add-to-session#add-' + added_person.person_id).hide();
      });
    });

    $('form').on('cocoon:before-remove', function(e,removed_item) {
      // horrible hack continues
      window.inserted_people = jQuery.grep(window.inserted_people, function(value) {
        return value != $(removed_item).find('input[type=hidden]').val();
      });

      $(removed_item).find('input[type=hidden]').each(function() {
        $('.add-to-session#add-' + $(this).val()).show();
      });
    });
  }

});
