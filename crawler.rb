require 'open-uri'
require 'uri'

class Crawler
	def extract_links_from_html(html_string)
		links = Array.new
		link_match_regex = Regexp.new("<a href=[\"']?(((https?)?(:\/\/)?([a-zA-Z0-9]+?\.)?gocardless\.com).*?|(?!https?)(?!:\/\/)[[a-zA-Z0-9]\/#\?].+?)[\"']?>", Regexp::IGNORECASE)
		html_string.scan(link_match_regex) do |link|
			links.push(link[0])
		end

		links
	end

	def get_page_links(uri_string)
		uri = URI(uri_string)
		file = open(uri)

		contents = file.read
		links = self.extract_links_from_html(contents)
	end
end