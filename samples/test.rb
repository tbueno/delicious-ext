require File.dirname(__FILE__) + "/../lib/delicious"

d = Delicious::Collector.new


links = d.hot_list


links.each do |link|
  tags = ''
  link.tags.each do |tag|
    tags << tag+','
  end
  
  puts '------------------------------------------'
  puts 'Text: '+link.text
  puts 'URL: '+link.url
  puts 'People: '+link.people.to_s
  puts 'Posted By: '+link.posted_by.name
  puts 'Tags: '+ tags
end
