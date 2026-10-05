local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
require(ReplicatedStorage.Shared.Globals.Constants)
local Log = require(ReplicatedStorage.Packages.Log)
local Player = require(ReplicatedStorage.Shared.Player)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local cframe = CFrame.new(-1.7, 0, 0)
local cframe2 = CFrame.new(1.7, 0, 0)
local v = Enum.RenderPriority.Camera.Value + 1
local v2 = {
	Off = "rbxasset://textures/ui/mouseLock_off@2x.png",
	On = "rbxasset://textures/ui/mouseLock_on@2x.png"
}
local localPlayer = Players.LocalPlayer
local parent = script.Parent
assert(parent:IsA("ImageButton"), "StarterGui.ShiftLockButton.ImageButton must be an ImageButton")
local parent2 = parent.Parent
assert(parent2:IsA("ScreenGui"), "StarterGui.ShiftLockButton must be a ScreenGui")
local lock = parent2.Lock
assert(lock:IsA("ImageLabel"), "StarterGui.ShiftLockButton.Lock must be an ImageLabel")
local flag = false
local v3 = false
local v4 = Log.new()

local function updateImage(visible: boolean)
	parent.Image = visible and "rbxasset://textures/ui/mouseLock_on@2x.png" or "rbxasset://textures/ui/mouseLock_off@2x.png"
	lock.Visible = visible
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getCurrentCamera()
	local currentCamera = Workspace.CurrentCamera
	assert(currentCamera ~= nil, "Mobile shift lock requires Workspace.CurrentCamera")
	return currentCamera
end

local function updateShiftLock()
	if v3 then
		return
	end

	local currentCamera = getCurrentCamera() -- equivalent call inferred; original call site unknown

	if currentCamera.CameraType == Enum.CameraType.Scriptable then
		return
	end

	local v5 = Player.WaitForRootPart(localPlayer)
	local waitForHumanoid = Player.WaitForHumanoid(localPlayer)
	waitForHumanoid.AutoRotate = false
	parent.Image = v2.On
	lock.Visible = true
	local lookVector = currentCamera.CFrame.LookVector
	v5.CFrame = CFrame.new(v5.Position, (Vector3.new(lookVector.X * 900000, v5.Position.Y, lookVector.Z * 900000)))
	currentCamera.CFrame *= cframe2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function disableShiftLock()
	if not flag then
		return
	end

	flag = false
	RunService:UnbindFromRenderStep("MobileShiftLock")
	local humanoid = Player.FindHumanoid(localPlayer)

	if humanoid ~= nil then
		humanoid.AutoRotate = true
	end

	parent.Image = v2.Off
	lock.Visible = false
	local currentCamera = getCurrentCamera() -- equivalent call inferred; original call site unknown
	currentCamera.CFrame *= cframe
end

local function enableShiftLock()
	if flag or v3 then
		return
	end

	flag = true
	RunService:BindToRenderStep("MobileShiftLock", v, updateShiftLock)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateAvailability()
	local v5 = v3

	if v5 then
		disableShiftLock() -- equivalent call inferred; original call site unknown
		v4:AtDebug():Log("Mobile shift lock suppressed by a gameplay lock")
	end

	parent.Visible = UserInputService.TouchEnabled and not v5
end

local function toggleShiftLock()
	if flag then
		disableShiftLock() -- equivalent call inferred; original call site unknown
	elseif not flag then
		if v3 then
			return
		end

		flag = true
		RunService:BindToRenderStep("MobileShiftLock", v, updateShiftLock)
	end
end

parent.Image = v2.Off
lock.Visible = false
updateAvailability() -- equivalent call inferred; original call site unknown
Remotes.Treadmill.AssignedBeltShifted.OnClientEvent:Connect(function(p: string?)
	v3 = p ~= nil
	updateAvailability() -- equivalent call inferred; original call site unknown
end)
parent.Activated:Connect(toggleShiftLock)