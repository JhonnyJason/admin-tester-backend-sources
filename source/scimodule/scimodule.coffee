
scimodule = {name: "scimodule"}
############################################################
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["scimodule"]?  then console.log "[scimodule]: " + arg
    return

############################################################
#region moduleFromEnvironment
#region node_modules
require('systemd')
express = require('express')
expressFileUpload = require("express-fileupload")
bodyParser = require('body-parser')
#endregion

############################################################
cfg = null

authHandler = null
dataHandler = null
assetHandler = null
#endregion


############################################################
app = null

############################################################
scimodule.initialize = () ->
    log "scimodule.initialize"
    cfg = allModules.configmodule
    authHandler = allModules.authhandlermodule
    dataHandler = allModules.datahandlermodule
    assetHandler = allModules.assethandlermodule

    app = express()
    app.use bodyParser.urlencoded(extended: false)
    app.use bodyParser.json()
    app.use expressFileUpload()
    return

############################################################
#region internalFunctions
onLogin = (req, res) ->
    log "onLogin"
    try
        response = await authHandler.login(req)
        res.send(response)
    catch err
        res.sendStatus(403)
    return

onTokenCheck = (req, res) ->
    log "onTokenCheck"
    try
        response = await authHandler.tokenCheck(req)
        res.send(response)
    catch err
        res.sendStatus(403)
    return

onInvalidate = (req, res) ->
    log "onInvalidate"
    try
        response = await authHandler.invalidate(req)
        res.send(response)
    catch err
        res.sendStatus(403)
    return


onGetDataState = (req, res) ->
    log "onGetDataState"
    try
        authHandler.authenticate(req)
        response = await dataHandler.dataState(req)
        res.send(response)
    catch err
        res.sendStatus(403)
    return

onGetOriginalContent = (req, res) ->
    log "onGetOriginalContent"
    try
        authHandler.authenticate(req)
        response = await dataHandler.originalContent(req)
        res.send(response)
    catch err
        res.sendStatus(403)
    return

onGetCurrentEdits = (req, res) ->
    log "onGetCurrentEdits"
    try
        authHandler.authenticate(req)
        response = await dataHandler.currentEdits(req)
        res.send(response)
    catch err
        res.sendStatus(403)
    return


onUpdate = (req, res) ->
    log "onUpdate"
    try
        authHandler.authenticate(req)
        response = await dataHandler.update(req)
        res.send(response)
    catch err
        res.sendStatus(403)
    return

onDiscard = (req, res) ->
    log "onDiscard"
    try
        authHandler.authenticate(req)
        response = await dataHandler.discard(req)
        res.send(response)
    catch err
        res.sendStatus(403)
    return

onApply = (req, res) ->
    log "onApply"
    try
        authHandler.authenticate(req)
        response = await dataHandler.apply(req)
        res.send(response)
    catch err
        res.sendStatus(403)
    return

onImageUpload = (req, res) ->
    log "onImageUpload"
    try
        authHandler.authenticate(req)
        assetHandler.saveImageFiles(req)
        res.sendStatus(200)
    catch err
        log err
        res.sendStatus(403)
    return

onPdfUpload = (req, res) ->
    log "onPdfUpload"
    log "onPdfUpload - TODO implement!"
    res.send("Not implemented yet!")
    return

#################################################################
attachSCIFunctions = ->
    log "attachSCIFunctions"
    app.post "/login", onLogin
    app.post "/tokenCheck", onTokenCheck
    app.post "/invalidate", onInvalidate
    app.post "/getDataState", onGetDataState
    app.post "/getOriginalContent", onGetOriginalContent
    app.post "/getCurrentEdits", onGetCurrentEdits
    app.post "/update", onUpdate
    app.post "/discard", onDiscard
    app.post "/apply", onApply
    app.post "/uploadImage", onImageUpload
    app.post "/uploadPdf", onPdfUpload
    return

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

############################################################
#region exposedFunctions
scimodule.prepareAndExpose = ->
    log "scimodule.prepareAndExpose"
    attachSCIFunctions()
    listenForRequests()
    
#endregion exposed functions

export default scimodule