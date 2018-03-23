defmodule Faker.Locale do

  defmacro __using__(_opts) do
    quote do
      Module.register_attribute __MODULE__, :functions, accumulate: true, persist: false
      import unquote(__MODULE__), only: [localize: 1]
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(env) do
    compile(Module.get_attribute(env.module, :functions))
  end

  def compile(functions) do
    ast = for function <- functions do
      deflocalized(function)
    end
    
    quote do: unquote(ast)
  end

  defp deflocalized(function) do
    quote do
      def unquote(function)() do
        apply(unquote(__MODULE__), :proxy, [{__MODULE__, unquote(function)}])
      end
    end
  end

  def proxy({module, function}) do
    locale_module = Module.concat(module, Faker.mlocale)

    if function_exported?(locale_module, function, 0) do
      apply(module, function, [])
    else
      apply(Module.concat(module, En), function, [])
    end
  end

  defmacro localize(function) when is_atom(function) do
    quote do
      @functions unquote(function)
    end
  end
end
