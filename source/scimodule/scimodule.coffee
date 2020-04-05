
scimodule = {name: "scimodule"}

#region node_modules
require('systemd')
express = require('express')
bodyParser = require('body-parser')
#endregion

#log Switch
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["scimodule"]?  then console.log "[scimodule]: " + arg
    return

#region internal variables
cfg = null

app = null
#endregion

##initialization function  -> is automatically being called!  ONLY RELY ON DOM AND VARIABLES!! NO PLUGINS NO OHTER INITIALIZATIONS!!
scimodule.initialize = () ->
    log "scimodule.initialize"
    cfg = allModules.configmodule
    
    app = express()
    app.use bodyParser.urlencoded(extended: false)
    app.use bodyParser.json()

#region internal functions
onAction = (req, res) ->
    log "onAction"
    log "onAction - TODO implement!"
    res.send("Not implemented yet!")

onOtherAction = (req, res) ->
    log "onOtherAction"
    log "onOtherAction - TODO implement!"
    res.send("Not implemented yet!")

#################################################################
attachSCIFunctions = ->
    log "attachSCIFunctions"
    app.post "/action", onAction
    app.post "/otherAction", onOtherAction

listenForRequests = ->
    log "listenForRequests"
    if process.env.SOCKETMODE
        app.listen "systemd"
        log "listening on systemd"
    else
        port = process.env.PORT || cfg.defaultPort
        app.listen port
        log "listening on port: " + port
#endregion


#region exposed functions
scimodule.prepareAndExpose = ->
    log "scimodule.prepareAndExpose"
    attachSCIFunctions()
    listenForRequests()
    
#endregion exposed functions

export default scimodule