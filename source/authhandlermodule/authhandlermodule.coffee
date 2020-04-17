authhandlermodule = {name: "authhandlermodule"}
############################################################
#region printLogFunctions
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["authhandlermodule"]?  then console.log "[authhandlermodule]: " + arg
    return
ostr = (obj) -> JSON.stringify(obj, null, 4)
olog = (obj) -> log "\n" + ostr(obj)
print = (arg) -> console.log(arg)
#endregion

############################################################
cfg = null
activeToken = ""
defaultTokenLength = 20

############################################################
authhandlermodule.initialize = () ->
    log "authhandlermodule.initialize"
    cfg = allModules.configmodule
    return
    
############################################################
generateToken = ->
    log "generateToken"
    token = ""
    options = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"

    i = 0
    while i < defaultTokenLength
        token += options.charAt(Math.floor(Math.random() * options.length))
        i++

    log token
    log token.length
    return token

############################################################
authhandlermodule.login = (request) ->
    log "authhandlermodule.login"
    log "body.secret: "+ request.body.secret
    log "cfg.defaultSecret: " + cfg.defaultSecret
    if request.body.secret == cfg.defaultSecret
        activeToken = generateToken()
        log "returning token: " + activeToken
        return { token: activeToken }
    else
        log "throwing error!"
        throw new Error("Invalid Secret!")
    return { status: "not handled"}

authhandlermodule.tokenCheck = (request) ->
    log "authhandlermodule.tokenCheck"
    log "activeToken: " + activeToken
    log "request.body.token: " + request.body.token 
    # if !activeToken then return { validToken: false }
    if !activeToken then throw new Error("Invalid Token!")
    if request.body.token == activeToken then return { validToken: true }
    # return { validToken: false }
    throw new Error("Invalid Token!")

authhandlermodule.invalidate = (request) ->
    log "authhandlermodule.invalidate"
    if !activeToken then return { validToken: false }
    if request.body.token == activeToken 
        activeToken = ""
        return { success: true }
    return { validToken: false }

authhandlermodule.authenticate = (request) ->
    throw new Error("Unauthenticated!") unless request.body.token == activeToken
    throw new Error("Unauthenticated!") if !activeToken
    return

module.exports = authhandlermodule