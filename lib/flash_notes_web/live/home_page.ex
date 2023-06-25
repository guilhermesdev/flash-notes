defmodule FlashNotesWeb.LiveView.HomePage do
  @moduledoc """
  The home page live view
  """

  use FlashNotesWeb, :live_view

  alias FlashNotes.Repositories.NotesRepository

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :note_url, nil)}
  end

  def handle_event("submit", params, socket) do
    text = params["text"]
    ttl = params["ttl"] |> String.to_integer()

    note_id = Nanoid.generate(8)

    NotesRepository.put(note_id, text, ttl)

    base_url =
      case FlashNotesWeb.Endpoint.host() do
        "localhost" -> FlashNotesWeb.Endpoint.url()
        _ -> FlashNotesWeb.Endpoint.host()
      end

    note_url = "#{base_url}/#{note_id}"

    {:noreply, assign(socket, :note_url, note_url)}
  end
end
