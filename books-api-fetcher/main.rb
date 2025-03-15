fetcher = BooksFetcher.new(20)
fetcher.fetch_all_pages do |page_data|
  # Process the page data here
end
