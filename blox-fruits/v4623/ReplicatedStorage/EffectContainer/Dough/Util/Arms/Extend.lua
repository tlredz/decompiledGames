local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
ReplicatedStorage:WaitForChild("Assets")
local FX = require(game.ReplicatedStorage.FX)
local dough = FX:WaitForChild("Dough")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
require(ReplicatedStorage:WaitForChild("Effect"))
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local models = dough.Models
local _ = Util.Tween.point

local function darkenColor(p, p2)
	return (p2 or Color3.new(0.1, 0.1, 0.1)):Lerp(p or Color3.new(1, 1, 1), 0.5):Lerp(Color3.new(), 0.575)
end

local function setupModel(instance)
	assert(instance, "Please make sure you use a correct arm side (i.e 'Right' or 'Left'")
	local clone = instance:Clone()
	local primaryPart = clone.PrimaryPart
	local arm = clone:FindFirstChild("Arm")
	local layer = clone:FindFirstChild("Layer")
	local bone = primaryPart:FindFirstChild("Bone")
	local move = primaryPart:FindFirstChild("Move")
	local v = {}

	local function gatherArmature(instance2, p)
		local v2 = p or instance2:GetAttribute("Scale") or 1

		if not instance2:GetAttribute("Size") then
			instance2:SetAttribute("Size", createVector(4.493, 4.113, 10.448) * Vector3.new(v2, v2, 1))
		end

		instance2.Size = instance2:GetAttribute("Size") * 1
		local motor6D = instance2:FindFirstChildOfClass("Motor6D")

		if motor6D then
			table.insert(v, {
				Object = motor6D,
				C0 = motor6D.C0,
				C1 = motor6D.C1
			})
		end

		return {
			Inverted = instance2.Name == "Layer",
			Part = instance2
		}
	end

	local _ = { (gatherArmature(arm)) }
	return clone, arm, layer, v, { gatherArmature(arm), (gatherArmature(layer)) }, {
		RootBone = bone,
		Bone = move,
		Length = 0.663,
		Direction = createVector(0, 0, -1)
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function serializeModel(child)
	local model, mainPart, layer, joints, parts, bones = setupModel(child)
	return {
		Joints = joints,
		Parts = parts,
		Bones = bones,
		Model = model,
		MainPart = mainPart,
		Layer = layer
	}
end

CFrame.new(0, 999999, 0)
local v = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function Return(side, segments, width, length)
	v[side][width][length][segments] = true

	for _, item in pairs(segments) do
		item.Model.Parent = nil
	end
end

local function Grab(side, width, length)
	v[side] = v[side] or {}
	v[side][width] = v[side][width] or {}
	v[side][width][length] = v[side][width][length] or {}
	local v2 = v[side][width][length]
	local v3, _ = next(v2)

	if v3 then
		v2[v3] = nil
		return v3
	end

	local result = {}

	for i = 1, 4 do
		local _ = i / 4
		local child = models.Arms.Extended:FindFirstChild(side)
		table.insert(result, serializeModel(child))
	end

	for _, v4 in pairs(result) do
		for _, part in pairs(v4.Parts) do
			local part2 = part.Part
			part2.Size = part2:GetAttribute("Size") * width
		end

		for _, joint in pairs(v4.Joints) do
			joint.Object.C0 = Util.Misc.scaleCF(joint.C0, width)
			joint.Object.C1 = Util.Misc.scaleCF(joint.C1, width)
		end

		for _, _ in pairs(v4.Bones) do

		end
	end

	for k, v4 in pairs(result) do
		v4.Bones.Bone.Position = v4.Bones.Direction * math.max(
			0.66,
			length * (k / 4) - 10.447999954223633 * (width or 1)
		)
	end

	return result
end

local v2 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function Return2(side, segments)
	v2[side][segments] = true

	for _, item in pairs(segments) do
		item.Model.Parent = nil
	end
end

function Grab2(childName)
	v2[childName] = v2[childName] or {}
	local v3 = v2[childName]
	local v4, _ = next(v3)

	if v4 then
		v3[v4] = nil
		return v4
	end

	local model, mainPart, layer, joints, parts, bones = setupModel(models.Arms.Extended:FindFirstChild(childName))
	return {
		{
			Joints = joints,
			Parts = parts,
			Bones = bones,
			Model = model,
			MainPart = mainPart,
			Layer = layer
		}
	}
end

local Extend = {}

function Extend.new(data)
	local v3 = {
		FastMode = data.FastMode,
		Segments = {},
		Side = data.Side or "Left",
		Buso = data.Buso,
		Anchor = data.Anchor,
		CFrame = data.CFrame or CFrame.new(),
		Width = data.Width or 1,
		Length = data.Length or 3.3000000000000003
	}
	v3.CurrentLength = v3.Length * (v3.StartAlpha or 0)
	v3.OnRetract = data.OnRetract
	v3.OnExtend = data.OnExtend
	v3.Events = {
		Retract = Util.Signal2.new(),
		Extend = Util.Signal2.new()
	}
	v3.Events.Retract:Connect(function(...)
		if v3.OnRetract then
			v3:OnRetract(...)
		end
	end)
	v3.Events.Extend:Connect(function(...)
		if v3.OnExtend then
			v3:OnExtend(...)
		end
	end)
	local object = setmetatable(v3, {
		__index = Extend
	})
	object:__build()
	return object
end

function Extend:__getCFrame()
	local identity = CFrame.identity

	if typeof(self.Anchor) ~= "Instance" or not self.Anchor:IsDescendantOf(workspace) then
		return (self.LastCFrame or identity) * self.CFrame
	end

	if self.Anchor:IsA("Attachment") then
		identity = self.Anchor.WorldCFrame
	else
		identity = self.Anchor.CFrame
	end

	self.LastCFrame = identity
	return (self.LastCFrame or identity) * self.CFrame
end

function Extend:__build()
	if self.FastMode then
		self.Segments = Grab(self.Side, self.Width, self.Length)
	else
		self.Segments = Grab2(self.Side)
	end

	local name = string.format("Dough/%s/%s", script.Parent.Name, script.Name)
	local modelCache = _WorldOrigin:FindFirstChild(name)

	if not modelCache then
		modelCache = Instance.new("Model")
		modelCache.Name = name
		modelCache.Parent = _WorldOrigin
	end

	self.ModelCache = modelCache
	self:update()

	for _, segment in pairs(self.Segments) do
		segment.Model.Parent = self.ModelCache
	end
end

function Extend:__paint()
	local buso = self.Buso

	for _, segment in pairs(self.Segments) do
		for _, part in pairs(segment.Parts) do
			if buso then
				if part.Inverted then
					if typeof(buso) == "Color3" then
						part.Part.Color = buso
					else
						part.Part.Color = Color3.new()
					end
				else
					part.Part.Material = "Glass"

					if typeof(buso) == "Color3" then
						part.Part.Color = darkenColor(buso)
					else
						part.Part.Color = darkenColor(Color3.new())
					end
				end
			elseif part.Inverted then
				part.Part.Color = Color3.new()
			else
				part.Part.Material = "SmoothPlastic"
				part.Part.Color = Color3.fromRGB(205, 205, 205)
			end
		end
	end
end

function Extend:__updateWidth()
	local width = self.Width

	for _, segment in pairs(self.Segments) do
		for _, part in pairs(segment.Parts) do
			local part2 = part.Part
			part2.Size = part2:GetAttribute("Size") * width
		end

		for _, joint in pairs(segment.Joints) do
			joint.Object.C0 = Util.Misc.scaleCF(joint.C0, width)
			joint.Object.C1 = Util.Misc.scaleCF(joint.C1, width)
		end

		for _, _ in pairs(segment.Bones) do

		end
	end
end

function Extend:update(_)
	local width = self.Width
	self:__paint()
	local __getCFrame = self:__getCFrame()
	local count = #self.Segments

	if count == 1 then
		self:__updateWidth()

		for _, segment in pairs(self.Segments) do
			segment.Bones.Bone.Position = segment.Bones.Direction * math.max(
				0.66,
				self.CurrentLength - 10.447999954223633 * width
			)
			segment.Model:SetPrimaryPartCFrame(__getCFrame * CFrame.new(0, 0, -4.440399980545044))
		end
	else
		local v3 = math.clamp(math.floor(count * (self.CurrentLength / self.Length)) + 1, 1, count)

		for k, segment in pairs(self.Segments) do
			if k == v3 then
				segment.Model:SetPrimaryPartCFrame(__getCFrame * CFrame.new(0, 0, -4.440399980545044))
				segment.Model.Parent = self.ModelCache
			else
				segment.Model.Parent = nil
			end
		end
	end
end

function Extend:extend(p, p2)
	if not p then
		return
	end

	local v3 = p2 or self.Length
	local _ = self.Width
	self.CurrentLength = v3 * p
end

function Extend:__refresh(p)
	self:extend(p and 1 or 0)
end

function Extend:Destroy()
	for _, event in pairs(self.Events) do
		event:Destroy()
	end

	if self.FastMode then
		Return(self.Side, self.Segments, self.Width, self.Length) -- equivalent call inferred; original call site unknown
	else
		Return2(self.Side, self.Segments) -- equivalent call inferred; original call site unknown
	end

	if #self.ModelCache:GetChildren() == 0 then
		self.ModelCache:Destroy()
	end
end

return Extend