define(function(require, exports, module) {
  var appInit, commandManager, defaultDialogs, dialogs, extensionUtils, handleSqlDisplay, log, menus, myPref, nodeDomain, panel, preferencesManager, removeRow, simpleDomain, sql_display_execute, startCo, workspaceManager;
  log = function(s) {
    return console.log("%c[SQL-DISPLAY] " + s, "color:#f4aa05;font-size:large");
  };
  commandManager = brackets.getModule("command/CommandManager");
  menus = brackets.getModule("command/Menus");
  dialogs = brackets.getModule("widgets/Dialogs");
  defaultDialogs = brackets.getModule("widgets/DefaultDialogs");
  workspaceManager = brackets.getModule("view/WorkspaceManager");
  preferencesManager = brackets.getModule("preferences/PreferencesManager");
  extensionUtils = brackets.getModule("utils/ExtensionUtils");
  nodeDomain = brackets.getModule("utils/NodeDomain");
  appInit = brackets.getModule("utils/AppInit");
  simpleDomain = new nodeDomain("simple", extensionUtils.getModulePath(module, "node/SimpleDomain.js"));
  myPref = preferencesManager.getExtensionPrefs("sql-display");
  sql_display_execute = 'sql-display.execute';
  panel = {};
  appInit.appReady(function() {
    var menu;
    extensionUtils.loadStyleSheet(module, "main.css");
    commandManager.register('sql-display-panel', sql_display_execute, handleSqlDisplay);
    menu = menus.getMenu(menus.AppMenuBar.VIEW_MENU);
    menu.addMenuItem(sql_display_execute);
    panel = workspaceManager.createBottomPanel('sql.display.execute', $(require('text!templates/panel.html')), 100);
    $('#hostInput').val(myPref.get('host'));
    $('#portInput').val(myPref.get('port'));
    $('#userInput').val(myPref.get('user'));
    $('#passInput').val(myPref.get('pass'));
    $('#dbInput').val(myPref.get('dbname'));
    $("#close").click(function() {
      panel.hide();
      return commandManager.get(sql_display_execute).setChecked(false);
    });
    $('#connect').click(function() {
      myPref.set("host", $('#hostInput').val());
      myPref.set("port", $('#portInput').val());
      myPref.set("user", $('#userInput').val());
      myPref.set("pass", $('#passInput').val());
      myPref.set("dbname", $('#dbInput').val());
      return startCo();
    });
    $('.removerow').on('click', function() {
      console.log(this);
      return removeRow($(this).attr('info'));
    });
    return $('#selecttable').on('change', function() {
      return simpleDomain.exec('query', 'select * from ' + $(this).val()).done(function(data, err) {
        var attr, col, colones, entree, i, j, k, len, len1, len2, ref, ref1, results, temp, val;
        if (err) {
          log(err);
        }
        colones = [];
        col = $('#colone');
        col.find('th').remove();
        ref = data[0];
        for (i = 0, len = ref.length; i < len; i++) {
          val = ref[i];
          col.append('<th>' + val['name'] + '</th>');
          colones.push(val['name']);
        }
        entree = $('#entree');
        entree.find('tr').remove();
        ref1 = data[1];
        results = [];
        for (j = 0, len1 = ref1.length; j < len1; j++) {
          val = ref1[j];
          temp = '<tr>';
          for (k = 0, len2 = colones.length; k < len2; k++) {
            attr = colones[k];
            console.log(val[attr]);
            temp += '<td>' + val[attr] + '</td>';
          }
          temp += '</tr>';
          results.push(entree.append(temp));
        }
        return results;
      }).fail(function(err) {
        return log(err);
      });
    });
  });
  handleSqlDisplay = function() {
    if (panel.isVisible()) {
      panel.hide();
      return commandManager.get(sql_display_execute).setChecked(false);
    } else {
      panel.show();
      return commandManager.get(sql_display_execute).setChecked(true);
    }
  };
  startCo = function() {
    var coParam;
    coParam = {
      host: myPref.get('host'),
      port: myPref.get('port'),
      user: myPref.get('user'),
      pass: myPref.get('pass'),
      database: myPref.get('dbname')
    };
    return simpleDomain.exec('connect', coParam).done(function(data, err) {
      if (err) {
        console.error(err);
      }
      return simpleDomain.exec('query', 'show tables').done(function(data, err) {
        var i, len, ref, results, select, table;
        if (err) {
          console.error(err);
        }
        select = $('#selecttable');
        select.find('option').remove();
        ref = data[1];
        results = [];
        for (i = 0, len = ref.length; i < len; i++) {
          table = ref[i];
          results.push(select.append('<option>' + table['Tables_in_' + coParam.database] + '</option>'));
        }
        return results;
      });

      /*.fail (err)->
          console.error err
              .fail (err)->
      console.error err
       */
    });
  };
  return removeRow = function(info) {
    return log('delete' + info);
  };
});
