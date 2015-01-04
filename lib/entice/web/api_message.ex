defmodule Entice.Web.ApiMessage do
  @moduledoc """
  Simple API message helpers, that are kinda like templates but more simple.
  """

  def ok(msg), do: Map.merge(%{status: :ok}, msg)
  def error(msg), do: Map.merge(%{status: :error}, msg)
end
