require 'sinatra'
require 'json'
require_relative '../brain'

set :fitness_checker, Brain::FitnessChecker::RedFinder.new

post '/fitness_of' do
  individual = OpenStruct.new(JSON.parse(request.body.read))
  puts "got individual: #{individual}"
  score = settings.fitness_checker.fitness_of(individual)
  puts "got fitness: #{score}"
  { fitness: score }.to_json
end
