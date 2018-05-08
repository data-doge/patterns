$(document).on('page:load turbolinks:load ready', function() {
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
  
  var $chkboxes = $(':checkbox');
  var lastChecked = null;

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


});
