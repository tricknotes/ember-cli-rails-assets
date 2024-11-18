require "tmpdir"
require "pathname"
require "fileutils"
require "ember_cli/assets/directory_asset_map"

describe EmberCli::Assets::DirectoryAssetMap do
  describe "#to_h" do
    it "represents the directory" do
      create_file("first")
      create_file("second")
      create_file("third")
      create_file("fourth/fifth")
      directory_manifest = build_directory_asset_map(directory).to_h

      expect(directory_manifest["prepend"]).to eq("assets/")
      # Strict match the hash
      expect(directory_manifest["assets"]).to eq({
        "first" => "first",
        "second" => "second",
        "third" => "third",
        "fourth/fifth" => "fourth/fifth",
      })
    end
  end

  def build_directory_asset_map(directory)
    EmberCli::Assets::DirectoryAssetMap.new(directory)
  end

  def create_file(name)
    path = directory.join(name)

    FileUtils.mkdir_p(File.dirname(path))
    FileUtils.touch(path)

    File.new(path)
  end

  def directory
    @directory ||= Pathname(Dir.mktmpdir)
  end
end
