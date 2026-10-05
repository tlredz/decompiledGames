local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage.Packages.Observers)
local Trove = require(ReplicatedStorage.Packages.Trove)
local VFX = require(ReplicatedStorage.Shared.VFX)
local v = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function loadAnimation(animator, animation, maid)
	local track = animator:LoadAnimation(animation)
	maid:Add(function()
		track:Stop(0)
		track:Destroy()
	end)
	return track
end

local function PointInTriangleXZ(p, worldPosition, worldPosition2, worldPosition3)
	local vector2 = vector.create(p.X, 0, p.Z)
	local vector3 = vector.create(worldPosition.X, 0, worldPosition.Z)
	local vector4 = vector.create(worldPosition2.X, 0, worldPosition2.Z)
	local vector5 = vector.create(worldPosition3.X, 0, worldPosition3.Z) - vector3
	local vector6 = vector4 - vector3
	local v2 = vector2 - vector3
	local dot = vector5:Dot(vector5)
	local dot2 = vector5:Dot(vector6)
	local dot3 = vector5:Dot(v2)
	local dot4 = vector6:Dot(vector6)
	local dot5 = vector6:Dot(v2)
	local v3 = dot * dot4 - dot2 * dot2

	if v3 == 0 then
		return false
	end

	local v4 = (dot4 * dot3 - dot2 * dot5) / v3
	local v5 = (dot * dot5 - dot2 * dot3) / v3
	return v4 >= 0 and v5 >= 0 and v4 + v5 <= 1
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ProjectPointOntoTriangle(p, p2, p3, p4)
	local unit = (p3 - p2):Cross(p4 - p2).Unit
	return p - unit * (p - p2):Dot(unit)
end

local FishingController = {}

function FishingController.WaterSurfacePoint(_, vector2: Vector3)
	for _, list in v do
		local v2, v3, v4 = unpack(list)

		if PointInTriangleXZ(vector2, v2.WorldPosition, v3.WorldPosition, v4.WorldPosition) then
			return ProjectPointOntoTriangle(
				vector2,
				v2.Bone.WorldPosition + v2.Bone.Transform.Position,
				v3.Bone.WorldPosition + v3.Bone.Transform.Position,
				v4.Bone.WorldPosition + v4.Bone.Transform.Position
			)
		end
	end

	return vector2
end

function FishingController.Start(_)
	Observers.observeTag("FishingCatchZone", function(parent)
		local maid = Trove.new()
		task.wait(1)

		if not parent.Parent then
			return maid:WrapClean()
		end

		if parent:FindFirstChild("PoolVFX") then
			parent:FindFirstChild("PoolVFX"):Destroy()
		end

		local pool = parent:GetAttribute("Pool")
		local child = script.PoolVFX:FindFirstChild(pool)

		if not child then
			return maid:WrapClean()
		end

		child.Name = "PoolVFX"
		child:PivotTo(parent.CFrame * CFrame.Angles(1.5707963267948966, 0, 0))
		child.Parent = parent
		maid:Add(function()
			VFX.disable(child)
			task.wait(2)
			child:Destroy()
		end)
		local BrainrotAssets = require(ReplicatedStorage.Shared.BrainrotAssets)
		local model = BrainrotAssets.getModel(pool)

		if not (model and parent.Parent and child.Parent and child:FindFirstChild("Animation")) then
			return maid:WrapClean()
		end

		local clone = maid:Clone(model)

		if not clone.PrimaryPart then
			return maid:WrapClean()
		end

		clone.PrimaryPart.Anchored = true
		clone:PivotTo(CFrame.new(parent.Position))
		clone.Parent = parent
		local animator = clone:FindFirstChildWhichIsA("Animator", true)

		if animator then
			local track = loadAnimation(animator, child.Animation, maid) -- equivalent call inferred; original call site unknown
			track.Looped = true
			track:Play()
		end

		return maid:WrapClean()
	end)
	Observers.observeTag("FishingWater", function(instance)
		local v2 = {}

		for _, bone in instance:GetChildren() do
			if not bone:IsA("Bone") then
				continue
			end

			local order = bone:GetAttribute("Order")
			local v3 = {
				Order = order,
				X = (order - 1) % 5 + 1,
				Y = math.floor((order - 1) / 5) + 1,
				WorldPosition = bone.WorldPosition,
				Bone = bone
			}
			v2[vector.create(v3.X, v3.Y)] = v3
		end

		local v3 = {}

		for _, v4 in v2 do
			local X = v4.X
			local Y = v4.Y

			if not (X < 5) then
				continue
			end

			local v5 = v2[vector.create(X, Y)]
			local v6 = v2[vector.create(X + 1, Y)]
			local v7 = v2[vector.create(X, Y + 1)]
			local v8 = v2[vector.create(X + 1, Y + 1)]

			if not (v5 and v6 and v7 and v8) then
				continue
			end

			table.insert(v3, { v5, v6, v7 })
			table.insert(v3, { v6, v8, v7 })
		end

		v = v3
		return function()
			v = nil
		end
	end)
	Observers.observeTag("FishingBobber", function(parent)
		local ropeConstraint = parent:WaitForChild("RopeConstraint", 30)
		local beam = Instance.new("Beam")
		beam.Attachment0 = ropeConstraint.Attachment0
		beam.Attachment1 = ropeConstraint.Attachment1
		beam.TextureSpeed = 0
		beam.Segments = 1
		beam.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0))
		beam.Width0 = 0.04
		beam.Width1 = 0.04
		beam.Transparency = NumberSequence.new(0)
		beam.Parent = parent
		local clone = nil
		local renderSteppedConnection = nil

		-- equivalent calls inferred from this helper; original call sites unknown
		local function removeBubbles()
			if renderSteppedConnection then
				renderSteppedConnection:Disconnect()
			end

			if clone then
				clone:Destroy()
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function addBubbles()
			removeBubbles() -- equivalent call inferred; original call site unknown
			clone = script.catchbubbles:Clone()
			clone.Parent = parent
			renderSteppedConnection = RunService.RenderStepped:Connect(function()
				if parent:IsDescendantOf(workspace) then
					clone.CFrame = CFrame.new(parent.PrimaryPart.Position)
				else
					removeBubbles() -- equivalent call inferred; original call site unknown
				end
			end)
		end

		parent:GetAttributeChangedSignal("bite"):Connect(function()
			if parent:GetAttribute("bite") then
				addBubbles() -- equivalent call inferred; original call site unknown
			else
				removeBubbles() -- equivalent call inferred; original call site unknown
			end
		end)
		return function()
			beam:Destroy()
		end
	end)
end

return FishingController