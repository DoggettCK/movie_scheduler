defmodule MovieScheduler.CSV do
  @moduledoc """
  Documentation for `MovieScheduler.CSV`.
  """

  # Trailers are always 15 minutes, which adds to runtime, but you could also
  # use it to not be so strict with the start time and show up up to 15 minutes
  # "late".
  @trailers_length 15

  @days_of_week ~w(Monday Tuesday Wednesday Thursday Friday Saturday Sunday)
  |> Enum.with_index(1)
  |> Enum.into(%{}, fn {k, v} -> {v, k} end)

  @doc """
  Given a list of CSV lines of movie showtimes, return a list of
  maps containing the movie title, location, start and end times.
  """
  def get_showtimes(movies) do
    Enum.map(movies, &parse_showtimes/1)
  end

  def print_schedule(schedule) do
    schedule
    |> Map.drop([:last_finish])
    |> Map.values()
    |> Enum.sort_by(& &1.start_time, NaiveDateTime)
    |> Scribe.print(data: [{"Theater", :theater}, {"Title", :title}, {"Time", &print/1}])
  end

  def optimize_schedule(movies) do
    scheduled = %{
      last_finish: ~N[2024-01-01 00:00:00]
    }

    movies
    |> Enum.sort_by(& &1.end_time, NaiveDateTime)
    |> Enum.reduce(scheduled, &maybe_schedule/2)
  end

  defp maybe_schedule(movie, schedule) when is_map_key(schedule, movie.title) do
    schedule
  end

  defp maybe_schedule(movie, %{last_finish: last_finish} = schedule) do
    case NaiveDateTime.compare(last_finish, movie.start_time) do
      :lt ->
        schedule
        |> Map.put(movie.title, movie)
        |> Map.put(:last_finish, movie.end_time)

      _ ->
        schedule
    end
    # TODO: Wiggle room if next start is within trailer time at same theater
    # TODO: Travel time to other theaters
  end

  defp print(movie) do
    day = day_of_week(movie.start_time)
    day_of_month = day_of_month(movie.start_time)
    begin = human_time(movie.start_time)
    finish = human_time(movie.end_time)
    runtime = calc_runtime(movie.runtime)
    "#{day} #{day_of_month} #{begin}-#{finish} (#{runtime})"
  end

  defp day_of_week(datetime) do
    datetime
    |> Date.day_of_week()
    |> then(&Map.get(@days_of_week, &1))
  end

  defp day_of_month(datetime) do
    "#{datetime.month}/#{datetime.day}"
  end

  defp human_time(datetime) do
    minutes =
      datetime.minute
      |> to_string()
      |> String.pad_leading(2, "0")

    {hour, am_pm} =
      cond do
        datetime.hour == 0  -> {12, "AM"}
        datetime.hour == 12  -> {12, "PM"}
        datetime.hour > 12 -> {rem(datetime.hour, 12), "PM"}
        true -> {datetime.hour, "AM"}
      end

    "#{hour}:#{minutes}#{am_pm}"
  end

  defp calc_runtime(runtime) do
    hours = div(runtime, 60)
    minutes = rem(runtime, 60)

    case hours do
      0 -> "#{minutes}m"
      _ -> "#{hours}h #{minutes}m"
    end
  end

  defp parse_showtimes(movie) do
    [title, runtime, theater, date, time] = movie

    [month, day] = parse_ints_from_string(date)
    [hour, minute] = parse_ints_from_string(time)
    runtime = String.to_integer(runtime)

    today = Date.utc_today()

    year =
      case {today.month, month} do
        {12, 1} ->
          today.year + 1

        _ ->
          today.year
      end

    start_time = %NaiveDateTime{
      year: year,
      month: month,
      day: day,
      hour: hour,
      minute: minute,
      second: 0
    }
    end_time = NaiveDateTime.add(start_time, runtime + @trailers_length, :minute)

    %{
      title: title,
      runtime: runtime,
      theater: theater,
      start_time: start_time,
      end_time: end_time
    }
  end

  defp parse_ints_from_string(str) do
    ~r/\d+/
      |> Regex.scan(str)
      |> List.flatten()
      |> Enum.map(&String.to_integer/1)
  end
end
