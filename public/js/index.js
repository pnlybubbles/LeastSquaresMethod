function evaluate_input () {
  document.location = "/?data=" + $(".input_area").val().split("\n").join(":");
}