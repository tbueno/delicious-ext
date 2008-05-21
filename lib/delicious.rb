require 'rubygems'
require 'hpricot'
require 'open-uri'




#
#
#
#	TODO Japanese link descriptions are returning strange strings
#
#
#


require 'link'

class Delicious
	
	BASE_URL = 'http://del.icio.us'
	HOT_LIST_QUERY = "//div[@class='hotlist']/ol/li/h4"
	
	POPULAR_URL = BASE_URL+'/popular'
	POPULAR_NEW_URL = POPULAR_URL+'/?new'
	POPULAR_QUERY = "//div[@id='main']/ol/li/h4"
	
	RECENT_URL = BASE_URL+'/recent'
	
	SEARCH_URL = BASE_URL+'/search/?fr='
	SEARCH_QUERY = "////div[@id='main']/div/ol[@class='posts']/li/h4"
	
	

	def hot_list
		get_links BASE_URL, HOT_LIST_QUERY
	end
	
	def popular(tag='')
		get_links POPULAR_URL+'/'+tag, POPULAR_QUERY
	end
	
	def popular_new
		get_links POPULAR_NEW_URL, POPULAR_QUERY
	end
	
	def recent(min=2)
		get_links RECENT_URL+'?min='+min.to_s, POPULAR_QUERY
	end
	
	def search(term)
		get_links SEARCH_URL+term+'&type=all', SEARCH_QUERY		
	end

	private
	def get_links(base_url, query)
		links = []
		doc = Hpricot(open(base_url))			
		doc.search(query).each do |result|			
			text = result.search("a[@href").first.inner_text
			url =  result.search("a[@href").first['href']				
			links << Link.new( text, url)
		end
		links		
	end
end





d = Delicious.new
d.popular_new.each{|l| p l.text}
p "--"