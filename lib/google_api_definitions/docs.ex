defmodule GoogleApiDefinitions.Docs do
  @moduledoc false

  require EEx
  EEx.function_from_file(:def, :to_md, "templates/doc.md.eex", [:api])

  def discovery_to_pages do
    pages =
      GoogleApiDefinitions.list_discovered_full()
      |> Enum.map(&to_page/1)
      |> Enum.sort_by(
        fn {_id, detail} ->
          detail[:title]
        end,
        :asc
      )

    pages
  end

  defp to_page({id, api}) do
    dir = Path.join(File.cwd!(), "priv/pages")
    path = Path.join(dir, "#{id}.md")
    File.mkdir_p!(dir)
    File.write!(path, to_md(api))
    {Path.relative_to_cwd(path), title: "#{api["title"]} #{api["version"]}"}
  end
end
