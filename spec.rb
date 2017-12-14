require 'ostruct'
require 'rspec'
require_relative 'lib'

describe Population do

  let(:fitness_checker) { instance_double FitnessChecker }
  let(:population_size) { rand(10..20) }
  let(:individuals) { Array.new(population_size) {|c| OpenStruct.new(fitness: c) }.shuffle }

  before do
    subject.add individuals
    allow(fitness_checker).to receive(:fitness) { |i| i.fitness }
  end

  describe 'identifying the best performing individuals (#best_performers)' do
    let(:result) { subject.best_performers(fitness_checker) }
    let(:top_20_percent) { individuals.sort_by {|i| i.fitness }.take(population_size * 0.2) }
    it 'returns most fit 20% of population, sorted by fitness' do
      expect(result).to eq top_20_percent
    end
  end

  describe 'identifying the best performing individual (#most_fit)' do
    let(:result) { subject.most_fit fitness_checker }
    it 'returns the individual with best fitness' do
      expect(result).to eq top_20_percent.first
    end
  end
end

describe FitnessChecker do
  describe 'check individuals fitness (#fitness)' do
    let(:individual) { instance_double Individual }
    let(:actor) { instance_double Actor }
    let(:result_behavior) { Object.new }
    let(:desired_behavior) { Object.new }
    let(:fitness) { Object.new }
    before do
      subject.actor = actor
      subject.desired_behavior = desired_behavior
      allow(actor).to receive(:perform).and_return(result_behavior)
      allow(desired_behavior).to receive(:-).with(result_behavior).and_return(fitness)
    end
    it 'has actor perform individual' do
      expect(actor).to receive(:perform).with(individual)
      subject.fitness individual
    end
    it "returns the diff between the desired behavior and the actor's behavior" do
      expect(subject.fitness(individual)).to eq(desired_behavior - result_behavior)
    end
  end
end

describe GoalChecker do
  describe 'checking if population has reached its goal (#goal_reached?)' do
    let(:target_fitness) { instance_double Fitness }
    let(:fitness) { instance_double Fitness }
    let(:individual) { instance_double Individual }
    let(:result) { subject.goal_reached? individual, target_fitness }
    context 'the fitness of the best individuals is greater than target' do
      it 'returns false' do
        expect(result).to eq false
      end
    end
  end
end
