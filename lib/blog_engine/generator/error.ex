defmodule Ember.Generator.Error do
  defexception [:message, :reason, :file]

  @type t :: %__MODULE__{
    message: String.t(),
    reason: atom(),
    file: String.t()
  }

  def new(message, reason, file) do
    %__MODULE__{message: message, reason: reason, file: file}
  end
end
