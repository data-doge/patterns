jQuery(document).on('turbolinks:load', function() {
  
  
    console.log('loading actioncable');
    function render_gift_card(data){
      console.log(data);
      if($('#active-unassigned-cards-count').length > 0){
        $('#active-unassigned-cards-count').html(data.count);
      }
      switch(data.type){
        case 'update':
          if ($('#gift-cards-mini').length > 0) {
            if ($('#gift-card-' + data.id).length == 1) {
              $('#gift-card-' + data.id).replaceWith(data.mini);
            }else{
              $('#gift-cards-mini').prepend(data.mini);
            }
          }
          if ($('#gift-cards-large').length > 0){
            if ($('#gift-card-' + data.id).length == 1) {
              $('#gift-card-' + data.id).replaceWith(data.large);
            }else{
              $('#gift-cards-large').prepend(data.large);
            }
          }
          break;
        case 'delete':
          $('#gift-card-'+data.id).remove();
          break;
        default:
          console.log('this should not happen.');  
      }
    };

    App.cable.subscriptions.create({
      channel: "GiftCardEventChannel"
    }, {
      connected: function() {
        this.perform('log_me')
      },
      disconnected: function() {
        console.log('disconnected');
      },
      received: function(data) {
        render_gift_card(data);
      }
    });
  
});
