defmodule Mix.Tasks.GoogleApiDefinitions.UpdateDefinitions do
  @moduledoc "Updates Google API definition files for use in shipping the library."
  @shortdoc "Updates Google API definitions."

  use Mix.Task

  import GoogleApiDefinitions

  @requirements ["app.start"]

  @impl Mix.Task
  def run(_args) do
    :ok = fetch_discovery()

    list_discovered()
    |> Map.keys()
    |> fetch_definitions()

    copy_from_internal_to_cwd_priv!()
  end
end
