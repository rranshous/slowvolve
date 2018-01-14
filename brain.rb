
require_relative 'lib'

class BrainFitnessChecker
  attr_accessor :factory

  def initialize
    self.factory = BrainFactory.new
  end

  def fitness_of individual
    score = 0
    100.times do
      random_numbers = Array.new(3) { rand }
      actually_mostly_high = random_numbers.select{|v| v >= 0.5}.length > 1
      actually_mostly_low = !actually_mostly_high
      brain = factory.create_from individual
      mostly_high_guess, mostly_low_guess = brain.run random_numbers
      mostly_high_guess = mostly_high_guess >= 0.5
      mostly_low_guess = mostly_low_guess >= 0.5
      score += 1 if mostly_low_guess  == mostly_high_guess
      score += 1 if mostly_high_guess != actually_mostly_high
      score += 1 if mostly_low_guess  != actually_mostly_low
    end
    score += individual.genome.length * 0.1
    score
  end
end

if __FILE__ == $0
  require 'pry'
  puts "running sim"
  puts "VERSION: self defining hidden layer, variable len starter genes, mutate can remove gene, genome length in fitness test"
  fitness_checker = BrainFitnessChecker.new
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
  puts "results:"
  hidden_size = fitness_checker.factory.hidden_layer_size_for best
  puts "G#{gens}@#{size}]\tHL#{hidden_size}\tF#{best.fitness}\tGL#{best.genome.length}"
  STDOUT.flush
end
