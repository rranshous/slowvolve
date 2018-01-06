
require_relative 'lib'
require_relative 'neural_net'

class BrainFitnessChecker

  attr_accessor :layers, :target_genome_length

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
    self.layers = [
      3,
      5,
      2
    ]
    self.target_genome_length = calc_target_genome_length
    puts "target genome length: #{self.target_genome_length}"
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
    self.layers[1..-1].each_with_index do |layer_size, i|
      weights[i+1] = []
      (layer_size).times do
        weights[i+1] << genome.shift(self.layers[i])
      end
    end
    nn = NeuralNet.new self.layers
    nn.weights = weights
    nn
  end

  def calc_target_genome_length
    neurons = 0
    previous_layer_size = layers[0]
    layers[1..-1].each do |layer_size|
      neurons += (previous_layer_size + 1) * layer_size
      previous_layer_size = layer_size
    end
    neurons
  end
end

if __FILE__ == $0
  require 'pry'
  puts "running sim"
  fitness_checker = BrainFitnessChecker.new
  s = Sim.new(fitness_checker)
  Individual::GENOME_LENGTH = fitness_checker.target_genome_length
  results = s.run!(generations: 100, community_size: 1000) do |gen, sim, comm|
    best = sim.most_fit(comm)
    puts "G#{gen}] #{best.fitness} :: #{best.genome}"
  end
  puts "results: #{results.fitness} :: #{results.genome}"
end
