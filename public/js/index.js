function evaluate_input () {
  document.location = "/?type=plain&data=" + $(".input_area").val().split("\n").join(":");
}

function drop_receive_prepare (e) {
  e.preventDefault();
}

function get_drop_file (e) {
  e.preventDefault();
  var f = e.dataTransfer.files[0];
  console.log(f);
  var reader = new FileReader();
  reader.onloadend = function(){
    console.log(reader);
    console.log(reader.result.replace(/data:text\/csv;base64\,/, ""));
    if(/data:text\/csv;base64\,/.test(reader.result)) {
      document.location = "/?type=base64&data=" + reader.result.replace(/data:text\/csv;base64\,/, "");
    } else {
      alert("csv以外のファイルには対応していません");
    }
  };
  reader.readAsDataURL(f);
}
