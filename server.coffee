# Dependencies
express = require 'express'
app = express()
mongo = (require 'mongodb').MongoClient

# App configuration
app.use express.bodyParser()

app.configure 'development', () ->
    #Mongo Local
    mongo.connect 'mongodb://localhost:27017/groupbox', (error, db) ->
        if not error 
            @db = db
            console.log "connected"
            # Cron Jobs
            setInterval (require './api/event-scanner'), 6000, @db # onGoingEvent Scanner (1 minute interval)
        else
            console.log error
            
app.configure 'production', () ->
    #Mongo Remote
    mongo.connect process.env.MONGOHQ_URL, (error, db) ->
        if not error 
            @db = db
            @db.authenticate process.env.MONGO_USER, process.env.MONGOHQ_PWD, (error) ->
                if not error
                    console.log "connected"
                    # Cron Jobs
                    setInterval (require './api/event-scanner'), 3000, @db # onGoingEvent Scanner (1 minute interval) 
                else 
                    console.log error
                
        else
            console.log error 

# Start App on Port 5000
app.listen (process.env.PORT || 5000)
console.log 'Express app started on port ' + (process.env.PORT || 5000)

# Routes
app.post '/api/register', require './api/register'
app.post '/api/create-event', require './api/create-event'
app.get '/api/auth-twitter', require './api/auth-twitter'
app.get '/api/auth-twitter-callback', require './api/auth-twitter-callback'