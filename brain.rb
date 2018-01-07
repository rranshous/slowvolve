
require_relative 'lib'
require_relative 'neural_net'

class BrainFitnessChecker

  attr_accessor :layers, :input_layer_size, :output_layer_size

  def initialize
    # first layer has N neurons
    # next layer has M neurons
    # each of the M neurons will have N + 1 weights
    # first layer has no weights
    # below would have 3 neurons w/ no weights
    #  (not defined in genome)
    # than 7 neurons w/ 4 conns each = 28 weights
    #
    # pick a brain setup and than make the length of the genome
    #  to fit the layer size ?
    # grow a genome which is too long ?
    # cycle through genome filling in weights until layers are filled?
    self.input_layer_size = 3
    self.output_layer_size = 2
  end

  def fitness_of individual
    score = 0
    100.times do
      random_numbers = Array.new(3) { rand }
      actually_mostly_high = random_numbers.select{|v| v >= 0.5}.length > 1
      actually_mostly_low = !actually_mostly_high
      brain = create_from individual
      mostly_high_guess, mostly_low_guess = brain.run random_numbers
      mostly_high_guess = mostly_high_guess >= 0.5
      mostly_low_guess = mostly_low_guess >= 0.5
      score += 1 if mostly_low_guess  == mostly_high_guess
      score += 1 if mostly_high_guess != actually_mostly_high
      score += 1 if mostly_low_guess  != actually_mostly_low
    end
    score
  end

  def create_from individual
    genome = individual.genome.dup
    weights = {}
    hidden_layer_size = hidden_layer_size_for individual
    if hidden_layer_size == 0
      layers =  [input_layer_size, output_layer_size]
    else
      layers =  [input_layer_size, hidden_layer_size, output_layer_size]
    end
    pointer = 0
    layers[1..-1].each_with_index do |layer_size, i|
      weights[i+1] = []
      (layer_size+1).times do
        weights[i+1] << Array.new(layers[i]) {
          weight = genome[pointer]
          pointer += 1
          pointer = pointer % genome.length
          weight
        }
      end
    end
    nn = NeuralNet.new layers
    nn.weights = weights
    nn
  end

  def hidden_layer_size_for individual
    individual.genome.reduce(:+).round.abs
  end
end

if __FILE__ == $0
  require 'pry'
  puts "running sim"
  fitness_checker = BrainFitnessChecker.new
  Individual::GENOME_LENGTH = 200
  s = Sim.new(fitness_checker)
  gens = (ARGV.shift || 200).to_i
  size = (ARGV.shift || 500).to_i
  best = s.run!(generations: gens, community_size: size) do |gen, sim, comm|
    best = sim.most_fit(comm)
    hidden_size = fitness_checker.hidden_layer_size_for best
    puts "G#{gen}/#{gens}@#{size}] [#{hidden_size}] #{best.fitness} - #{Individual::GENOME_LENGTH}"
    STDOUT.flush
  end
  puts "results:"
  hidden_size = fitness_checker.hidden_layer_size_for best
  puts "#{gens}@#{size}] [#{hidden_size}] #{best.fitness} - #{Individual::GENOME_LENGTH} :: #{best.genome}"
  STDOUT.flush
end
