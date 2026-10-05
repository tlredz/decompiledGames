local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
require(ReplicatedStorage.Modules.CONSTANTS)
local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
local TestLibrary = require(ReplicatedStorage.Modules.TestLibrary)
local ShootingRangeController = require(Players.LocalPlayer.PlayerScripts.Controllers.ShootingRangeController)
local testAttribute = TestLibrary:GetTestAttribute("StudioFinisherTest")
local testAttribute2 = TestLibrary:GetTestAttribute("StudioSkinTest")
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self:_Init()
	return self
end

function class._SetupFinisherTest(_)
	if not testAttribute then
		return
	end

	if not Players.LocalPlayer.Character then
		Players.LocalPlayer.CharacterAdded:Wait()
	end

	ShootingRangeController:Enter("Sniper")
end

function class._SetupSkinTest(_)
	if not testAttribute2 then
		return
	end

	if not Players.LocalPlayer.Character then
		Players.LocalPlayer.CharacterAdded:Wait()
	end

	ShootingRangeController:Enter(CosmeticLibrary.Cosmetics[testAttribute2] and CosmeticLibrary.Cosmetics[testAttribute2].ItemName or testAttribute2)
end

function class:_Init()
	task.defer(self._SetupSkinTest, self)
	task.defer(self._SetupFinisherTest, self)
end

return class._new()