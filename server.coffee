http = require 'http'
url = require 'url'
AWS = require 'aws-sdk'

AWS.config.loadFromPath './aws-cred.json'
AWS.config.apiVersion = '2014-03-10'

route53 = new AWS.Route53()

update = ({name, zoneid, ip}, cb) ->
  if name? and zoneid? and ip? and cb?
    route53.changeResourceRecordSets
      ChangeBatch:
        Changes: [
          Action: 'UPSERT'
          ResourceRecordSet:
            Name: name
            Type: 'A'
            TTL: 3600
            ResourceRecords: [ {Value: ip} ]
        ]
      HostedZoneId: zoneid,
      cb
  else cb? new Error('invalid argument')

server = http.createServer (req, res) ->
  {pathname, query} = url.parse req.url, true
  if pathname == '/update' then update query, (err, data) ->
    console.log data
    res.statusCode = if err then 500 else 200
    res.end()

server.listen 7321