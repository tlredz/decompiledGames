local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Signal = require(ReplicatedStorage.Packages.Signal)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local v = Component.new({
	Tag = "ChristmasLightsControl"
})
local PropertyPermissions = require(ReplicatedStorage.Modules.Client.Components.Housing.PropertyPermissions)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local ChristmasEffectInfo = require(ReplicatedStorage.Modules.Client.Houses.Specific.Christmas2025.ChristmasEffectInfo)
local InteractUIColorPicker = require(ReplicatedStorage.Modules.Client.UI.InteractUIColorPicker)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)

function v:Construct()
	self._Janitor = Janitor.new()
	self.OnColorChanged = Signal.new()
	self.brightness = { 1, 1, 1 }
	self.colors = { Color3.fromRGB(255, 0, 0), Color3.fromRGB(0, 255, 0), Color3.fromRGB(255, 255, 255) }
	self.colorSamples = {}
end

function v.GetColors(p)
	return p.colors
end

function v.GetBrightness(p)
	return p.brightness
end

function v:UpdateColors(data)
	local v2 = { self.colors[data.ColorIndex[1]], self.colors[data.ColorIndex[2]], self.colors[data.ColorIndex[3]] }
	self.OnColorChanged:Fire(v2, data.Brightness, data.Transition)
end

function v:RefreshState()
	self.effectInfo = ChristmasEffectInfo[self.style]

	if not self.effectInfo then
		return
	end

	self:UpdateColors(self.effectInfo.Sequence[1])

	if self.effectInfo.IsLooping then
		self.currentSequenceIndex = 1
		self.currentTime = 0
	end
end

function v:StartLooping()
	self._Janitor:Add(RunService.Heartbeat:Connect(function(dt)
		if not (self.effectInfo and self.effectInfo.IsLooping) then
			return
		end

		self.currentTime += dt

		if self.currentTime >= self.effectInfo.Sequence[self.currentSequenceIndex].Time then
			self:UpdateColors(self.effectInfo.Sequence[self.currentSequenceIndex])
			self.currentSequenceIndex += 1

			if self.currentSequenceIndex > #self.effectInfo.Sequence then
				self.currentSequenceIndex = 1
				self.currentTime = 0
			end
		end
	end))
end

function v:SetupButtons()
	for _, child in self.Instance:WaitForChild("Color"):GetChildren() do
		local v2 = child:FindFirstChild("ClickDetector")

		if not v2 then
			v2 = Instance.new("ClickDetector")
			v2.Parent = self.Instance
		end

		local colorID = child:GetAttribute("ColorID")
		local colorSample = child:WaitForChild("UI"):WaitForChild("ColorSample")
		self.colorSamples[colorID] = colorSample
		self.colorSamples[colorID].BackgroundColor3 = self.colors[colorID]
		local flag = false
		self._Janitor:Add(v2.MouseClick:Connect(function(p)
			if not self.propertyPermissions:HasAnyRole(p, "Owner", "Roommate") then
				NotificationController.NotifyCenter("You don't have permission to do that")
				return
			end

			if flag then
				return
			end

			flag = true
			task.delay(0.5, function()
				flag = false
			end)
			self._interactUIColorPicker:Open(`Change Color {colorID}`, self.colors[colorID], function(backgroundColor)
				self.colors[colorID] = backgroundColor
				self.colorSamples[colorID].BackgroundColor3 = backgroundColor
				Remotes.fireServerComponent(self.Instance, "SetColor", self.colors)
				self:RefreshState()
			end)
		end))
	end

	for _, child in self.Instance:WaitForChild("Style"):GetChildren() do
		local v2 = child:FindFirstChild("ClickDetector")

		if not v2 then
			v2 = Instance.new("ClickDetector")
			v2.Parent = self.Instance
		end

		local flag = false
		local v3 = child
		self._Janitor:Add(v2.MouseClick:Connect(function(p)
			if not self.propertyPermissions:HasAnyRole(p, "Owner", "Roommate") then
				NotificationController.NotifyCenter("You don't have permission to do that")
				return
			end

			if flag then
				return
			end

			flag = true
			task.delay(0.5, function()
				flag = false
			end)
			self.style = v3.Name
			Remotes.fireServerComponent(self.Instance, "SetStyle", self.style)
			self:RefreshState()

			if self.previousStyleCheckmark ~= nil then
				self.previousStyleCheckmark.Visible = false
			end

			self.previousStyleCheckmark = v3:WaitForChild("UI"):WaitForChild("Checkmark")
			self.previousStyleCheckmark.Visible = true
		end))

		if not child:GetAttribute("IsDefault") then
			continue
		end

		self.style = child.Name
		self.previousStyleCheckmark = child:WaitForChild("UI"):WaitForChild("Checkmark")
		self.previousStyleCheckmark.Visible = true
	end
end

function v:Start()
	local uIColorPicker = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("NoResetGUIHandler"):WaitForChild("UIColorPicker")
	self._interactUIColorPicker = ComponentUtil.GetComponentFromInstance(uIColorPicker, InteractUIColorPicker)
	Remotes.connectComponentRemote(self.Instance, "UpdateColors", function(colors, style: string)
		self.colors = colors

		for k, colorSample in self.colorSamples do
			colorSample.BackgroundColor3 = self.colors[k]
		end

		self.style = style
		self:RefreshState()
	end)
	self.propertyPermissions = ComponentUtil.FindAndWaitForAncestorComponent(
		self.Instance,
		"PropertyPermissions",
		PropertyPermissions
	)
	self:SetupButtons()
	self:RefreshState()
	self:StartLooping()
end

function v:Stop()
	self._Janitor:Destroy()
end

return v