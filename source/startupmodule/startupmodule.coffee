
startupmodule = {name: "startupmodule"}

#log Switch
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["startupmodule"]?  then console.log "[startupmodule]: " + arg
    return

############################################################
sci = null
gitHandler = null
dataHandler = null

############################################################
startupmodule.initialize = () ->
    log "startupmodule.initialize"
    sci = allModules.scimodule
    gitHandler = allModules.githandlermodule
    dataHandler = allModules.datahandlermodule
    return

############################################################
startupmodule.serviceStartup = ->
    log "startupmodule.serviceStartup"
    await gitHandler.startupCheck()
    await dataHandler.loadAvailableData()
    sci.prepareAndExpose()
    return

export default startupmodule