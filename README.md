# alexa-commute

This is a personalizable Alexa Skill to get real time pricing estimates from 2 popular ride sharing services. 

Lets get started by creating a A [skill for Alexa](https://developer.amazon.com/alexa "skill for Alexa") . To do this, ensure you sign in with the *same amazon account you use with your device*.

## ALEXA SKILL SETUP

### Basic Skill Information: ![Alt](/public/alexa1.png "Basic Skill Information") 

### Configure Skill Intent and Custom Slots: ![Alt](/public/alexa2.png "Configure Skill Intent and Custom Slots") 

Adding a custom slot with pre defined values really helps with voice recognition accuracy.

#### Intent Configuration  
  
```css
{
  "intents": [
    {
      "intent": "CabDriver",
      "slots": [
        {
          "name": "location",
          "type": "LOCATION"
        }
      ]
    }
  ]
}
```



### Endpoint Configuration: ![Alt](/public/alexa3.png "Endpoint") 

### Certificate Configuration: ![Alt](/public/alexa4.png "Certificate") 

The last 2 screens of the skill setup is straight forward and you have now created the skill! 

## API KEY
Go to [Uber Dev](https://developer.uber.com/ "UBER")  and [Lyft Dev](https://www.lyft.com/developers "LYFT") to create an application. This will give you the API tokens necessary.

## EDIT THE RUBY CODE


Edit these 2 lines of code with the appropriate tokens. The lyft bearer token is longer than the uber client secret token.

```css
  headers = {'Authorization' => 'Token <<UBER CLIENT SECRET>>'}
  lyft_headers = {'Authorization' => 'bearer <<LYFT TOKEN GOES HERE>>'}
```

  Edit all occurances of _REPLACE WITH HOME LAT_ and _REPLACE WITH HOME LON_ with the lat and lon of your home/starting point

```css
      :url => 'https://api.uber.com/v1.2/estimates/price?start_latitude=<<REPLACE WITH HOME LAT>>&start_longitude=<<REPLACE WITH HOME LON>>&end_latitude='+ end_latitude + '&end_longitude=' + end_longitude,
```

Edit this data with lat, long of  popular endpoints

```css
  payload_data = [{ {destination: 'Downtown', coordinates: '37.790616, -122.396968'},
  {destination: 'Downtown', coordinates: '37.790616, -122.396968'},
  {destination: 'San Ramon', coordinates: '37.778564, -121.910870'},
  {destination: 'Fremont', coordinates: '37.556726, -121.977101'},
  {destination: 'San Jose', coordinates: '37.364957, -121.923813'},
  {destination: 'Evergreen', coordinates: '37.323373, -121.771255'},
  {destination: 'San Francisco', coordinates: '37.615704, -122.390059'},
  {destination: 'Youtube', coordinates: '37.628367, -122.425932'}]
```

Please do ensure that your destination preset names above are also reflected in the slot value configuration (see Intent Configuration  section above)

You are now ready to deploy the code to Heroku and test your custom skill!!

