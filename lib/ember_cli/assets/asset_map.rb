require 'nokogiri'
require "ember_cli/assets/errors"
require "ember_cli/assets/url"

module EmberCli
  module Assets
    class AssetMap
      def initialize(name:, asset_map:, index_html:)
        @name = name
        @asset_map = asset_map
        @index_html = index_html
      end

      def javascripts
        assert_asset_map!

        document.css('script').filter_map { |script| asset_for(script['src']) }
      end

      def stylesheets
        assert_asset_map!

        document.css('link[rel="stylesheet"]').filter_map { |link| asset_for(link['href']) }
      end

      private

      attr_reader :name, :asset_map, :index_html

      def document
        @document ||= Nokogiri::HTML(index_html.read)
      end

      # Assets hosted outside the build (a CDN, a font service) have no entry in the asset map, so their URL is emitted untouched.
      # A tag without a URL (an inline `<script>`) references no asset at all.
      def asset_for(url)
        if url.to_s.empty?
          nil
        elsif Url.remote?(url)
          url
        else
          asset_matching(url)
        end
      end

      # `index.html` references an asset through the build's `rootURL`, while the asset map keys the same file by its path within the build output, so match on the longest trailing path the two agree on.
      def asset_matching(url)
        matching_asset = path_suffixes(url).find { |suffix| files.include?(suffix) }

        if matching_asset.nil?
          raise_missing_asset(url)
        end

        prepend + matching_asset
      end

      # Every trailing path of `url`, longest first: `/my-app/assets/font-awesome/css/font-awesome.css` yields `my-app/assets/font-awesome/css/font-awesome.css`, then `assets/font-awesome/css/font-awesome.css`, down to `font-awesome.css`.
      def path_suffixes(url)
        segments = url.split("/").reject(&:empty?)

        segments.each_index.map { |index| segments[index..].join("/") }
      end

      def prepend
        asset_map["prepend"].to_s
      end

      def files
        Array(assets.values)
      end

      def assets
        asset_map["assets"] || {}
      end

      def raise_missing_asset(url)
        raise BuildError.new("Failed to find assets matching `#{url}`")
      end

      def assert_asset_map!
        if assets.empty?
          raise BuildError.new <<-MSG
            Missing `#{name}/assets/assetMap.json`
          MSG
        end
      end
    end
  end
end
