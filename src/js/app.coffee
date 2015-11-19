window.$ = require 'jquery'
window._ = require 'underscore'
window.Backbone = require 'Backbone'
require '../../vendor/backbone.websqloffline/backbone.websqloffline.js'

TestCollection = Backbone.Collection.extend
  # model: TestModel
  url: '/api/test_collection'
  initialize: ->
      this.storage = new Offline.Storage 'test_collection', this

#Instantiate a local collection
myCollection = new TestCollection
#Request a full update from the server, calling 
#the successCallback after results are received.
myCollection.fetch success: (a,b,c) ->
  console.log [a,b,c]
#Create a new model, which will be saved to the local
#Web SQL database and have a client-side id assigned 
model = myCollection.create(name: 'Test Model')
#Saves on the model effect only the locally stored copy
model.save name: 'New Name'
