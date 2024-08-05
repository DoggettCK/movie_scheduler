var title = document.querySelector(".c-screening-data h1").innerHTML;
var [hours, minutes] = document.querySelector(".c-screening-data > p:nth-child(4)").innerText.match(/(\d+)h (\d+)min/).slice(1, 3).map(x => parseInt(x));
var runtime = hours * 60 + minutes;

var showtime_nodes = document.querySelectorAll(".c-showtime-select-wrap div[id^=showtime-20] a");

var theater = "Austin Film Society"

var csv = Array.from(showtime_nodes).map(function(st_a) {
  var time = st_a.innerText.match(/(\d+):(\d{2})\s*(PM|AM)/);

  var hours = (parseInt(time[1] || 0));
  if (time[3] && hours < 12) {
    hours += 12;
  }
  hours = hours.toString().padStart(2, "0");
  var minutes = (parseInt(time[2]) || 0).toString().padStart(2, "0");
  var show_date = st_a.parentNode.id.slice(-4);
  show_date = show_date.slice(0, 2) + '/' + show_date.slice(2, 4);

  return `"${title}","${runtime}","${theater}","${show_date}","${hours}:${minutes}"`
}).join("\n");

navigator.clipboard.writeText(csv);
