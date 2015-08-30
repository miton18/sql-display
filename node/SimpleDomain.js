var cmdConnect, cmdDisconnect, cmdQuerying, connection, init, mysql;

mysql = require("mysql");

connection = null;

cmdConnect = function(db_connect, callback) {
  connection = mysql.createConnection({
    host: db_connect.host,
    port: db_connect.port,
    user: db_connect.user,
    password: db_connect.pass,
    database: db_connect.database,
    debug: true,
    trace: true
  });
  return connection.connect(function(err) {
    if (err) {
      callback('err connection ' + err);
    }
    return callback(0, 'thread: ' + connection.threadId);
  });
};

cmdDisconnect = function(callback) {
  return connection.end(function(err) {
    if (err) {
      callback(err);
    }
    return callback(0, 1);
  });
};

cmdQuerying = function(query, callback) {
  return connection.query(query, function(err, rows, fields) {
    if (err) {
      callbackerr;
    }
    return callback(0, [fields, rows]);
  });
};

init = function(domainManager) {
  if (!domainManager.hasDomain("simple")) {
    domainManager.registerDomain("simple", {
      major: 0,
      minor: 1
    });
  }
  domainManager.registerCommand("simple", "connect", cmdConnect, true, "Connect to a database");
  domainManager.registerCommand("simple", "disconnect", cmdDisconnect, true, "Disconnect from database");
  return domainManager.registerCommand("simple", "query", cmdQuerying, true, "Querying a database");
};

exports.init = init;
