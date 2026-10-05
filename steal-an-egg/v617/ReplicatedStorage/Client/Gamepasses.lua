local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Gamepasses = require(ReplicatedStorage.Data.Gamepasses)
local Save = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Save"))
return table.freeze({
	Owns = function(p: string, p2)
		local v = Gamepasses.Directory[p]

		if v == nil then
			error(`"{tostring(p)}" is not a gamepass`, 2)
		end

		local v2 = Save.Await(p2 or Players.LocalPlayer)

		if v2 == nil then
			return false
		end

		local gamepasses = v2.Gamepasses
		return typeof(gamepasses) == "table" and gamepasses[v.Name] == true
	end
})