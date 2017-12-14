class Individual
end

class Fitness
end

class Mutator
  def mutate individual
  end
end

class Breeder
  def breed
  end
end

class Actor
  def perform individual
  end
end

class GoalChecker
  attr_accessor :target_fitness

  def goal_reached? population
  end
end

class FitnessChecker
  attr_accessor :actor, :desired_behavior

  def fitness individual
    desired_behavior - actor.perform(individual)
  end
end

class Population
  def initialize
    @individuals = []
  end

  # assumes that the lowest fitness is best fitness
  def best_performers fitness_checker
    @individuals
      .sort_by{ |i| f = fitness_checker.fitness i }
      .take(top_individuals_count)
  end

  def most_fit fitness_checker
    best_performers.first
  end

  def add individuals
    @individuals += individuals
  end

  private

  def calculate_fitnesses
  end

  def top_individuals_count
    @individuals.length * top_individuals_percent
  end

  def top_individuals_percent
    0.2
  end
end

