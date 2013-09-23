require 'open-uri'
require 'uri'
require 'set'
require './page.rb'

class Crawler
	def initialize start_uri
		start_uri = URI(start_uri).normalize()
		@link_queue = [ start_uri.to_s ]
		@found_pages_set = [ start_uri.to_s ]
		@site_map = Array.new
		@domain_boundary = start_uri.scheme + "://" + start_uri.host
		@link_match_regex = link_match_regex = Regexp.new("<a.*?href=[\"']?(((https?)?(:\/\/)?([a-zA-Z0-9]+?\.)?" + start_uri.host + ")[^\"'>]*|(?!([a-zA-Z0-9]+):)[a-zA-Z0-9\/#\?][^\"'>]*)[\"']?[^>]*?>", Regexp::IGNORECASE)
		@asset_match_regex = Regexp.new("<(img.*?src=[\"']?((((http)s?)?://)?[^\" '>]*)[\"']?|link.*?href=[\"']?((((http)s?)?://)?[^\" '>]*)[\"']?|script.*?src=[\"']?((((http)s?)?://)?[^\" '>]*)[\"']?).*?>", Regexp::IGNORECASE)
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
				puts "Adding " + link + " to the queue"
				@link_queue.push(link)
			end
		end

		p = Page.new(uri_string, links, assets)
		puts p.to_s
		@site_map.push(p)
		@found_pages_set.push(uri_string)
	rescue RuntimeError
		puts "Had trouble with one of the URIs: " + uri_string
		@found_pages_set.push(uri_string)
	rescue OpenURI::HTTPError => ex
		# puts ex
		p = Page.new(uri_string, nil, nil, ex.io.status[0])
		puts p.to_s
		@site_map.push(p)
		@found_pages_set.push(uri_string)
	end

	def crawl
		puts "Domain is " + @domain_boundary
		while @link_queue.length > 0 do
			current_link = @link_queue.shift
			puts "Looking at " + current_link
			scrape_page_for_links_and_assets(current_link)
		end
	end
end