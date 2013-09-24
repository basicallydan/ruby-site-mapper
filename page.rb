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
		s = "<div class=\"page\"><h3 class=\"page-uri\">URI: " + @uri + " (" + @status.to_s + ")</h3>"
		s += "\n\r<h4 class=\"links-header\">LINKS:</h4>"
		s += "\n\r<ul class=\"links-list hidden\">"

		if (@links == nil || @links.length == 0)
			s += "\n\r<li class=\"link\">(no links)</li>"
		else
			for link in @links
				s += "\n\r<li class=\"link\">" + link + "</li>"
			end
		end

		s += "\n\r</ul>"

		s += "\n\r<h4 class=\"assets-header\">STATIC ASSETS:</h4>"
		s += "\n\r<ul class=\"assets-list hidden\">"

		if (@assets == nil || @assets.length == 0)
			s += "\n\r<li class=\"asset\">(no assets)</li>"
		else
			for asset in @assets
				s += "\n\r<li class=\"asset\">" + asset + "</li>"
			end
		end

		s += "\n\r</ul></div>"

		s
	end
end