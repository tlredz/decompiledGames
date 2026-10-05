local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local Utility = require(ReplicatedStorage.Modules.Utility)
local Handgun = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.Handgun)
local object = setmetatable({}, Handgun)
object.__index = object

function object.new(...)
	local self = setmetatable(Handgun.new(...), object)
	self._domain_expansion_hash = 0
	self._domain_expansion_cc = nil
	self._domain_expansion_sound = nil
	self:_Init()
	return self
end

function object:Destroy()
	self._domain_expansion_hash += 1

	if self._domain_expansion_cc then
		self._domain_expansion_cc:Destroy()
		self._domain_expansion_cc = nil
	end

	if self._domain_expansion_sound then
		self._domain_expansion_sound:Destroy()
		self._domain_expansion_sound = nil
	end

	Handgun.Destroy(self)
end

function object:_DomainExpansion()
	if self._destroyed or not self.ClientItem.ClientFighter:Get("IsSpectating") then
		return
	end

	self._domain_expansion_hash += 1

	if self._domain_expansion_cc then
		self._domain_expansion_cc:Destroy()
		self._domain_expansion_cc = nil
	end

	if self._domain_expansion_sound then
		self._domain_expansion_sound:Destroy()
		self._domain_expansion_sound = nil
	end

	self._domain_expansion_cc = Instance.new("ColorCorrectionEffect")
	self._domain_expansion_cc.Brightness = -0.5
	self._domain_expansion_cc.Contrast = 2
	self._domain_expansion_cc.Saturation = -3
	self._domain_expansion_cc.Parent = Lighting
	self._domain_expansion_sound = Utility:CreateSound("rbxassetid://83352422371729", 1.25, 1.1, script, true, 20)
	local _domain_expansion_hash = self._domain_expansion_hash
	task.delay(15, function()
		local volume = self._domain_expansion_sound and self._domain_expansion_sound.Volume
		Utility:RenderstepForLoop(1, 0, -0.04, function(p)
			if _domain_expansion_hash ~= self._domain_expansion_hash then
				return true
			end

			local v = p ^ 4
			self._domain_expansion_cc.Saturation = -3 * v
			self._domain_expansion_cc.Contrast = 2 * v
			self._domain_expansion_cc.Brightness = -0.5 * v

			if self._domain_expansion_sound then
				self._domain_expansion_sound.Volume = volume * p
			end
		end)

		if _domain_expansion_hash ~= self._domain_expansion_hash then
			return
		end

		self._domain_expansion_cc:Destroy()
		self._domain_expansion_cc = nil

		if self._domain_expansion_sound then
			self._domain_expansion_sound:Destroy()
			self._domain_expansion_sound = nil
		end
	end)
end

function object:_Init()
	self.AnimationPlayed:Connect(function(p2)
		if p2 == "RareInspect" then
			task.delay(0.6, self._DomainExpansion, self)
		end
	end)
end

return object