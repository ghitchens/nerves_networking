defmodule Ethernet.Storage do
  @moduledoc """
  Behaviour describing the necessary methods a module must implement to enable
  "storage" of static configuration options provided during runtime.

  To utilize a behaviour you must specify it in the applications config file.

  ## Examples
  ```
  config :ethernet, storage: YourCustomStorageModule
  ```
  """
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
