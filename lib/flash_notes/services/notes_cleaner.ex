defmodule FlashNotes.Services.NotesCleaner do
  @moduledoc """
  This module schedule a task to delete outdated notes periodically
  """

  alias FlashNotes.Entities.Note
  alias FlashNotes.Services.NoteStorage

  use GenServer

  @five_minutes 1000 * 60 * 5

  @impl GenServer
  def init(opts \\ []) do
    Process.send(self(), :delete_expired_notes, [])

    {:ok, opts}
  end

  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  @impl GenServer
  def handle_info(:delete_expired_notes, _state) do
    NoteStorage.get_all_entries()
    |> Enum.each(fn {key, note} ->
      case Note.is_expired?(note) do
        true -> NoteStorage.delete(key)
        false -> :ok
      end
    end)

    Process.send_after(self(), :delete_expired_notes, @five_minutes)

    {:noreply, nil}
  end
end
