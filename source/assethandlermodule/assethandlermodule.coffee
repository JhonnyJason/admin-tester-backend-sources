assethandlermodule = {name: "assethandlermodule"}
############################################################
#region printLogFunctions
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["assethandlermodule"]?  then console.log "[assethandlermodule]: " + arg
    return
ostr = (obj) -> JSON.stringify(obj, null, 4)
olog = (obj) -> log "\n" + ostr(obj)
print = (arg) -> console.log(arg)
#endregion

############################################################
pathModule = require "path"
fs = require "fs-extra"

############################################################
dataHandler = null

############################################################
imagesBufferBasePath = ""
imagesDeployBasePath = ""

############################################################
assethandlermodule.initialize = () ->
    log "assethandlermodule.initialize"
    dataHandler = allModules.datahandlermodule
    c = allModules.configmodule

    imagesBufferBasePath = pathModule.resolve(process.cwd(), c.imageBufferPath)
    imagesDeployBasePath = pathModule.resolve(process.cwd(), c.imageDeployPath)

    return
    
############################################################
saveImageFile = (image, imageObject) ->
    log "saveImageFile"
    bufferPath = pathModule.resolve(imagesBufferBasePath, imageObject.name)
    await new Promise (res) -> image.mv(bufferPath, res)
    # els = fs.readdirSync(imagesBufferBasePath)
    # log els
    ##TODO cut and scale the images to correct proportion
    return

wipeImageBuffer = ->
    log "wipeImageBuffer"
    files = await fs.readdir(imagesBufferBasePath)
    files = files.filter((file) -> file.charAt(0) != ".")
    promises = []
    for file in files
        filePath = pathModule.resolve(imagesBufferBasePath, file)
        promises.push fs.remove(filePath)
    await Promise.all(promises)    
    return

############################################################
assethandlermodule.saveImageFiles = (req) ->
    log "assethandlermodule.saveImageFiles"
    files = req.files
    langTag = req.body.langTag
    documentName = req.body.documentName
    if !documentName then documentName = "index"
    imageLabels = Object.keys(files)
    for label in imageLabels
        imageObject = dataHandler.getImageObject(label, langTag, documentName)
        saveImageFile(files[label], imageObject)
        dataHandler.imageToEdits(label, langTag, documentName, imageObject)
    return

assethandlermodule.bufferToDeploy = ->
    log "assethandlermodule.bufferToDeploy"
    await fs.copy(imagesBufferBasePath, imagesDeployBasePath)    
    # files = await fs.readdir(imagesBufferBasePath)
    # files = files.filter((file) -> file.charAt(0) != ".")
    # log files
    # promises = []
    # for file in files
    #     sourcePath = pathModule.resolve(imagesBufferBasePath, file)
    #     destPath = pathModule.resolve(imagesDeployBasePath, file)
    #     promises.push fs.copy(sourcePath, destPath, {overwrite: true})
    # await Promise.all(promises)
    return

assethandlermodule.prepare = ->
    log "assethandlermodule.prepare"
    await wipeImageBuffer()
    await fs.copy(imagesDeployBasePath, imagesBufferBasePath)
    return

assethandlermodule.discard = assethandlermodule.prepare

module.exports = assethandlermodule