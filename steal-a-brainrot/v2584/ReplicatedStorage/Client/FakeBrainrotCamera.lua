local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local Net = require(ReplicatedStorage.Packages.Net)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local localPlayer = Players.LocalPlayer
local parent = nil
local v2 = nil
local flag = false
local T = Enum.KeyCode.T
local remoteEvent = Net:RemoteEvent("SpawnFakeBrainrot/Camera")
local remoteEvent2 = Net:RemoteEvent("SpawnFakeBrainrot/CameraToggle")
local remoteEvent3 = Net:RemoteEvent("SpawnFakeBrainrot/Poof")

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyCameraAnchor()
	if v2 then
		v2:Destroy()
		v2 = nil
	end
end

local function getOrCreateCameraAnchor()
	if v2 and v2.Parent then
		return v2
	end

	if not (parent and parent.PrimaryPart) then
		return nil
	end

	local part = Instance.new("Part")
	part.Name = "FakeBrainrotCameraAnchor"
	part.Size = createVector(1, 1, 1)
	part.Transparency = 1
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Massless = true
	part.Anchored = false
	local weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Part0 = parent.PrimaryPart
	weldConstraint.Part1 = part
	weldConstraint.Parent = part
	part.CFrame = parent.PrimaryPart.CFrame + createVector(0, 3, 0)
	part.Parent = parent
	v2 = part
	return part
end

-- equivalent calls inferred from this helper; original call sites unknown
local function resetCamera()
	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")

	if humanoid then
		workspace.CurrentCamera.CameraSubject = humanoid
	end

	if flag then
		flag = false
		remoteEvent2:FireServer(false)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function followTarget()
	if not (parent and parent.PrimaryPart) then
		return
	end

	local cameraAnchor = getOrCreateCameraAnchor()

	if cameraAnchor then
		workspace.CurrentCamera.CameraSubject = cameraAnchor
	end

	flag = true
	remoteEvent2:FireServer(true)
end

local function toggleCamera(_: string, p)
	if p ~= Enum.UserInputState.Begin then
		return Enum.ContextActionResult.Pass
	end

	if flag then
		resetCamera() -- equivalent call inferred; original call site unknown
	else
		followTarget() -- equivalent call inferred; original call site unknown
	end

	return Enum.ContextActionResult.Sink
end

remoteEvent.OnClientEvent:Connect(function(p)
	if p then
		parent = p
		followTarget() -- equivalent call inferred; original call site unknown
		ContextActionService:BindAction("FakeBrainrotCameraToggle", toggleCamera, false, T)
	else
		resetCamera() -- equivalent call inferred; original call site unknown
		destroyCameraAnchor() -- equivalent call inferred; original call site unknown
		parent = nil
		ContextActionService:UnbindAction("FakeBrainrotCameraToggle")
	end
end)
remoteEvent3.OnClientEvent:Connect(function(cframe: CFrame)
	local clone = script.Smoke:Clone()
	clone:PivotTo(CFrame.new(cframe.Position))
	clone.Parent = workspace
	clone.smoke1:Emit(10)
	task.spawn(function()
		SoundController:PlaySound(ReplicatedStorage.Sounds.Sfx.Puff3, cframe.Position, false)
	end)
	task.delay(3, function()
		clone:Destroy()
	end)
end)