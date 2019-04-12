require 'em-http-request'
require 'json'

class GithubSearch
  def initialize(term)
    @term = term
  end
  
  def results
    result['items'] || []
  end
  
  def url
    "https://api.github.com/search/repositories?q=#{URI.encode(@term)}"
  end
  
  def result 
    fiber = Fiber.current
    
    http = EventMachine::HttpRequest.new(url).get
    http.callback { fiber.resume(http) }
    Fiber.yield
    
    http.response_header.status == 200 ? JSON.parse(http.response) : {}
  end
end
