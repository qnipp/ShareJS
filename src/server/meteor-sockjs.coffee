# This reuses the SockJS connection of Meteor.

sessionHandler = require('./session').handler

wrapSession = (original_conn) ->
  conn = Object.create original_conn
  conn._proto
  conn.abort = -> @close()
  conn.stop = -> @end()
  conn.send = (response) -> original_conn.write JSON.stringify(response)
  conn.ready = -> @readyState is 1
  savedFunction = original_conn._events.data.bind original_conn
  original_conn._events.data = (data) -> 
    parsed = JSON.parse data
    if parsed.msg
      savedFunction data
    else
      console.log 'meteor-sockjs', parsed
      @emit 'message', parsed
  conn.address = conn.remoteAddress
  conn

exports.attach = (server, createAgent, options) ->
  server.register (conn) ->  sessionHandler wrapSession(conn), createAgent