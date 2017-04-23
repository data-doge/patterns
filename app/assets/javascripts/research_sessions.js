//All time is converted to seconds for easier comparison

$(document).on('page:load ready', function(){

  //https://eonasdan.github.io/bootstrap-datetimepicker/
  $('#research_session_start_datetime').datetimepicker({
    format: 'YYYY-MM-DD HH:mm'
  });

  $('#research_session_end_datetime').datetimepicker({
    useCurrent: false,
    format: 'YYYY-MM-DD HH:mm'
  });

  $('#research_session_start_datetime').on("dp.change", function (e) {
    var new_end = moment(e.date).add(1, 'hours');
    $('#research_session_end_datetime').data("DateTimePicker").minDate(new_end);
  });
});

