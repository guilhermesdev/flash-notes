defmodule FlashNotes.Services.NotesStorage do
  @moduledoc """
  This module wraps all the logic related to store the notes on a :dets table
  in a easy way to consume and manage the data
  """

  alias FlashNotes.Entities.Note

  require Logger

  @table_name :notes

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]}
    }
  end

  def start_link(opts \\ []) do
    Logger.info("Starting notes storage...")

    table_name = opts[:table_name] || @table_name

    :dets.open_file(table_name, type: :set)

    Logger.info("Notes storage table created succesfully!")

    Task.start_link(fn ->
      Process.hibernate(Function, :identity, [])
    end)
  end

  @spec get(String.t()) :: {:empty, nil} | {:ok, String.t()}
  def get(key, table_name \\ @table_name) do
    :dets.lookup(table_name, key) |> handle_note_data(table_name)
  end

  @spec handle_note_data([{String.t(), Note.t()}], atom() | String.t()) ::
          {:empty, nil} | {:ok, String.t()}
  defp handle_note_data([], _table_name), do: {:empty, nil}

  defp handle_note_data([{key, note}], table_name) do
    case Note.is_expired?(note) do
      true ->
        delete(key, table_name)
        {:empty, nil}

      false ->
        {:ok, note.value}
    end
  end

  @spec get_all_entries :: [{String.t(), Note.t()}]
  @spec get_all_entries(atom() | String.t()) :: [{String.t(), Note.t()}]
  def get_all_entries(table_name \\ @table_name) do
    :dets.foldl(fn item, acc -> [item | acc] end, [], table_name)
  end

  @spec put(String.t(), String.t(), integer()) :: :ok
  @spec put(String.t(), String.t(), integer(), atom() | String.t()) :: :ok
  def put(key, value, ttl, table_name \\ @table_name) do
    expiration_time = ttl + :os.system_time(:millisecond)

    :dets.insert(table_name, {key, %Note{value: value, expire_at: expiration_time}})
  end

  @spec delete(String.t(), atom() | String.t()) :: :ok
  @spec delete(String.t()) :: :ok
  def delete(key, table_name \\ @table_name), do: :dets.delete(table_name, key)

  @spec delete_all_entries(atom() | String.t()) :: :ok | {:error, any}
  @spec delete_all_entries :: :ok | {:error, any}
  def delete_all_entries(table_name \\ @table_name), do: :dets.delete_all_objects(table_name)
end
