defmodule GoogleApiDefinitions.MixProject do
  use Mix.Project
  require EEx

  def project do
    [
      app: :google_api_definitions,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
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
