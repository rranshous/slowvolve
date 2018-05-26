require 'json'
require 'bson'
require 'oj'

module Brain
  class PixelReader

    attr_accessor :image

    def initialize image: nil
      self.image = image
    end

    def rgb
      # rgb_from_bson || # BSON NOT WORKING!!!
      rgb_from_json ||
        rgb_from_text
    end

    def rgb_from_text
      return false unless text_version_exists?
      File.open(image_path+'.txt', 'r')
        .readlines
        .drop(1)
        .map { |l| l.match(/\(.+?,.+?,.+?\)/)[0] }
        .map { |s| s[1..-2] }
        .map { |rgbs| rgbs.split(',').map(&:strip) }
        .map { |rgb| rgb.map(&:to_i) }
    end

    def rgb_from_json
      return false unless json_version_exists?
      Oj.load(File.open(image_path+'.json', 'r').read)
    end

    def rgb_from_bson
      return false unless bson_version_exists?
      Array.from_bson(File.open(image_path+'.bson', 'rb').read)
    end

    def text_version_exists?
      File.exists?(image_path+'.txt')
    end

    def json_version_exists?
      File.exists?(image_path+'.json')
    end

    def bson_version_exists?
      File.exists?(image_path+'.bson')
    end

    def image_path
      image.path
    end
  end

  class PixelWriter

    attr_accessor :image

    def initialize image: nil
      self.image = image
    end

    def write_as_json
      rgb_data = image.rgb
      File.open(image_path+'.json', 'w') do |fh|
        fh.write(Oj.dump(rgb_data))
      end
    end

    def write_as_bson
      rgb_data = image.rgb
      File.open(image_path+'.bson', 'wb') do |fh|
        fh.write(rgb_data.to_bson)
      end
    end

    def image_path
      image.path
    end

    def image_rgb
      image.rgb
    end

    # TODO: not repeat
    def text_version_exists?
      File.exists?(image_path+'.txt')
    end

    def json_version_exists?
      File.exists?(image_path+'.json')
    end

    def bson_version_exists?
      File.exists?(image_path+'.bson')
    end
  end
end
