local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local legacyControllers = ReplicatedStorage.client.legacyControllers
local LightingController = require(legacyControllers.LightingController)
local Trove = require(ReplicatedStorage.packages.Trove)
local GeneralUtils = require(ReplicatedStorage.shared.utils.GeneralUtils)
local localPlayer = game.Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local playerGui = localPlayer.PlayerGui
local tweenInfo = TweenInfo.new(2)
local DustStorm = {}
DustStorm.__index = DustStorm

function DustStorm.new()
	local character = localPlayer.Character
	local self = setmetatable({}, DustStorm)
	self._trove = Trove.new()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "DustStorm-Effect"
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = -1
	screenGui.Parent = playerGui
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.BorderSizePixel = 0
	imageLabel.BackgroundTransparency = 1
	imageLabel.Image = "rbxassetid://84382770129827"
	imageLabel.ImageTransparency = 1
	imageLabel.Size = UDim2.fromScale(1, 1)
	imageLabel.Parent = screenGui
	GeneralUtils.fastTween(imageLabel, tweenInfo, {
		ImageTransparency = 0.3
	})
	local clone = script.Storm:Clone()
	clone.Parent = currentCamera
	local v = {
		density = character:GetAttribute("DuneGogglesEquipped") and 0.4 or 0.65
	}
	local connection = LightingController.HookLighting:BindAtPriority(9000, function(p)
		p.Atmosphere.Color = Color3.fromRGB(255, 214, 143)
		p.Atmosphere.Decay = Color3.fromRGB(255, 255, 255)
		p.Atmosphere.Density = v.density
		p.Atmosphere.Haze = 3
		p.Atmosphere.Glare = 0.4
		return p
	end)
	LightingController.UpdateLighting(1)
	self._trove:Add(function()
		connection:Disconnect()
		LightingController.UpdateLighting(1)
	end)
	self._trove:Add(function()
		GeneralUtils.fastTween(imageLabel, tweenInfo, {
			ImageTransparency = 1
		}).Completed:Once(function()
			screenGui:Destroy()
		end)
	end)
	self._trove:Add(RunService.RenderStepped:Connect(function()
		clone.CFrame = currentCamera.CFrame * CFrame.new(0, 0, -1)
	end))
	self._trove:Add(clone)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateVFX()
		local dunehavenWraps = character:GetAttribute("DunehavenWraps")
		clone.xstart.Flipbook.Brightness = dunehavenWraps and 5 or 20
	end

	updateVFX() -- equivalent call inferred; original call site unknown
	self._trove:Add(character:GetAttributeChangedSignal("DunehavenWraps"):Connect(updateVFX))

	local function updateDensity()
		v.density = character:GetAttribute("DuneGogglesEquipped") and 0.4 or 0.65
		LightingController.UpdateLighting(0.35)
	end

	self._trove:Add(character:GetAttributeChangedSignal("DuneGogglesEquipped"):Connect(updateDensity))
	return self
end

function DustStorm:Destroy()
	self._trove:Destroy()
end

return DustStorm