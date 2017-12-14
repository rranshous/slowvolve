class Individual
  GENOME_LENGTH = 100

  def self.new_random
    new random_genome(GENOME_LENGTH)
  end

  def self.random_genome len
    choices = [0, 1]
    Array.new(len) { choices.sample }
  end

  attr_accessor :genome, :fitness, :age

  def initialize genome
    raise "wtf?! #{genome.length}" if genome.length != GENOME_LENGTH
    self.genome = genome
    self.age = 0
  end

  def get_older
    self.age += 1
  end

  def + other
    # TODO: make gene based choice for crossover % (?)
    crossover_percent = rand(1..9).to_f * 0.1
    crossover_index = (crossover_percent * genome.length).to_i
    new_genome = genome[0...crossover_index].zip(other.genome).map { |g1, g2|  [g1, g2].sample }
    new_genome += genome[crossover_index..-1]
    new_genome = mutate(new_genome)
    self.class.new new_genome
  end

  def mutate genome
    genome.map { |g| random_mutate? ? flip(g) : g }
  end

  private

  def flip g
    g == 0 ? 1 : 0
  end

  def random_mutate?
    # TODO: make gene based choice
    rand(0..1000) == 11
  end
end

class Community
  MAX_AGE = 3

  attr_accessor :fitness_checker, :target_size

  def run_generation sim
    cull sim
    age sim
    breed sim
    fill_out sim
    compute_fitnesses sim
  end

  def compute_fitnesses sim
    sim.individuals
      .select { |i| i.fitness.nil? }
      .each { |i| i.fitness = compute_fitness(i) }
  end

  def cull sim
    dying = sim.individuals.select { |i| i.age > MAX_AGE }
    sim.remove_individuals dying
    remaining_population_size = sim.individuals.length
    to_kill = [remaining_population_size - target_size, 0].max
    individuals_by_fitness(sim).take(to_kill)
      .each { |i| sim.remove_individual i }
  end

  def age sim
    sim.individuals.each(&:get_older)
  end

  def breed sim
    new_individuals = top_pairs(sim).map { |i1, i2| i1 + i2 }
    sim.add_individuals new_individuals
  end

  def fill_out sim
    to_create = target_size - sim.individuals.length
    to_create.times { |i| sim.add_individual random_individual }
  end

  def random_individual
    Individual.new_random
  end

  def compute_fitness individual
    fitness_checker.fitness_of individual
  end

  def most_fit sim
    sim.individuals.sort_by(&:fitness).first
  end

  def individuals_by_fitness sim
    sim.individuals.sort_by(&:fitness)
  end

  private

  def top_pairs sim
    breed_count = sim.individuals.length * 0.2 # take top 20%
    sim.individuals
      .sort_by(&:fitness)
      .take(breed_count)
      .each_cons(2)
  end
end

class Sim
  attr_accessor :community, :individuals

  def initialize fitness_checker
    self.community = Community.new
    self.community.fitness_checker = fitness_checker
    self.individuals = []
  end

  def run! generations: 100, community_size: 100
    puts "Running: #{community_size}x#{generations}"
    community.target_size = community_size
    generations.times do |i|
      puts "GENERATION: #{i}"
      community.run_generation self
      return community.most_fit(self) if done?
    end
    community.most_fit(self)
  end

  def done?
    max_fitness_achieved?
  end

  def add_individuals individuals
    self.individuals += individuals
  end

  def remove_individuals individuals
    self.individuals -= individuals
  end

  def remove_individual i
    remove_individuals [i]
  end

  def add_individual i
    add_individuals [i]
  end

  def max_fitness_achieved?
    individuals.detect { |i| i.fitness == 0 } ? true : false
  end
end


