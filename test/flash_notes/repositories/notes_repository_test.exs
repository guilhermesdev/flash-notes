defmodule FlashNotes.Repositories.NotesRepositoryTest do
  use ExUnit.Case, async: false

  alias FlashNotes.Repositories.NotesRepository

  @table_name :test_notes_table

  setup_all do
    NotesRepository.start_link(table_name: @table_name)
    NotesRepository.delete_all_entries(@table_name)

    :ok
  end

  setup do
    NotesRepository.delete_all_entries(@table_name)
  end

  test "it should return a tuple with :empty atom and nil value if the note with given key does not exists" do
    assert {:empty, nil} == NotesRepository.get("some-key", @table_name)
  end

  test "it should return a tuple with :ok atom and a text if the note with given key does exists" do
    NotesRepository.put("some-key", "some text", 1_000_000, @table_name)

    assert {:ok, "some text"} == NotesRepository.get("some-key", @table_name)
  end

  test "it should return a tuple with :empty atom and nil if the note with given key is expired" do
    ttl = 5

    NotesRepository.put("some-key", "some text", ttl, @table_name)

    Process.sleep(ttl + 1)

    assert {:empty, nil} == NotesRepository.get("some-key", @table_name)
  end
end
