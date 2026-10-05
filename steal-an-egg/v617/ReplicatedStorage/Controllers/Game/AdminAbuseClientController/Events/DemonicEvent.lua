local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local HiddenUIHandler = require(ReplicatedStorage.Client.HiddenUIHandler)
local localPlayer = Players.LocalPlayer
local flag = false
local v = nil

local function resolveMarker()
	local world = Workspace:FindFirstChild("World")
	local areas = world and world:FindFirstChild("Areas")
	local adminAbuseEggSpawn = areas and areas:FindFirstChild("AdminAbuseEggSpawn")

	if adminAbuseEggSpawn == nil or not adminAbuseEggSpawn:IsA("BasePart") then
		return nil
	end

	return adminAbuseEggSpawn
end

-- equivalent calls inferred from this helper; original call sites unknown
local function restoreCamera()
	local currentCamera = Workspace.CurrentCamera

	if currentCamera == nil then
		return
	end

	currentCamera.CameraType = Enum.CameraType.Custom
	currentCamera.FieldOfView = 70
	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if humanoid ~= nil then
		currentCamera.CameraSubject = humanoid
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopCutscene()
	if not flag then
		return
	end

	flag = false
	restoreCamera() -- equivalent call inferred; original call site unknown
	local v2 = v
	v = nil

	if v2 ~= nil then
		v2()
	end
end

local function resolveEggShot(adminAbuseEggDrop)
	local facing = adminAbuseEggDrop:GetAttribute("Facing")
	local finish = adminAbuseEggDrop:GetAttribute("Finish")

	if typeof(facing) ~= "Vector3" or typeof(finish) ~= "Vector3" then
		return nil
	end

	local vector2 = Vector3.new(facing.X, 0, facing.Z)

	if vector2.Magnitude <= 0 then
		return nil
	end

	local boundingBox, v2 = adminAbuseEggDrop:GetBoundingBox()
	local v3 = finish + (boundingBox.Position - adminAbuseEggDrop:GetPivot().Position)
	local v4 = v2.Y / 0.8 * 0.5 / 0.22169466264293988
	local v5 = (vector2.Unit * 0.9945218953682733 + createVector(0, 0.104528464, 0)) * v4
	return CFrame.lookAt(v3 + v5, v3)
end

local function startCutscene()
	if flag then
		return
	end

	local world = Workspace:FindFirstChild("World")
	local areas = world and world:FindFirstChild("Areas")
	local adminAbuseEggSpawn = areas and areas:FindFirstChild("AdminAbuseEggSpawn")

	if adminAbuseEggSpawn == nil or not adminAbuseEggSpawn:IsA("BasePart") then
		adminAbuseEggSpawn = nil
	end

	local currentCamera = Workspace.CurrentCamera

	if adminAbuseEggSpawn == nil or currentCamera == nil then
		return
	end

	v = HiddenUIHandler.Acquire()
	flag = true
	currentCamera.CameraType = Enum.CameraType.Scriptable
	TweenService:Create(currentCamera, TweenInfo.new(2), {
		FieldOfView = 80
	}):Play()
	local v2 = adminAbuseEggSpawn.Position + createVector(0, 165, 0)
	local v3 = adminAbuseEggSpawn.Position + createVector(-200, 25, 0)
	local cframe = CFrame.lookAt(v3, v2)
	currentCamera.CFrame = cframe
	task.spawn(function()
		while flag do
			local v4 = RunService.RenderStepped:Wait()

			if not flag then
				break
			end

			currentCamera.CameraType = Enum.CameraType.Scriptable
			local adminAbuseEggDrop = Workspace:FindFirstChild("AdminAbuseEggDrop")

			if adminAbuseEggDrop == nil or not adminAbuseEggDrop:IsA("Model") then
				currentCamera.CFrame = cframe
			else
				local eggShot = resolveEggShot(adminAbuseEggDrop)

				if eggShot == nil then
					currentCamera.CFrame = cframe
				elseif adminAbuseEggDrop:GetAttribute("Done") then
					local v5 = math.clamp(v4 * 2.5, 0, 1)
					currentCamera.CFrame = currentCamera.CFrame:Lerp(eggShot, v5)
					currentCamera.FieldOfView += (25 - currentCamera.FieldOfView) * v5
				else
					local position = adminAbuseEggDrop:GetPivot().Position
					local start = adminAbuseEggDrop:GetAttribute("Start")
					local finish = adminAbuseEggDrop:GetAttribute("Finish")
					local v5 = start.Y - finish.Y
					local v6 = not (v5 > 0) and 1 or 1 - (position.Y - finish.Y) / v5
					currentCamera.CFrame = currentCamera.CFrame:Lerp(
						CFrame.lookAt(eggShot.Position, position),
						(math.clamp(v4 * 2, 0, 1))
					)
					currentCamera.FieldOfView = math.lerp(80, 25, (math.clamp(v6, 0, 1)))
				end
			end
		end
	end)
end

local function onPhaseChanged()
	if Workspace:GetAttribute("AdminAbusePhase") == "Cutscene" then
		startCutscene()
		return
	end

	stopCutscene() -- equivalent call inferred; original call site unknown
end

local DemonicEvent = {
	StartEvent = function(_, _: number, _) end,
	StopEvent = function(_)
		if not flag then
			return
		end

		flag = false
		restoreCamera() -- equivalent call inferred; original call site unknown
		local v2 = v
		v = nil

		if v2 ~= nil then
			v2()
		end
	end
}
Workspace:GetAttributeChangedSignal("AdminAbusePhase"):Connect(onPhaseChanged)
localPlayer.CharacterAdded:Connect(function()
	if not flag then
		restoreCamera() -- equivalent call inferred; original call site unknown
	end
end)

if Workspace:GetAttribute("AdminAbusePhase") == "Cutscene" then
	startCutscene()
else
	stopCutscene() -- equivalent call inferred; original call site unknown
end

return DemonicEvent