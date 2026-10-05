local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
require(ReplicatedStorage.Modules.BetterDebris)
require(ReplicatedStorage.Modules.Utility)
local ClientDestructable = require(Players.LocalPlayer.PlayerScripts.Modules.ClientReplicatedClasses.ClientEntity.ClientCustomEntity.ClientDestructable)
Players.LocalPlayer.PlayerScripts.Assets.Misc:WaitForChild("ExplosiveZombieExplosionEffect")
local object = setmetatable({}, ClientDestructable)
object.__index = object

function object.new(...)
	local self = setmetatable(ClientDestructable.new(...), object)
	self._shatter_effect_chance = 0.5
	self._colored_tile_part = self.Model:FindFirstChild("ColoredTile")
	self:_Init()
	return self
end

function object:ReplicateFromServer(p, ...)
	if p == "SpleefTileShake" then
		if not (self:IsRendered() and self._colored_tile_part) then
			return
		end

		local pivot = self._colored_tile_part:GetPivot()
		local lastTime = tick()

		while self:IsAlive() do
			local v = math.clamp(tick() - lastTime, 0, 1)
			self._colored_tile_part:PivotTo(pivot + Vector3.new(
				math.random() - 0.5,
				math.random() - 0.5,
				math.random() - 0.5
			) * v * 2)
			RunService.RenderStepped:Wait()
		end
	else
		ClientDestructable.ReplicateFromServer(self, p, ...)
	end
end

function object:_Init()
	self.ShatterModelAdded:Connect(function(instance)
		if not self._colored_tile_part then
			return
		end

		for _, part in pairs(instance:GetChildren()) do
			if part:IsA("BasePart") then
				part.Color = self._colored_tile_part.Color
			end
		end
	end)
end

return object