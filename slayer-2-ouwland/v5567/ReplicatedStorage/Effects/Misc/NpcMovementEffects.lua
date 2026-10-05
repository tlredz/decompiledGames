local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local v = {}
local v2 = {}
local v3 = {
	FadeInTime = 0,
	Frequency = 0.2,
	Amplitude = 0.3,
	SustainTime = 0.05,
	FadeOutTime = 0.5,
	RotationInfluence = createVector(0.35, 0.35, 0.35),
	PositionInfluence = createVector(1, 1, 1)
}

-- equivalent calls inferred from this helper; original call sites unknown
local function stopStep(p)
	p.Name = "--"
	DebrisModule:AddItem(p, 2)
end

return function(instance, p: string?, childName: string?, p2: string?)
	local name = p2 == nil and "NpcStepEffect" or `NpcStepEffect-{p2}` or "NpcStepEffect"
	local debree = workspace:FindFirstChild("Debree")
	local child

	if debree ~= nil then
		child = debree:FindFirstChild(name) or nil
	end

	if p == "Walk" then
		if child ~= nil or (instance == nil or debree == nil) then
			return
		end

		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart

		if humanoidRootPart == nil then
			return
		end

		local v5

		if childName ~= nil then
			v5 = v2[childName] or nil
		end

		local v6 = v5 ~= nil and script:FindFirstChild(v5) or script:FindFirstChild("Step")

		if v6 == nil then
			return
		end

		local clone = v6:Clone()
		clone.Name = name
		local root = clone:FindFirstChild("Root")

		if root == nil then
			return
		end

		clone:PivotTo(humanoidRootPart.CFrame)
		local weld = Instance.new("Weld")
		weld.Part0 = humanoidRootPart
		weld.Part1 = root
		weld.Parent = root
		clone.Parent = debree
		local sounds = script:FindFirstChild("Sounds")
		local child2

		if sounds == nil or childName == nil then
			child2 = nil
		else
			child2 = sounds:FindFirstChild(childName) or nil
		end

		local children

		if child2 == nil then
			children = nil
		else
			children = child2:GetChildren() or nil
		end

		task.spawn(function()
			while clone.Parent ~= nil and clone.Name == name and humanoidRootPart.Parent ~= nil and instance:GetAttribute("MovementState") == "Walk" do
				local raycastResult = workspace:Raycast(
					humanoidRootPart.Position + createVector(0, 3, 0),
					createVector(0, -20, 0),
					RaycastHelper.Crater
				)
				Ouwmit.Emit(
					clone,
					Ouwmit.Owned(
						instance,
						raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
					)
				)

				if children ~= nil and #children > 0 then
					local v7 = children[math.random(1, #children)]
					vfxUtility.PlaySound(child2, v7.Name, root, true)
				end

				Cam_Shaker(humanoidRootPart.Position, v3)
				task.wait(childName == nil and 0.825 or v[childName] or 0.825)
			end

			if clone.Parent ~= nil and clone.Name == name then
				stopStep(clone) -- equivalent call inferred; original call site unknown
			end
		end)
	elseif child ~= nil then
		stopStep(child) -- equivalent call inferred; original call site unknown
	end
end