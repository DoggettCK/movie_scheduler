defmodule MovieScheduler.JSONTest do
  use ExUnit.Case
  doctest MovieScheduler.JSON

  alias MovieScheduler.JSON, as: MovieScheduler

  test "gets a list of showtimes from json" do
    showtime_json =
      "test/fixtures/showtimes.json"
      |> File.read!()
      |> Jason.decode!(keys: :atoms)

    # expected_showtimes = []

    # assert ^expected_showtimes =
    showtime_json
    |> MovieScheduler.get_showtimes()
    |> MovieScheduler.optimize_schedule()
    |> MovieScheduler.print_schedule()
  end
end
