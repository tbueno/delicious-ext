class Link

	attr_reader :text, :url, :posted_by
	
	def initialize(text, url, posted_by)
		@text = text
		@url = url
		@posted_by = posted_by		
	end

end
