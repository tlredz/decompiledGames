local createVector = vector.create
local parent = script.Parent
local children = parent.CylinderVerticalRig:GetChildren()
local descendants = parent:GetDescendants()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Util.SkinnedCylinder)
local Util = require(game.ReplicatedStorage.Util)
local heartbeatLoopFor = Util.HeartbeatLoopFor.HeartbeatLoopFor
local Quality = require(game.ReplicatedStorage.Modules.Quality)

-- equivalent calls inferred from this helper; original call sites unknown
local function createFrameSkipper()
	local v = 1
	return function(p)
		local v2 = 60 / p
		v += 1

		if v2 <= v then
			v -= v2
			return false
		else
			return true
		end
	end
end

local function naturalSort(p, p2)
	local function extractNumber(name)
		local match = name:match("(%d+%.?%d*)")

		if match == nil then
			warn("Warning: No number found in: " .. name)
			return 0
		end

		local v = select(2, match:gsub("%.", ""))

		if v > 1 then
			warn("Warning: More than one dot in number in: " .. name)
			match = match:gsub("%.", "", v - 1)
		end

		local match2 = name:match("(%d+)%D+%d+")

		if match2 ~= nil and not name:match("(%d+%.%d+)") then
			warn("Warning: Numbers separated by non-dot characters in: " .. name)
			match = match2
		end

		return (tonumber(match))
	end

	return extractNumber(p.Name) < extractNumber(p2.Name)
end

table.sort(children, naturalSort)
local v = {}

for i, bone in ipairs(children) do
	if not bone:IsA("Bone") then
		table.remove(children, i)
	end
end

local worldCFrames = {}

for i, v2 in ipairs(children) do
	worldCFrames[i] = v2.WorldCFrame
end

local clones = {}

for i, parent2 in ipairs(children) do
	if i % 2 ~= 0 then
		continue
	end

	local clone = script.ParticleEmitter:Clone()
	clone.Enabled = false
	table.insert(clones, clone)
	clone.Parent = parent2
end

