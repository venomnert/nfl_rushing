defmodule NflRushingWeb.ExportController do
  use NflRushingWeb, :controller

  alias NflRushing.Boundary.DataManager

  def get_csv(conn, _params) do
    filename = "export#{:os.system_time(:millisecond)}.csv"
    file = File.open!(filename, [:write, :utf8])
    :ok = DataManager.export(file)

    # Send file
    conn
    |> send_download({:file, filename}, filename: filename)
  end
end
