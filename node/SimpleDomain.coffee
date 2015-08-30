mysql       = require "mysql"
connection  = null

cmdConnect = (db_connect, callback)->
    connection = mysql.createConnection
        host : db_connect.host
        port : db_connect.port
        user : db_connect.user
        password : db_connect.pass
        database : db_connect.database

        debug: true
        trace: true

    connection.connect (err)->
        if err
            callback 'err connection ' + err

        callback 0, 'thread: ' + connection.threadId

cmdDisconnect = (callback)->
    connection.end (err)->
        if err
            callback err
        callback 0, 1

cmdQuerying = (query, callback)->

    connection.query query, (err, rows, fields)->
        if err
            callbackerr
        callback 0, [fields, rows]

init = (domainManager)->
    if !domainManager.hasDomain("simple")
        domainManager.registerDomain "simple",
            major: 0
            minor: 1

    domainManager.registerCommand "simple", "connect", cmdConnect, true, "Connect to a database"

    domainManager.registerCommand "simple", "disconnect", cmdDisconnect, true, "Disconnect from database"

    domainManager.registerCommand "simple", "query", cmdQuerying, true, "Querying a database"

exports.init = init
