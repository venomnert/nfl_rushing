defmodule NflRushing.Core.Rushing do
  @ignore_keys ["Player", "Team", "Pos"]
  @export_file Application.app_dir(:nfl_rushing, "priv/static/export.csv")

  def load_file(path) do
    path
    |> File.read!()
    |> Jason.decode!()
    |> normalize()
  end

  def load_file_stream(path, chunk) do
    data = path
            |> File.stream!()
            |> Jaxon.Stream.from_enumerable()
            |> Jaxon.Stream.query([:root, :all])
            |> Enum.take(chunk)
            |> normalize()

    next_stream = path
                  |> File.stream!()
                  |> Jaxon.Stream.from_enumerable()
                  |> Jaxon.Stream.query([:root, :all])
                  |> Stream.drop(chunk)

    {data, next_stream}

  end

  def next(stream, chunk) do
    data = stream |> Enum.take(chunk) |> normalize()
    next_stream = stream |> Stream.drop(chunk)

    {data, next_stream}
  end

  def sort(data, {:desc, sort_key}) do
    data
    |> Enum.sort(fn a,b ->
      Map.get(a, sort_key) >= Map.get(b, sort_key)
    end)
  end

  def sort(data, {:asc, sort_key}) do
    data
    |> Enum.sort(fn a,b ->
      Map.get(a, sort_key) <= Map.get(b, sort_key)
    end)
  end

  def filter(data, query) do
    data
    |> Enum.filter(&compare_player(&1, query))
  end

  def get_headers(data) do
    data
    |> List.first()
    |> Map.keys()
  end

  def create_csv(data, header) do
    try do
      csv_data = data |> CSV.encode(headers: header)

      file = File.open!(@export_file, [:write, :utf8])

      csv_data |> Enum.each(&IO.write(file, &1))

      @export_file
    rescue
      _ -> nil
    end
  end

  defp compare_player(%{"Player" => player}, query) do
    player
    |> String.downcase()
    |> String.contains?(String.downcase(query))
  end

  defp normalize(rushing_data) do
    rushing_data
    |> Enum.map(&convert_to_int(&1))
  end

  defp convert_to_int(single_data) do
    map_a = for {k,v} <- single_data, is_integer(v) or is_float(v), into: %{}, do: {k, abs(v)}

    map_b = for {k,v} <- single_data, is_binary(v), into: %{} do
      if k in @ignore_keys do
        {k, v}
      else
        converted_value = v
        |> String.replace(~r"[^0-9]", "")
        |> String.to_integer()
        {k, converted_value}
      end
    end

    Map.merge(map_a, map_b)
  end
end
