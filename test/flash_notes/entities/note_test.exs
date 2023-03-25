defmodule FlashNotes.Entities.NoteTest do
  use ExUnit.Case, async: true

  @moduletag :note

  alias FlashNotes.Entities.Note

  describe "Note.is_expired?/1" do
    @describetag :note_is_expired

    test "should return true if given note has a past date in expire_at" do
      expired_note = %Note{value: "", expire_at: :os.system_time(:millisecond) - 1}

      assert Note.is_expired?(expired_note) == true
    end

    test "should return false if given note has a future date in expire_at" do
      non_expired_note = %Note{value: "", expire_at: :os.system_time(:millisecond) + 1_000_000}

      assert Note.is_expired?(non_expired_note) == false
    end
  end
end
