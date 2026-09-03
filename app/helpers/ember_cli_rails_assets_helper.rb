require "ember_cli/assets/errors"
require "ember_cli/assets/lookup"
require "ember_cli/assets/paths"

module EmberCliRailsAssetsHelper
  def include_ember_script_tags(name, prepend: "")
    app = EmberCli[name]
    app.build

    if dev_server?(app)
      dev_server_ember_script_tags(app)
    else
      paths = EmberCli::Assets::Paths.new(app)

      if paths.vite?
        vite_ember_script_tags(paths, prepend)
      else
        classic_ember_script_tags(app, prepend)
      end
    end
  end

  def include_ember_stylesheet_tags(name, prepend: "")
    app = EmberCli[name]
    app.build

    paths = EmberCli::Assets::Paths.new(app)

    if dev_server?(app) || paths.vite?
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

  # Whether ember-cli-rails serves the application from Vite's development
  # server. Older ember-cli-rails releases have no development server, so
  # feature-detect the reader.
  def dev_server?(app)
    app.respond_to?(:dev_server?) && app.dev_server?
  end

  # The application is served by Vite's development server, so read
  # `index.html` from the server instead of a build directory, and rewrite
  # its root-relative URLs to absolute URLs on the server — the same way
  # ember-cli-rails serves the document itself. `app.build` has already
  # booted the server.
  def dev_server_ember_script_tags(app)
    vite_startup_tags(app.dev_server.index_html, prefix: app.dev_server.origin)
  end

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
    vite_startup_tags(paths.index_html.read, prefix: prepend.to_s.chomp("/"))
  end

  # Extracts the tags a Vite-based application needs to boot from an
  # `index.html` document, with `prefix` joined onto every root-relative
  # URL. Protocol-relative URLs (`//`) are left alone.
  def vite_startup_tags(html, prefix:)
    document = Nokogiri::HTML5(html)

    tags = document.css(
      'meta[name$="/config/environment"], link[rel="stylesheet"], link[rel="modulepreload"], script'
    ).map do |tag|
      %w(href src).each do |attribute|
        value = tag[attribute]

        if value&.start_with?("/") && !value.start_with?("//")
          tag[attribute] = "#{prefix}#{value}"
        end
      end
      tag.to_html.html_safe
    end

    safe_join(tags, "\n")
  end
end
