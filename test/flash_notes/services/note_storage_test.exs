defmodule FlashNotes.Services.NoteStorageTest do
  use ExUnit.Case, async: false

  alias FlashNotes.Services.NoteStorage

  setup_all do
    NoteStorage.init()
    NoteStorage.delete_all_entries()

    :ok
  end

  setup do
    NoteStorage.delete_all_entries()
  end

  test "it should return a tuple with :empty atom and nil value if the note with given key does not exists" do
    assert {:empty, nil} == NoteStorage.get("some-key")
  end

  test "it should return a tuple with :ok atom and a text if the note with given key does exists" do
    NoteStorage.put("some-key", "some text", 1_000_000)

    assert {:ok, "some text"} == NoteStorage.get("some-key")
  end

  test "it should return a tuple with :empty atom and nil if the note with given key is expired" do
    ttl = 5

    NoteStorage.put("some-key", "some text", ttl)

    Process.sleep(ttl + 1)

    assert {:empty, nil} == NoteStorage.get("some-key")
  end
end
