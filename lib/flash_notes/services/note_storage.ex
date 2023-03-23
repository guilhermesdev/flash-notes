defmodule FlashNotes.Services.NoteStorage do
  alias FlashNotes.Entities.Note
  @table_name :notes

  def init, do: :dets.open_file(@table_name, type: :set)

  @spec get(String.t()) :: {:empty, nil} | {:ok, String.t()}
  def get(key) do
    :dets.lookup(@table_name, key) |> handle_note_data
  end

  @spec handle_note_data([{String.t(), Note.t()}]) :: {:empty, nil} | {:ok, String.t()}
  defp handle_note_data([]), do: {:empty, nil}

  defp handle_note_data([{key, note}]) do
    case Note.is_expired?(note) do
      true ->
        :dets.delete(@table_name, key)
        {:empty, nil}

      false ->
        {:ok, note.value}
    end
  end

  @spec get_all_entries :: [{String.t(), Note.t()}]
  def get_all_entries do
    :dets.foldl(fn item, acc -> [item | acc] end, [], @table_name)
  end

  @spec put(String.t(), String.t(), integer()) :: :ok
  def put(key, value, ttl) do
    expiration_time = ttl + :os.system_time(:millisecond)

    :dets.insert(@table_name, {key, %Note{value: value, expire_at: expiration_time}})
  end

  @spec delete(String.t()) :: :ok
  def delete(key), do: :dets.delete(@table_name, key)
end
