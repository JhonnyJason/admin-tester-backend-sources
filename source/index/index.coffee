import Modules from "./allmodules"

global.allModules = Modules


for name, module of Modules
    module.initialize() 
        
Modules.startupmodule.serviceStartup()