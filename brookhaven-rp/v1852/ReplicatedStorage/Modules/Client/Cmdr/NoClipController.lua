local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local PlayerModule = require(Players.LocalPlayer.PlayerScripts.PlayerModule)
local controls = PlayerModule:GetControls()
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local v = {}
local v2 = nil
local v3 = false
local maid = Janitor.new()

local function createFlightControls()
	local character = Players.LocalPlayer.Character

	if not character then
		return
	end

	local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 10)

	if not humanoidRootPart then
		return
	end

	local rootRigAttachment = humanoidRootPart:WaitForChild("RootRigAttachment")
	local linearVelocity = maid:Add(Instance.new("LinearVelocity"))
	local alignOrientation = maid:Add(Instance.new("AlignOrientation"))
	alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
	alignOrientation.Attachment0 = rootRigAttachment
	alignOrientation.MaxTorque = 1000000000
	alignOrientation.RigidityEnabled = true
	linearVelocity.Attachment0 = rootRigAttachment
	linearVelocity.MaxForce = 1000000000
	alignOrientation.Parent = humanoidRootPart
	linearVelocity.Parent = humanoidRootPart
	v2 = {
		linearVelocity = linearVelocity,
		alignOrientation = alignOrientation
	}
end

local function updateFlight()
	if not v2 then
		return
	end

	local linearVelocity = v2.linearVelocity
	local alignOrientation = v2.alignOrientation
	local moveVector = controls:GetMoveVector()
	local currentCamera = workspace.CurrentCamera

	if moveVector.Magnitude > 0 then
		local v4 = currentCamera.CFrame * CFrame.new(moveVector)
		linearVelocity.VectorVelocity = CFrame.lookAt(currentCamera.CFrame.Position, v4.Position).LookVector * 100
	else
		linearVelocity.VectorVelocity = createVector(0, 0, 0)
	end

	alignOrientation.CFrame = currentCamera.CFrame
end

local function turnOffCollisions()
	local character = Players.LocalPlayer.Character

	if not character then
		return
	end

	for _, part in character:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		v[part] = v[part] or part.CollisionGroup
		part.CollisionGroup = "NoCollisions"
	end
end

local function stopNoClip()
	v3 = false

	for k, collisionGroup in v do
		k.CollisionGroup = collisionGroup
	end

	v = {}
	maid:Cleanup()
	return "No clip stopped"
end

local function startNoClip()
	local character = Players.LocalPlayer.Character

	if not character then
		return "You do not have a character"
	end

	local humanoid = character:FindFirstChild("Humanoid")

	if not humanoid then
		return "You do not have a humanoid"
	end

	maid:Cleanup()
	humanoid.PlatformStand = true
	maid:Add(humanoid.Died:Once(function()
		v3 = false

		for k, collisionGroup in v do
			k.CollisionGroup = collisionGroup
		end

		v = {}
		maid:Cleanup()
	end))
	maid:Add(RunService.Stepped:Connect(function()
		if not v3 then
			return
		end

		turnOffCollisions()
		updateFlight()
	end))
	maid:Add(function()
		humanoid.PlatformStand = false
	end)
	turnOffCollisions()
	createFlightControls()
	v3 = true
	return "No clip started"
end

return {
	FrameworkStart = function()
		Remotes.connect("NoClip", startNoClip)
		Remotes.connect("UnNoClip", stopNoClip)
	end
}