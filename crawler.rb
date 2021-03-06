require 'open-uri'
require 'uri'
require 'set'
require './page.rb'
require 'thread'

class Crawler
	def initialize start_uri
		start_uri = URI(start_uri).normalize()
		@link_queue = [ start_uri.to_s ]
		@found_pages_set = [ start_uri.to_s ]
		@site_map = Array.new
		@domain_boundary = start_uri.scheme + "://" + start_uri.host
		@link_match_regex = link_match_regex = Regexp.new("<a.*?href=[\"']?(((https?)?(:\/\/)?([a-zA-Z0-9]+?\.)?" + start_uri.host + ")[^\"'>]*|(?!([a-zA-Z0-9]+):)[a-zA-Z0-9\/#\?][^\"'>]*)[\"']?[^>]*?>", Regexp::IGNORECASE)
		@asset_match_regex = Regexp.new("<(img.*?src=[\"']?((((http)s?)?://)?[^\" '>]*)[\"']?|link.*?href=[\"']?((((http)s?)?://)?[^\" '>]*)[\"']?|script.*?src=[\"']?((((http)s?)?://)?[^\" '>]*)[\"']?).*?>", Regexp::IGNORECASE)
		@num_threads = 0
		@max_threads = 15
		@mutex = Mutex.new
	end

	def extract_links_from_html(html_string)
		links = Array.new
		
		html_string.scan(@link_match_regex) do |link|
			links.push(link[0])
		end

		links
	end

	def extract_static_assets_from_html(html_string)
		assets = Array.new
		html_string.scan(@asset_match_regex) do |asset|
			if (asset[1])
				asset[1].strip!
				assets.push(asset[1])
			elsif (asset[5])
				asset[5].strip!
				assets.push(asset[5])
			elsif (asset[9])
				asset[9].strip!
				assets.push(asset[9])
			end
		end

		assets
	end

	def scrape_page_for_links_and_assets(uri_string)
		uri = URI(uri_string)
		file = open(uri)

		# puts "Scraping " + uri_string

		contents = file.read
		links = self.extract_links_from_html(contents)
		assets = self.extract_static_assets_from_html(contents)

		for link in links
			if (link.start_with?("/"))
				link = URI.join(@domain_boundary, link).normalize().to_s
			elsif (!link.start_with?("://") || !link.start_with?("http"))
				link = URI.join(uri_string, link).normalize().to_s
			end

			if (!@link_queue.include?(link) && !@found_pages_set.include?(link))
				# puts "Adding " + link + " to the queue"
				@mutex.synchronize do
					@link_queue.push(link)
				end
			end
		end

		p = Page.new(uri_string, links, assets)
		# puts "DONE: " + uri_string
		@mutex.synchronize do
			@site_map.push(p)
			@found_pages_set.push(uri_string)
			@num_threads -= 1
		end
		p
	rescue RuntimeError
		# puts "Had trouble with one of the URIs: " + uri_string
		@mutex.synchronize do
			@found_pages_set.push(uri_string)
			@num_threads -= 1
		end
		nil
	rescue OpenURI::HTTPError => ex
		# puts ex
		p = Page.new(uri_string, nil, nil, ex.io.status[0])
		# puts "DONE: " + uri_string
		@mutex.synchronize do
			@site_map.push(p)
			@found_pages_set.push(uri_string)
			@num_threads -= 1
		end
		p
	end

	def scrape_next_page
		@num_threads += 1
		current_link = @link_queue.shift
		puts "Looking at " + current_link + " (" + @link_queue.length.to_s + " pages left, " + @num_threads.to_s + " threads being used, " + @found_pages_set.length.to_s + " pages found so far)"
		Thread.new{
			scrape_page_for_links_and_assets(current_link)
		}
		# if (p)
		# 	output << p.to_html
		# end
	end

	def crawl
		t1 = Time.now
		puts "Domain is " + @domain_boundary
		scrape_next_page
		while @link_queue.length > 0 || @num_threads > 0 do
			# puts "Queue length is " + @link_queue.length.to_s + " and num threads is " + @num_threads.to_s
			if (@num_threads < @max_threads && @link_queue.length > 0)
				t = scrape_next_page
			end
		end
		t2 = Time.now
		total_time = t2 - t1
		puts "Done! Found " + @found_pages_set.length.to_s + ' pages and it took ' + total_time.to_f.to_s + ' seconds to run with ' + @max_threads.to_s + ' threads available'
		puts "Outputting to an HTML page..."
		output = File.open("results/index.html", "w")
		output.truncate(0)
		output << "\r\n<!DOCTYPE html>"
		output << "\r\n<html>"
		output << "\r\n<head>"
		output << "\r\n<link href=\"results.css\" rel=\"stylesheet\" />"
		output << "\r\n<body>"
		for page in @site_map
			output << page.to_html
		end
		output << "\r\n<script src=\"jquery-2.0.3.min.js\"></script>"
		output << "\r\n<script src=\"results.js\"></script>"
		output << "\r\n</body>"
		output << "\r\n</html>"
		output.close
		puts "Done with the output! See it at /resuls/index.html"
	end
end