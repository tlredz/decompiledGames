local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Utility = require(ReplicatedStorage.Modules.Utility)
local FighterController = require(Players.LocalPlayer.PlayerScripts.Controllers.FighterController)
local ClientMap = require(Players.LocalPlayer.PlayerScripts.Modules.ClientReplicatedClasses.ClientDuel.ClientMap)
local object = setmetatable({}, ClientMap)
object.__index = object

function object.new(...)
	local self = setmetatable(ClientMap.new(...), object)
	self.Entrance = self.Model:WaitForChild("Portals"):WaitForChild("Entrance"):WaitForChild("Hitbox")
	self.Exit = self.Model:WaitForChild("Portals"):WaitForChild("Exit"):WaitForChild("Hitbox")
	self._teleport_cooldown = 0
	self:_Init()
	return self
end

function object:_Init()
	self.Entrance.Touched:Connect(function(otherPart)
		if tick() < self._teleport_cooldown or otherPart.Parent ~= Players.LocalPlayer.Character or not (FighterController.LocalFighter and FighterController.LocalFighter:IsAlive()) then
			return
		end

		self._teleport_cooldown = tick() + 1
		FighterController.LocalFighter.Entity:WarpTo(self.Exit.CFrame)
		Utility:CreateSound("rbxassetid://86785771664692", 0.5, 1 + 0.1 * math.random(), self.Entrance, true, 10)
		Utility:CreateSound("rbxassetid://81610952487049", 1, 1 + 0.1 * math.random(), self.Exit, true, 10)
	end)
end

return object