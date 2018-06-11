jQuery(document).on('turbolinks:load', function() {
  
  
    console.log('loading actioncable');
    function render_card_activation(data){
      console.log(data);
      if($('#active-unassigned-cards-count').length > 0){
        $('#active-unassigned-cards-count').html(data.count);
      }
      switch(data.type){
        case 'update':
          if ($('#card-activations-mini').length > 0) {
            if ($('#card-activation-' + data.id).length == 1) {
              $('#card-activation-' + data.id).replaceWith(data.mini);
            }else{
              $('#card-activations-mini').prepend(data.mini);
            }
          }
          if ($('#card-activations-large').length > 0){
            if ($('#card-activation-' + data.id).length == 1) {
              $('#card-activation-' + data.id).replaceWith(data.large);
            }else{
              $('#card-activations-large').prepend(data.large);
            }
          }
          break;
        case 'delete':
          $('#card-activation-'+data.id).remove();
          break;
        default:
          console.log('this should not happen.');  
      }
    };

    App.cable.subscriptions.create({
      channel: "ActivationEventChannel"
    }, {
      connected: function() {
        this.perform('log_me')
      },
      disconnected: function() {
        console.log('disconnected');
      },
      received: function(data) {
        render_card_activation(data);
      }
    });
  
});
