local parentModule = require(script.Parent)
local Display = require(game.ReplicatedStorage.Packages.Display)
return Display.JSON.new():setIndentWith("  "):display(parentModule)