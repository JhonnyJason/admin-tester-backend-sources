debugmodule = {name: "debugmodule"}

############################################################
debugmodule.initialize = -> return

############################################################
debugmodule.modulesToDebug = 
    unbreaker: true
    assethandlermodule: true
    # authhandlermodule: true
    # configmodule: true
    datahandlermodule: true
    # githandlermodule: true
    # scimodule: true
    # startupmodule: true

#region exposed variables

export default debugmodule