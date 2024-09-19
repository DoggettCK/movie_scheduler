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
    village: "0003"
    # south_lamar: "0004",
    # slaughter_lane: "0006",
    # lakeline: "0007",
    # mueller: "0008"
  }

  @switches [from: :string, until: :string]

  def run(args) do
    Application.ensure_all_started(:hackney)
    {flags, _raw, _invalid} = OptionParser.parse(args, strict: @switches)

    from = parse_date_from_flags(flags, :from)
    until = parse_date_from_flags(flags, :until)

    for {name, _} <- @theaters do
      fetch_schedule_from_theater(name, from, until)
    end
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
    theater_id = Map.get(@theaters, theater_name)
    theater_feed = "https://feeds.drafthouse.com/adcService/showtimes.svc/calendar/#{theater_id}/"

    with {:ok, response} <- HTTPoison.get(theater_feed, [], hackney: [:insecure]),
         {:ok, json} <- Jason.decode(response.body),
         {:ok, showtimes} <- parse_showtimes_from_json(json, from, until) do
      {:ok, showtimes}
    else
      {:error, response} ->
        Logger.warning("Problem fetching feed for #{theater_name}")
        Logger.warning(response.body)
        {:error, response.status_code, []}
    end
  end

  defp parse_showtimes_from_json(json, from, until) do
    [start_date, end_date] = Enum.sort([from, until])

    date_ids =
      start_date
      |> Date.range(end_date)
      |> Enum.into(%{}, fn date ->
        {
          date |> Date.to_iso8601() |> String.replace("-", ""),
          true
        }
      end)
      |> IO.inspect(label: "Date filters")

    {:ok, []}
  end
end
