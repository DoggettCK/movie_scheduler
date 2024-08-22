# MovieScheduler

Working on an idea for candidate interviews, where, given a listing of movie
times in one of a few formats, they should attempt to maximize the number of
movies they could see, with no repeats.


## How to Use

Simply run `mix test`, and the existing tests will run both the CSV and JSON
schedulers and output optimized movie schedules.

## Ideas for future improvements

- Calculate travel time between different theaters
- Allow for wiggle room if one movie's end time overlaps the trailers at the
  beginning of the next
