# alexa-commute
My Personal Alexa Skill to find commute time to the popular places I go to. You can edit the ruby file and deploy the endpoint to Heroku! Including screenshots to configure alexa skill on the amazon side too

Alexa Setup Screen 1


Alexa Setup Screen 2 

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