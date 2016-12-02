require 'sinatra'
require 'rest-client'
require 'json'

# VERY IMPORTANT: MAJOR CONFLICT between sinatra gem and rest-client gem. Needs this setting to be EXPLICIT
set :server, 'webrick'

def UberLyftAPIForRide(destination, address)
	coordinates = address.split (', ')
	end_latitude =  coordinates[0]
	end_longitude = coordinates[1]
	headers = {'Authorization' => 'Token <<UBER >>'}
	lyft_headers = {'Authorization' => 'bearer <<LYFT TOKEN GOES HERE>>'}
	p 'Ready To Invoke '
	fare_response = RestClient::Request.execute(
	    :method => :get,
	    :url => 'https://api.uber.com/v1.2/estimates/price?start_latitude=<<REPLACE WITH HOME LAT>>&start_longitude=<<REPLACE WITH HOME LON>>&end_latitude='+ end_latitude + '&end_longitude=' + end_longitude,
	    :headers => headers
	    )
	p fare_response.code.to_s


	time_response = RestClient::Request.execute(
	    :method => :get,
	    :url => 'https://api.uber.com/v1.2/estimates/time?start_latitude=<<REPLACE WITH HOME LAT>>&start_longitude=<<REPLACE WITH HOME LON>>',
	    :headers => headers
	    )
	p time_response.code.to_s

	lyft_fare_response = RestClient::Request.execute(
	    :method => :get,
	    :url => 'https://api.lyft.com/v1/cost?start_lat=<<REPLACE WITH HOME LAT>>&start_lng=<<REPLACE WITH HOME LON>>&end_lat=' + end_latitude + '&end_lng=' + end_longitude,
	    :headers => lyft_headers
	    )
	p lyft_fare_response.code.to_s


	lyft_time_response = RestClient::Request.execute(
	    :method => :get,
	    :url => 'https://api.lyft.com/v1/eta?lat=<<REPLACE WITH HOME LAT>>&lng=<<REPLACE WITH HOME LON>>',
	    :headers => lyft_headers
	    )
	p lyft_time_response.code.to_s


	# p JSON.pretty_generate(JSON.parse(response.body))
	fare_object = JSON.parse(fare_response.body, object_class: OpenStruct)
	time_object = JSON.parse(time_response.body, object_class: OpenStruct)
	lyft_fare_object = JSON.parse(lyft_fare_response.body, object_class: OpenStruct)
	lyft_time_object = JSON.parse(lyft_time_response.body, object_class: OpenStruct)
	p 'UBER'
	p fare_object.prices[1].high_estimate
	p fare_object.prices[1].low_estimate
	p fare_object.prices[1].duration
	p 'LYFT'
	p lyft_time_object.eta_estimates[1].eta_seconds.divmod(60)[0]
	p lyft_fare_object.cost_estimates[2].estimated_duration_seconds.divmod(60)[0]
	p lyft_fare_object.cost_estimates[2].primetime_percentage
	p lyft_fare_object.cost_estimates[2].estimated_cost_cents_min.divmod(100)[0]
	p lyft_fare_object.cost_estimates[2].estimated_cost_cents_max.divmod(100)[0]

	return_to_alexa =  ConstructRidePayload(destination, time_object.times[1].estimate.divmod(60)[0] , 
		fare_object.prices[1].duration.divmod(60)[0], fare_object.prices[1].low_estimate.floor, 
		fare_object.prices[1].high_estimate.floor,
		lyft_time_object.eta_estimates[1].eta_seconds.divmod(60)[0],
		lyft_fare_object.cost_estimates[2].estimated_duration_seconds.divmod(60)[0],
		lyft_fare_object.cost_estimates[2].primetime_percentage,
		lyft_fare_object.cost_estimates[2].estimated_cost_cents_min.divmod(100)[0],
		lyft_fare_object.cost_estimates[2].estimated_cost_cents_max.divmod(100)[0]
		 )
	return return_to_alexa

	rescue RestClient::ExceptionWithResponse => e
		response = e.response
		p 'FAIL'
		p e.response.code
		p e.response.body
		# TODO: return canned resp template
end


