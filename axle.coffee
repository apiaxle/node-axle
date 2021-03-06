# A wrapper library for interfacing with the API Axle API
_ = require "lodash"
request = require "request"
qs = require "querystring"

{ EventEmitter } = require "events"

class Client
  constructor: ( @host, @port ) ->
    @emitter = new EventEmitter()

  getPath: ( path, query_params ) ->
    url = "http://#{ @host }:#{ @port }#{ path }"
    if query_params
      url += "?#{ qs.stringify query_params }"

    return url

  on: ( ) ->
    @emitter.on arguments...

  request: ( path, options, cb ) ->
    defaults =
      json: true
      method: "GET"
      headers:
        "content-type": "application/json"

    options = _.merge defaults, options

    options.url = @getPath path, options.query_params
    @emitter.emit "request", options

    request options, ( err, res ) =>
      return cb err if err
        
      # the response contains meta and the actual results
      { meta, results } = res.body
      return cb new Error res.body if not meta

      if res.statusCode isnt 200
        { type, message } = results.error
        problem = new Error message
        problem.type = type
        return cb problem, meta, null

      return cb null, meta, results

class exports.V1 extends Client
  getKeysByApi: ( api, options={}, cb ) ->
    @request "/v1/api/#{api}/keys", { query_params: options }, cb

  getApi: ( name, options={}, cb ) ->
    @request "/v1/api/#{ name }", { query_params: options }, cb

  getKey: ( name, options={}, cb ) ->
    @request "/v1/key/#{ name }", { query_params: options }, cb

  apiStats: ( name, options={}, cb ) ->
    @request "/v1/api/#{ name }/stats", { query_params: options }, cb

  keyStats: ( name, options={}, cb ) ->
    @request "/v1/key/#{ name }/stats", { query_params: options }, cb

  updateApi: ( name, options={}, cb ) ->
    @request "/v1/api/#{ name }", { method: "PUT", body: options, options }, cb

  createApi:( name, options={}, cb ) ->
    @request "/v1/api/#{ name }", { method: "POST", body: options, options }, cb

  updateKey: ( name, options={}, cb ) ->
    @request "/v1/key/#{ name }", { method: "PUT", body: options, options }, cb

  createKey:( name, options={}, cb ) ->
    @request "/v1/key/#{ name }", { method: "POST", body: options, options }, cb

  linkKey: (api, key, options={}, cb ) ->
    @request "/v1/api/#{ api }/linkkey/#{ key }", { method: "PUT", body: options, options }, cb

  getApis: ( options={}, cb ) ->
    @request "/v1/apis", { query_params: options }, cb

  getKeyrings: ( options={}, cb ) ->
    @request "/v1/keyrings", { query_params: options }, cb

  getKeys: ( options={}, cb ) ->
    @request "/v1/keys", { query_params: options }, cb

  getKeyStats: ( key, options={}, cb ) ->
    @request "/v1/key/#{key}/stats", { query_params: options }, cb

  getKeyringStats: ( key, options={}, cb ) ->
    @request "/v1/keyring/#{key}/stats", { query_params: options }, cb

  getApiKeys: ( api, options={}, cb ) ->
    @request "/v1/api/#{api}/keys", { query_params: options }, cb

  getKeyApis: ( key, options={}, cb ) ->
    @request "/v1/key/#{key}/apis", { query_params: options }, cb

  getApiStats: ( api, options={}, cb ) ->
    @request "/v1/api/#{api}/stats", { query_params: options }, cb
