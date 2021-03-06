defmodule Specify.Provider.MixEnv do
  @moduledoc """
  A Configuration Provider source based on `Mix.env()` / `Application.get_env/2`.

  ### Examples

  The following examples use the following specification for reference:

      defmodule Elixir.Pet do
        require Specify
        Specify.defconfig do
          @doc "The name of the pet"
          field :name, :string
          @doc "is it a dog or a cat?"
          field :kind, :atom
        end
      end


  """
  defstruct [:application, :key, optional: false]

  @doc """
  By default, will try to use `Application.get_all_env(YourConfigModule)` to fetch the source's configuration.
  A different application name can be used by supplying a different `application` argument.

  If the actual configuration is only inside one of the keys in this application, the second field `key`
  can also be provided.


      iex> Application.put_env(Elixir.Pet, :name, "Timmy")
      iex> Application.put_env(Elixir.Pet, :kind, "cat")
      iex> Pet.load(sources: [Specify.Provider.MixEnv.new()])
      %Pet{name: "Timmy", kind: :cat}
      iex> Pet.load(sources: [Specify.Provider.MixEnv.new(Elixir.Pet)])
      %Pet{name: "Timmy", kind: :cat}

      iex> Application.put_env(:second_pet, :name, "John")
      iex> Application.put_env(:second_pet, :kind, :dog)
      iex> Pet.load(sources: [Specify.Provider.MixEnv.new(:second_pet)])
      %Pet{name: "John", kind: :dog}

  """
  def new(application \\ nil, key \\ nil, options \\ []) do
    optional = options[:optional] || false
    %__MODULE__{application: application, key: key, optional: optional}
  end

  defimpl Specify.Provider do
    def load(%Specify.Provider.MixEnv{application: nil, key: nil, optional: optional}, module) do
      res =  Enum.into(Application.get_all_env(module), %{})

      case {Enum.empty?(res), optional} do
        {true, false} ->
          {:error, :not_found}
        _ ->
          {:ok, res}
      end
    end

    def load(%Specify.Provider.MixEnv{application: application, key: nil, optional: optional}, _module) do
      res = Enum.into(Application.get_all_env(application), %{})

      case {Enum.empty?(res), optional} do
        {true, false} ->
          {:error, :not_found}
        _ ->
          {:ok, res}
      end
    end

    def load(%Specify.Provider.MixEnv{application: application, key: key, optional: optional}, _module) do
      case Application.get_env(
             application,
             key,
             :there_is_no_specify_configuration_in_this_application_environment!
           ) do
        map when is_map(map) ->
          {:ok, map}

        list when is_list(list) ->
          {:ok, Enum.into(list, %{})}

        :there_is_no_specify_configuration_in_this_application_environment! ->
          if optional do
            {:ok, %{}}
          else
            {:error, :not_found}
          end

        _other ->
          {:error, :malformed}
      end
    end
  end
end
