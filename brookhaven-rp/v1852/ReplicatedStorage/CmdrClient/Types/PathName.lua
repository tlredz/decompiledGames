local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.Packages
local GameSdkShared = require(packages.GameSdkShared)
local Pathing = require(GameSdkShared.Modules.Pathing)
local CmdrUtil = require(GameSdkShared.Utils.CmdrUtil)

local function stringsGetter()
	local expect = Pathing.ListPaths():expect()
	table.sort(expect)
	return expect
end

local function stringToObject(p: string)
	return p
end

return function(registry)
	registry:RegisterType("pathName", (CmdrUtil.createTypeDefinition("pathName", stringsGetter, stringToObject)))
end