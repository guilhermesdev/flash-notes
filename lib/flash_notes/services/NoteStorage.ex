defmodule FlashNotes.NoteStorage do
  @table_name :notes

  def init, do: :dets.open_file(@table_name, type: :set)

  @spec get(String.t()) :: any
  def get(key) do
    :dets.lookup(@table_name, key) |> handle_note_data
  end

  @spec handle_note_data([]) :: {:empty, nil}
  defp handle_note_data([]), do: {:empty, nil}

  @spec handle_note_data({String.t(), any, integer()}) :: {:empty, nil} | {:ok, any}
  defp handle_note_data([{key, result, expire_at}]) do
    is_expired? = expire_at < :os.system_time(:millisecond)

    case is_expired? do
      true ->
        :dets.delete(@table_name, key)
        {:empty, nil}

      false ->
        {:ok, result}
    end
  end

  def get_all_entries do
    :dets.foldl(fn item, acc -> [item | acc] end, [], @table_name)
  end

  @spec put(String.t(), any, integer()) :: :ok
  def put(key, value, ttl) do
    expiration_time = ttl + :os.system_time(:millisecond)

    :dets.insert(@table_name, {key, value, expiration_time})
  end
end
