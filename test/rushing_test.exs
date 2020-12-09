defmodule RushingTest do
  use ExUnit.Case
  alias NflRushing.Core.Rushing

  @small_data_file Application.app_dir(:nfl_rushing, "priv/static/rushing_small.json")
  @headers ["1st","1st%","20+","40+","Att","Att/G","Avg","FUM","Lng","Player","Pos","TD","Team","Yds","Yds/G"]
  @export_file Application.app_dir(:nfl_rushing, "priv/static/export.csv")

  test "Load file & normalize" do
    @small_data_file
    |> Rushing.load_file()
    |> assert_datas(["Larry Fitzgerald", "Dion Lewis", "Tom Holton", "Johnny Holton"])
  end

  describe "Filter" do
    test "Empty data Filter" do
      @small_data_file
      |> Rushing.load_file()
      |> Rushing.filter("Nert")
      |> assert_filter([])
    end

    test "Single data Filter" do
      @small_data_file
      |> Rushing.load_file()
      |> Rushing.filter("Fitz")
      |> assert_filter(["Larry Fitzgerald"])
    end
  end

  describe "sort" do
    test "Sort Yds asc" do
      @small_data_file
      |> Rushing.load_file()
      |> Rushing.sort({:asc, "Yds"})
      |> assert_sort({"Yds", [3, 6, 10, 11]})
    end

    test "Sort Yds desc" do
      @small_data_file
      |> Rushing.load_file()
      |> Rushing.sort({:desc, "Yds"})
      |> assert_sort({"Yds", [11, 10, 6, 3]})
    end

    test "Sort Lng asc" do
      @small_data_file
      |> Rushing.load_file()
      |> Rushing.sort({:asc, "Lng"})
      |> assert_sort({"Lng", [4, 15, 29, 29]})
    end

    test "Sort Lng desc" do
      @small_data_file
      |> Rushing.load_file()
      |> Rushing.sort({:desc, "Lng"})
      |> assert_sort({"Lng", [29, 29, 15, 4]})
    end

    test "Sort TD asc" do
      @small_data_file
      |> Rushing.load_file()
      |> Rushing.sort({:asc, "TD"})
      |> assert_sort({"TD", [0, 10, 10, 50]})
    end

    test "Sort TD desc" do
      @small_data_file
      |> Rushing.load_file()
      |> Rushing.sort({:desc, "TD"})
      |> assert_sort({"TD", [50, 10, 10, 0]})
    end
  end

  describe "Filter and sort" do
    test "filter data and then sort it" do
      @small_data_file
      |> Rushing.load_file()
      |> Rushing.filter("Hol")
      |> assert_filter(["Tom Holton", "Johnny Holton"])
      |> Rushing.sort({:desc, "Yds"})
      |> assert_sort({"Yds", [10,3]})
    end

    test "filter data and apply multi sort" do
      @small_data_file
      |> Rushing.load_file()
      |> Rushing.filter("Hol")
      |> assert_filter(["Tom Holton", "Johnny Holton"])
      |> Rushing.sort({:desc, "Yds"})
      |> assert_sort({"Yds", [10,3]})
      |> Rushing.sort({:asc, "TD"})
      |> assert_sort({"TD", [10, 50]})
    end
  end

  describe "Header" do
    test "get header" do
      @small_data_file
      |> Rushing.load_file()
      |> Rushing.get_headers()
      |> assert_header(@headers)
    end
  end

  describe "Export" do
    test "Test valid export" do
      file = @export_file
              |> File.open!([:write, :utf8])

      @small_data_file
      |> Rushing.load_file()
      |> Rushing.create_csv(@headers, file)

      assert_export(@export_file, true)
    end
  end

  defp assert_datas(data, expected) do
    assert length(data) == length(expected)
    data
  end
  defp assert_filter(data, expected) do
    min_data = for row <- data, do: row["Player"]
    assert min_data == expected
    data
  end
  defp assert_sort(data, {key, expected}) do
    min_data = for row <- data, do: row[key]
    assert min_data == expected
    data
  end
  defp assert_header(data, expected) do
    assert data == expected
    data
  end
  defp assert_export(path, expected) do
    assert File.exists?(path) == expected
  end
end
