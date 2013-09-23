class Page
	def initialize uri, links = nil, assets = nil, status = 200
		@uri = uri
		@links = links
		@assets = assets
		@status = status
	end

	def to_s
		s = "URI: " + @uri + " (" + @status.to_s + ")"
		s += "\n\r- LINKS:"

		if (@links == nil || @links.length == 0)
			s += "\n\r-- (no links)"
		else
			for link in @links
				s += "\n\r-- " + link
			end
		end

		s += "\n\r- STATIC ASSETS:"

		if (@assets == nil || @assets.length == 0)
			s += "\n\r-- (no assets)"
		else
			for asset in @assets
				s += "\n\r-- " + asset
			end
		end

		s
	end

	def to_html
		s = "<h3 class=\"page\">URI: " + @uri + " (" + @status.to_s + ")</h3>"
		s += "\n\r<h4>- LINKS:</h4>"

		if (@links == nil || @links.length == 0)
			s += "\n\r<span class=\"link\">-- (no links)</span>"
		else
			for link in @links
				s += "<span class=\"link\">\n\r-- " + link + "</span>"
			end
		end

		s += "\n\r<h4>- STATIC ASSETS:</h4>"

		if (@assets == nil || @assets.length == 0)
			s += "\n\r<span class=\"link\">-- (no assets)</span>"
		else
			for asset in @assets
				s += "\n\r<span class=\"link\">-- " + asset + "</span>"
			end
		end

		s
	end
end