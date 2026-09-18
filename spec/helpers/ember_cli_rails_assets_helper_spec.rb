require "rails_helper"

describe EmberCliRailsAssetsHelper do
  describe "#include_ember_script_tags" do
    context "when the application is served by Vite's development server" do
      it "emits the startup tags ember-cli-rails read from the server" do
        app = build_app(
          dev_server?: true,
          startup_tags: [
            %{<script type="module" src="http://127.0.0.1:4200/@vite/client"></script>},
            %{<link rel="stylesheet" href="http://127.0.0.1:4200/app.css">},
          ],
        )

        tags = helper.include_ember_script_tags(:frontend)

        expect(app).to have_received(:build)
        expect(app).to have_received(:startup_tags).with(prepend: "")
        expect(tags).to include(%{src="http://127.0.0.1:4200/@vite/client"})
        expect(tags).to include(%{href="http://127.0.0.1:4200/app.css"})
      end
    end

    context "when the application is built with Vite" do
      it "emits the startup tags with the mount point joined onto them" do
        app = build_app(
          vite?: true,
          startup_tags: [%{<script type="module" src="/admin/app.js"></script>}],
        )

        tags = helper.include_ember_script_tags(:frontend, prepend: "/admin")

        expect(app).to have_received(:startup_tags).with(prepend: "/admin")
        expect(tags).to include(%{src="/admin/app.js"})
      end
    end

    context "when the application is a classic build" do
      it "emits the scripts as ember-cli-rails reports them, mounted onto `prepend`" do
        app = build_app(
          javascript_assets: [
            "http://example.com/assets/vendor-abc123.js",
            "https://cdn.example.com/analytics.js",
            "//cdn.example.com/protocol-relative.js",
          ],
        )

        tags = helper.include_ember_script_tags(:frontend, prepend: "http://example.com/")

        expect(app).to have_received(:javascript_assets).
          with(prepend: "http://example.com/")
        expect(tags).to include(%{src="http://example.com/assets/vendor-abc123.js"})
        expect(tags).to include(%{src="https://cdn.example.com/analytics.js"})
        expect(tags).to include(%{src="//cdn.example.com/protocol-relative.js"})
      end
    end
  end

  describe "#include_ember_stylesheet_tags" do
    context "when the application is served by Vite's development server" do
      it "raises an error pointing at `include_ember_script_tags`" do
        build_app(dev_server?: true)

        expect { helper.include_ember_stylesheet_tags(:frontend) }.to raise_error(
          EmberCli::Assets::NotSupportedError,
          /include_ember_script_tags/,
        )
      end
    end

    context "when the application is built with Vite" do
      it "raises an error pointing at `include_ember_script_tags`" do
        build_app(vite?: true)

        expect { helper.include_ember_stylesheet_tags(:frontend) }.to raise_error(
          EmberCli::Assets::NotSupportedError,
          /include_ember_script_tags/,
        )
      end
    end

    context "when the application is a classic build" do
      it "emits the stylesheets as ember-cli-rails reports them, mounted onto `prepend`" do
        app = build_app(
          stylesheet_assets: [
            "http://example.com/assets/vendor-abc123.css",
            "https://fonts.example.com/css?family=Frontend",
            "//fonts.example.com/protocol-relative.css",
          ],
        )

        tags = helper.include_ember_stylesheet_tags(:frontend, prepend: "http://example.com/")

        expect(app).to have_received(:build)
        expect(app).to have_received(:stylesheet_assets).
          with(prepend: "http://example.com/")
        expect(tags).to include(%{href="http://example.com/assets/vendor-abc123.css"})
        expect(tags).to include(%{href="https://fonts.example.com/css?family=Frontend"})
        expect(tags).to include(%{href="//fonts.example.com/protocol-relative.css"})
      end
    end
  end

  def build_app(**stubs)
    app = instance_double(
      EmberCli::App,
      build: true, dev_server?: false, vite?: false, **stubs,
    )
    allow(EmberCli).to receive(:[]).with(:frontend).and_return(app)

    app
  end
end
