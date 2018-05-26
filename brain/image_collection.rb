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
          #puts "loading: #{image_path}"
          reader = PixelReader.new(image_path: image_path)
          image = Image.new
          image.rgb = reader.rgb
          image.path = image_path
          #puts "loaded rgbs: #{image.rgb.size}"
          print '.'
          @image_sets[type] << image
        rescue SignalException
          raise
        rescue Exception => ex
          puts "Ex: #{ex}"
          require 'pry';binding.pry
        end
      end
    end

    class Image
      attr_accessor :rgb, :path

      def rgb_flat
        rgb.flatten
      end

      def inspect
        "image:#{path}"
      end

      def to_s
        inspect
      end
    end
  end
end
