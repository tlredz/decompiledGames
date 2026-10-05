local React = require(game.ReplicatedStorage.Packages.React)
require(game.ReplicatedStorage.React.Components.WorldTeleporter.Types)
local CONSTANTS = require(game.ReplicatedStorage.React.Components.WorldTeleporter.CONSTANTS)
return React.createContext(CONSTANTS.DEFAULT_THEME)