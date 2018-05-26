
require_relative 'lib'
require_relative 'brain/lib'
require 'json'

puts "VERSION: self defining hidden layer, variable len starter genes, mutate can remove gene, genome length in fitness test, red images, real images as input"

if __FILE__ == $0
  require 'pry'
  puts "running sim"
  fitness_checker = Brain::FitnessChecker::RedFinder.new
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
