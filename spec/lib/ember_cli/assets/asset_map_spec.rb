require "ember_cli/assets/asset_map"

describe EmberCli::Assets::AssetMap do
  describe "#javascripts" do
    it "includes the most recent javascript build artifacts" do
      asset_map = {
        "assets" => {
          "not-a-match" => nil,
          "bar.js" => "bar-abc123.js",
          "vendor.js" => "vendor-abc123.js",
        },
        "prepend" => "foo/",
      }
      index_html = StringIO.new(<<~HTML)
        <html>
          <head>
            <script src="bar-abc123.js"></script>
            <script src="vendor-abc123.js"></script>
          </head>
        </html>
      HTML
      assets = build_assets(name: "bar", asset_map: asset_map, index_html: index_html)

      javascripts = assets.javascripts

      expect(javascripts).to match_array([
        "foo/bar-abc123.js",
        "foo/vendor-abc123.js",
      ])
    end

    context "when the asset_map is empty" do
      it "raises a BuildError" do
        assets = build_assets(asset_map: {}, name: "bar", index_html: StringIO.new)

        expect { assets.javascripts }.to raise_build_error
      end
    end
  end

  describe "#stylesheets" do
    it "includes the most recent stylesheet build artifacts" do
      asset_map = {
        "assets" => {
          "not-a-match" => nil,
          "bar.css" => "bar-abc123.css",
          "vendor.css" => "vendor-abc123.css",
        },
        "prepend" => "foo/",
      }
      index_html = StringIO.new(<<~HTML)
        <html>
          <head>
            <link rel="stylesheet" href="bar-abc123.css"></link>
            <link rel="stylesheet" href="vendor-abc123.css"></link>
          </head>
        </html>
      HTML
      assets = build_assets(name: "bar", asset_map: asset_map, index_html: index_html)

      stylesheets = assets.stylesheets

      expect(stylesheets).to match_array([
        "foo/bar-abc123.css",
        "foo/vendor-abc123.css",
      ])
    end
    
    it 'can find additional CSS files found inside the HTML' do
      asset_map = {
        'assets' => {
          'not-a-match' => {},
          'bar.css' => 'bar-abc123.css',
          'vendor.css' => 'vendor-abc123.css',
          'additional.css' => 'additional-abc123.css',
          'here/is/another/file.css' => 'here/is/another/file-abc123.css'
        },
        'prepend' => 'foo/'
      }
      index_html = StringIO.new(<<~HTML)
        <html>
          <head>
            <link rel="stylesheet" href="bar-abc123.css"></link>
            <link rel="stylesheet" href="vendor-abc123.css"></link>
            <link rel="stylesheet" href="additional-abc123.css"></link>
            <link rel="stylesheet" href="here/is/another/file-abc123.css"></link>
          </head>
        </html>
      HTML
      assets = build_assets(name: 'bar', asset_map: asset_map, index_html: index_html)

      stylesheets = assets.stylesheets

      expect(stylesheets).to match_array([
        "foo/additional-abc123.css",
        "foo/bar-abc123.css", 
        "foo/here/is/another/file-abc123.css", 
        "foo/vendor-abc123.css"
      ])
    end
    
    context "when the asset_map is empty" do
      it "raises a BuildError" do
        assets = build_assets(asset_map: {}, name: "bar", index_html: StringIO.new)

        expect { assets.stylesheets }.to raise_build_error
      end
    end
  end
end

def raise_build_error
  raise_error(EmberCli::Assets::BuildError)
end

def build_assets(asset_map: {}, **options)
  EmberCli::Assets::AssetMap.new(**options.merge(asset_map: asset_map))
end
