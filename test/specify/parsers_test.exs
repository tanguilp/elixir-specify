defmodule Specify.ParsersTest do
  use ExUnit.Case
  use ExUnitProperties

  doctest Specify.Parsers
  alias Specify.Parsers

  describe "integer/1" do
    property "works on integers" do
      check all int <- integer() do
        assert Parsers.integer(int) === {:ok, int}
      end
    end

    property "works on binaries representing integers" do
      check all int <- integer() do
        str = to_string(int)
        assert Parsers.integer(str) === {:ok, int}
      end
    end

    property "fails on binaries representing integers with trailing garbage" do
      check all int <- integer(),  postfix <- string(:printable), Integer.parse(postfix) == :error, postfix != "" do
        str = to_string(int)
        assert {:error, _} = Parsers.integer(str <> postfix)
      end
    end

    property "fails on non-integer terms" do
      check all thing <- term() do
        if is_integer(thing) do
          assert {:ok, thing} = Parsers.integer(thing)
        else
          if !is_binary(thing) || Integer.parse(thing) == :error do
            assert {:error, _} = Parsers.integer(thing)
          end
        end
      end
    end
  end

  describe "nonnegative_integer/1" do
    property "works on non-negative integers, fails on negative integers" do
      check all int <- integer() do
        if int >= 0 do
          assert Parsers.nonnegative_integer(int) === {:ok, int}
        else
          assert {:error, _} = Parsers.nonnegative_integer(int)
        end
      end
    end

    property "works on binaries representing non-negative integers, fails on binaries representing negative integers" do
      check all int <- integer() do
        str = to_string(int)
        if int >= 0 do
          assert Parsers.nonnegative_integer(str) === {:ok, int}
        else
          assert {:error, _} = Parsers.nonnegative_integer(str)
        end
      end
    end

    property "fails on binaries representing non-negative integers with trailing garbage" do
      check all int <- integer(), postfix <- string(:printable), Integer.parse(postfix) == :error, postfix != "" do
        str = to_string(int)
        assert {:error, _} = Parsers.nonnegative_integer(str <> postfix)
      end
    end

    property "fails on non-integer terms" do
      check all thing <- term() do
        if is_integer(thing) && thing >= 0 do
          assert {:ok, thing} = Parsers.nonnegative_integer(thing)
        else
          if !is_binary(thing) || Integer.parse(thing) == :error do
            assert {:error, _} = Parsers.nonnegative_integer(thing)
          end
        end
      end
    end
  end

  describe "positive_integer/1" do
    property "works on positive integers, fails on other integers" do
      check all int <- integer() do
        if int > 0 do
          assert Parsers.positive_integer(int) === {:ok, int}
        else
          assert {:error, _} = Parsers.positive_integer(int)
        end
      end
    end

    property "works on binaries representing positive integers, fails on binaries representing other integers" do
      check all int <- integer() do
        str = to_string(int)
        if int > 0 do
          assert Parsers.positive_integer(str) === {:ok, int}
        else
          assert {:error, _} = Parsers.positive_integer(str)
        end
      end
    end

    property "fails on binaries representing non-negative integers with trailing garbage" do
      check all int <- integer(), postfix <- string(:printable), Integer.parse(postfix) == :error, postfix != "" do
        str = to_string(int)
        assert {:error, _} = Parsers.positive_integer(str <> postfix)
      end
    end

    property "fails on non-integer terms" do
      check all thing <- term() do
        if is_integer(thing) && thing > 0 do
          assert {:ok, thing} = Parsers.positive_integer(thing)
        else
          if !is_binary(thing) || Integer.parse(thing) == :error do
            assert {:error, _} = Parsers.positive_integer(thing)
          end
        end
      end
    end
  end

  describe "float/1" do
    property "works on floats" do
      check all float <- float() do
        assert Parsers.float(float) === {:ok, float}
      end
    end

    property "works on integers" do
      check all int <- integer() do
        assert Parsers.float(int) === {:ok, int * 1.0}
      end
    end

    property "works on binaries representing floats" do
      check all float <- float() do
        str = to_string(float)
        assert Parsers.float(str) === {:ok, float}
      end
    end

    property "fails on binaries representing floats with trailing garbage" do
      check all float <- float(),  postfix <- string(:printable), Float.parse(postfix) == :error, postfix != "" do
        str = to_string(float)
        assert {:error, _} = Parsers.float(str <> postfix)
      end
    end

    property "works on binaries representing integers" do
      check all int <- integer() do
        str = to_string(int)
        assert Parsers.float(str) === {:ok, 1.0 * int}
      end
    end

    property "fails on non-integer, non-float terms" do
      check all thing <- term() do
        if(is_float(thing) or is_integer(thing)) do
          assert {:ok, 1.0 * thing} == Parsers.float(thing)
        else
          if !is_binary(thing) || Float.parse(thing) == :error do
            assert {:error, _} = Parsers.float(thing)
          end
        end
      end
    end
  end

  describe "nonnegative_float/1" do
    property "works on non-negative floats, fails on negative floats" do
      check all float <- float() do
        if float >= 0 do
          assert Parsers.nonnegative_float(float) === {:ok, float}
        else
          assert {:error, _} = Parsers.nonnegative_float(float)
        end
      end
    end

    property "works on non-negative integers, fails on negative integers" do
      check all int <- integer() do
        if int >= 0 do
          assert Parsers.nonnegative_float(int) === {:ok, int * 1.0}
        else
          assert {:error, _} = Parsers.nonnegative_float(int)
        end
      end
    end

    property "works on binaries representing non-negative floats, fails on binaries representing negative floats" do
      check all float <- float() do
        str = to_string(float)
        if float >= 0 do
          assert Parsers.nonnegative_float(str) === {:ok, float}
        else
          assert {:error, _} = Parsers.nonnegative_float(str)
        end
      end
    end

    property "fails on binaries representing floats with trailing garbage" do
      check all float <- float(),  postfix <- string(:printable), Float.parse(postfix) == :error, postfix != "" do
        str = to_string(float)
        assert {:error, _} = Parsers.nonnegative_float(str <> postfix)
      end
    end

    property "works on binaries representing non-negative integers, fails on binaries representing negative integers" do
      check all int <- integer() do
        str = to_string(int)
        if int >= 0 do
          assert Parsers.nonnegative_float(str) === {:ok, 1.0 * int}
        else
          assert {:error, _} = Parsers.nonnegative_float(str)
        end
      end
    end

    property "fails on non-float, non-integer terms" do
      check all thing <- term() do
        if (is_float(thing) or is_integer(thing)) and thing >= 0 do
          assert {:ok, 1.0 * thing} == Parsers.nonnegative_float(thing)
        else
          if !is_binary(thing) || Float.parse(thing) == :error do
            assert {:error, _} = Parsers.nonnegative_float(thing)
          end
        end
      end
    end
  end

  describe "positive_float/1" do
    property "works on positive floats, fails on negative floats" do
      check all float <- float() do
        if float > 0 do
          assert Parsers.positive_float(float) === {:ok, float}
        else
          assert {:error, _} = Parsers.positive_float(float)
        end
      end
    end

    property "works on positive integers, fails on negative integers" do
      check all int <- integer() do
        if int > 0 do
          assert Parsers.positive_float(int) === {:ok, int * 1.0}
        else
          assert {:error, _} = Parsers.positive_float(int)
        end
      end
    end

    property "works on binaries representing positive floats, fails on binaries representing negative floats" do
      check all float <- float() do
        str = to_string(float)
        if float > 0 do
          assert Parsers.positive_float(str) === {:ok, float}
        else
          assert {:error, _} = Parsers.positive_float(str)
        end
      end
    end

    property "fails on binaries representing floats with trailing garbage" do
      check all float <- float(),  postfix <- string(:printable), Float.parse(postfix) == :error, postfix != "" do
        str = to_string(float)
        assert {:error, _} = Parsers.positive_float(str <> postfix)
      end
    end

    property "works on binaries representing positive integers, fails on binaries representing negative integers" do
      check all int <- integer() do
        str = to_string(int)
        if int > 0 do
          assert Parsers.positive_float(str) === {:ok, 1.0 * int}
        else
          assert {:error, _} = Parsers.positive_float(str)
        end
      end
    end

    property "fails on non-float, non-integer terms" do
      check all thing <- term() do
        if (is_float(thing) or is_integer(thing)) and thing >= 0 do
          assert {:ok, 1.0 * thing} == Parsers.nonnegative_float(thing)
        else
          if !is_binary(thing) || Float.parse(thing) == :error do
            assert {:error, _} = Parsers.nonnegative_float(thing)
          end
        end
      end
    end
  end

  describe "string/1" do
    property "works on binaries" do
      check all bin <- string(:printable) do
        assert {:ok, bin} = Parsers.string(bin)
      end
    end

    property "works on charlists" do
      check all bin <- string(:printable) do
        chars = to_charlist(bin)
        assert {:ok, bin} = Parsers.string(chars)
      end
    end

    property "works on terms that implement String.Chars" do
      check all thing <-
                  one_of([
                    integer(),
                    string(:printable),
                    binary(),
                    float(),
                    boolean(),
                    atom(:alphanumeric)
                  ]) do
        assert {:ok, "#{thing}"} == Parsers.string(thing)
      end
    end
  end

  describe "boolean/1" do
    property "works on booleans" do
      check all bool <- boolean() do
        assert {:ok, bool} == Parsers.boolean(bool)
      end
    end

    property "works on strings representing booleans" do
      check all bool <- boolean() do
        str = to_string(bool)
        assert {:ok, bool} == Parsers.boolean(str)
      end
    end

    property "does not work on non-boolean terms" do
      check all thing <- term() do
        if is_boolean(thing) do
          assert {:ok, thing} == Parsers.boolean(thing)
        else
          assert {:error, _} = Parsers.boolean(thing)
        end
      end
    end
  end

  describe "atom/1 and unsafe_atom/1" do
    property "works on atoms" do
      check all atom <- one_of([atom(:alphanumeric), atom(:alias)]) do
        assert {:ok, atom} == Parsers.atom(atom)
        assert {:ok, atom} == Parsers.unsafe_atom(atom)
      end
    end

    property "Works on strings" do
      check all atom <- one_of([atom(:alphanumeric), atom(:alias)]) do
        str = to_string(atom)
        assert {:ok, atom} == Parsers.atom(str)
        assert {:ok, atom} == Parsers.unsafe_atom(str)
      end
    end

    test "atom/1 raises on non-existent atom" do
      assert {:error, _} = Parsers.atom("this_does_not_exist_as_atom")
      assert {:error, _} = Parsers.atom("This.Module.Does.Not.Exist.Either")
    end

    test "unsafe_atom/1 does noton non-existent atom" do
      assert {:ok, :this_does_not_exist_as_atom2} =
               Parsers.unsafe_atom("this_does_not_exist_as_atom2")

      assert {:ok, This.Module.Does.Not.Exist.Either2} =
               Parsers.unsafe_atom("Elixir.This.Module.Does.Not.Exist.Either2")
    end
  end

  describe "list/2" do
    property "works on lists of atoms" do
      check all list <- list_of(atom(:alphanumeric)) do
        assert {:ok, list} == Parsers.list(list, &Parsers.atom/1)
      end
    end

    property "works on strings representing lists of atoms" do
      check all list <- list_of(atom(:alphanumeric)) do
        str = inspect(list, limit: :infinity)
        assert {:ok, list} == Parsers.list(str, &Parsers.atom/1)
      end
    end

    property "works on lists of integers" do
      check all list <- list_of(integer()) do
        assert {:ok, list} == Parsers.list(list, &Parsers.integer/1)
      end
    end

    property "works on strings representing lists of integers" do
      check all list <- list_of(integer()) do
        str = inspect(list, limit: :infinity)
        assert {:ok, list} == Parsers.list(str, &Parsers.integer/1)
      end
    end

    property "works on strings representing lists of arbitrary terms" do
      check all list <- list_of(supported_terms_generator()) do
        str = inspect(list, limit: :infinity)
        assert {:ok, list} == Parsers.list(str, &Parsers.term/1)
      end
    end
  end

  describe "timeout/1" do
    test "works on `:infinity` (both as atom and as binary)" do
      assert Parsers.timeout(:infinity) === {:ok, :infinity}
      assert Parsers.timeout("infinity") === {:ok, :infinity}
    end

    property "works on positive integers, fails on other integers" do
      check all int <- integer() do
        if int > 0 do
          assert Parsers.timeout(int) === {:ok, int}
        else
          assert {:error, _} = Parsers.timeout(int)
        end
      end
    end

    property "works on binaries representing positive integers, fails on binaries representing other integers" do
      check all int <- integer() do
        str = to_string(int)
        if int > 0 do
          assert Parsers.timeout(str) === {:ok, int}
        else
          assert {:error, _} = Parsers.timeout(str)
        end
      end
    end

    property "fails on binaries representing non-negative integers with trailing garbage" do
      check all int <- integer(), postfix <- string(:printable), Integer.parse(postfix) == :error, postfix != "" do
        str = to_string(int)
        assert {:error, _} = Parsers.integer(str <> postfix)
      end
    end

    property "fails on non-integer, non-`:infinity` terms" do
      check all thing <- term() do
        if thing == :infinity || (is_integer(thing) && thing > 0) do
          assert {:ok, thing} = Parsers.timeout(thing)
        else
          if !is_binary(thing) || Integer.parse(thing) == :error do
            assert {:error, _} = Parsers.timeout(thing)
          end
        end
      end
    end
  end

  describe "mfa/1" do
    property "works on MFA tuples of existing functions (and binaries of the same)" do
      existing_mfas =
        Enum.__info__(:functions)
        |> Enum.map(fn {fun, arity} -> constant({Enum, fun, arity}) end)
      check all mfa <- one_of(existing_mfas) do
        assert {:ok, fun} = Parsers.mfa(mfa)
        assert {:ok, fun} = Parsers.mfa(inspect(mfa))
      end
    end

    property "Fails on MFA tuples of non-existing functions" do
      check all module <- atom(:alphanumeric), fun <- atom(:alphanumeric), arity <- integer(), !function_exported?(module, fun, arity) do
        assert {:error, res} = Parsers.mfa({module, fun, abs(arity)})
      end
    end
  end

  describe "function/1" do
    property "works on MFA tuples of existing functions (and binaries of the same)" do
      existing_mfas =
        Enum.__info__(:functions)
        |> Enum.map(fn {fun, arity} -> constant({Enum, fun, arity}) end)
      check all mfa <- one_of(existing_mfas) do
        assert {:ok, fun} = Parsers.mfa(mfa)
        assert {:ok, fun} = Parsers.mfa(inspect(mfa))
      end
    end

    property "Fails on MFA tuples of non-existing functions" do
      check all module <- atom(:alphanumeric), fun <- atom(:alphanumeric), arity <- integer(), !function_exported?(module, fun, arity) do
        assert {:error, res} = Parsers.mfa({module, fun, abs(arity)})
      end
    end
  end

  describe "one_of_atoms/2" do
    test "works on atoms" do
      assert {:ok, :atom2} == Parsers.one_of_atoms(:atom2, [:atom1, :atom2, :atom3])
      assert {:error, _} = Parsers.one_of_atoms(:atom4, [:atom1, :atom2, :atom3])
    end

    test "works on strings" do
      assert {:ok, :atom2} == Parsers.one_of_atoms("atom2", [:atom1, :atom2, :atom3])
      assert {:error, _} = Parsers.one_of_atoms("atom4", [:atom1, :atom2, :atom3])
    end
  end

  describe "one_of_strings/2" do
    test "works on strings" do
      assert {:ok, "str2"} == Parsers.one_of_strings("str2", ["str1", "str2", "str3"])
      assert {:error, _} = Parsers.one_of_strings("str4", ["str1", "str2", "str3"])
    end
  end

  describe "option/1" do
    property "works on option of arbitrary term" do
      check all option <- tuple({atom(:alphanumeric), supported_terms_generator()}) do
        assert {:ok, option} == Parsers.option(option)
      end
    end

    property "works on strings representing options of arbitrary terms" do
      check all option <- tuple({atom(:alphanumeric), supported_terms_generator()}) do
        str = inspect(option, limit: :infinity)
        assert {:ok, option} == Parsers.option(str)
      end
    end
  end

  defp supported_terms_generator(max_depth \\ 2) do
    generators = [
      boolean(),
      float(),
      integer(),
      string(:ascii),
      string(:alphanumeric),
      string(:printable),
    ]

    generators
    |> maybe_add_tuple_generator(max_depth)
    |> maybe_add_map_generator(max_depth)
    |> one_of()
  end

  defp maybe_add_tuple_generator(generators, 0) do
    generators
  end

  defp maybe_add_tuple_generator(generators, max_depth) do
    [
      (for _ <- 1..Enum.random(1..5), do: supported_terms_generator(max_depth - 1))
      |> List.to_tuple()
      |> tuple
    | generators]
  end

  defp maybe_add_map_generator(generators, 0) do
    generators
  end

  defp maybe_add_map_generator(generators, max_depth) do
    [
      map_of(
        supported_terms_generator(max_depth - 1),
        supported_terms_generator(max_depth - 1),
        max_length: 5
      )
      | generators
    ]
  end
end
