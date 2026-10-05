local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Utility = require(ReplicatedStorage.Modules.Utility)
local ClientViewModel = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ClientReplicatedClasses"):WaitForChild("ClientFighter"):WaitForChild("ClientItem"):WaitForChild("ClientViewModel"))
local object = setmetatable({}, ClientViewModel)
object.__index = object

function object.new(...)
	local self = setmetatable(ClientViewModel.new(...), object)
	self._ammo_visuals = {}
	self:_Init()
	return self
end

function object:_UpdateAmmoVisual()
	local v = self.ClientItem:Get("Ammo") > 0 and 0 or 1

	for k in pairs(self._ammo_visuals) do
		self:_LocalTransparencyModifier(k, "AmmoVisual", v)
	end
end

function object:_RegisterAmmoVisual(p2)
	self._ammo_visuals[p2] = true
end

function object:_RegisterDefaultAmmoVisuals()
	for _, part in pairs(self.ItemModel:WaitForChild("Shell"):GetChildren()) do
		if part:IsA("BasePart") then
			self:_RegisterAmmoVisual(part)
		end
	end
end

function object:_Init()
	self.ClientItem:GetDataChangedSignal("Ammo"):Connect(function()
		self:_UpdateAmmoVisual()
	end)
	task.defer(function()
		self.ClientItem.ProjectileShot:Connect(function(_, folder)
			local teamID = self.ClientItem.ClientFighter.Player:GetAttribute("TeamID")
			local color = not self.ClientItem.ClientFighter.IsLocalPlayer and (not teamID or teamID ~= Players.LocalPlayer:GetAttribute("TeamID")) and Color3.fromRGB(
				255,
				0,
				0
			) or Color3.fromRGB(47, 255, 0)
			local HSV, v, v2 = color:ToHSV()
			local color2 = Color3.fromHSV(HSV, v * 0.875, v2)

			for _, descendant in pairs(folder:GetDescendants()) do
				if descendant:GetAttribute("IgnoreRecolor") then
					continue
				end

				local color3 = descendant:GetAttribute("IsDangerParticle") and color or color2

				if descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") then
					descendant.Color = ColorSequence.new(color3)
				elseif descendant:IsA("Light") then
					descendant.Color = color3
				end
			end

			local createSound = Utility:CreateSound("rbxassetid://17331783148", 1.25, 1, folder.Primary, true)
			createSound.Looped = true
		end)
	end)
	self:_UpdateAmmoVisual()
end

return object