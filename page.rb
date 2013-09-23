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
end