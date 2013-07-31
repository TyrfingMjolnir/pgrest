``#!/usr/bin/env node``
require! {optimist, plv8x}
{argv} = optimist

if argv.version
  {version} = require require.resolve \../package.json
  console.log "PgRest v#{version}"
  process.exit 0

conString = argv.db or process.env['PLV8XCONN'] or process.env['PLV8XDB'] or process.env.TESTDBNAME or process.argv?2
unless conString
  console.log "ERROR: Please set the PLV8XDB environment variable, or pass in a connection string as an argument"
  process.exit!
{pgsock} = argv

if pgsock
  conString = do
    host: pgsock
    database: conString

pgrest = require \..
plx <- pgrest .new conString, {}
{mount-default,with-prefix} = pgrest.routes!

process.exit 0 if argv.boot
{port=3000, prefix="/collections", host="127.0.0.1"} = argv
express = try require \express
throw "express required for starting server" unless express
app = express!
require! cors
require! \connect-csv

app.use express.json!
app.use connect-csv header: \guess

cols <- mount-default plx, argv.schema, with-prefix prefix, (path, r) ->
  app.all path, cors!, r

app.listen port, host
console.log "Available collections:\n#{ cols * ' ' }"
console.log "Serving `#conString` on http://#host:#port#prefix"
