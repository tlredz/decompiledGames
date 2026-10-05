local createVector = vector.create
local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage3:WaitForChild("UserInputService"))
local currentCamera = workspace.CurrentCamera
local localPlayer = Players.LocalPlayer
local v2 = require3(ReplicatedStorage2.Common.Utils)
local DynamicSpectatorController = {}
local v3 = require3(ReplicatedStorage2.Controllers.CinematicController)
local v4 = require3(ReplicatedStorage2.ClientGameModules.FFlagClient)
local client = require3(ReplicatedStorage2.Packages.Replion).Client
local v5 = require3(ReplicatedStorage2.Controllers.AnalyticsController)
local v6 = require3(ReplicatedStorage2.ServerInfo)

-- equivalent calls inferred from this helper; original call sites unknown
local function getSineOrientation(p, p2, value, value2)
	return math.sin(math.noise(p * (value or 1), p2) * 3.141592653589793 * 2) * (value2 or 1)
end

function DynamicSpectatorController.Spectate(_, p)
	local total = 0
	local v7 = math.random()
	local v8 = math.random()

	local function getDefaultCFrame(p2)
		local boundingBox, v9 = v2.CameraUtils:GetBoundingBox(p)
		local v10 = boundingBox or CFrame.new()
		total += p2
		local sineOrientation = getSineOrientation(total, v7, 0.3, nil) -- equivalent call inferred; original call site unknown
		local sineOrientation2 = getSineOrientation(total, v8, 0.01, 12.566370614359172) -- equivalent call inferred; original call site unknown
		local v15 = currentCamera.ViewportSize.X / currentCamera.ViewportSize.Y
		local fitBoundingBoxToCamera = v2.CameraUtils.fitBoundingBoxToCamera(
			v9 or createVector(1, 1, 1),
			currentCamera.FieldOfView,
			v15
		)
		return v10 * CFrame.Angles(0, sineOrientation2, 0) * CFrame.Angles(
			-0.7853981633974483 - sineOrientation * 3.141592653589793 / 16,
			0,
			0
		) * CFrame.new(0, 0, fitBoundingBoxToCamera)
	end

	v2.Thread.Every(15, function()
		v7 = math.random()
		v8 = math.random()
	end)
	return v3:AddCameraStep(function(p2)
		return currentCamera.CFrame:Lerp(getDefaultCFrame(p2), p2 * 5)
	end)
end

local maid = v2.Maid.new()

function DynamicSpectatorController.EnableAimAssist(_) end

function DynamicSpectatorController:Track()
	if not v4:IsDataReady() then
		return
	end

	if not v2.FFlag.GetInstantFFlag("AimAssistTutorialEnabled", false) then
		maid:Destroy()
		return
	end

	if maid.Active then
		return
	end

	maid.Active = true
	local balls = workspace.Balls
	local v7 = {}

	for _, child in pairs(balls:GetChildren()) do
		if not (child:IsA("BasePart") or child:IsA("Model")) or child:GetAttribute("realBall") then
			continue
		end

		table.insert(v7, child)
	end

	maid:GiveTask(balls.ChildAdded:Connect(function(instance)
		if instance:IsA("BasePart") or instance:IsA("Model") then
			table.insert(v7, instance)
		end
	end))
	maid:GiveTask(balls.ChildRemoved:Connect(function(instance)
		if instance:IsA("BasePart") or instance:IsA("Model") then
			for k, v8 in pairs(v7) do
				if v8 == instance then
					table.remove(v7, k)
				end
			end
		end
	end))
	local v8 = client:WaitReplion("Data")
	local v9 = localPlayer.Character and localPlayer.Character:IsDescendantOf(workspace.Alive)
	local v10 = v.MouseBehavior == Enum.MouseBehavior.LockCenter
	local v11 = v8:Get("TotalStats.Matches") < 3
	local v12 = v.MouseBehavior == Enum.MouseBehavior.LockCurrentPosition
	maid.TrackActive = v2.Thread.Every(1, function()
		v9 = localPlayer.Character and localPlayer.Character:IsDescendantOf(workspace.Alive)
	end)
	maid:GiveTask(v:GetPropertyChangedSignal("MouseBehavior"):Connect(function()
		v10 = v.MouseBehavior == Enum.MouseBehavior.LockCenter
		v12 = v.MouseBehavior == Enum.MouseBehavior.LockCurrentPosition
	end))
	maid.TrackNoob = v8:Get("TotalStats.Matches") < 3

	function maid.RenderStep()
		currentCamera:SetAttribute("AimAssist", nil)
		RunService:UnbindFromRenderStep("BallAimAssist")
	end

	maid:GiveTask(v8:OnChange("TotalStats.Matches", function(p)
		v11 = p < 3
	end))

	local function isEnabled()
		if v12 or v10 or not v11 then
			return false
		end

		if v9 then
			return #v7 ~= 0
		end

		return false
	end

	RunService:BindToRenderStep("BallAimAssist", Enum.RenderPriority.Camera.Value - 1, function(p)
		local v13

		if v12 or v10 or not (v11 and v9) then
			v13 = false
		else
			v13 = #v7 ~= 0
		end

		if not v13 then
			currentCamera:SetAttribute("AimAssist", nil)
			return
		end

		currentCamera:SetAttribute("AimAssist", true)
		local boundingBox, _ = v2.CameraUtils:GetBoundingBox(v7)
		local position = currentCamera.CFrame.Position
		local position2 = boundingBox.Position
		local v14 = math.abs((localPlayer.Character and localPlayer.Character:GetPivot().Position.Y or position2.Y) - position2.Y)
		local v15 = position2 - Vector3.new(0, not (v14 < 10) and 0 or math.clamp(1 - v14 / 10, 0, 1) * 20, 0)
		local v16 = position.Y - v15.Y
		local v17 = math.sqrt((position.X - v15.X) ^ 2 + (position.Z - v15.Z) ^ 2)
		local v18 = math.atan2(v16, v17) * 57.29577951308232

		if math.abs(v18) > 30 then
			local v19 = v17 * 0.5773502691896257

			if v18 > 0 then
				v15 += Vector3.new(0, v16 - v19, 0)
			else
				v15 += Vector3.new(0, v16 + v19, 0)
			end
		end

		currentCamera.CFrame = currentCamera.CFrame:Lerp(CFrame.new(position, v15), p * 3)
	end)
	return maid
end

function DynamicSpectatorController.Start(_)
	v5:GetRemoteConfigValue("AimAssist", false):andThen(function(flag: boolean)
		if flag and v6.isTutorialServer() then
			DynamicSpectatorController:Track()
		elseif maid.Active then
			maid:Destroy()
		end
	end)
end

return DynamicSpectatorController