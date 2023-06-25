defmodule FlashNotesWeb.LiveView.NotePage do
  @moduledoc """
  The note page live view
  """

  use FlashNotesWeb, :live_view

  alias FlashNotes.Repositories.NotesRepository

  def mount(%{"note_id" => note_id}, _session, socket) do
    {_, note_text} = NotesRepository.get(note_id)

    {:ok, assign(socket, :note_text, note_text)}
  end
end
