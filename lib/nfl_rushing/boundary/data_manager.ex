defmodule NflRushing.Boundary.DataManager do
  use GenServer

  @data_file Application.app_dir(:nfl_rushing, "priv/static/rushing_small.json")
  alias NflRushing.Core.Rushing


  #  Client
  def get() do
    GenServer.call(__MODULE__, :get)
  end

  def sort(sort_msg) do
    GenServer.call(__MODULE__, {:sort, sort_msg})
  end

  def export do
    GenServer.call(__MODULE__, :export)
  end

  def filter(query) do
    GenServer.call(__MODULE__, {:filter, query})
  end

  # Server
  def start_link(init_state) do
    GenServer.start_link(__MODULE__, init_state, name: __MODULE__)
  end

  @impl true
  def init(_) do
    init_state = %{data: %{}, filtered_data: %{}}

    {:ok, init_state, {:continue, :get_data}}
  end

  @impl true
  def handle_continue(:get_data, state) do
    data = @data_file |> Rushing.load_file()
    updated_state = Map.put(state, :data, data)

    {:noreply, updated_state}
  end

  @impl true
  def handle_call(:get, _from, state) do
    {:reply, state.data, state}
  end

  @impl true
  def handle_call({:filter, query}, _from, state) do
    filtered_data = state.data |> Rushing.filter(query)
    updated_state = Map.put(state, :filtered_data, filtered_data)

    {:reply, filtered_data, updated_state}
  end

  @impl true
  def handle_call({:sort, sort_msg}, _from, state) do
    filtered_data = state.filtered_data |> Rushing.sort(sort_msg)
    # filtered_data = state.data |> Rushing.sort(sort_msg)
    updated_state = Map.put(state, :filtered_data, filtered_data)

    {:reply, filtered_data, updated_state}
  end

  @impl true
  def handle_call(:export, _from, state) do
    Process.sleep(4000)
    {:reply, @data_file, state}
  end

end
