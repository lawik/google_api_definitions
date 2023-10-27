defmodule GoogleApiDefinitions do
  @discovery_url "https://discovery.googleapis.com/discovery/v1/apis"
  @discovery_file "discovery.json.gz"
  @definitions_dir "definitions"

  require Logger

  def fetch_discovery do
    start_finch()
    path = discovery_path!()
    fetch_to_file(@discovery_url, path)
  end

  def list_discovered do
    discovered =
      discovery_path!()
      |> File.stream!([:compressed])
      |> Enum.into(<<>>)
      |> Jason.decode!()

    discovered["items"]
    |> Enum.map(fn %{"id" => id, "title" => title} ->
      {id, title}
    end)
    |> Map.new()
  end

  def list_discovered_full do
    discovered =
      discovery_path!()
      |> File.stream!([:compressed])
      |> Enum.into(<<>>)
      |> Jason.decode!()

    discovered["items"]
    |> Enum.map(fn item ->
      {item["id"], item}
    end)
    |> Map.new()
  end

  def fetch_definitions([_ | _] = ids) do
    start_finch()

    list_discovered_full()
    |> Map.take(ids)
    |> Task.async_stream(
      fn {id, disco} ->
        Logger.info(
          "Fetching #{disco["title"]} (#{disco["version"]}) from #{disco["discoveryRestUrl"]}..."
        )

        fetch_to_file(disco["discoveryRestUrl"], definition_path(id))
        Logger.info("Written to #{definition_path(id)}.")
      end,
      timeout: 30_000
    )
    |> Enum.to_list()
  end

  def copy_from_internal_to_cwd_priv! do
    from_disco = discovery_path!()
    to_disco = Path.join([File.cwd!(), "priv", @discovery_file])
    Logger.info("Copying #{from_disco} to #{to_disco}.")
    File.cp!(from_disco, to_disco)

    from_defs = definitions_dir()
    to_defs = Path.join([File.cwd!(), "priv", @definitions_dir])
    Logger.info("Copying recursively #{from_defs} to #{to_defs}.")
    File.cp_r!(from_defs, to_defs)
  end

  defp discovery_path! do
    dir = :code.priv_dir(:google_api_definitions)
    Path.join(dir, @discovery_file)
  end

  defp definitions_dir do
    dir = :code.priv_dir(:google_api_definitions)
    Path.join(dir, @definitions_dir)
  end

  defp definition_path(id) do
    Path.join(definitions_dir(), "#{id}.json.gz")
  end

  defp start_finch do
    case Finch.start_link(name: GoogleApiDefinitions.Finch) do
      {:ok, pid} ->
        pid

      {:error, {:already_started, pid}} ->
        pid
    end
  end

  defp fetch_to_file(url, filepath) do
    result =
      Finch.build(:get, url)
      |> Finch.request(GoogleApiDefinitions.Finch)

    case result do
      {:ok, response} ->
        filepath
        |> Path.dirname()
        |> File.mkdir_p!()

        File.write(filepath, response.body, [:compressed])

      err ->
        err
    end
  end
end
