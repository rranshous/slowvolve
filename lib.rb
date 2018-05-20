require_relative 'neural_net'

class Individual
  GENOME_LENGTH = 100
  VariableGeneLength = false

  def self.new_random
    new random_genome(GENOME_LENGTH)
  end

  def self.random_genome len
    #choices = [0, 1]
    #Array.new(len) { choices.sample }
    variance = len * 0.5
    len += rand(-variance..variance) if VariableGeneLength
    Array.new(len) { rand }.map {|v| rand(0..1)==1 ? -(v) : v }
  end

  attr_accessor :genome, :fitness

  def initialize genome
    self.genome = genome
  end

  def + other
    # TODO: make gene based choice for crossover % (?)
    crossover_percent = rand(1..9).to_f * 0.1
    crossover_index = (crossover_percent * genome.length).to_i
    new_genome = genome[0...crossover_index].zip(other.genome).map { |g1, g2|  [g1, g2].sample }.compact
    new_genome += genome[crossover_index..-1]
    new_genome = mutate(new_genome)
    self.class.new new_genome
  end

  def mutate genome
    genome.pop if VariableGeneLength && random_mutate?
    genome.map { |g| random_mutate? ? nudge(g) : g }
  end

  private

  def nudge g
    [g + 0.1, g - 0.1].sample
  end

  def flip g
    #g == 0 ? 1 : 0
    -(g)
  end

  def random_mutate?
    # TODO: make gene based choice
    rand(0..1000) == 11
  end
end

class Community
  attr_accessor :fitness_checker, :target_size

  def run_generation sim
    puts "pop size: #{sim.individuals.size}"
    cull sim
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
    to_kill = sim.individuals.size * 0.8
    puts "killing: #{to_kill}"
    individuals_by_fitness(sim).reverse.take(to_kill)
      .each { |i| sim.remove_individual i }
  end

  def breed sim
    return if sim.individuals.length == 0
    to_birth = (target_size - sim.individuals.length) * 0.8
    new_individuals = []
    while new_individuals.length < to_birth
      new_individuals += top_pairs(sim).map { |i1, i2| i1 + i2 }
    end
    puts "birthed: #{new_individuals.length}"
    sim.add_individuals new_individuals
  end

  def fill_out sim
    to_create = target_size - sim.individuals.length
    puts "creating: #{to_create}"
    sim.add_individuals(Array.new(to_create) { random_individual })
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
    sim.individuals
      .sort_by(&:fitness)
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
    puts "Running: #{generations}@#{community_size}"
    community.target_size = community_size
    generations.times do |i|
      community.run_generation self
      yield(i, self, community) if block_given?
      return community.most_fit(self) if done?
    end
    community.most_fit(self)
  end

  def done?
    max_fitness_achieved?
  end

  def most_fit community
    community.most_fit self
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
    individuals.detect do |i|
      fitness_checker.best_possible?(i)
    end
  end

  def fitness_checker
    community.fitness_checker
  end
end

class BrainFactory
  attr_accessor :input_layer_size, :output_layer_size

  def initialize input_layer_size: 3, output_layer_size: 2
    # first layer has N neurons
    # next layer has M neurons
    # each of the M neurons will have N + 1 weights
    # first layer has no weights
    # below would have 3 neurons w/ no weights
    #  (not defined in genome)
    # than 7 neurons w/ 4 conns each = 28 weights
    #
    # define just the top and bottom, hidden layer is self defining from genome
    self.input_layer_size = input_layer_size
    self.output_layer_size = output_layer_size
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
