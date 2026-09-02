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
  end
end
