local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local PlayerModule = require(Players.LocalPlayer.PlayerScripts.PlayerModule)
local controls = PlayerModule:GetControls()
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local v = nil
local v2 = false
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
	alignOrientation.CFrame = workspace.CurrentCamera.CFrame
	v = {
		linearVelocity = linearVelocity,
		alignOrientation = alignOrientation
	}
end

local function updateFlight()
	if not v then
		return
	end

	local linearVelocity = v.linearVelocity
	local alignOrientation = v.alignOrientation
	local parent = linearVelocity.Parent

	if not parent then
		return
	end

	local moveVector = controls:GetMoveVector()
	local currentCamera = workspace.CurrentCamera

	if moveVector.Magnitude > 0 then
		local v3 = currentCamera.CFrame * CFrame.new(moveVector)
		linearVelocity.VectorVelocity = CFrame.lookAt(currentCamera.CFrame.Position, v3.Position).LookVector * 100
		alignOrientation.CFrame = currentCamera.CFrame
	else
		linearVelocity.VectorVelocity = createVector(0, 0, 0)
		parent.AssemblyLinearVelocity = createVector(0, 0, 0)
		parent.AssemblyAngularVelocity = createVector(0, 0, 0)
	end
end

local function stopFlying()
	v2 = false
	maid:Cleanup()
	return "Flying stopped"
end

local function startFlying()
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
		v2 = false
		maid:Cleanup()
	end))
	maid:Add(RunService.Stepped:Connect(function()
		if not v2 then
			return
		end

		updateFlight()
	end))
	maid:Add(function()
		humanoid.PlatformStand = false
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart ~= nil then
			humanoidRootPart:RemoveTag("MuteRunSound")
		end
	end)
	createFlightControls()
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart ~= nil then
		humanoidRootPart:AddTag("MuteRunSound")
	end

	v2 = true
	return "Flying started"
end

return {
	FrameworkStart = function()
		Remotes.connect("StartFly", startFlying)
		Remotes.connect("StopFly", stopFlying)
	end
}