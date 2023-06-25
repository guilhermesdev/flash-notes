defmodule FlashNotes.Workers.NotesCleaner do
  @moduledoc """
  This module schedule a task to delete outdated notes periodically
  """

  alias FlashNotes.Entities.Note
  alias FlashNotes.Repositories.NotesRepository

  require Logger

  use GenServer

  @interval :timer.minutes(5)

  def start_link(opts \\ []) do
    Logger.info("Starting notes cleaner worker...")
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl GenServer
  def init(opts) do
    Process.send(self(), {:delete_expired_notes, opts[:table_name]}, [])

    {:ok, nil}
  end

  @impl GenServer
  def handle_info({:delete_expired_notes, table_name}, _state) do
    Logger.info("Cleaning expired notes...")

    NotesRepository.get_all_entries(table_name)
    |> Enum.each(fn {key, note} ->
      case Note.is_expired?(note) do
        true -> NotesRepository.delete(key, table_name)
        false -> :ok
      end
    end)

    Logger.info("Expired notes cleaned successfully!")

    Process.send_after(self(), {:delete_expired_notes, table_name}, @interval)

    {:noreply, nil}
  end
end
