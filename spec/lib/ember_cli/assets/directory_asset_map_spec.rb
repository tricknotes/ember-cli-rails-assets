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

      directory_manifest = build_directory_asset_map(directory).to_h

      expect(directory_manifest["prepend"]).to eq("assets/")
      expect(directory_manifest["assets"]).to match a_hash_including(
        "first" => "first",
        "second" => "second",
        "third" => "third",
      )
    end

    it "represents the files nested in the directory by their path within it" do
      create_file("font-awesome/css/font-awesome.min.css")

      directory_manifest = build_directory_asset_map(directory).to_h

      expect(directory_manifest["assets"]).to match a_hash_including(
        "font-awesome/css/font-awesome.min.css" => "font-awesome/css/font-awesome.min.css",
      )
    end
  end

  def build_directory_asset_map(directory)
    EmberCli::Assets::DirectoryAssetMap.new(directory)
  end

  def create_file(name)
    path = directory.join(name)

    FileUtils.mkdir_p(path.dirname)
    FileUtils.touch(path)

    File.new(path)
  end

  def directory
    @directory ||= Pathname(Dir.mktmpdir)
  end
end
