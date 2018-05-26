module Brain
  class PixelReader

    attr_accessor :image_path

    def initialize image_path: nil
      self.image_path = image_path
    end

    def rgb
      #puts "reading rgbs: #{image_path}"
      File.open(image_path+'.txt', 'r')
        .readlines
        .drop(1)
        .map { |l| l.match(/\(.+?,.+?,.+?\)/)[0] }
        .map { |s| s[1..-2] }
        .map { |rgbs| rgbs.split(',').map(&:strip) }
        .map { |rgb| rgb.map(&:to_i) }
    end
  end
end
