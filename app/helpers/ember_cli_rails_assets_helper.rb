require "ember_cli/assets/errors"
require "ember_cli/assets/lookup"
require "ember_cli/assets/paths"

module EmberCliRailsAssetsHelper
  def include_ember_script_tags(name, prepend: "")
    app = EmberCli[name]
    app.build

    paths = EmberCli::Assets::Paths.new(app)

    if paths.vite?
      vite_ember_script_tags(paths, prepend)
    else
      classic_ember_script_tags(app, prepend)
    end
  end

  def include_ember_stylesheet_tags(name, prepend: "")
    app = EmberCli[name]
    app.build

    paths = EmberCli::Assets::Paths.new(app)

    if paths.vite?
      raise EmberCli::Assets::NotSupportedError, <<~MSG
        `include_ember_stylesheet_tags` does not support Vite-based
        applications (`ember-cli >= 6.8`).

        `include_ember_script_tags` already emits their stylesheet tags,
        so remove this call.
      MSG
    end

    assets = EmberCli::Assets::Lookup.new(app)

    assets.stylesheet_assets.
      map { |src| [prepend, src].join }.
      map { |src| %{<link rel="stylesheet" href="#{src}">}.html_safe }.
      inject(&:+)
  end

  private

  # Classic builds ship a fixed set of scripts (vendor and app) resolved
  # through the asset map, so emit a plain script tag per JavaScript asset
  # with `prepend` joined onto each path.
  def classic_ember_script_tags(app, prepend)
    assets = EmberCli::Assets::Lookup.new(app)

    assets.javascript_assets.
      map { |src| [prepend, src].join }.
      map { |src| %{<script src="#{src}"></script>}.html_safe }.
      inject(&:+)
  end

  # Vite builds boot from ES modules declared in dist/index.html, so extract
  # the tags required for startup (including the config meta tag and
  # stylesheets) and remap root-absolute paths onto the mount point.
  def vite_ember_script_tags(paths, prepend)
    document = Nokogiri::HTML5(paths.index_html.read)
    prefix = prepend.to_s.chomp("/")

    tags = document.css(
      'meta[name$="/config/environment"], link[rel="stylesheet"], link[rel="modulepreload"], script'
    ).map do |tag|
      %w(href src).each do |attribute|
        value = tag[attribute]
        tag[attribute] = "#{prefix}#{value}" if value&.start_with?("/")
      end
      tag.to_html.html_safe
    end

    safe_join(tags, "\n")
  end
end
