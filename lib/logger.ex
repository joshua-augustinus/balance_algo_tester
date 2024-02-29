defmodule Teiserver.Battle.Logger do
  def log(object, label) do
    IO.inspect(object, label: label, charlists: :as_lists)
  end

  def log(object) do
    IO.inspect(object, charlists: :as_lists)
  end
end
