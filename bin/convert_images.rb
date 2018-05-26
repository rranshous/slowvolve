require_relative '../brain'
fitness_checker = Brain::FitnessChecker::RedFinder.new
images = fitness_checker.image_collection.all
images.each do |image|
  writer = Brain::PixelWriter.new image: image
  unless writer.json_version_exists?
    puts "converting to json: #{image}"
    writer.write_as_json
  end
  unless writer.bson_version_exists?
    puts "converting to bson: #{image}"
    writer.write_as_bson
  end
end
