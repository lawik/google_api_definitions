defmodule GoogleApiDefinitions.MixProject do
  use Mix.Project
  require EEx

  def project do
    [
      name: "Google API Definitions",
      app: :google_api_definitions,
      version: "0.0.1",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      docs: [
        main: "GoogleApiDefinitions",
        extras:
          try do
            extras =
              "extra_pages.term"
              |> File.read!()
              |> :erlang.binary_to_term()

            extras
          rescue
            _ ->
              []
          end
      ]
    ]
  end

  defp description do
    "A library for containing up-to-date (or ancient) Google API definitions. Useful for other libraries to generate things from. Also includes some documentation for the APIs in each version."
  end

  defp package do
    [
      files: ~w(lib priv .formatter.exs mix.exs README.md LICENSE.txt),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/lawik/google_api_definitions"}
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :telemetry, :eex]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.4"},
      {:finch, "~> 0.15"},

      # Docs & Packaging
      {:ex_doc, "~> 0.27", only: :dev, runtime: false}
    ]
  end
end
