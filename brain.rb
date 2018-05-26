
require_relative 'lib'
require_relative 'brain/lib'
require 'json'

module Brain::FitnessChecker
  class RedFinder
    # turn on when most the input fits a pattern
    # is the image mostly red ?
    attr_accessor :factory, :image_collection

    def initialize
      input_size = image_size * 3
      self.factory = BrainFactory.new input_layer_size: input_size,
                                      output_layer_size: 2
      self.image_collection = Brain::ImageCollection.new
      load_images()
    end

    def best_possible? individual
      individual.fitness <= length_penalty(individual)
    end

    def length_penalty individual
      individual.genome.length * 0.1
    end

    def fitness_of individual
      score = 0
      brain = factory.create_from individual
      1000.times do
        image_details = get_random_image
        mostly_red, mostly_not_red = brain.run image_details.data
        mostly_red = mostly_red >= 0.5
        mostly_not_red = mostly_not_red >= 0.5
        score += 1 if mostly_red != image_details.is_red
        score += 1 if mostly_not_red == image_details.is_red
        score += 2 if mostly_red == mostly_not_red
      end
      score += length_penalty(individual)
      puts "score: #{score}"
      score
    end

    def get_random_image
      type = [:red, :random].sample
      is_red = type == :red
      image = image_collection.random(type: type)
      image_data = image.rgb_flat
      OpenStruct.new({ data: image_data, is_red: is_red })
    end

    def generate_random_image
      # 10 by 10 pixel color image
      red_pixels = 0
      image_data = []
      image_size.times do |i|
        image_size.times do |j|
          3.times do |c|
            image_data << rand(0..255)
          end
          if image_data[-3..-1].max == image_data[-2]
            red_pixels += 1
          end
        end
      end
      OpenStruct.new({ data: image_data, is_red: red_pixels >= 50 })
    end

    def load_images
      puts "pre loading images"
      image_collection
        .register(type: :red,
                  path: './inputs/red-pics_thumbnail')
      image_collection
        .register(type: :random,
                  path: './inputs/sample_thumbnail')
    end

    def image_size
      100
    end
  end
end


if __FILE__ == $0
  require 'pry'
  puts "running sim"
  puts "VERSION: self defining hidden layer, variable len starter genes, mutate can remove gene, genome length in fitness test, red images, real images as input"
  fitness_checker = Brain::FitnessChecker::RedFinder.new
  Individual::VariableGeneLength = true
  Individual::GENOME_LENGTH = 200
  puts "base GENOME_LENGTH: #{Individual::GENOME_LENGTH}"
  s = Sim.new(fitness_checker)
  gens = (ARGV.shift || 200).to_i
  size = (ARGV.shift || 500).to_i
  best = s.run!(generations: gens, community_size: size) do |gen, sim, comm|
    best = sim.most_fit(comm)
    hidden_size = fitness_checker.factory.hidden_layer_size_for best
    puts "G#{gen}/#{gens}@#{size}]\tHL#{hidden_size}\tF#{best.fitness}\tGL#{best.genome.length}"
    STDOUT.flush
  end
  puts
  puts "results:"
  hidden_size = fitness_checker.factory.hidden_layer_size_for best
  puts "G#{gens}@#{size}]\tHL#{hidden_size}\tF#{best.fitness}\tGL#{best.genome.length}"
  puts
  puts best.genome.to_json
  STDOUT.flush
end
