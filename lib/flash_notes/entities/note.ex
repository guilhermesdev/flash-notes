defmodule FlashNotes.Entities.Note do
  @enforce_keys [:value, :expire_at]
  defstruct [:value, :expire_at]

  @type t :: %__MODULE__{value: any(), expire_at: integer()}

  @spec is_expired?(t()) :: boolean
  def is_expired?(note), do: note.expire_at < :os.system_time(:millisecond)
end
