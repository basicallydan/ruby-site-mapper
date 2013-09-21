# crawler_spec.rb
require_relative '../crawler'

describe Crawler, "#extract_links_from_html" do
	it "returns a list of links" do
		crawler = Crawler.new
		links = crawler.extract_links_from_html("<a href=""https://gocardless.com/blog"">blog</a> <a href=""/contact/"">contact</a> <a href=""://gocardless.com/glob"">glob</a> <a href=""https://www.gocardless.com/bleepbloop"">bleep</a> <a href=https://whatever.gocardless.com/stuff>whatever</a> <a href=""http://google.com/privacy"">google privacy</a> <a href=""relative"">hello</a> <a href=""#hash"">hash</a> <a href=""?query=whatever"">query</a>")
		links.should include("https://gocardless.com/blog")
		links.should include("/contact/")
		links.should include("://gocardless.com/glob")
		links.should include("https://www.gocardless.com/bleepbloop")
		links.should include("https://whatever.gocardless.com/stuff")
		links.should include("relative")
		links.should include("#hash")
		links.should include("?query=whatever")
		# puts links
		links.length.should equal(8)
	end
end

describe Crawler, "#get_page_links" do
	it "returns a list of links" do
		crawler = Crawler.new
		links = crawler.get_page_links("https://gocardless.com")
		links.should include("https://gocardless.com/blog")
		# puts links
		links.length.should be > 1
	end
end