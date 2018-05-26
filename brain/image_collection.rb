require_relative 'pixel_reader'
module Brain
  class ImageCollection

    def initialize
      @image_sets = {}
    end

    def register type: nil, path: nil
      puts "registering: #{path}"
      @image_sets[type] = []
      load_images type: type, path: path
    end

    def random type: nil
      @image_sets[type].sample
    end

    def load_images type: nil, path: nil
      puts "loading images from: #{path}"
      image_paths = Dir.glob(path+'/*.jpg')
      puts "found images: #{image_paths.size}"
      image_paths.each do |image_path|
        begin
          image = Image.new path: image_path
          @image_sets[type] << image
        end
      end
    end

    def all type: :ALL
      if type == :ALL
        @image_sets.values.flatten
      else
        @image_sets[type]
      end
    end

    # TODO: move out from under ImageCollection
    class Image
      attr_accessor :path

      def initialize path: nil
        self.path = path
      end

      def rgb_flat
        rgb.flatten
      end

      def inspect
        "image:#{path}"
      end

      def to_s
        inspect
      end

      def rgb
        @rgb ||= pixel_reader.rgb
      end

      def pixel_reader
        @pixel_reader ||= Brain::PixelReader.new image: self
      end
    end
  end
end
