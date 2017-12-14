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

class FitnessChecker

  def fitness_of individual
    # find a genome w/ 5 occurencees of the pattern
    (5 - PatternCountChromosome.new([1,1,0]).express(individual.genome)).abs
  end


  def fitness_of_old individual
    # all 1s
    f = individual.genome.length - individual.genome.count(&:odd?)
    puts "fitness [#{individual}]: #{f}"
    f
  end
end

if __FILE__ == $0
  require 'pry'
  puts "running sim"
  sim = Sim.new FitnessChecker.new
  results = sim.run! 1000
  puts "results: #{results.fitness} :: #{results.genome}"
end
