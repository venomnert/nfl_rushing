defmodule NflRushing.Boundary.DataManager do
  @data_file Application.app_dir(:nfl_rushing, "priv/static/rushing.json")

  use GenServer

  alias NflRushing.Core.Rushing
  @chunks 5

  #  Client
  def get() do
    GenServer.call(__MODULE__, :get)
  end

  def next() do
    GenServer.call(__MODULE__, :next)
  end

  def reset_filter() do
    GenServer.call(__MODULE__, :reset_filter)
  end

  def sort(sort_msg) do
    GenServer.call(__MODULE__, {:sort, sort_msg})
  end

  def export(file) do
    GenServer.call(__MODULE__, {:export, file})
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
    init_state = %{data: [], filtered_data: [], headers: [], next_stream: nil}

    {:ok, init_state, {:continue, :get_data}}
  end

  @impl true
  def handle_continue(:get_data, state) do
    {data, next_stream} = @data_file |> Rushing.load_file_stream(@chunks)
    updated_state = Map.put(state, :data, data)
                    |> Map.put(:headers, Rushing.get_headers(data))
                    |> Map.put(:filtered_data, data)
                    |> Map.put(:next_stream, next_stream)

    {:noreply, updated_state}
  end

  @impl true
  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call(:reset_filter, _from, state) do
    updated_state = Map.put(state, :filtered_data, state.data)

    {:reply, updated_state, updated_state}
  end

  @impl true
  def handle_call(:next, _from, state) do
    {data, next_stream} = state.next_stream |> Rushing.next(@chunks)
    updated_data = state.data ++ data
    updated_state = Map.put(state, :data, updated_data)
                    |> Map.put(:filtered_data, updated_data)
                    |> Map.put(:next_stream, next_stream)

    {:reply, updated_state, updated_state}
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
    updated_state = Map.put(state, :filtered_data, filtered_data)

    {:reply, filtered_data, updated_state}
  end

  @impl true
  def handle_call({:export, file}, _from, state) do
    state.filtered_data
    |> Rushing.create_csv(state.headers, file)
    
    {:reply, :ok, state}
  end
end
