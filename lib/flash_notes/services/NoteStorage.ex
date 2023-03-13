defmodule FlashNotes.NoteStorage do
  use GenServer

  @impl GenServer
  def init(state \\ nil) do
    :dets.open_file(:notes, type: :set)
    {:ok, state}
  end

  def start_link(opts \\ []), do: GenServer.start_link(__MODULE__, opts, name: __MODULE__)

  @impl GenServer
  @spec handle_call(
          {:put, {String.t(), any, integer()}},
          {pid, term},
          any
        ) :: {:reply, any, nil}
  def handle_cast({:put, {key, value, ttl}}, _) do
    expiration_time = ttl + :os.system_time(:millisecond)

    :dets.insert(:notes, {key, value, expiration_time})

    {:noreply, nil}
  end

  @impl GenServer
  @spec handle_call(
          {:get, String.t()},
          {pid(), term()},
          any()
        ) :: {:reply, any(), nil}
  def handle_call({:get, key}, _from, _) do
    :dets.lookup(:notes, key) |> handle_note_data
  end

  @spec handle_note_data({String.t(), any, integer()}) :: any
  defp handle_note_data([{key, result, expire_at}]) do
    is_expired? = expire_at < :os.system_time(:millisecond)

    case is_expired? do
      true ->
        :dets.delete(:notes, key)
        {:reply, nil, nil}

      false ->
        {:reply, result, nil}
    end
  end

  @spec handle_note_data([]) :: any
  defp handle_note_data([]), do: {:reply, nil, nil}

  @spec put(String.t(), any, integer()) :: :ok
  def put(key, value, ttl), do: GenServer.cast(__MODULE__, {:put, {key, value, ttl}})

  @spec get(String.t()) :: any
  def get(key), do: GenServer.call(__MODULE__, {:get, key})
end
