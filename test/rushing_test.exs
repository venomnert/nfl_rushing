defmodule RushingTest do
  use ExUnit.Case
  alias NflRushing.Core.Rushing

  @small_data_file Application.app_dir(:nfl_rushing, "priv/static/rushing_small.json")

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
end
