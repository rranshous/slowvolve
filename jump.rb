require_relative 'lib'


class PatternCountChromosome
  attr_accessor :pattern

  def initialize pattern
    self.pattern = pattern
  end

  def express genome
    # returns the # of times that the genome contains the pattern
    genome.each_cons(pattern.length).select { |els| els == pattern }.length
  end
end

class CompoundFitnessChecker
  attr_accessor :fitness_checkers

  def initialize *fitness_checkers
    self.fitness_checkers = fitness_checkers
  end

  def fitness_of individual
    self.fitness_checkers.reduce(0) { |sum, fit| sum + fit.fitness_of(individual) }
  end
end

class PatternFitnessChecker
  attr_accessor :chromosome, :count, :pattern

  def initialize pattern, count=5
    self.count = count
    self.pattern = pattern
    self.chromosome = PatternCountChromosome.new pattern
  end

  def fitness_of individual
    # find a genome w/ 5 occurencees of the pattern
    (count - chromosome.express(individual.genome)).abs
  end
end

if __FILE__ == $0
  require 'pry'
  puts "running sim"
  sim = Sim.new CompoundFitnessChecker.new(
    PatternFitnessChecker.new([1,1,1]),
    PatternFitnessChecker.new([0,0,0]),
    PatternFitnessChecker.new([0,0,0,1,1,0,1])
  )
  results = sim.run! generations: 1000, community_size: 1000
  puts "results: #{results.fitness} :: #{results.genome}"
end
