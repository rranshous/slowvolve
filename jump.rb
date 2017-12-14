require_relative 'lib'


class PatternChromosome
  attr_accessor :pattern, :count

  def initialize pattern, count=1
    self.pattern = pattern
    self.count = count
  end

  def distance genome
    return 0 if find_occurances(genome).length >= 1
    genome.each_cons(pattern.length).map do |els|
      pattern.zip(els).reduce(0) { |sum, (p,e)| sum += (p == e ? 0: 1) }
    end.reduce(0, :+)
  end

  private

  def find_occurances genome
    genome.each_cons(pattern.length).select { |els| els == pattern }
  end
end

class ChromosomeFitnessChecker
  attr_accessor :chromosomes

  def initialize *chromosomes
    self.chromosomes = chromosomes
  end

  def fitness_of individual
    self.chromosomes.reduce(0) do |sum, chromosome|
      sum += chromosome.distance(individual.genome)
    end
  end
end

if __FILE__ == $0
  require 'pry'

  patterns = [
    [1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 0, 1, 1, 0,
     1, 1, 1, 0, 0, 0, 1, 1, 0, 1, 0, 0]
  ]
  patterns = [[ 1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,0,1,1,0 ]]
  puts "running sim"
  chromosomes = patterns.map { |p| PatternChromosome.new(p) }
  sim = Sim.new(ChromosomeFitnessChecker.new(*chromosomes))
  results = sim.run!(generations: 1000, community_size: 1000) do |generation, sim, community|
    best = sim.most_fit(community)
    puts "G#{generation}] #{best.fitness} :: #{best.genome}"
  end
  puts "results: #{results.fitness} :: #{results.genome}"
end
