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
  
  #Possible types of lists
  HOT_LIST = 0
  POPULAR = 1
  RECENT = 2
  SEARCH = 3
  
	
	BASE_URL = 'http://del.icio.us'
	HOT_LIST_QUERY = "//div[@class='hotlist']/ol/li"
	
	POPULAR_URL = BASE_URL+'/popular'
	POPULAR_NEW_URL = POPULAR_URL+'/?new'
	POPULAR_QUERY = "//div[@id='main']/ol/li"
	
	RECENT_URL = BASE_URL+'/recent'
	
	SEARCH_URL = BASE_URL+'/search/?fr='
	SEARCH_QUERY = "////div[@id='main']/div/ol[@class='posts']/li"
	
	@list_type = 0

	def hot_list
	  @list_type = HOT_LIST
		get_links BASE_URL, HOT_LIST_QUERY
	end
	
	def popular(tag='')
	  @list_type = POPULAR
		get_links POPULAR_URL+'/'+tag, POPULAR_QUERY
	end
	
	def popular_new
	  @list_type = POPULAR
		get_links POPULAR_NEW_URL, POPULAR_QUERY
	end
	
	def recent(min=2)
	  @list_type = RECENT
		get_links RECENT_URL+'?min='+min.to_s, POPULAR_QUERY
	end
	
	def search(term)
	  @list_type = SEARCH
		get_links SEARCH_URL+term+'&type=all', SEARCH_QUERY		
	end

	private
	def get_links(base_url, query)
		links = []
		
		doc = Hpricot(open(base_url))			
		doc.search(query).each do |result|			
			text = result.search("h4/a[@href").first.inner_text
			url =  result.search("h4/a[@href").first['href']
			posted_by = get_posted_by(result)	
			links << Link.new( text, url, posted_by)
		end
		links		
	end
	
	def get_posted_by(result)
	  query = " "
   
    
    if @list_type == POPULAR
      query = result.search("div[@class='meta']/a[@class='pop").first['href'].gsub("/", "")	
    elsif @list_type == HOT_LIST
      query = result.search("div[@class='tags']/p/a").inner_text
    elsif @list_type == RECENT
      query = result.search("div[@class='meta']/a[@class='user").first['href'].gsub("/", "")	
    end
    query
  end
 
  
end





d = Delicious.new

p "-- Popular --"
#d.popular.each{|l| p l.posted_by}

p "-- Popular new --"
#d.popular_new.each{|l| p l.posted_by}
p "-- Hot List --"
#d.hot_list.each{|l| p l.posted_by}
p "-- Recent --"
d.recent.each{|l| p l.posted_by}