local createVector = vector.create
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local v = nil
local humanoidRootPart = nil
local rootJoint = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function setupCharacter(character)
	v = character
	humanoidRootPart = v:WaitForChild("HumanoidRootPart")
	rootJoint = humanoidRootPart:WaitForChild("RootJoint")
	originalC0 = rootJoint.C0
end

setupCharacter(localPlayer.Character or localPlayer.CharacterAdded:Wait()) -- equivalent call inferred; original call site unknown
localPlayer.CharacterAdded:Connect(setupCharacter)
RunService.RenderStepped:Connect(function(dt)
	if v:GetAttribute("InOverdriveMech") then
		rootJoint.C0 = originalC0
		return
	end

	local v2 = humanoidRootPart.AssemblyLinearVelocity * createVector(1, 0.75, 1)
	local v3, v4

	if v2.Magnitude > 2 then
		local unit = v2.Unit
		local cFrame = humanoidRootPart.CFrame
		v3 = cFrame.LookVector:Dot(unit) * 0.1
		v4 = -cFrame.RightVector:Dot(unit) * 0.1
	else
		v3 = 0
		v4 = 0
	end

	local v5 = originalC0 * CFrame.Angles(v3, v4, 0)
	local v6 = 1 - (1 - math.min(dt / 0.35, 1)) ^ 2
	rootJoint.C0 = rootJoint.C0:Lerp(v5, v6)
end)