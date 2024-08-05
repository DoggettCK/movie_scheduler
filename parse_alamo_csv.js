var title = document.querySelector(".moviedetailsTitle").innerHTML;
var runtime = [...document.querySelectorAll(".moviedetails__sub")].slice(-2, -1).map(x => parseInt(x.innerHTML))[0];

var show_date = document.querySelector(".showtime-slider--date button.selected").innerText.split("\n")[1];
var theater = document.querySelector(".showtime-slider--cinema button.selected").innerText.split(" \n")[0];
var show_times = [...document.querySelectorAll(".showtime-slider--time .status--onsale")].filter(x => !x.parentNode.classList.contains("invalid")).map(x => x.innerText);

var csv = show_times.map(function(st) {
  var time = st.match(/(\d+)(?::(\d\d))?\s*(p?)/);
  var hours = (parseInt(time[1] || 0));
  if (time[3] && hours < 12) {
    hours += 12;
  }
  hours = hours.toString().padStart(2, "0");
  var minutes = (parseInt(time[2]) || 0).toString().padStart(2, "0");

  return `"${title}","${runtime}","${theater}","${show_date}","${hours}:${minutes}"`
}).join("\n");

navigator.clipboard.writeText(csv);
