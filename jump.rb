require_relative 'lib'

class Actor

  CHROMOSOMES = {
    MORE_JUMP: PatternChromosome.new(pattern:  [0, 0, 0, 0, 1, 1, 1, 0], affect: [0,  1]),
    MORE_LEFT: PatternChromosome.new(pattern:  [0, 0, 0, 1, 0, 1, 1, 1], affect: [-1, 0]),
    MORE_DUCK: PatternChromosome.new(pattern:  [1, 0, 1, 1, 1, 1, 0, 0], affect: [0, -1]),
    MORE_RIGHT: PatternChromosome.new(pattern: [1, 1, 0, 1, 1, 0, 1, 1], affect: [1,  0]),
    LESS_JUMP: PatternChromosome.new(pattern:  [1, 0, 0, 1, 1, 0, 1, 0], affect: [0, -1]),
    LESS_LEFT: PatternChromosome.new(pattern:  [1, 1, 0, 0, 1, 1, 1, 1], affect: [1,  0]),
    LESS_DUCK: PatternChromosome.new(pattern:  [1, 1, 0, 0, 0, 1, 0, 1], affect: [0,  1]),
    LESS_RIGHT: PatternChromosome.new(pattern: [1, 1, 0, 1, 0, 1, 1, 1], affect: [-1, 0]),
  }

  def actions genome
    moves = expressions(genome)
              .group_by { |e| e.first }
              .to_a
              .sort_by { |(_, es)| es.length }
              .map { |(e, _)| e }
    moves
  end

  def chromosomes
    CHROMOSOMES.values
  end

  def expressions genome
    chromosomes.reduce([]) do |expressions, chromosome|
      expressions += chromosome.alleles genome
    end
  end
end

class PatternChromosome
  attr_accessor :pattern, :count, :affect

  def initialize pattern: [], count: 1, affect: []
    self.pattern = pattern
    self.count   = count
    self.affect  = affect
  end

  def alleles genome
    [affect] * activation_level
  end

  def active? genome
    activation_level > 0
  end

  def activation_level genome
    1 + find_occurances(genome).length - count
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
  puts "running sim"
  chromosomes = patterns.map { |p| PatternChromosome.new(p) }
  sim = Sim.new(ChromosomeFitnessChecker.new(*chromosomes))
  results = sim.run!(generations: 1000, community_size: 1000) do |generation, sim, community|
    best = sim.most_fit(community)
    puts "G#{generation}] #{best.fitness} :: #{best.genome}"
  end
  puts "results: #{results.fitness} :: #{results.genome}"
end
