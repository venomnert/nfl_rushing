defmodule NflRushingWeb.PageLive do
  use NflRushingWeb, :live_view

  alias NflRushing.Boundary.DataManager

  @impl true
  def mount(_params, _session, socket) do
    data = DataManager.get()
    update_socket = assign(socket,
                            headers: get_table_headers(data),
                            filtered_data: data,
                            query: "",
                            download_link: "")
    {:ok, update_socket}
  end

  @impl true
  def handle_event("filter-player", %{"q" => query}, socket) do
    filtered_data = DataManager.filter(query)
    {:noreply, assign(socket, filtered_data: filtered_data)}
  end

  @impl true
  def handle_event("sort-asc", %{"header" => header}, socket) do
    filtered_data = DataManager.sort({:asc, header})
    {:noreply, assign(socket, filtered_data: filtered_data)}
  end

  @impl true
  def handle_event("sort-desc", %{"header" => header}, socket) do
    filtered_data = DataManager.sort({:desc, header})
    {:noreply, assign(socket, filtered_data: filtered_data)}
  end

  @impl true
  def handle_event("export-csv", _ , socket) do
    url = Task.async(DataManager, :export, [])
          |> Task.await()
    IO.inspect(url, label: "URL IS HERE")
    {:noreply, assign(socket, download_link: url)}
  end

  defp get_table_headers([]), do: []
  defp get_table_headers(data) do
    data
    |> List.first()
    |> Map.keys()
  end
end
