datahandlermodule = {name: "datahandlermodule"}
############################################################
#region printLogFunctions
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["datahandlermodule"]?  then console.log "[datahandlermodule]: " + arg
    return
ostr = (obj) -> JSON.stringify(obj, null, 4)
olog = (obj) -> log "\n" + ostr(obj)
print = (arg) -> console.log(arg)
#endregion

############################################################
#region modulesFromEnvironment
fs = require "fs-extra"
hasher = require "crypto-hash"
pathModule = require "path"

############################################################
git = null
assetHandler = null
#endregion

############################################################
#region internalProperties
llT = "" #lastlangTag
llN = "" 
contentPath = ""
languages = null
originalContents = {}
originalContentHashes = {}
contentEdits = {}
#endregion

############################################################
datahandlermodule.initialize = () ->
    log "datahandlermodule.initialize"
    git = allModules.githandlermodule
    assetHandler = allModules.assethandlermodule
    c = allModules.configmodule

    contentPath = pathModule.resolve(process.cwd(), c.contentRepoPath)
    return

############################################################
#region internalFunctions
loadLanguageContent = (path, name, contents, hashes, edits) ->
    log "loadLanguageContent"
    # log path
    # log name
    edits[name] = {}

    contentString = String(await fs.readFile(path))
    content = JSON.parse(contentString)
    contents[name] = content

    contentString = JSON.stringify(content)
    contentHash = await hasher.sha1(contentString)
    hashes[name] = contentHash
    return

loadContentsForLanguage = (langTag) ->
    log "loadContentDataForLanguage"
    path = pathModule.resolve(contentPath, langTag)
    originalContents[langTag] = {}
    contents = originalContents[langTag]
    originalContentHashes[langTag] = {}
    hashes = originalContentHashes[langTag]
    contentEdits[langTag] = {}
    edits = contentEdits[langTag]
    # log path
    contentFiles = await fs.readdir(path)
    promises = []
    for file in contentFiles
        filePath = pathModule.resolve(path, file)
        siteName = file.slice(0, file.length - 5) # ".json".length = 5
        promises.push(loadLanguageContent(filePath, siteName, contents, hashes, edits))
    await Promise.all(promises)
    return

############################################################
saveContents = (langTag, contents) ->
    log "saveContents"
    await git.pullContents()
    promises = []
    for name,content of contents
        path = pathModule.resolve(contentPath,langTag,name+".json")
        contentString = JSON.stringify(content)
        promises.push(fs.writeFile(path, contentString))
    await Promise.all(promises)
    return

savePushAllContents = ->
    log "savePushAllContents"
    olog originalContents
    promises = (saveContents(langTag, content) for langTag,content of originalContents)
    await Promise.all(promises)
    await git.pushContents()
    return

############################################################
applyEdits = (key, langTag, edits) ->
    log "applyEdits"
    tokens = key.split(".")
    log tokens
    relevantContentObject = originalContents[langTag][key]
    reflectEdit(contentKey, content, relevantContentObject) for contentKey,content of edits

    contentEdits[langTag][key] = {}
    contentString = JSON.stringify(relevantContentObject)
    originalContentHashes[langTag][key] = await hasher.sha1(contentString)
    return

reflectEdit = (key, newContent, contentObject) ->
    log "reflectEdit"
    tokens = key.split(".")
    log tokens
    index = 0
    while index < (tokens.length - 1)
        contentObject = contentObject[tokens[index]]
        index++
    contentObject[tokens[index]] = newContent
    return

#endregion

############################################################
#region exposedFunctions
datahandlermodule.currentEdits = (request) ->
    log "datahandlermodule.originalContent"
    langTag  = request.body.languageTag
    llT = langTag
    name = request.body.documentName
    if !name then name = "index"
    return contentEdits[langTag][name]

datahandlermodule.originalContent = (request) ->
    log "datahandlermodule.originalContent"
    langTag  = request.body.langTag
    llT = langTag
    name = request.body.documentName
    if !name then name = "index"
    content = originalContents[langTag][name]
    # olog content 
    return content

datahandlermodule.dataState = (request) ->
    log "datahandlermodule.dataState"
    try
        langTag  = request.body.langTag
        llT = langTag
        name = request.body.documentName
        if !name then name = "index"
        responseObject = {}
        responseObject.contentHash = originalContentHashes[langTag][name]
        responseObject.edits = contentEdits[langTag][name]
    catch err
        log err
        throw err
    return responseObject

datahandlermodule.update = (request) ->
    log "datahandlermodule.update"
    try
        langTag = request.body.langTag
        llT = langTag
        name = request.body.documentName
        if !name then name = "index"
        key = request.body.contentKeyString
        content = request.body.content

        edits = contentEdits[langTag][name]
        edits[key] = content
    catch err
        log err
        throw err
    olog contentEdits
    return {ok: true}

datahandlermodule.discard = (request) ->
    log "datahandlermodule.discard"
    try
        langTag = request.body.langTag
        llT = langTag
        allEdits = contentEdits[langTag]
        allEdits[key] = {} for key,edits of allEdits
        await assetHandler.discard()
        # olog contentEdits
    catch err
        log err
        throw err
    return {ok: true}

datahandlermodule.apply = (request) ->
    log "datahandlermodule.apply"
    try
        langTag = request.body.langTag
        llT = langTag
        allEdits = contentEdits[langTag]
        applyEdits(key, langTag, edits) for key,edits of allEdits
        await savePushAllContents()
        await assetHandler.bufferToDeploy()
    catch err 
        log err
        throw err
    return {ok: true}

############################################################
datahandlermodule.loadAvailableData = ->
    log "datahandlermodule.loadAvailableData"
    languages = (await fs.readdir(contentPath)).filter((option) => option.charAt(0) != "." )
    promises = (loadContentsForLanguage(langTag) for langTag in languages)
    await Promise.all(promises)
    await assetHandler.prepare()     
    return

datahandlermodule.getImageObject = (label, langTag, name) ->
    log "datahandlermodule.getImageObject"
    content = originalContents[langTag][name]
    images = content.images
    imageObject = images[label]
    if imageObject then return imageObject
    throw Error("Unhandled case - uploading image which was not in originalContent")
    # editImage = contentEdits[langTag][name][label]
    # return editImage

datahandlermodule.imageToEdits = (label, langTag, name, imageObject) ->
    log "datahandlermodule.imageToEdits"
    edits = contentEdits[langTag][name]
    edits[label] = imageObject
    return

#endregion

module.exports = datahandlermodule