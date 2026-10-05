local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local color = Color3.new(0, 0, 0)
local sounds = script:WaitForChild("Sounds")
local v = {
	Clone = "PS2speedandreflexLEAVE",
	Recall = "PS2speedandreflexRETURN"
}
local v2 = {
	Clone = "SetClone",
	Recall = "Teleportback"
}

local function cloneName(p)
	return (`{p.Name}'s Speed Reflex Clone`)
end

local fn

-- equivalent calls inferred from this helper; original call sites unknown
local function removeClone(p)
	local child = workspace.Debree:FindFirstChild((`{p.Name}'s Speed Reflex Clone`))

	if child ~= nil then
		child:Destroy()
	end
end

local function plantClone(instance, duration: number?)
	removeClone(instance) -- equivalent call inferred; original call site unknown
	local archivable = instance.Archivable
	instance.Archivable = true
	local clone = instance:Clone()
	instance.Archivable = archivable

	if clone == nil then
		warn((`[SpeedReflexVFX] could not clone {instance:GetFullName()}`))
		return
	end

	clone.Name = `{instance.Name}'s Speed Reflex Clone`

	for _, descendant in clone:GetDescendants() do
		if not (descendant:IsA("Humanoid") or descendant:IsA("Animator") or descendant:IsA("AnimationController") or descendant:IsA("JointInstance") or descendant:IsA("Constraint") or descendant:IsA("Attachment") or descendant:IsA("BaseScript") or descendant:IsA("BodyMover") or descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("Trail") or descendant:IsA("Light") or descendant:IsA("Sound") or descendant:IsA("LayerCollector") or descendant:IsA("Tool") or descendant:IsA("ValueBase") or descendant:IsA("Animation") or descendant:IsA("Highlight")) then
			continue
		end

		descendant:Destroy()
	end

	for _, part in clone:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
	end

	local highlight = Instance.new("Highlight")
	highlight.FillColor = color
	highlight.OutlineColor = color
	highlight.FillTransparency = 0.3
	highlight.OutlineTransparency = 1
	highlight.Adornee = clone
	highlight.Parent = clone
	clone.Parent = workspace.Debree

	if duration ~= nil then
		task.delay(duration, function()
			if clone.Parent == nil then
				return
			end

			fn("SetClone", clone:GetPivot(), instance)
			removeClone(instance) -- equivalent call inferred; original call site unknown
		end)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function groundDust(position: Vector3)
	local raycastResult = workspace:Raycast(
		position + createVector(0, 5, 0),
		createVector(-0, -20, -0),
		RaycastHelper.Crater
	)
	return raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
end

fn = function(childName: string, cframe: CFrame, instance)
	local child = script:FindFirstChild(childName)

	if child == nil then
		return
	end

	local clone = child:Clone()
	clone.Parent = workspace.Debree
	clone:PivotTo(cframe)
	Ouwmit.Emit(clone, Ouwmit.Owned(instance, groundDust(cframe.Position)))
	DebrisModule:AddItem(clone, 2)
end

return function(instance, p: string, cframe: CFrame?, value)
	if instance == nil or p == nil or cframe == nil then
		return
	end

	local v3 = v2[p]

	if not (v3 ~= nil and script:FindFirstChild(v3) ~= nil) then
		return
	end

	if p == "Clone" then
		local v5

		if typeof(value) == "number" then
			v5 = value
		end

		plantClone(instance, v5)
	elseif p == "Recall" then
		removeClone(instance) -- equivalent call inferred; original call site unknown
	end

	local cframe2

	if p == "Recall" and typeof(value) == "Vector3" then
		local position = cframe.Position
		local vector2 = Vector3.new(value.X, position.Y, value.Z)

		if (vector2 - position).Magnitude > 0.01 then
			cframe2 = CFrame.lookAt(position, vector2)
		else
			cframe2 = cframe
		end
	else
		cframe2 = cframe
	end

	fn(v3, cframe2, instance)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
	local v4 = v[p]

	if humanoidRootPart ~= nil and v4 ~= nil then
		vfxUtility.PlaySound(sounds, v4, humanoidRootPart, true)
	end

	Cam_Shaker(cframe.Position, "activate_shake")
end