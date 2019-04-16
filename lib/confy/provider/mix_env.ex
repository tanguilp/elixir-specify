defmodule Confy.Provider.MixEnv do
  @moduledoc """
  A Configuration Provider source based on `Mix.env()` / `Application.get_env`.

  """
  defstruct [:application, :key]

  @doc """
  By default, will try to use `Application.get_all_env(YourConfigModule)` to fetch the source's configuration.
  A differnt application name can be used by supplying a different `application` argument.

  If the actual configuration is only inside one of the keys in this application, the second field `key`
  can also be provided.
  """
  def new(application \\ nil, key \\ nil) do
    %__MODULE__{application: application, key: key}
  end

  defimpl Confy.Provider do
    def load(%Confy.Provider.MixEnv{application: nil, key: nil}, module) do
      {:ok, Enum.into(Application.get_all_env(module), %{})}
    end
    def load(%Confy.Provider.MixEnv{application: application, key: nil}, module) do
      load(%Confy.Provider.MixEnv{application: application, key: module}, module)
    end
    def load(%Confy.Provider.MixEnv{application: application, key: key}, _module) do
      case Application.get_env(application, key, :there_is_no_confy_configuration_in_this_application_environment!) do
        map when is_map(map) ->
          {:ok, map}
        list when is_list(list) ->
          {:ok, Enum.into(list, %{})}
        :there_is_no_confy_configuration_in_this_application_environment! ->
          {:error, :not_found}
        _other ->
          {:error, :malformed}
      end
    end
  end
end
