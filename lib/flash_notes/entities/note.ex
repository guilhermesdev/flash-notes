defmodule FlashNotes.Entities.Note do
  @spec is_expired?({String.t(), any, integer()}) :: boolean
  def is_expired?({_key, _value, expire_at}), do: expire_at < :os.system_time(:millisecond)
end
