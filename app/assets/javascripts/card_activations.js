$(document).on('page:load turbolinks:load ready ajax:complete', function() {
  assign_cards_to_user = function(){
    var user_id = document.getElementById('select_user_for_cards').value;
    var checked = $('input:checked[name="card_activation_id_change[]"]').map(function() {
      return parseInt(this.value);
    }).get().join()
    
    if (checked.length > 0) {
      url = '/card_activations/change_user/'+checked;
      $.ajax({type: "POST",url: url,data:{user_id: user_id}});
    }
  }


  $('#card-all').on('click',function(){
    $(':checkbox').prop('checked', this.checked);
  });

  var multiselect_setup = function(){
    var lastChecked = null;
    var $chkboxes = $(':checkbox');  
    $chkboxes.click(function(e) {
      if(!lastChecked) {
          lastChecked = this;
          return;
      }
      if(e.shiftKey) {
          var start = $chkboxes.index(this);
          var end = $chkboxes.index(lastChecked);
          $chkboxes.slice(Math.min(start,end), Math.max(start,end)+ 1).prop('checked', lastChecked.checked);
      }
      lastChecked = this;
    });
  }
  multiselect_setup();
  $(document).ajaxComplete(function(event, request) {multiselect_setup();});


  // searches for workers. simple Fuse search.
  var filter = function() {
    // map through each card, hide it, and return a searchable obj.
    var searchable_cards = $('.card-activation').map(function() {
          $(this).hide(); // hide em all.
          console.log($(this));
          return { 
            sequence: $(this).data('sequence-number'), 
            last4:$(this).data('last-4'), 
            username:$(this).data('user-name'),
            obj: $(this)}
        })

    //small search area, so way less fuzzy
    var options = {
      keys: ['sequence', 'username'],
      distance: 0,
      threshold: 0.1
    };

    var fuse = new Fuse(searchable_cards, options);
    var query = $('#card-search').val();
    var found = [];
    if (query.length > 0) {
      found = fuse.search(query);
      // show only found workers.
      $(found).each(function(i, v) { $(v.obj).show();});
    } else {
      // show all of the workers, didn't find anything
      $('.card-activation').each(function(i, v) { $(v).show(); });
    }
  };
  // should we think about a typeahead +filter here? for ease of use?
  // similar to register.js for slack ids, would need to ajax.
  // searching, simple debounce
  var t = null;
  $('#card-search').keyup(function() {
      if (t) {
          clearTimeout(t);
      }
      t = setTimeout(filter(), 100);
      if ($('#card-search').val() != '') {
        $('.form-control-clear button').removeClass('btn-secondary').addClass('btn-primary');
      } else {
        $('.form-control-clear button').removeClass('btn-primary').addClass('btn-secondary');
      }
  });
  $('.form-control-clear').click(function() {
    $(this).siblings('input[type="text"]').val('').trigger('propertychange').focus();
    $('.form-control-clear button').removeClass('btn-primary').addClass('btn-secondary');
    $(this).siblings('input[type="text"]').blur();
    $('.card-activation').each(function(i, v) { $(v).show(); });
  });
});
