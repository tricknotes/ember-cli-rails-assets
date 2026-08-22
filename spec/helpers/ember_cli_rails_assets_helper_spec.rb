require "rails_helper"

describe EmberCliRailsAssetsHelper do
  describe "#include_ember_stylesheet_tags" do
    context "when the application is built with Vite" do
      it "raises an error pointing at `include_ember_script_tags`" do
        app = instance_double(EmberCli::App, build: true)
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
