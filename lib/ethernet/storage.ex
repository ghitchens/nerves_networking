defmodule Ethernet.Storage do
  use Behaviour


  @type t :: list | map

  @doc """
  Stores the config information for static ip configuration
  """
  defcallback put(t) :: :ok

  @doc """
  Retrieves the config information for static ip configuration
  """
  defcallback get :: t | nil

  @doc """
  Deletes the config information for static ip configuration
  """
  defcallback delete :: :ok | :error
end
