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

function render_graph (plot_data_json, a_s, b_s, last_x) {
  var plot_data = JSON.parse(plot_data_json);
  var a = parseFloat(a_s);
  var b = parseFloat(b_s);
  var linear_data = [[0, a], [last_x, a + b * last_x]];
  console.log(plot_data, a, b);
  $.plot($(".graph_area"), [
    {
      label: "測定データ",
      data: plot_data,
      points: { show: true }
    },
    {
      label: "最小二乗法(1次関数)",
      data: linear_data,
      lines: { show: true }
    }
  ]);
}

