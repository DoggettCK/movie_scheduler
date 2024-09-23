defmodule Mix.Tasks.Schedule do
  use Mix.Task

  require Logger

  @moduledoc """
  Downloads schedules from Alamo Drafthouse's feed.

  ## Command line options
    * `--from` - ISO8601 date to start filtering showtimes, defaults to today
    * `--until` - ISO8601 date to end filtering showtimes, defaults to a week from today
  """

  @theaters %{
    village: "0003",
    south_lamar: "0004",
    slaughter_lane: "0006",
    lakeline: "0007",
    mueller: "0008"
  }
  @csv_headers ~w(film_name film_runtime cinema_name start_time)a

  @switches [from: :string, until: :string, test: :boolean]

  def run(args) do
    Application.ensure_all_started(:hackney)
    {flags, _raw, _invalid} = OptionParser.parse(args, strict: @switches)

    from = parse_date_from_flags(flags, :from)
    until = parse_date_from_flags(flags, :until)

    @theaters
    |> Map.keys()
    |> Enum.reduce([], fn name, showtimes ->
      showtimes ++ fetch_schedule_from_theater(name, from, until)
    end)
    |> CSV.encode(headers: @csv_headers)
    |> Enum.join("")
    |> IO.puts()
  end

  defp parse_date_from_flags(flags, :from) do
    flags
    |> Keyword.get(:from)
    |> parse_date_with_default(Date.utc_today())
  end

  defp parse_date_from_flags(flags, :until) do
    flags
    |> Keyword.get(:until)
    |> parse_date_with_default(Date.utc_today() |> Date.add(7))
  end

  defp parse_date_with_default(nil, default_date), do: default_date

  defp parse_date_with_default(user_date, default_date) do
    case DateTimeParser.parse_date(user_date) do
      {:error, msg} ->
        Logger.warning(msg)
        Logger.warning("Falling back to default (#{default_date})")
        default_date

      {:ok, parsed_date} ->
        parsed_date
    end
  end

  defp fetch_schedule_from_theater(theater_name, from, until) do
    with {:ok, response_body} <- fetch_response_body(theater_name),
         {:ok, json} <- Jason.decode(response_body),
         {:ok, showtimes} <- parse_showtimes_from_json(json, from, until) do
      showtimes
    else
      {:error, response} ->
        Logger.warning("Problem fetching feed for #{theater_name}")
        Logger.warning(response.body)
        []
    end
  end

  defp fetch_response_body(theater_name) do
    theater_id = Map.get(@theaters, theater_name)
    theater_feed = "https://feeds.drafthouse.com/adcService/showtimes.svc/calendar/#{theater_id}/"

    with {:ok, response} <- HTTPoison.get(theater_feed, [], hackney: [:insecure]) do
      {:ok, response.body}
    end
  end

  defp parse_showtimes_from_json(json, from, until) do
    valid_dates = build_filter_dates(from, until)

    showtimes =
      json["Calendar"]["Cinemas"]
      |> Enum.flat_map(&build_films_by_cinema(valid_dates, &1))

    {:ok, showtimes}
  end

  defp build_filter_dates(from, until) do
    [start_date, end_date] = Enum.sort([from, until])

    start_date
    |> Date.range(end_date)
    |> Enum.into(%{}, fn date ->
      {
        date |> Date.to_iso8601() |> String.replace("-", ""),
        true
      }
    end)
  end

  defp build_films_by_cinema(valid_dates, cinema) do
    movie_detail = %{cinema_name: cinema["CinemaName"]}

    cinema
    |> get_in(["Months", Access.all(), "Weeks", Access.all(), "Days", Access.all()])
    |> List.flatten()
    |> Stream.filter(&Map.has_key?(valid_dates, &1["DateId"]))
    |> Enum.filter(&Map.has_key?(&1, "Films"))
    |> Enum.flat_map(&build_films_by_day(movie_detail, &1))
  end

  defp build_films_by_day(movie_detail, day) do
    day["Films"]
    |> Enum.flat_map(fn film ->
      movie_detail =
        %{
          film_name: film["FilmName"],
          film_runtime: film["FilmRuntime"]
        }
        |> Map.merge(movie_detail)

      film
      |> get_in(["Series", Access.all(), "Formats", Access.all(), "Sessions", Access.all()])
      |> List.flatten()
      |> Enum.map(&Map.put(movie_detail, :start_time, &1["SessionDateTime"]))
    end)
  end
end
