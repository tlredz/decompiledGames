local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local RunService = game:GetService("RunService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local StarterGui = game:GetService("StarterGui")
require3(ReplicatedStorage2.Packages.Trove)
local spring = require3(ReplicatedStorage2.Common.Utils).Spring
local v = {
	Enum.CoreGuiType.PlayerList,
	Enum.CoreGuiType.Health,
	Enum.CoreGuiType.Backpack,
	Enum.CoreGuiType.Chat,
	Enum.CoreGuiType.EmotesMenu,
	Enum.CoreGuiType.All
}
local playerGui = Players.LocalPlayer.PlayerGui
local softShutdown = playerGui.SoftShutdown
local holder = softShutdown.Holder
local contentContainer = holder.ContentContainer
local blurEffect = Instance.new("BlurEffect")
blurEffect.Name = "SoftShutdownBlue"
blurEffect.Size = 0
blurEffect.Enabled = false
blurEffect.Parent = workspace.CurrentCamera

local function animateObject(p, p2)
	spring.target(p, 0.6, 3.5, p2)
end

local SoftShutdownController = {}
SoftShutdownController._isVisible = false
SoftShutdownController._screenGuiStates = {}
SoftShutdownController._lastChange = 0

function SoftShutdownController:SetVisible(isVisible)
	if self._isVisible == isVisible then
		return
	end

	local serverTimeNow = workspace:GetServerTimeNow()
	self._lastChange = serverTimeNow
	self._isVisible = isVisible

	if isVisible then
		softShutdown.Enabled = true
		blurEffect.Enabled = true
		GuiService.TouchControlsEnabled = false

		for _, screenGui in playerGui:GetChildren() do
			if not (screenGui ~= softShutdown and screenGui:IsA("ScreenGui")) then
				continue
			end

			self._screenGuiStates[screenGui] = screenGui.Enabled
			screenGui.Enabled = false
		end
	end

	for _, v2 in v do
		local v3 = v2
		task.spawn(function()
			StarterGui:SetCoreGuiEnabled(v3, not isVisible)
		end)
	end

	local v2 = isVisible and 0 or 1
	local uIScale = contentContainer.UIScale
	spring.target(uIScale, 0.6, 3.5, {
		Scale = isVisible and 1 or 0.7
	})
	spring.target(blurEffect, 0.6, 3.5, {
		Size = isVisible and 30 or 0
	})
	spring.target(holder, 0.6, 3.5, {
		BackgroundTransparency = isVisible and 0.4 or 1
	})
	local imageLabel = contentContainer.ImageLabelContainer.ImageLabel
	spring.target(imageLabel, 0.6, 3.5, {
		ImageTransparency = v2
	})
	local titleLabel = contentContainer.LabelContainer.TitleLabel
	spring.target(titleLabel, 0.6, 3.5, {
		TextTransparency = v2
	})
	local subtitleLabel = contentContainer.LabelContainer.SubtitleLabel
	spring.target(subtitleLabel, 0.6, 3.5, {
		TextTransparency = v2
	})
	local robloxLogo = contentContainer.LoadingLabel.RobloxLogo
	spring.target(robloxLogo, 0.6, 3.5, {
		BackgroundTransparency = v2
	})
	local frame = contentContainer.LoadingLabel.RobloxLogo.Frame
	spring.target(frame, 0.6, 3.5, {
		BackgroundTransparency = v2
	})

	if isVisible then
		if not self._logoConn then
			self._logoConn = RunService.RenderStepped:Connect(function()
				local v5 = tick() * 3.141592653589793 * 1.5
				local v6 = math.sin(v5)
				local midpoint = (math.sin(v5 - 1.5707963267948966) + 1) / 2
				local rotation = not (v6 > 0) and 15 or midpoint * 360 + 15
				contentContainer.LoadingLabel.RobloxLogo.Rotation = rotation
			end)
		end
	else
		spring.completed(contentContainer.LoadingLabel.RobloxLogo, function()
			if self._lastChange ~= serverTimeNow then
				return
			end

			if self._logoConn then
				self._logoConn:Disconnect()
				self._logoConn = nil
			end

			softShutdown.Enabled = false
			blurEffect.Enabled = false
		end)
		GuiService.TouchControlsEnabled = true

		for k, _screenGuiState in self._screenGuiStates do
			k.Enabled = _screenGuiState
			self._screenGuiStates[k] = nil
		end
	end
end

function SoftShutdownController:Start()
	if workspace:GetAttribute("IsServerClosing") then
		self:SetVisible(true)
	end

	workspace:GetAttributeChangedSignal("IsServerClosing"):Connect(function()
		self:SetVisible(workspace:GetAttribute("IsServerClosing") == true)
	end)
end

return SoftShutdownController