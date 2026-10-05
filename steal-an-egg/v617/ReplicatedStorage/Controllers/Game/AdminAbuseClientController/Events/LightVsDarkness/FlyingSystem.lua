local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local CameraShaker = require(ReplicatedStorage.Packages.CameraShaker)
local LightVsDarknessEventFlags = require(ReplicatedStorage.Shared.Flags.LightVsDarknessEventFlags)
local Player = require(ReplicatedStorage.Shared.Player)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
require(ReplicatedStorage.Packages.Trove)
local tweenInfo = TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(1.05, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
local tweenInfo3 = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local localPlayer = Players.LocalPlayer
local v = nil
local currentCamera = Workspace.CurrentCamera
local v2 = CameraShaker.new(Enum.RenderPriority.Camera.Value + 2, function(cframe: CFrame)
	currentCamera.CFrame *= cframe
end)
local total = 0
local total2 = 0
local v3 = nil
local identity = CFrame.identity
local v4 = nil
local v5 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function cancelCameraLead()
	local v6 = v4
	v4 = nil

	if v6 then
		v6:Cancel()
	end
end

local function settleCameraLead(p, tweenInfo4)
	cancelCameraLead() -- equivalent call inferred; original call site unknown

	if p.Parent == nil then
		return
	end

	local tween = TweenService:Create(p, tweenInfo4, {
		CameraOffset = createVector(0, 0, 0)
	})
	v4 = tween
	tween:Play()
end

local function raiseCameraLead()
	local humanoid = Player.FindHumanoid(localPlayer)

	if humanoid == nil then
		return
	end

	cancelCameraLead() -- equivalent call inferred; original call site unknown
	v5 = humanoid
	local tween = TweenService:Create(humanoid, tweenInfo, {
		CameraOffset = createVector(0, 12, 0)
	})
	v4 = tween
	tween.Completed:Once(function(p)
		if v4 ~= tween or p ~= Enum.PlaybackState.Completed then
			return
		end

		settleCameraLead(humanoid, tweenInfo2)
	end)
	tween:Play()
end

local function setFlyingVisuals(flag: boolean)
	if flag then
		raiseCameraLead()
		return
	end

	local v6 = v5 or Player.FindHumanoid(localPlayer)
	v5 = nil
	cancelCameraLead() -- equivalent call inferred; original call site unknown

	if v6 ~= nil and v6.Parent ~= nil and v6.CameraOffset ~= createVector(0, 0, 0) then
		settleCameraLead(v6, tweenInfo3)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isFlying()
	return localPlayer:GetAttribute("LvdFlying") == true
end

local function rootJointOf(character)
	local lowerTorso = character:FindFirstChild("LowerTorso")
	local root

	if lowerTorso ~= nil then
		root = lowerTorso:FindFirstChild("Root")
	end

	if root == nil then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart == nil then
			root = nil
		else
			root = humanoidRootPart:FindFirstChild("RootJoint")
		end
	end

	if root == nil or not root:IsA("Motor6D") then
		return nil
	end

	return root
end

-- equivalent calls inferred from this helper; original call sites unknown
local function releaseLean()
	local v6 = v3
	v3 = nil

	if v6 ~= nil and v6.Parent ~= nil then
		v6.C0 = identity
	end

	total = 0
	total2 = 0
end

-- equivalent calls inferred from this helper; original call sites unknown
local function trackLeanJoint(p)
	if v3 == p then
		return
	end

	releaseLean() -- equivalent call inferred; original call site unknown
	v3 = p
	identity = p.C0
end

local function stepLean(p: number)
	local character = Player.FindCharacter(localPlayer)
	local humanoid = Player.FindHumanoid(localPlayer)
	local part = Player.FindRootPart(localPlayer)
	local v6

	if character ~= nil then
		v6 = rootJointOf(character)
	end

	if v6 == nil or humanoid == nil or part == nil or not part:IsA("BasePart") then
		releaseLean() -- equivalent call inferred; original call site unknown
	else
		trackLeanJoint(v6) -- equivalent call inferred; original call site unknown
		local moveDirection = humanoid.MoveDirection
		local v7, v8

		if isFlying() and humanoid.Health > 0 and moveDirection.Magnitude > 0.001 and LightVsDarknessEventFlags.FlyingLeanEnabled:Get() then
			local cFrame = part.CFrame
			v7 = -0.7853981633974483 * cFrame.LookVector:Dot(moveDirection)
			v8 = -0.2617993877991494 * cFrame.RightVector:Dot(moveDirection)
		else
			v7 = 0
			v8 = 0
		end

		local v9 = 1 - math.exp(p * -8)
		total += (v7 - total) * v9
		total2 += (v8 - total2) * v9

		if not (math.abs(total) < 0.001 and math.abs(total2) < 0.001) then
			v6.C0 = identity * CFrame.Angles(total, 0, total2)
			return
		end

		total = 0
		total2 = 0
		v6.C0 = identity
	end
end

local function start()
	total = 0
	total2 = 0
	v.AssetTrove:Connect(localPlayer:GetAttributeChangedSignal("LvdFlying"), function()
		if isFlying() then
			raiseCameraLead()
			return
		end

		local v6 = v5 or Player.FindHumanoid(localPlayer)
		v5 = nil
		cancelCameraLead() -- equivalent call inferred; original call site unknown

		if v6 ~= nil and v6.Parent ~= nil and v6.CameraOffset ~= createVector(0, 0, 0) then
			settleCameraLead(v6, tweenInfo3)
		end
	end)
	v.AssetTrove:Connect(RunService.PreRender, stepLean)
	v.AssetTrove:Add(releaseLean)
	v.AssetTrove:Connect(Remotes.LightVsDarkness.Struck.OnClientEvent, function()
		v2:ShakeOnce(3, 12, 0.1, 0.8)
	end)

	if isFlying() then
		raiseCameraLead()
		return
	end

	local v6 = v5 or Player.FindHumanoid(localPlayer)
	v5 = nil
	cancelCameraLead() -- equivalent call inferred; original call site unknown

	if v6 ~= nil and v6.Parent ~= nil and v6.CameraOffset ~= createVector(0, 0, 0) then
		settleCameraLead(v6, tweenInfo3)
	end
end

local function stop()
	releaseLean() -- equivalent call inferred; original call site unknown
	local v6 = v5 or Player.FindHumanoid(localPlayer)
	v5 = nil
	cancelCameraLead() -- equivalent call inferred; original call site unknown

	if v6 ~= nil and v6.Parent ~= nil and v6.CameraOffset ~= createVector(0, 0, 0) then
		settleCameraLead(v6, tweenInfo3)
	end
end

v2:Start()
return function(p)
	v = p
	return {
		Start = start,
		Stop = stop
	}
end