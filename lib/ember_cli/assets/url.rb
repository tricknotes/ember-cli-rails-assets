module EmberCli
  module Assets
    # URLs in a built `index.html` either point into the build output or somewhere else entirely (a CDN, a font service).
    # Only the former are resolved against the build and mounted onto the Rails application.
    module Url
      # Matches a URL that resolves outside the build: one carrying a scheme (`https://example.com/app.css`, `data:…`), and a protocol-relative one (`//example.com/app.css`).
      REMOTE = %r{\A(?:[a-zA-Z][a-zA-Z0-9+.\-]*:|//)}

      def self.remote?(url)
        REMOTE.match?(url.to_s)
      end
    end
  end
end
