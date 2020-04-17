configmodule = {name: "configmodule"}
############################################################
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["configmodule"]?  then console.log "[configmodule]: " + arg
    return

############################################################
configmodule.initialize = () ->
    log "configmodule.initialize"

############################################################
configmodule.defaultPort = 3333
configmodule.defaultSecret = "defaultsecret"

############################################################
configmodule.imageBufferPath = "../images-buffer"
configmodule.imageDeployPath = "../images-deploy" 
configmodule.contentRepoPath = "../admin-tester-pwa-content" 
configmodule.gitRootPath = "../" 
## github access
configmodule.user = "JhonnyJason"
configmodule.pass = "hu8bu8bhbhu8gz7vi9njt6cf"
configmodule.contentRepo = "github.com/JhonnyJason/admin-tester-pwa-content.git"
export default configmodule