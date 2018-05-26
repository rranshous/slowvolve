require_relative '../brain'
fitness_checker = Brain::FitnessChecker::RedFinder.new
images = fitness_checker.image_collection.all
images.each do |image|
  writer = Brain::PixelWriter.new image: image
  puts "converting: #{image}"
  writer.write_as_json
end
