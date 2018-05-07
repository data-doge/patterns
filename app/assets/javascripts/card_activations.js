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
});
