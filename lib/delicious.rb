require 'rubygems'
require 'hpricot'
require 'open-uri'


# This Module is an extension to official del.icio.us API.
# The main purpose her is to provide functions like 
# get popular, hot and recent links. 
#
# Author::    Thiago Bueno Silva  (mailto:tbueno@gmail.com)
# License::   Distributes under the same terms as Ruby
module Delicious
  
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
	
	class Collector
	  @list_type = 0
  
    #Return the links from <i>'what's hot right now on del.icio.us'</i> section.
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
  			people = get_people(result).to_i
  			links << Delicious::Link.new( text, url, posted_by, people)
  		end
  		links		
  	end
	
  	def get_posted_by(result)
  	  name = " "
   
      if @list_type == POPULAR
        name = result.search("div[@class='meta']/a[@class='pop").first['href'].gsub("/", "")	
      elsif @list_type == HOT_LIST
        name = result.search("div[@class='tags']/p/a").inner_text
      elsif @list_type == RECENT
        name = result.search("div[@class='meta']/a[@class='user").first['href'].gsub("/", "")	
      end
      Delicious::Person.new(name)
    end
  
    def get_people(result)
      query = " "
   
      if @list_type == POPULAR or @list_type == RECENT
        query = result.search("div[@class='meta']/a[@class='pop']").inner_text.gsub(/[a-z]/, '').strip
      elsif @list_type == HOT_LIST
        query = result.search("div[@class='meta']/strong/span[@class='num']/span/a").inner_text
    
      end
      query
    end
  end
  ####### Collector Class end #############
  
  class Link

  	attr_reader :text, :url, :posted_by, :people

  	def initialize(text, url, posted_by, people)
  		@text = text
  		@url = url
  		@posted_by = posted_by
  		@people = people		
  	end

  	#Comparator method. The links should be ordered by the number of people that saved them.
  	def <=> (link)
  	  if @people > link.people
  	    return 1
      elsif @people < link.people
        return -1
      else
        return 0
      end

    end

    def equal?(link)
      link.url == @url
    end

  end
  ####### Link Class end #############
  
  class Person
    
    attr_reader :name, :url
    
    def initialize(name)
      @name = name
      @url = BASE_URL+'/'+name
    end
  end
  
end

d = Delicious::Collector.new

d.hot_list.each{ |l| puts l.posted_by.name}
