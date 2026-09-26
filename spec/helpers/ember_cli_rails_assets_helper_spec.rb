require "rails_helper"

describe EmberCliRailsAssetsHelper do
  describe "#include_ember_script_tags" do
    context "when the application boots from startup tags" do
      it "emits the startup tags ember-cli-rails reads, mounted onto `prepend`" do
        app, embedding = build_embedding(
          startup_tags?: true,
          startup_tags: [
            %{<script type="module" src="/admin/app.js"></script>},
            %{<link rel="stylesheet" href="/admin/app.css">},
          ],
        )

        tags = helper.include_ember_script_tags(:frontend, prepend: "/admin")

        expect(app).to have_received(:build)
        expect(embedding).to have_received(:startup_tags).with(prepend: "/admin")
        expect(tags).to include(%{src="/admin/app.js"})
        expect(tags).to include(%{href="/admin/app.css"})
      end
    end

    context "when the application is a classic build" do
      it "emits the scripts as ember-cli-rails reports them, mounted onto `prepend`" do
        app, embedding = build_embedding(
          javascript_assets: [
            "http://example.com/assets/vendor-abc123.js",
            "https://cdn.example.com/analytics.js",
            "//cdn.example.com/protocol-relative.js",
          ],
        )

        tags = helper.include_ember_script_tags(:frontend, prepend: "http://example.com/")

        expect(app).to have_received(:build)
        expect(embedding).to have_received(:javascript_assets).
          with(prepend: "http://example.com/")
        expect(tags).to include(%{src="http://example.com/assets/vendor-abc123.js"})
        expect(tags).to include(%{src="https://cdn.example.com/analytics.js"})
        expect(tags).to include(%{src="//cdn.example.com/protocol-relative.js"})
      end
    end
  end

  describe "#include_ember_stylesheet_tags" do
    context "when the application boots from startup tags" do
      it "raises an error pointing at `include_ember_script_tags`" do
        build_embedding(startup_tags?: true)

        expect { helper.include_ember_stylesheet_tags(:frontend) }.to raise_error(
          EmberCli::Assets::NotSupportedError,
          /include_ember_script_tags/,
        )
      end
    end

    context "when the application is a classic build" do
      it "emits the stylesheets as ember-cli-rails reports them, mounted onto `prepend`" do
        app, embedding = build_embedding(
          stylesheet_assets: [
            "http://example.com/assets/vendor-abc123.css",
            "https://fonts.example.com/css?family=Frontend",
            "//fonts.example.com/protocol-relative.css",
          ],
        )

        tags = helper.include_ember_stylesheet_tags(:frontend, prepend: "http://example.com/")

        expect(app).to have_received(:build)
        expect(embedding).to have_received(:stylesheet_assets).
          with(prepend: "http://example.com/")
        expect(tags).to include(%{href="http://example.com/assets/vendor-abc123.css"})
        expect(tags).to include(%{href="https://fonts.example.com/css?family=Frontend"})
        expect(tags).to include(%{href="//fonts.example.com/protocol-relative.css"})
      end
    end
  end

  def build_embedding(**stubs)
    app = instance_double(EmberCli::App, build: true)
    embedding = instance_double(EmberCli::Embedding, startup_tags?: false, **stubs)
    allow(EmberCli).to receive(:[]).with(:frontend).and_return(app)
    allow(EmberCli::Embedding).to receive(:new).with(app).and_return(embedding)

    [app, embedding]
  end
end
