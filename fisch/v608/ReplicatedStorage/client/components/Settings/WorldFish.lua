local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local packages = ReplicatedStorage:WaitForChild("packages")
local Component = require(packages:WaitForChild("Component"))
local Trove = require(packages:WaitForChild("Trove"))
local SettingsController = require(ReplicatedStorage.client.legacyControllers.SettingsController)
local localPlayer = Players.LocalPlayer
local v = Component.new({
	Tag = "WorldFish"
})

function v:Construct()
	self.trove = Trove.new()
end

local function hasLocalTransparencyModifier(instance)
	return instance:IsA("BasePart") or instance:IsA("Decal") or instance:IsA("ParticleEmitter") or instance:IsA("Trail") or instance:IsA("Beam") or instance:IsA("Fire") or instance:IsA("Smoke") or instance:IsA("Sparkles") or instance:IsA("Explosion")
end

function v:UpdateTransparency(instance)
	local settingValue = SettingsController:GetSettingValue("showFishWater")

	if hasLocalTransparencyModifier(instance) then
		instance.LocalTransparencyModifier = settingValue and 0 or 1
	elseif instance:IsA("Sound") then
		if not instance:GetAttribute("OriginalVolume") then
			instance:SetAttribute("OriginalVolume", instance.Volume)
		end

		instance.Volume = not settingValue and 0 or instance:GetAttribute("OriginalVolume") or 0
	elseif instance:IsA("Light") or instance:IsA("LayerCollector") then
		if instance:GetAttribute("OriginalEnabled") == nil then
			instance:SetAttribute("OriginalEnabled", instance.Enabled)
		end

		local enabled

		if settingValue then
			enabled = instance:GetAttribute("OriginalEnabled")
		else
			enabled = false
		end

		instance.Enabled = enabled
	end

	if instance:IsA("BasePart") then
		if instance:GetAttribute("OriginalCanCollide") == nil then
			instance:SetAttribute("OriginalCanCollide", instance.CanCollide)
			instance:SetAttribute("OriginalCanTouch", instance.CanTouch)
			instance:SetAttribute("OriginalCanQuery", instance.CanQuery)
		end

		local canCollide

		if settingValue then
			canCollide = instance:GetAttribute("OriginalCanCollide")
		else
			canCollide = false
		end

		instance.CanCollide = canCollide
		local canTouch

		if settingValue then
			canTouch = instance:GetAttribute("OriginalCanTouch")
		else
			canTouch = false
		end

		instance.CanTouch = canTouch
		local canQuery

		if settingValue then
			canQuery = instance:GetAttribute("OriginalCanQuery")
		else
			canQuery = false
		end

		instance.CanQuery = canQuery
	end
end

function v:UpdateFull()
	for _, descendant in self.Instance:GetDescendants() do
		self:UpdateTransparency(descendant)
	end
end

function v:Start()
	local v2 = self.Instance:GetAttribute("OwnerId") == localPlayer.UserId or localPlayer.Character and self.Instance:IsDescendantOf(localPlayer.Character)
	local immediateImpulse = self.Instance:GetAttribute("ImmediateImpulse")

	if immediateImpulse and self.Instance.PrimaryPart then
		self.Instance.PrimaryPart:ApplyImpulse(immediateImpulse * self.Instance.PrimaryPart.AssemblyMass)
	end

	local settingValue = SettingsController:GetSettingValue("showFishWater")
	local settingValue2 = SettingsController:GetSettingValue("shownVfx")
	local v3

	if v2 then
		v3 = settingValue2 == "HideAll"
	else
		v3 = settingValue2 ~= "All"
	end

	local fadeIn = self.Instance:GetAttribute("FadeIn")

	if fadeIn and (v2 or settingValue) and not v3 then
		local tweenInfo = TweenInfo.new(fadeIn, Enum.EasingStyle.Linear)
		local v4 = {
			LocalTransparencyModifier = 0
		}

		for _, descendant in self.Instance:GetDescendants() do
			if not hasLocalTransparencyModifier(descendant) then
				continue
			end

			descendant.LocalTransparencyModifier = 1
			TweenService:Create(descendant, tweenInfo, v4):Play()
		end

		task.wait(fadeIn)
	end

	local fadeOut = self.Instance:GetAttribute("FadeOut")

	if fadeOut then
		local fadeOutAfter = self.Instance:GetAttribute("FadeOutAfter") or workspace:GetServerTimeNow()
		task.delay(fadeOutAfter - workspace:GetServerTimeNow(), function()
			if not (v2 or settingValue) or v3 then
				return
			end

			local tweenInfo = TweenInfo.new(fadeOut, Enum.EasingStyle.Linear)
			local v4 = {
				LocalTransparencyModifier = 1
			}

			for _, descendant in self.Instance:GetDescendants() do
				if hasLocalTransparencyModifier(descendant) then
					TweenService:Create(descendant, tweenInfo, v4):Play()
				end
			end
		end)
	end

	if v2 then
		return
	end

	self.trove:Add(SettingsController:GetSettingChangedSignal("showFishWater"):Connect(function()
		self:UpdateFull()
	end))
	self.trove:Add(self.Instance.DescendantAdded:Connect(function(descendant)
		self:UpdateTransparency(descendant)
	end))
	self:UpdateFull()
end

function v.Stop(p)
	if p.trove then
		p.trove:Clean()
	end
end

return v