# simple, get actor to jump
require_relative 'lib'


fitness_checker.actor = actor
fitness_checker.desired_behavior = desired_behavior

goal_checker.target_fitness = target_fitness

until goal_checker.goal_reached? fitness_checker, individual
  best_performers = population.best_performers fitness_checker
  new_individuals = breeder.breed best_performers
  new_individuals = new_individuals.map{ |i| mutator.mutate i }
  population = Population.new
  population.add best_performers
  population.add new_individuals
end
