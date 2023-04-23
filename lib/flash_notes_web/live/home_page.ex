defmodule FlashNotesWeb.LiveView.HomePage do
  use FlashNotesWeb, :live_view

  alias FlashNotes.Services.NotesStorage

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :note_url, nil)}
  end

  def handle_event("submit", params, socket) do
    text = params["text"]
    ttl = params["ttl"] |> String.to_integer()

    note_id = Nanoid.generate(8)

    NotesStorage.put(note_id, text, ttl)

    note_url = "#{FlashNotesWeb.Endpoint.url()}/#{note_id}"

    {:noreply, assign(socket, :note_url, note_url)}
  end
end
