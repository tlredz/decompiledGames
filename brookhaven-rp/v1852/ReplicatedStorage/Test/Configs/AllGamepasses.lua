local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
return {
	Gamepasses = TableUtil.Values(Gamepasses.All)
}