
require_relative 'lib'
require_relative 'brain/lib'
require 'json'

module Brain::FitnessChecker
  class Blah
    # turn on when most the input fits a pattern
    # is the image mostly red ?
    attr_accessor :factory

    def initialize
      self.factory = BrainFactory.new input_layer_size: 300,
                                      output_layer_size: 2
    end

    def fitness_of individual
      score = 0
      100.times do
        brain = factory.create_from individual
        image_details = generate_random_image
        mostly_red, mostly_not_red = brain.run image_details.data
        mostly_red = mostly_red >= 0.5
        mostly_not_red = mostly_not_red >= 0.5
        score += 1 if mostly_red != image_details.is_red
        score += 1 if mostly_not_red == image_details.is_red
        score += 2 if mostly_red == mostly_not_red
      end
      score += individual.genome.length * 0.1
      score
    end

    def generate_random_image
      # 10 by 10 pixel color image
      red_pixels = 0
      image_data = []
      10.times do |i|
        10.times do |j|
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
  end
end


if __FILE__ == $0
  require 'pry'
  puts "running sim"
  puts "VERSION: self defining hidden layer, variable len starter genes, mutate can remove gene, genome length in fitness test"
  fitness_checker = Brain::FitnessChecker::HighOrLow.new
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
