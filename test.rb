require 'eventmachine'
require './lib/fiber_pool'
require './lib/github_search'

pool = FiberPool.new(3)

def print_result(line, repo_name)
  repo_name ||= '-none-'
  puts "#{line}: #{repo_name}"
end

# Read phrases from a file, printing the first github repo matching each
EM.run do
  File.open('phrases.txt') do |f|
    while (line = f.gets)
      line = line.strip
      pool.enqueue(line) do |line|
        results = GithubSearch.new(line).results
        if results.any?
          repo = results.first
          print_result(line, repo['name'])
        else
          print_result(line, nil)
        end
      end
    end
  end
  
  # Need a notification when all of the items on the queue are done processing
  Fiber.new do 
    pool.finish(Fiber.current) 
    Fiber.yield # wait for callback
    EM.stop
  end.resume
end
