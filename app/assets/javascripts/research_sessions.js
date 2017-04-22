//All time is converted to seconds for easier comparison

$(document).on('page:load ready', function(){


  var startTimeElement = $("#research_session_start_datetime");
  var endTimeElement = $("#research_session_end_datetime");

  $("#submit").click(function(e){
    var startTime = timeToSeconds(startTimeElement.val());
    var endTime = timeToSeconds(endTimeElement.val());

    if(isEndTimeAfterStartTime(startTime, endTime)){
      var alertMessage = "Please make sure that the End time is greater than the Start time";
      alert(alertMessage);
      endTimeElement.wrap("<div class='field_with_errors'></div>");
      e.preventDefault();
    }

  });

  startTimeElement.change(function(){
    endTimeElement.val(startTimeElement.val());
  });


  function isEndTimeAfterStartTime(startTime, endTime) {
    return !(endTime > startTime);
  }

  function timeToSeconds(time) {
    time = time.split(/:/);
    return time[0] * 3600 + time[1] * 60;
  }
  function slotLength(){
    parseInt(slotLengthElement.val().substr(0,2),10) * 60;
  };

  //https://eonasdan.github.io/bootstrap-datetimepicker/
  $('.datepicker').datepicker('setDate', new Date());
  // defaulting to a reasonable time
  startTimeElement.prop('selectedIndex', 38).change();

});

