local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local ChristmasLightsControl = require(ReplicatedStorage.Modules.Client.Components.Housing.Specific.Christmas2025.ChristmasLightsControl)
local v = Component.new({
	Tag = "ChristmasLights"
})
local color = Color3.fromRGB(25, 25, 25)

function v:Construct()
	self._Janitor = Janitor.new()
	self.lightID = self.Instance:GetAttribute("LightId")
	self.christmasLightsControl = ComponentUtil.FindAndWaitForAncestorComponent(
		self.Instance,
		"ChristmasLightsControl",
		ChristmasLightsControl
	)
end

function v:SetColor(p, p2, p3)
	self.color = p[self.lightID]
	self.brightness = p2[self.lightID]
	self.transition = p3[self.lightID]
	self:UpdateColor()
end

function v:UpdateColor()
	if self.tween then
		self.tween:Cancel()
	end

	self.tween = TweenService:Create(self.Instance, TweenInfo.new(self.transition), {
		Color = color:Lerp(self.color, self.brightness)
	}):Play()
end

function v:Start()
	self._Janitor:Add(self.christmasLightsControl.OnColorChanged:Connect(function(p, p2, p3)
		self:SetColor(p, p2, p3)
	end))
	self.christmasLightsControl:RefreshState()
end

function v:Stop()
	self._Janitor:Destroy()
end

return v