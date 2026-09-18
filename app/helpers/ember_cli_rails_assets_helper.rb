require "ember_cli/assets/errors"

module EmberCliRailsAssetsHelper
  def include_ember_script_tags(name, prepend: "")
    app = EmberCli[name]
    app.build

    if app.dev_server? || app.vite?
      safe_join(app.startup_tags(prepend: prepend).map(&:html_safe), "\n")
    else
      tags_for(app.javascript_assets(prepend: prepend)) do |src|
        %{<script src="#{src}"></script>}
      end
    end
  end

  def include_ember_stylesheet_tags(name, prepend: "")
    app = EmberCli[name]
    app.build

    if app.dev_server? || app.vite?
      raise EmberCli::Assets::NotSupportedError, <<~MSG
        `include_ember_stylesheet_tags` does not support Vite-based
        applications (`ember-cli >= 6.8`).

        `include_ember_script_tags` already emits their stylesheet tags,
        so remove this call.
      MSG
    end

    tags_for(app.stylesheet_assets(prepend: prepend)) do |href|
      %{<link rel="stylesheet" href="#{href}">}
    end
  end

  private

  def tags_for(assets)
    assets.
      map { |asset| yield(asset).html_safe }.
      inject(&:+)
  end
end
