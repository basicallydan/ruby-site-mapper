# crawler_spec.rb
require_relative '../crawler'

describe Crawler, "#extract_links_from_html" do
	it "returns a list of links" do
		crawler = Crawler.new
		links = crawler.extract_links_from_html("<a href=\"https://gocardless.com/blog\">blog</a> <a href=\"/contact/\">contact</a> <a href=\"://gocardless.com/glob\">glob</a> <a href=\"https://www.gocardless.com/bleepbloop\" class=\"whee\">bleep</a> <a href=https://whatever.gocardless.com/stuff>whatever</a> <a href=\"http://google.com/privacy\">google privacy</a> <a href=\"relative\">hello</a> <a href=\"#hash\">hash</a> <a href=\"?query=whatever\">query</a>")
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

describe Crawler, "#extract_static_assets_from_html" do
	it "returns images" do
		crawler = Crawler.new
		static_assets = crawler.extract_static_assets_from_html("<img src=cat.gif /> <img class=\"whatevs\" src=anothercat.gif> <img src=\"manycats.gif\"> <img src=\"http://gocardless.com/morecats.gif\" class=\"image\"> <img href=dog.png>")
		static_assets.should include("cat.gif")
		static_assets.should include("anothercat.gif")
		static_assets.should include("manycats.gif")
		static_assets.should include("http://gocardless.com/morecats.gif")
		static_assets.should_not include("dog.png")

		static_assets.length.should equal(4)
	end

	it "returns resource links" do
		crawler = Crawler.new
		static_assets = crawler.extract_static_assets_from_html("<link href=\"style.css\" /> <link rel=\"stylesheet\" href=alt.css>")
		static_assets.should include("style.css")
		static_assets.should include("alt.css")

		static_assets.length.should equal(2)
	end

	it "returns script links" do
		crawler = Crawler.new
		static_assets = crawler.extract_static_assets_from_html("<script src=\"js.js\"></script> <script src=script.js type=\"text/javascript\">")
		static_assets.should include("js.js")
		static_assets.should include("script.js")

		static_assets.length.should equal(2)
	end
end