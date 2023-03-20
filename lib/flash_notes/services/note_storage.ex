defmodule FlashNotes.Services.NoteStorage do
  alias FlashNotes.Entities.Note
  @table_name :notes

  def init, do: :dets.open_file(@table_name, type: :set)

  @spec get(String.t()) :: any
  def get(key) do
    :dets.lookup(@table_name, key) |> handle_note_data
  end

  @spec handle_note_data([]) :: {:empty, nil}
  defp handle_note_data([]), do: {:empty, nil}

  @spec handle_note_data({String.t(), any, integer()}) :: {:empty, nil} | {:ok, any}
  defp handle_note_data([{key, result, _expire_at} = note]) do
    case Note.is_expired?(note) do
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

  @spec delete(String.t()) :: :ok
  def delete(key), do: :dets.delete(@table_name, key)
end
