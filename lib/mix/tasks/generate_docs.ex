defmodule Mix.Tasks.GoogleApiDefinitions.GenerateDocs do
  @moduledoc "Updates documentation from current Google API definitions."
  @shortdoc "Updates documentation for Google API definitions."

  use Mix.Task

  @requirements ["app.start"]

  @impl Mix.Task
  def run(_args) do
    paths =
      GoogleApiDefinitions.Docs.discovery_to_pages()
      |> :erlang.term_to_binary()

    File.write!("extra_pages.term", paths)
  end
end
