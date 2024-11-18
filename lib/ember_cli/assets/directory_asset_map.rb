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

      # Returns a hash of files in the directory
      def files_with_data
        files.each_with_object({}) do |file, manifest|
          name = Pathname.new(file).relative_path_from(directory).to_s
          manifest[name] = name
        end
      end
      
      # Returns a recursive list of files in the directory

      def files
        directory.glob('**/*').select { |f| f.file? }.map do |file|
          File.new(file)
        end
      end
    end
  end
end
