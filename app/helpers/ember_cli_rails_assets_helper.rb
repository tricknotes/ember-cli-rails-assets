require "ember_cli/assets/errors"

module EmberCliRailsAssetsHelper
  def include_ember_script_tags(name, prepend: "")
    embedding = build_ember_embedding(name)

    if embedding.startup_tags?
      safe_join(embedding.startup_tags(prepend: prepend).map(&:html_safe), "\n")
    else
      tags_for(embedding.javascript_assets(prepend: prepend)) do |src|
        %{<script src="#{src}"></script>}
      end
    end
  end

  def include_ember_stylesheet_tags(name, prepend: "")
    embedding = build_ember_embedding(name)

    if embedding.startup_tags?
      raise EmberCli::Assets::NotSupportedError, <<~MSG
        `include_ember_stylesheet_tags` does not support Vite-based
        applications (`ember-cli >= 6.8`).

        `include_ember_script_tags` already emits their stylesheet tags,
        so remove this call.
      MSG
    end

    tags_for(embedding.stylesheet_assets(prepend: prepend)) do |href|
      %{<link rel="stylesheet" href="#{href}">}
    end
  end

  private

  def build_ember_embedding(name)
    app = EmberCli[name]
    app.build

    EmberCli::Embedding.new(app)
  end

  def tags_for(assets)
    assets.
      map { |asset| yield(asset).html_safe }.
      inject(&:+)
  end
end
