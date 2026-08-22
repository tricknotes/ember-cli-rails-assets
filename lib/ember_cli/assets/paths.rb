require "nokogiri"

module EmberCli
  module Assets
    class Paths
      def initialize(app)
        @app = app
      end

      def assets
        app.dist_path.join("assets")
      end

      def asset_map
        Pathname.glob(assets.join("assetMap*.json")).first
      end

      def package_json
        app.root_path.join("package.json")
      end

      def index_html
        app.dist_path.join("index.html")
      end

      # Vite builds (ember-cli >= 6.8) boot from ES modules in index.html,
      # while classic builds emit plain script tags.
      def vite?
        index_html.exist? &&
          !Nokogiri::HTML5(index_html.read).at_css('script[type="module"]').nil?
      end

      protected

      attr_reader :app
    end
  end
end
