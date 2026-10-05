local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Common = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.Common)
local FeatureManager = require(ReplicatedStorage._FRAMEWORK.Libraries.FeatureManager)
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local GravityController = require(ReplicatedStorage._FRAMEWORK.Features.ClientOnly.GravityController)
local Janitor = require(ReplicatedStorage.Utilities.Janitor)
local logger = LoggerManager.createLogger(script.Name, {
	feature = script:GetFullName()
})
local v = nil
local character = nil
local v2 = false

-- equivalent calls inferred from this helper; original call sites unknown
local function isTouchDevice()
	return (not UserInputService.KeyboardEnabled or not UserInputService.MouseEnabled or UserInputService.TouchEnabled) and true or false
end

local function checkFallbackReady()
	local v3 = character
	local humanoid

	if v3 ~= nil then
		humanoid = v3:FindFirstChildOfClass("Humanoid")
	end

	local rootPart

	if humanoid ~= nil then
		rootPart = humanoid.RootPart
	end

	local currentCamera = workspace.CurrentCamera

	if rootPart == nil or currentCamera == nil or not (humanoid.Health > 0) or humanoid.Sit then
		return false, nil
	end

	return true, {
		humanoid = humanoid,
		rootPart = rootPart,
		camera = currentCamera
	}
end

local function applyFallback(data)
	local up = GravityController.getUp()
	local lookVector = data.camera.CFrame.LookVector
	local v3 = lookVector - up * lookVector:Dot(up)
	data.humanoid.AutoRotate = false

	if v3.Magnitude > 0.001 then
		local position = data.rootPart.Position
		data.rootPart.CFrame = CFrame.lookAt(position, position + v3.Unit, up)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function releaseFallback()
	local v3, v4 = checkFallbackReady()

	if v3 and not GravityController.isActive() then
		v4.humanoid.AutoRotate = true
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setEnabled(flag: boolean)
	v2 = flag
	GravityController.setCameraRelative(flag)

	if not flag then
		releaseFallback() -- equivalent call inferred; original call site unknown
	end
end

local function createIcon(maid)
	local Icon = require(ReplicatedStorage.TopbarPlus.Icon)
	local autoDeselect = Icon.new():setName("ShiftLock"):setLabel("🔓"):autoDeselect(false)
	maid:Add(autoDeselect, "Destroy")
	maid:Add(autoDeselect.selected:Connect(function()
		setEnabled(true) -- equivalent call inferred; original call site unknown
		autoDeselect:setLabel("🔒")
	end))
	maid:Add(autoDeselect.deselected:Connect(function()
		setEnabled(false) -- equivalent call inferred; original call site unknown
		autoDeselect:setLabel("🔓")
	end))
end

local function onCharacterAdded(p)
	character = p
end

local function startClient()
	local localPlayer = Players.LocalPlayer
	local maid = Janitor.new()
	local touchDevice = isTouchDevice() -- equivalent call inferred; original call site unknown
	v = maid
	maid:Add(localPlayer.CharacterAdded:Connect(onCharacterAdded))
	maid:Add(localPlayer.CharacterRemoving:Connect(function()
		character = nil
	end))

	if localPlayer.Character then
		character = localPlayer.Character
	end

	if touchDevice then
		createIcon(maid)
	end

	logger:info("ShiftLock client feature started, topbar icon:", touchDevice)
end

local ShiftLock = {
	setEnabled = function(flag: boolean)
		assert(Common.IsClient(), "ShiftLock is client-only")
		setEnabled(flag) -- equivalent call inferred; original call site unknown
	end,
	isEnabled = function()
		return v2
	end
}
FeatureManager.RegisterFeature(script.Name, {
	Priority = 1,
	OnInit = function()
		if Common.IsClient() then
			startClient()
		end
	end,
	OnRender = function()
		if v2 and not GravityController.isActive() then
			local v3, v4 = checkFallbackReady()

			if v3 then
				applyFallback(v4)
			end
		end
	end
})
return ShiftLock