for i, v2 in ipairs(clones) do
	v2.Rate = math.floor(20 * (1 - i / #clones))

	if i % 3 == 0 then
		v2.Orientation = Enum.ParticleOrientation.FacingCamera
		v2.LockedToPart = true
		v2.Speed = NumberRange.new(0)
		v2.RotSpeed = NumberRange.new(400)
		v2.Color = ColorSequence.new(parent.CylinderVerticalRig.Color)
		v2.LightEmission = 0
		v2.LightInfluence = 0.2
		v2.Brightness = 0.1
		v2.ZOffset += -22
	end

	if i % 3 == 0 then
		v2.Speed = NumberRange.new(0)
	end
end

parent.Ring.ParticleEmitter.Enabled = false
local clones2 = {}
local clone = parent.Ring:Clone()
clone.Parent = parent
table.insert(clones2, clone)
local clone2 = parent.Ring:Clone()
clone2.Parent = parent
table.insert(clones2, clone2)
local clone3 = parent.Ring:Clone()
clone3.Parent = parent
table.insert(clones2, clone3)
parent.Ring:Destroy()
local count = #children

local function spaceCurve(p, p2)
	return (Vector3.new(14 * p * math.cos(6.283185307179586 * p - p2), p, 14 * p * math.sin(6.283185307179586 * p - p2)))
end

local pivotPoint = parent.PivotPoint
local v2 = 1 * (worldCFrames[count].Position - worldCFrames[1].Position).Y
local v3 = 0
local inverse = CFrame.lookAt(createVector(0, 0, 0), createVector(0, 1, 0)):Inverse()
local v4 = createVector(1, 1, 1) * (0 / 0)
local v5 = math.random() * 7 * 10
local frameSkipper = createFrameSkipper() -- equivalent call inferred; original call site unknown
local v6 = 60
local v7 = time()
local RunService = game:GetService("RunService")
v.verticalCylinderConnection = RunService.Heartbeat:Connect(function()
	if frameSkipper(v6) then
		return
	end

	local v8 = (time() - v7) * 7 + v5
	local position = pivotPoint.Position

	if v3 > 0.1 then
		for i, v9 in ipairs(children) do
			local v10 = (i - 1) / (count - 1)
			local v11 = position + Vector3.new(1, v3, 1) * Vector3.new(
				14 * v10 * math.cos(6.283185307179586 * v10 - v8),
				v10,
				14 * v10 * math.sin(6.283185307179586 * v10 - v8)
			)
			local lookVector = (CFrame.lookAt(createVector(0, 0, 0), v11 - position) * CFrame.Angles(
				0.3490658503988659,
				0,
				0
			)).LookVector

			if lookVector == lookVector then
				v9.WorldCFrame = CFrame.lookAt(createVector(0, 0, 0), lookVector) * inverse + v11
			else
				v9.WorldCFrame = CFrame.Angles(0, v8, 0) + v11
			end
		end
	else
		for _, v9 in ipairs(children) do
			v9.WorldCFrame = CFrame.new(v4)
		end
	end

	for i = 1, 3 do
		clones2[i].CFrame = children[math.ceil(i * count / 3)].WorldCFrame * CFrame.Angles(0, v8, 0) * inverse
	end
end)
local v8 = 1
parent.SplashMesh:Destroy()
local v9 = math.clamp(parent.FadeInInterpolant.Value, 0, 1)
v.fadeInChanged = parent.FadeInInterpolant:GetPropertyChangedSignal("Value"):Connect(function()
	local v10 = math.clamp(parent.FadeInInterpolant.Value, 0, 1)

	if v10 <= 0 then
		for _, effect in ipairs(descendants) do
			if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
				effect.Enabled = false
			end
		end
	elseif v10 >= 1 then
		for _, effect in ipairs(descendants) do
			if effect:IsA("ParticleEmitter") then
				effect.Enabled = true
			elseif effect:IsA("Beam") then
				effect.Enabled = true
				effect.Transparency = NumberSequence.new(0)
			end
		end
	else
		local v11 = 1 - v10

		for _, effect in ipairs(descendants) do
			if effect:IsA("ParticleEmitter") then
				effect.Enabled = true
			elseif effect:IsA("Beam") then
				effect.Enabled = true
				effect.Transparency = NumberSequence.new(v11)
			end
		end
	end

	if v9 <= 0.25 and v10 > 0.25 then
		parent.PivotPoint.Attachment.OuterRing:Emit(1)

		for _, v11 in ipairs(children) do
			local particleEmitter = v11:FindFirstChild("ParticleEmitter")

			if particleEmitter then
				particleEmitter.Enabled = true
			end
		end

		for _, v11 in ipairs(clones2) do
			local particleEmitter = v11:FindFirstChild("ParticleEmitter")

			if particleEmitter then
				particleEmitter.Enabled = true
			end
		end
	elseif v9 >= 0.25 and v10 < 0.25 then
		for _, v11 in ipairs(children) do
			local particleEmitter = v11:FindFirstChild("ParticleEmitter")

			if particleEmitter then
				particleEmitter.Enabled = false
			end
		end

		for _, v11 in ipairs(clones2) do
			local particleEmitter = v11:FindFirstChild("ParticleEmitter")

			if particleEmitter then
				particleEmitter.Enabled = false
			end
		end
	end

	v3 = v2 * v10
	v9 = v10
end)
parent.FadeInInterpolant.Value = 0
local v10 = 600
local v11 = 2000
local v12 = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function updateQuality()
	local v13 = math.max(3, Quality:GetQuality().auto.Value) / Quality.MAX_GUI_SETTING
	v12 = 1 - v13
	v10 = math.clamp(v13 * 600, 300, 600)
	v11 = math.clamp(v13 * 2000, 1000, 2000)
	return v12
end

local v13 = math.max(3, Quality:GetQuality().auto.Value) / Quality.MAX_GUI_SETTING
v12 = 1 - v13
v10 = math.clamp(v13 * 600, 300, 600)
v11 = math.clamp(v13 * 2000, 1000, 2000)
local v14 = math.clamp(parent.LODInterpolant.Value, v12, 1)
v.LODChanged = parent.LODInterpolant:GetPropertyChangedSignal("Value"):Connect(function()
	local v15 = math.clamp(parent.LODInterpolant.Value, v12, 1)
	v6 = math.clamp(math.ceil((1 - v15) * 60), 1, 60)
	local transparency = math.clamp((v15 - 0.8) / 0.19999999999999996, 0, 1)

	if v14 >= 0.8 then
		parent.CylinderVerticalRig.Transparency = transparency
	end

	v14 = v15
end)
parent.LODInterpolant.Value = v12
v.CameraLODUpdate = heartbeatLoopFor(100000, function()
	local v15 = ((workspace.CurrentCamera.CFrame.Position - parent.PivotPoint.Position).Magnitude - v10) / (v11 - v10)
	local v16 = math.clamp(v15, updateQuality(), 1)
	parent.LODInterpolant.Value = v16
end)
local size = parent.PrimaryPart.Size
parent.PrimaryPart:GetPropertyChangedSignal("Size"):Connect(function()
	local X = (parent.PrimaryPart.Size / size).X
	v8 *= X
	v3 *= X
	size = parent.PrimaryPart.Size
end)
local v15 = nil
local TweenService = game:GetService("TweenService")
local TornadoLogic = {
	Model = parent,
	_Destroyed = false
}

local function cleanup(scope)
	if scope._Destroyed then
		return
	end

	scope._Destroyed = true

	for _, connection in pairs(v) do
		connection:Disconnect()
	end

	table.clear(v)

	if scope.Model and scope.Model.Parent then
		scope.Model:Destroy()
	end

	scope.Model = nil
end

function TornadoLogic:Tween(p2, value)
	if self._Destroyed then
		return
	end

	if v15 then
		v15:Cancel()
		v15 = nil
	end

	v15 = TweenService:Create(parent.FadeInInterpolant, TweenInfo.new(value or 0.5, Enum.EasingStyle.Cubic), {
		Value = p2
	})
	v15:Play()
	return v15
end

function TornadoLogic:Destroy(p)
	if not p then
		cleanup(self)
		return
	end

	local tween = self:Tween(0, p)

	if tween then
		tween.Completed:Connect(function()
			cleanup(self)
		end)
	end
end

return TornadoLogic