require "pathname"

module EmberCli
  module Assets
    class DirectoryAssetMap
      def initialize(directory)
        @directory = Pathname.new(directory)
      end

      def to_h
        {
          "assets" => files_with_data,
          "prepend" => "assets/",
        }
      end

      private

      attr_reader :directory

      def files_with_data
        files.reduce({}) do |manifest, file|
          name = file.relative_path_from(directory).to_s

          manifest[name] = name

          manifest
        end
      end

      # A build may nest assets in the directory, as an addon shipping a stylesheet next to the fonts it references does.
      # Walk the whole tree so that every file is represented by its path within the directory, not only the ones sitting at its top level.
      def files
        directory.glob("**/*", File::FNM_DOTMATCH).select(&:file?)
      end
    end
  end
end
