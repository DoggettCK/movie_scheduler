var title = document.querySelector(".moviedetailsTitle").innerHTML;
var details = [...document.querySelectorAll(".moviedetails__sub")].slice(-2).map(x => x.innerHTML);
var release_year = parseInt(details.pop());
var runtime = parseInt(details.pop());

var showtime_date_string = document.querySelector(".showtime-slider--date button.selected").innerText.split("\n")[1];
var current_date = new Date();
var show_date = new Date(showtime_date_string);

if (current_date.getMonth() == 11 && show_date.getMonth() == 0) {
  show_date.setFullYear(current_date.getFullYear() + 1);
} else {
  show_date.setFullYear(current_date.getFullYear());
}

var theater = document.querySelector(".showtime-slider--cinema button.selected").innerText.split(" \n")[0];
var showtimes = [...document.querySelectorAll(".showtime-slider--time .status--onsale")].filter(x => !x.parentNode.classList.contains("invalid")).map(x => x.innerText);

var base_json = {
  title: title,
  runtime: runtime,
  locations: [
    {
      name: theater,
      showtimes: showtimes.map(function(st) {
        var showtime = new Date(show_date);
        var time = st.match(/(\d+)(?::(\d\d))?\s*(p?)/);
        showtime.setHours(parseInt(time[1]) + (time[3] ? 12 : 0));
        showtime.setMinutes(parseInt(time[2]) || 0);
        return [showtime.toLocaleDateString("sv"), showtime.toLocaleTimeString("sv")].join(" ");
      })
    }
  ]
};

console.log(base_json);
