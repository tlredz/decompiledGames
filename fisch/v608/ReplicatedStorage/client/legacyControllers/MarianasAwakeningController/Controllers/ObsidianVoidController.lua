local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local packages = ReplicatedStorage.packages
local Net = require(packages.Net)
local Trove = require(packages.Trove)
local CutsceneController = require(ReplicatedStorage.client.legacyControllers.CutsceneController)
local localPlayer = Players.LocalPlayer
local remoteEvent = Net:RemoteEvent("MarianasAwakening/JumpStart")
local flag = false

-- equivalent calls inferred from this helper; original call sites unknown
local function getCamera()
	return workspace.CurrentCamera
end

local function getRoot()
	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		return humanoidRootPart
	end

	return nil
end

local function easeOut(p: number)
	return 1 - (1 - p) ^ 2
end

local function clearEye(position: Vector3, vector2: Vector3)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { localPlayer.Character }
	raycastParams.IgnoreWater = true
	local v = vector2 - position
	local raycastResult = workspace:Raycast(position, v, raycastParams)

	if raycastResult then
		return raycastResult.Position - v.Unit * 6
	end

	return vector2
end

local function playFall()
	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		humanoidRootPart = nil
	end

	if not humanoidRootPart then
		return
	end

	local maid = Trove.new()
	local position = humanoidRootPart.Position
	local lastTime = os.clock()
	local camera = getCamera() -- equivalent call inferred; original call site unknown
	local vector2 = Vector3.new(camera.CFrame.Position.X - position.X, 0, camera.CFrame.Position.Z - position.Z)
	local unit

	if vector2.Magnitude > 0.1 then
		unit = vector2.Unit
	else
		unit = camera.CFrame.LookVector * -1
	end

	local position2 = camera.CFrame.Position
	local v = camera.CFrame.Position + camera.CFrame.LookVector * 20
	maid:Add(function()
		local camera2 = getCamera() -- equivalent call inferred; original call site unknown
		local character2 = localPlayer.Character
		local humanoidRootPart2 = character2 and character2:FindFirstChild("HumanoidRootPart")

		if not (humanoidRootPart2 and humanoidRootPart2:IsA("BasePart")) then
			humanoidRootPart2 = nil
		end

		if humanoidRootPart2 then
			local lookVector = humanoidRootPart2.CFrame.LookVector
			local vector3 = Vector3.new(lookVector.X, 0, lookVector.Z)
			local v2 = not (vector3.Magnitude > 0.1) and createVector(0, 0, 1) or vector3.Unit
			local v3 = humanoidRootPart2.Position - v2 * 12 + createVector(0, 4, 0)
			camera2.CFrame = CFrame.lookAt(v3, humanoidRootPart2.Position)
		end

		camera2.CameraType = Enum.CameraType.Custom
	end)
	maid:Add(RunService.PreRender:Connect(function(dt: number)
		local camera2 = getCamera() -- equivalent call inferred; original call site unknown

		if camera2.CameraType ~= Enum.CameraType.Scriptable then
			camera2.CameraType = Enum.CameraType.Scriptable
		end

		local character2 = localPlayer.Character
		local humanoidRootPart2 = character2 and character2:FindFirstChild("HumanoidRootPart")

		if not (humanoidRootPart2 and humanoidRootPart2:IsA("BasePart")) then
			humanoidRootPart2 = nil
		end

		local position3

		if humanoidRootPart2 then
			position3 = humanoidRootPart2.Position
		else
			position3 = position
		end

		local v2 = 1 - (1 - math.clamp((os.clock() - lastTime) / 1.1 + 0.35, 0, 1)) ^ 2
		local vector3 = Vector3.new(position.X - position3.X, 0, position.Z - position3.Z)
		local v3

		if vector3.Magnitude > 0.1 then
			v3 = vector3.Unit
		else
			v3 = unit
		end

		local v4 = position + Vector3.new(0, v2 * 55, 0) + v3 * 10 * v2
		position2 = position2:Lerp(clearEye(position, v4), (math.min(dt * 14, 1)))
		v = v:Lerp(position3, (math.min(dt * 10, 1)))
		camera2.CFrame = CFrame.lookAt(position2, v)
	end))
	task.delay(0.1, function()
		CutsceneController:FadeToggle(0.8, true)
	end)
	task.wait(1.5)
	maid:Destroy()
	CutsceneController:FadeToggle(0.8, false)
end

return {
	Start = function(_)
		remoteEvent.OnClientEvent:Connect(function()
			if flag then
				return
			end

			flag = true
			local success, result = pcall(playFall)

			if not success then
				warn((`[ObsidianVoid]: {result}`))
			end

			flag = false
		end)
	end
}