def ConstructRidePayload (destination, wait_time, ride_time, low_price, high_price, lyft_wait_time, lyft_ride_time, lyft_surge, lyft_low_price, lyft_high_price)

	lowest_fare = [high_price, lyft_high_price].min
	highest_fare = [high_price, lyft_high_price].max
	lowest_time = [wait_time , lyft_wait_time ].min
	highest_time = [wait_time , lyft_wait_time ].max

	cheaper_range = highest_fare - lowest_fare
	faster_range = highest_time - lowest_time
	cheaper_service = 'Uber and Lift'
	faster_service = 'Uber and Lift'


	if lowest_fare == lyft_high_price
		cheaper_service = 'Lift'
	elsif lowest_fare == high_price
		cheaper_service = 'Uber'
	else
		cheaper_service = 'Uber and Lift'
	end

	if lowest_time == lyft_wait_time 
		faster_service = 'Lift'
	elsif lowest_time == wait_time
		faster_service = 'Uber'
	else
		faster_service = 'Uber and Lift'
	end

	payload = {
	  "version" => "1.0",
	  "sessionAttributes" => {},
	  "response" => {
	    "shouldEndSession" => true,
	    "outputSpeech" => {
	      "type" => "SSML",
	      "ssml" => "<speak> Reaching #{destination} with #{cheaper_service} is cheaper, by #{cheaper_range} dollars with #{lyft_surge} surge in effect. 
		    		#{faster_service} is faster , by #{faster_range} minutes. Ride time will be around #{lyft_ride_time} minutes
		  			Uber will have a #{wait_time} minute wait time. Fares will range from #{low_price} to #{high_price} dollars. 
				  	Lift will have a #{lyft_wait_time} minute wait time. Fares will range from #{lyft_low_price} to #{lyft_high_price} dollars.</speak>"
	    }
	  }
	}
	#p payload.to_json
	return payload.to_json
end

def ConstructPayload(destination, duration, duration_in_traffic) 

	payload = {
	  "version" => "1.0",
	  "sessionAttributes" => {},
	  "response" => {
	    "shouldEndSession" => true,
	    "outputSpeech" => {
	      "type" => "SSML",
	      "ssml" => "<speak>Commute Time To #{destination} is #{duration} at this time normally and #{duration_in_traffic} in current traffic conditions </speak>"
	    }
	  }
	}
	#p payload.to_json
	return payload.to_json
end

post '/ride' do
	request_object = JSON.parse(request.body.read, object_class: OpenStruct)
	defaultslot = 'Bus stop'		
	if request_object.request.type == 'LaunchRequest'
		slot = defaultslot
	elsif request_object.request.type == 'IntentRequest'
		slot = request_object.request.intent.slots.location.value
		p 'Intent was'
		p slot
	else 
		slot = 'San Jose' 
	p slot
	end

	# TODO : ADD YOUR FAVS!
	payload_data = [{ {destination: 'Downtown', coordinates: '37.790616, -122.396968'},
	{destination: 'Downtown', coordinates: '37.790616, -122.396968'},
	{destination: 'San Ramon', coordinates: '37.778564, -121.910870'},
	{destination: 'Fremont', coordinates: '37.556726, -121.977101'},
	{destination: 'San Jose', coordinates: '37.364957, -121.923813'},
	{destination: 'Evergreen', coordinates: '37.323373, -121.771255'},
	{destination: 'San Francisco', coordinates: '37.615704, -122.390059'},
	{destination: 'Youtube', coordinates: '37.628367, -122.425932'}]

	if dest = payload_data.find { |dest| dest[:destination].casecmp(slot) == 0 }  
		p dest[:coordinates]
		return_to_alexa = UberLyftAPIForRide(slot, dest[:coordinates])
		p return_to_alexa
	else
		return_to_alexa = UberLyftAPIForRide('Bus Stop', '37.324639, -122.049359')
		p return_to_alexa
	end
		
end

 post '/commute'  do
		request_object = JSON.parse(request.body.read, object_class: OpenStruct)
		defaultslot = 'Downtown'		
		if request_object.request.type == 'LaunchRequest'
			slot = defaultslot
		elsif request_object.request.type == 'IntentRequest'
			slot = request_object.request.intent.slots.location.value
			p 'Intent was'
			p slot
		else 
			slot = 'Day care' 
		p slot
		end
		 
		# TODO : ADD YOUR FAVS!
	  	payload_data = [{ {destination: 'Downtown', address: '50 Fremont Street, San Francisco, CA'},
		{destination: 'San Ramon', address: 'Ironwood Drive, San Ramon, CA'},
		{destination: 'Fremont', address: '2000 Bart Way, Fremont, CA 94536'},
		{destination: 'San Jose', address: '1701 Airport Blvd, San Jose, CA 95110'},
		{destination: 'Evergreen', address: 'Chemin De Riviere, San Jose, CA 95148'},
		{destination: 'San Francisco', address: 'San Francisco International Airport, San Francisco, CA 94128'},
		{destination: 'Youtube', address: '901 Cherry Ave, San Bruno, CA 94066'}]

		if dest = payload_data.find { |dest| dest[:destination].casecmp(slot) == 0 }  
			p dest[:address]
			return_to_alexa = GoogleMapsAPIForCommute(slot, dest[:address])
			p return_to_alexa
		else
			return_to_alexa = GoogleMapsAPIForCommute('Downtown', '50 Fremont,San Francisco')
			p return_to_alexa
		end
 end
