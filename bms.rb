<`ruby>
#!/usr/bin/env ruby

require 'nokogiri'
require 'open-uri'
require 'net/smtp'
require 'gmail'
require 'active_support/time'
require 'notify-send'

# ADD THEATE NAME AS IN BOOKMYSHOW SITE
# EXAMPLE
# REQUIRED_THEATRES = [ 'Cinepolis: Manjeera Mall, Kukatpally','PVR Forum Sujana Mall: Kukatpally, Hyderabad' ]
REQUIRED_THEATRES = []

class Theatre <
	Struct.new(:name , :timings)
end

# ADD THE LINK OF THE DAY OF THE MOVIE
# EXAMPLE
# MOVIE_LINK = "https://in.bookmyshow.com/buytickets/nota-hyderabad/movie-hyd-ET00083360-MT/20181005" 
MOVIE_LINK = ""

while(1)
	doc = Nokogiri::HTML(open(MOVIE_LINK))


	theatres_list = Array.new

	doc.css('ul#venuelist li.list div.listing-info div.__name a.__venue-name').each do |link|
		t = Theatre.new
	    t.name = link.content.strip 
	    theatres_list.push(t)
	end

	theatres_list.each do |thea|
		timings_array = Array.new
		string = 'ul#venuelist li.list[data-name="'+"#{thea.name}" + '"] div.body div[data-online="Y"] a'
		doc.css(string).each do |link|
			timings_array.push(link.content.strip)
		end 
		thea.timings = timings_array
	end

# CREATE A GMAIL ACCOUNT TO SEND MESSAGES TO YOUR EMAIL 

	email_sent = 0
	theatres_list.each do |thea|
		if REQUIRED_THEATRES.include?(thea.name) && thea.timings.count != 0  
			NotifySend.send summary: "#{thea.name}:#{thea.timings}", timeout: 1			
			gmail = Gmail.connect('< USERNAME >', '< PASSWORD >')
			email = gmail.compose do
						to "<YOUR EMAIL ID>"
						subject "Tickets Hurry"
						body "#{thea.name} Show Timings : #{thea.timings} #{MOVIE_LINK}"
					end
			email.deliver!
			REQUIRED_THEATRES.delete(thea.name)
		end
	end
	sleep(1.minutes)
end

