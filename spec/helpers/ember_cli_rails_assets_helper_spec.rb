require "rails_helper"

describe EmberCliRailsAssetsHelper do
  describe "#include_ember_script_tags" do
    context "when the application is served by Vite's development server" do
      it "emits the startup tags with root-relative URLs rewritten onto the server" do
        index_html = <<~HTML
          <html>
            <head>
              <script type="module" src="/@vite/client"></script>
              <meta name="my-app/config/environment" content="%7B%7D">
              <link rel="stylesheet" href="/@embroider/virtual/app.css">
              <script type="module" src="https://cdn.example.com/analytics.js"></script>
              <script type="module" src="//cdn.example.com/protocol-relative.js"></script>
            </head>
            <body>
              <script src="/@embroider/virtual/vendor.js"></script>
            </body>
          </html>
        HTML
        dev_server = instance_double(
          EmberCli::DevServer,
          index_html: index_html,
          origin: "http://127.0.0.1:4200",
        )
        app = instance_double(
          EmberCli::App,
          build: true,
          dev_server?: true,
          dev_server: dev_server,
        )
        allow(EmberCli).to receive(:[]).with(:frontend).and_return(app)

        tags = helper.include_ember_script_tags(:frontend)

        expect(app).to have_received(:build)
        expect(tags).to include(%{src="http://127.0.0.1:4200/@vite/client"})
        expect(tags).to include(%{src="http://127.0.0.1:4200/@embroider/virtual/vendor.js"})
        expect(tags).to include(%{href="http://127.0.0.1:4200/@embroider/virtual/app.css"})
        expect(tags).to include(%{name="my-app/config/environment"})
        expect(tags).to include(%{src="https://cdn.example.com/analytics.js"})
        expect(tags).to include(%{src="//cdn.example.com/protocol-relative.js"})
      end
    end

    context "when the application is a classic build" do
      it "mounts the build's scripts onto `prepend`, leaving the ones hosted elsewhere untouched" do
        app = instance_double(EmberCli::App, build: true, dev_server?: false)
        paths = instance_double(EmberCli::Assets::Paths, vite?: false)
        lookup = instance_double(
          EmberCli::Assets::Lookup,
          javascript_assets: [
            "assets/vendor-abc123.js",
            "https://cdn.example.com/analytics.js",
            "//cdn.example.com/protocol-relative.js",
          ],
        )
        allow(EmberCli).to receive(:[]).with(:frontend).and_return(app)
        allow(EmberCli::Assets::Paths).
          to receive(:new).with(app).and_return(paths)
        allow(EmberCli::Assets::Lookup).
          to receive(:new).with(app).and_return(lookup)

        tags = helper.include_ember_script_tags(:frontend, prepend: "http://example.com/")

        expect(tags).to include(%{src="http://example.com/assets/vendor-abc123.js"})
        expect(tags).to include(%{src="https://cdn.example.com/analytics.js"})
        expect(tags).to include(%{src="//cdn.example.com/protocol-relative.js"})
      end
    end
  end

  describe "#include_ember_stylesheet_tags" do
    context "when the application is served by Vite's development server" do
      it "raises an error pointing at `include_ember_script_tags`" do
        app = instance_double(EmberCli::App, build: true, dev_server?: true)
        paths = instance_double(EmberCli::Assets::Paths)
        allow(EmberCli).to receive(:[]).with(:frontend).and_return(app)
        allow(EmberCli::Assets::Paths).
          to receive(:new).with(app).and_return(paths)

        expect { helper.include_ember_stylesheet_tags(:frontend) }.to raise_error(
          EmberCli::Assets::NotSupportedError,
          /include_ember_script_tags/,
        )
      end
    end

    context "when the application is built with Vite" do
      it "raises an error pointing at `include_ember_script_tags`" do
        app = instance_double(EmberCli::App, build: true, dev_server?: false)
        paths = instance_double(EmberCli::Assets::Paths, vite?: true)
        allow(EmberCli).to receive(:[]).with(:frontend).and_return(app)
        allow(EmberCli::Assets::Paths).
          to receive(:new).with(app).and_return(paths)

        expect { helper.include_ember_stylesheet_tags(:frontend) }.to raise_error(
          EmberCli::Assets::NotSupportedError,
          /include_ember_script_tags/,
        )
      end
    end

    context "when the application is a classic build" do
      it "mounts the build's stylesheets onto `prepend`, leaving the ones hosted elsewhere untouched" do
        app = instance_double(EmberCli::App, build: true, dev_server?: false)
        paths = instance_double(EmberCli::Assets::Paths, vite?: false)
        lookup = instance_double(
          EmberCli::Assets::Lookup,
          stylesheet_assets: [
            "assets/vendor-abc123.css",
            "https://fonts.example.com/css?family=Frontend",
            "//fonts.example.com/protocol-relative.css",
          ],
        )
        allow(EmberCli).to receive(:[]).with(:frontend).and_return(app)
        allow(EmberCli::Assets::Paths).
          to receive(:new).with(app).and_return(paths)
        allow(EmberCli::Assets::Lookup).
          to receive(:new).with(app).and_return(lookup)

        tags = helper.include_ember_stylesheet_tags(:frontend, prepend: "http://example.com/")

        expect(tags).to include(%{href="http://example.com/assets/vendor-abc123.css"})
        expect(tags).to include(%{href="https://fonts.example.com/css?family=Frontend"})
        expect(tags).to include(%{href="//fonts.example.com/protocol-relative.css"})
      end
    end
  end
end
