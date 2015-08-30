define (require, exports, module)->

    log = (s)->
        console.log "%c[SQL-DISPLAY] " + s, "color:#f4aa05;font-size:large"

    commandManager      = brackets.getModule "command/CommandManager"
    menus               = brackets.getModule "command/Menus"
    dialogs             = brackets.getModule "widgets/Dialogs"
    defaultDialogs      = brackets.getModule "widgets/DefaultDialogs"
    workspaceManager    = brackets.getModule "view/WorkspaceManager"
    preferencesManager  = brackets.getModule "preferences/PreferencesManager"
    extensionUtils      = brackets.getModule "utils/ExtensionUtils"
    nodeDomain          = brackets.getModule "utils/NodeDomain"
    appInit             = brackets.getModule "utils/AppInit"

    simpleDomain = new nodeDomain("simple", extensionUtils.getModulePath(module, "node/SimpleDomain.js"))
    myPref = preferencesManager.getExtensionPrefs "sql-display"
    sql_display_execute = 'sql-display.execute' # mon entrée dans le menu
    panel = {}

    appInit.appReady ()->

        extensionUtils.loadStyleSheet module, "main.css"
        commandManager.register 'sql-display-panel', sql_display_execute, handleSqlDisplay
        menu = menus.getMenu menus.AppMenuBar.VIEW_MENU
        menu.addMenuItem sql_display_execute

        panel = workspaceManager.createBottomPanel 'sql.display.execute', $(require('text!templates/panel.html')), 100

        $('#hostInput').val(myPref.get('host'))
        $('#portInput').val(myPref.get('port'))
        $('#userInput').val(myPref.get('user'))
        $('#passInput').val(myPref.get('pass'))
        $('#dbInput').val(myPref.get('dbname'))



        $("#close").click ()-> # raccourcis fermer panel
            panel.hide()
            commandManager.get(sql_display_execute).setChecked(false)

        $('#connect').click ()->
            myPref.set "host", $('#hostInput').val()
            myPref.set "port", $('#portInput').val()
            myPref.set "user", $('#userInput').val()
            myPref.set "pass", $('#passInput').val()
            myPref.set "dbname", $('#dbInput').val()

            startCo()

        $('.removerow').on 'click', ()->
            console.log this
            removeRow $(this).attr('info')

        $ '#selecttable'
        .on 'change', ()->
            simpleDomain.exec 'query', 'select * from ' + $(this).val()
            .done (data, err)->
                if err
                    log err

                colones = []
                col = $ '#colone'
                col.find('th').remove()

                for val in data[0]
                    col.append '<th>' + val['name'] + '</th>'
                    colones.push(val['name'])

                entree = $ '#entree'
                entree.find('tr').remove()

                for val in data[1] #val is object with attributes (champas)
                    temp = '<tr>'

                    for attr in colones
                        console.log val[attr]
                        temp += '<td>' + val[attr] + '</td>'
                    #temp += '<td><input type="button" value="delete" class="removerow" info="' + attr + '"></td>'
                    temp += '</tr>'
                    entree.append(temp)

            .fail (err)->
                log err

    handleSqlDisplay = ()-> # affichage du panel

        #dialogs.showModalDialog defaultDialogs.DIALOG_ID_INFO, "database informations", "<p>test</p>"
        if panel.isVisible()
            panel.hide()
            commandManager.get(sql_display_execute).setChecked(false)
        else
            panel.show()
            commandManager.get(sql_display_execute).setChecked(true)

    startCo = ()->
        coParam =
            host:       myPref.get('host')
            port:       myPref.get('port')
            user:       myPref.get('user')
            pass:       myPref.get('pass')
            database:   myPref.get('dbname')

        simpleDomain.exec 'connect', coParam
        .done (data, err)->
            if err
                console.error err
            #log data # THREAD

            simpleDomain.exec 'query', 'show tables'
            .done (data, err)->
                if err
                    console.error err
                #console.log data.getUnique()

                select = $ '#selecttable'
                #select.removeClass 'hidden'
                select.find('option').remove()

                for table in data[1]
                    #console.log table
                    select.append '<option>' + table['Tables_in_' + coParam.database] + '</option>'
            ###.fail (err)->
                console.error err
        .fail (err)->
            console.error err
            ###
    removeRow = (info)->
        log 'delete' + info
