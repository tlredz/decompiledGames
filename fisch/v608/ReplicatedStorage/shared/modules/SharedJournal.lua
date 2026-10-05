game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local packages = ReplicatedStorage.packages
require(packages.Net)
require(packages.Signal)
require(packages.Trove)
local modules = ReplicatedStorage.shared.modules
require(modules.SharedDataHelper)
local utils = ReplicatedStorage.shared.utils
require(utils.GeneralUtils)
require(utils.NumberUtils)
return {
	Start = function(_) end
}