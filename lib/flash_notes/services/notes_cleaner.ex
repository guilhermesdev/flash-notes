defmodule FlashNotes.Services.NotesCleaner do
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

  defp delete_expired_notes do
    NoteStorage.get_all_entries()
    |> Enum.each(fn {key, _value, _expire_at} = note ->
      case Note.is_expired?(note) do
        true -> NoteStorage.delete(key)
        false -> :ok
      end
    end)
  end

  @impl GenServer
  def handle_info(:delete_expired_notes, _state) do
    delete_expired_notes()

    Process.send_after(self(), :delete_expired_notes, @five_minutes)

    {:noreply, nil}
  end
end
