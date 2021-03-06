require 'rubygems'
require 'bundler/setup'

require "dotenv"
Dotenv.load

require "echelon"
require "csv"
require "fileutils"

require "./error_notifier"
require "./utils"

with_error_reporting do
  now = Time.now

  dir = ENV['TARGET_DIRECTORY']
  FileUtils::mkdir_p(dir)

  # Disney World
  wdw = Echelon::DisneyWorld.new
  parks = %w(animal_kingdom epcot hollywood_studios magic_kingdom)

  parks.each do |park_name|
    queue_times = { "Date" => now.strftime("%F %T") }

    park = wdw.send(park_name)

    park.rides.each do |ride|
      queue_times["#{ride.name} (#{humanize(park_name)})"] = ride.active == 1 ? ride.queue_time[:posted] : '-'
    end

    filename = File.join(dir, "#{park_name}-#{now.strftime("%Y-%m")}.csv")
  
    write_headers = !File.exists?(filename)

    CSV.open(filename, "ab") do |csv|
      csv << queue_times.keys if write_headers
      csv << queue_times.values
    end
  end
end
