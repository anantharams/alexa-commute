# alexa-commute

This is a personalizable Alexa Skill to get real time pricing estimates from 2 popular ride sharing services. 

You can edit the ruby file and deploy the endpoint to Heroku! Including screenshots to configure alexa skill on the amazon side too

## Basic Skill Information: ![Alt](/public/alexa1.png "Basic Skill Information") 

## Configure Skill Intent and Custom Slots: ![Alt](/public/alexa2.png "Configure Skill Intent and Custom Slots") 

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


Adding a custom slot with pre defined values really helps with accuracy.

## Endpoint Configuration: ![Alt](/public/alexa3.png "Endpoint") 

## Certificate Configuration: ![Alt](/public/alexa4.png "Certificate") 

