local createVector = vector.create
local cframe = CFrame.new(-1, -1, 0, -0, -0, -1, 0, 1, 0, 1, 0, 0)
local cframe2 = CFrame.new(1, -1, 0, 0, 0, 1, 0, 1, 0, -1, -0, -0)
local cframe3 = CFrame.new(0, 0, 0, -1, -0, -0, 0, 0, 1, 0, 1, 0)
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local function onCharacterAdded(instance)
	local running = instance:WaitForChild("HumanoidRootPart"):WaitForChild("Running")
	assert(running:IsA("Sound"), "running sound should be a sound")
	running.Volume = 0
end

local function getCharacterInstances()
	local character = localPlayer.Character

	if not character then
		return {
			found = false
		}
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local torso = character:FindFirstChild("Torso")

	if not (humanoidRootPart and torso) then
		return {
			found = false
		}
	end

	local rootJoint = humanoidRootPart:FindFirstChild("RootJoint")
	local leftHip = torso:FindFirstChild("Left Hip")
	local rightHip = torso:FindFirstChild("Right Hip")
	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if rootJoint and leftHip and rightHip and humanoid then
		return {
			found = true,
			humanoidRootPart = humanoidRootPart,
			humanoid = humanoid,
			leftHipJoint = leftHip,
			rightHipJoint = rightHip,
			rootJoint = rootJoint
		}
	end

	return {
		found = false
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isHoldingGlider()
	local character = localPlayer.Character

	if not character then
		return false
	end

	local tool = character:FindFirstChildOfClass("Tool")

	if not tool then
		return false
	end

	local name = string.lower(tool.Name)
	return string.find(name, "glider") ~= nil
end

RunService.PreRender:Connect(function()
	debug.profilebegin("character bodytilt")
	local characterInstances = getCharacterInstances()

	if not characterInstances.found or characterInstances.humanoidRootPart.Anchored then
		return
	end

	local v = characterInstances.humanoidRootPart.AssemblyLinearVelocity * createVector(1, 0, 1)

	if v.Magnitude < 2 then
		characterInstances.rootJoint.C0 = cframe3
		characterInstances.leftHipJoint.C0 = cframe
		characterInstances.rightHipJoint.C0 = cframe2
	else
		local unit = v.Unit
		local cFrame = characterInstances.humanoidRootPart.CFrame
		local dot = cFrame.RightVector:Dot(unit)
		local dot2 = cFrame.LookVector:Dot(unit)
		local holdingGlider = isHoldingGlider() -- equivalent call inferred; original call site unknown
		local v2 = holdingGlider and 0.3 or 0.2
		local walkSpeed = characterInstances.humanoid.WalkSpeed
		local lerped = cframe3:Lerp(
			cframe3 * CFrame.Angles(
				math.rad((math.clamp(dot2 * 5, -1e999, (math.clamp(walkSpeed - 11, 0, 1e999))))),
				math.rad(-dot * 5),
				0
			),
			v2 / 2
		)
		local lerped2 = cframe:Lerp(cframe * CFrame.Angles(math.rad(dot * 5), 0, 0), v2)
		local lerped3 = cframe2:Lerp(cframe2 * CFrame.Angles(math.rad(-dot * 5), 0, 0), v2)
		characterInstances.rootJoint.C0 = lerped
		characterInstances.leftHipJoint.C0 = lerped2
		characterInstances.rightHipJoint.C0 = lerped3
		debug.profileend()
	end
end)