defmodule NflRushingWeb.PageLive do
  use NflRushingWeb, :live_view

  alias NflRushing.Boundary.DataManager

  @impl true
  def mount(_params, _session, socket) do
    data = DataManager.get()
    update_socket = assign(socket,
                            headers: data.headers,
                            filtered_data: data.filtered_data,
                            query: "",
                            download_link: nil)
    {:ok, update_socket}
  end

  @impl true
  def handle_event("filter-player", %{"q" => query}, socket) do
    String.length(query)
    |> case do
        0 ->
          updated_socket = reset_data(socket)
          {:noreply, updated_socket}

        _ ->
          filtered_data = DataManager.filter(query)
          updated_socket = assign(socket, filtered_data: filtered_data, download_link: nil)
          {:noreply, updated_socket}
    end
  end

  @impl true
  def handle_event("reset", _params, socket) do
    updated_socket = reset_data(socket)
    {:noreply, updated_socket}
  end

  @impl true
  def handle_event("sort-asc", %{"header" => header}, socket) do
    filtered_data = DataManager.sort({:asc, header})
    updated_socket = assign(socket, filtered_data: filtered_data, download_link: nil)
    {:noreply, updated_socket}
  end

  @impl true
  def handle_event("sort-desc", %{"header" => header}, socket) do
    filtered_data = DataManager.sort({:desc, header})
    updated_socket = assign(socket, filtered_data: filtered_data, download_link: nil)
    {:noreply, updated_socket}
  end

  @impl true
  def handle_event("export-csv", _ , socket) do
    url = Task.async(DataManager, :export, [])
          |> Task.await()
    {:noreply, assign(socket, download_link: url)}
  end

  defp reset_data(socket) do
    data = DataManager.reset_filter()

    socket
    |> assign(
      filtered_data: data.filtered_data,
      query: "",
      download_link: nil
    )
  end

end
