defmodule FlashNotesWeb.LiveView.NotePage do
  @moduledoc """
  The note page live view
  """

  use FlashNotesWeb, :live_view

  alias FlashNotes.Services.NotesStorage

  def mount(%{"note_id" => note_id}, _session, socket) do
    {_, note_text} = NotesStorage.get(note_id)

    {:ok, assign(socket, :note_text, note_text)}
  end
end
