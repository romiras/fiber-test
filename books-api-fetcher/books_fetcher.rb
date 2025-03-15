require 'faraday'
require 'json'

# The fetch_all_pages method creates a Fiber for each page number, schedules them to be executed in a loop,
#  and yields the result of each Fiber instead of concatenating them into a single array.
# The loop continues until all Fibers have been executed,
#  and it introduces a delay between each request using the RATE_LIMIT_DELAY constant.

class BooksFetcher
  API_ENDPOINT = "http://api.example.com/api/v1/books".freeze
  RATE_LIMIT_DELAY = 0.25

  def initialize(total_pages)
    @total_pages = total_pages
    @connection = Faraday.new(url: API_ENDPOINT)
  end

  def fetch_all_pages
    fibers = Array.new(@total_pages) do |page_number|
      Fiber.new do
        data = fetch_page(page_number + 1)
        yield(data)
      end
    end

    while fibers.any?
      fibers.each do |fiber|
        if fiber.alive?
          fiber.resume
          sleep(RATE_LIMIT_DELAY)
        end
      end
    end
  end

  private

  def fetch_page(page_number)
    response = @connection.get("?page=#{page_number}")
    JSON.parse(response.body)
  end
end
