defmodule EthernetPersistentStorage do
  @moduledoc """
  Example way of adding storage for static configuration values.

  This would be utilized by adding the following to your projects config.exs:

  ```
  config :ethernet, storage: EthernetPersistentStorage
  ```

  This would also add a dependency on `cellulose/persistent_storage`
  """

  @behaviour Ethernet.Storage

  @static_config_key :eth_static_config

  @type t :: list | map

  @doc """
  Stores a `Dict` of values using PersistentStorage
  """
  @spec put(t) :: :ok
  def put(values) do
    PersistentStorage.put @static_config_key, values
  end

  @doc """
  Gets the values stored by put/1 returned as `Dict`
  """
  @spec get :: t
  def get do
    PersistentStorage.get @static_config_key
  end

  @doc """
  Removes the configuration stored by `put/1`
  """
  @spec delete :: :ok | :error
  def delete do
    case PersistentStorage.delete @static_config_key do
      {:error, _} -> :error
      _ -> :ok
    end
  end
end
