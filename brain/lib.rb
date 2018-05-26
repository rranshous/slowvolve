require_relative 'image_collection'
require_relative 'red_finder_fitness_checker'

module Brain

  module FitnessChecker
    class HighOrLow
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
  end
end
