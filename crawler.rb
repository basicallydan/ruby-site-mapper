require 'open-uri'
require 'uri'
require 'set'
require './page.rb'

class Crawler
	def initialize
		@link_queue = Array.new
		@found_pages_set = Set.new
		@site_map = Array.new
		@domain_boundary = String.new
	end

	def extract_links_from_html(html_string)
		links = Array.new
		link_match_regex = Regexp.new("<a.*?href=[\"']?(((https?)?(:\/\/)?([a-zA-Z0-9]+?\.)?gocardless\.com)[^\"'>]*|(?!https?)(?!:\/\/)[[a-zA-Z0-9]\/#\?][^\"'>]*)[\"']?[^>]*?>", Regexp::IGNORECASE)
		html_string.scan(link_match_regex) do |link|
			links.push(link[0])
		end

		links
	end

	def extract_static_assets_from_html(html_string)
		assets = Array.new
		asset_match_regex = Regexp.new("<(img.*?src=[\"']?((((http)s?)?://)?[^\" '>]*)[\"']?|link.*?href=[\"']?((((http)s?)?://)?[^\" '>]*)[\"']?).*?>", Regexp::IGNORECASE)
		html_string.scan(asset_match_regex) do |asset|
			if (asset[1])
				asset[1].strip!
				assets.push(asset[1])
			elsif (asset[5])
				asset[5].strip!
				assets.push(asset[5])
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
				link = URI.join(@domain_boundary, link).to_s
			elsif (!link.start_with?("://") || !link.start_with?("http"))
				link = URI.join(uri_string, link).to_s
			end

			if (!@link_queue.include?(link))
				puts "Adding " + link + " to the queue"
				@link_queue.push(link)
			end
		end

		p = Page.new(uri_string, links, assets)
		@site_map.push(p)
	end

	def crawl(start_page_uri)
		uri = URI(start_page_uri)
		@link_queue.push(start_page_uri)
		@domain_boundary = uri.scheme + "://" + uri.host
		puts "Domain is " + @domain_boundary
		while @link_queue.length > 0 do
			current_link = @link_queue.shift
			puts "Looking at " + current_link
			scrape_page_for_links_and_assets(current_link)
		end
	end
end