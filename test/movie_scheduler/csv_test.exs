defmodule MovieScheduler.CSVTest do
  use ExUnit.Case
  doctest MovieScheduler.CSV

  alias MovieScheduler.CSV, as: MovieScheduler

  test "gets a list of showtimes from csv" do
    showtime_csv =
      "test/fixtures/showtimes.csv"
      |> File.read!()
      |> String.split("\r", trim: true)
      |> CSV.decode!()
      |> Enum.to_list()

    # expected_showtimes = []

    # assert ^expected_showtimes =
      showtime_csv
      |> MovieScheduler.get_showtimes()
      |> MovieScheduler.optimize_schedule()
      |> MovieScheduler.print_schedule()
  end
end
