local createVector = vector.create
local MeshEmit = {}
MeshEmit.__index = MeshEmit
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
require(script.Types)

-- equivalent calls inferred from this helper; original call sites unknown
local function GetType(p)
	if p.Start:IsA("Part") and p.Start:FindFirstChildOfClass("SpecialMesh") then
		return "SpecialMesh"
	end

	return "Mesh"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetPartType(part)
	if part:IsA("Part") and part:FindFirstChildOfClass("SpecialMesh") then
		return "SpecialMesh"
	end

	return "Mesh"
end

local function RetrieveSettings(object)
	return (object:GetAttributes())
end

local function RotateMesh(clone, rotationSpeed: number, lifetime: number)
	local heartbeatConnection = RunService.Heartbeat:Connect(function(_)
		clone.CFrame *= CFrame.Angles(0, math.rad(rotationSpeed), 0)
	end)
	task.delay(lifetime, function()
		heartbeatConnection:Disconnect()
	end)
end

local function GenerateInRange(range: NumberRange)
	if range then
		return math.random(range.Min, range.Max)
	end

	return 0
end

local function RetrieveProperities(part)
	local v = {}

	if GetPartType(part) == "SpecialMesh" then
		local specialMesh = part:FindFirstChildOfClass("SpecialMesh")

		if not specialMesh then
			return {}
		end

		v.Scale = specialMesh.Scale
	else
		v.Size = part.Size
	end

	v.Position = part.CFrame.Position
	return v
end

function MeshEmit.new(model)
	return (setmetatable({
		Model = model,
		Type = GetType(model),
		Properities = RetrieveProperities(model.Start),
		EndProperities = RetrieveProperities(model.End),
		Settings = model:GetAttributes()
	}, MeshEmit))
end

function MeshEmit:SetFlipbook(moduleScript)
	self.__Flipbook = require(moduleScript)
end

function MeshEmit.RandomizeSize(p, vector2: Vector3, vector3: Vector3)
	if p.Type == "SpecialMesh" then
		p.EndProperities.Scale = Vector3.new(
			math.random(vector2.X, vector3.X),
			math.random(vector2.Y, vector3.Y),
			math.random(vector2.Z, vector3.Z)
		)
	else
		p.EndProperities.Size = Vector3.new(
			math.random(vector2.X, vector3.X),
			math.random(vector2.Y, vector3.Y),
			math.random(vector2.Z, vector3.Z)
		)
	end
end

function MeshEmit:PlayFlipbook(instance)
	local __Flipbook = self.__Flipbook

	if not __Flipbook then
		return
	end

	local v = 1
	local total = 0
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		total += dt

		if total >= (1 / self.Settings.FlipbookRate or 0.016666666666666666) then
			v += 1

			if v > #__Flipbook then
				heartbeatConnection:Disconnect()
				return
			end

			if self.Type == "SpecialMesh" then
				local decal = instance:FindFirstChildOfClass("Decal")

				if not decal then
					return
				end

				decal.Texture = __Flipbook[v]
			else
				instance.TextureId = __Flipbook[v]
			end

			total = 0
		end
	end)
end

function MeshEmit:Emit(p)
	local lifetime = self.Settings.Lifetime
	local v = Enum.EasingStyle[self.Settings.EasingStyle]
	local v2 = Enum.EasingDirection[self.Settings.EasingDirection]
	local transparency = self.Settings.Transparency or 1
	local startTransparency = self.Settings.StartTransparency or 1
	local rotationX = self.Settings.RotationX
	local v3 = not rotationX and 0 or math.random(rotationX.Min, rotationX.Max)
	local rotationY = self.Settings.RotationY
	local v4 = not rotationY and 0 or math.random(rotationY.Min, rotationY.Max)
	local rotationZ = self.Settings.RotationZ
	local v5 = not rotationZ and 0 or math.random(rotationZ.Min, rotationZ.Max)
	local tweenInfo = TweenInfo.new(lifetime, v, v2)
	local clone = self.Model.Start:Clone()
	self:PlayFlipbook(clone)
	clone.CFrame = (typeof(p) == "CFrame" and p or p.CFrame) * CFrame.Angles(math.rad(v3), math.rad(v4), (math.rad(v5)))
	clone.Parent = workspace.Thrown
	Debris:AddItem(clone, lifetime)
	local objectSpace = self.Model.Start.CFrame:ToObjectSpace(self.Model.End.CFrame)
	self.EndProperities.Position = nil

	if self.Settings.RotationSpeed then
		RotateMesh(clone, self.Settings.RotationSpeed, lifetime)
	end

	if self.Type == "SpecialMesh" then
		local specialMesh = clone:FindFirstChildOfClass("SpecialMesh")
		local decal = clone:FindFirstChildOfClass("Decal")

		if specialMesh then
			local tween = TweenService:Create(specialMesh, tweenInfo, self.EndProperities)
			local tween2 = TweenService:Create(clone, tweenInfo, {
				CFrame = clone.CFrame * objectSpace
			})
			tween:Play()
			tween2:Play()
			tween.Completed:Once(function()
				specialMesh.Scale = self.Properities.Scale or createVector(1, 1, 1)
				clone.Transparency = 1
			end)
		end

		if decal then
			decal.Transparency = startTransparency
			TweenService:Create(
				decal,
				TweenInfo.new(
					lifetime,
					Enum.EasingStyle[self.Settings.TransparencyEasingStyle],
					Enum.EasingDirection[self.Settings.TransparencyEasingDirection]
				),
				{
					Transparency = transparency,
					Color3 = self.Model.End:FindFirstChildOfClass("Decal").Color3
				}
			):Play()
		end
	else
		clone.Transparency = startTransparency
		TweenInfo.new(
			lifetime,
			Enum.EasingStyle[self.Settings.TransparencyEasingStyle],
			Enum.EasingDirection[self.Settings.TransparencyEasingDirection]
		)

		if self.Settings.Movement then
			self.EndProperities.CFrame = clone.CFrame * objectSpace
		end

		self.EndProperities.Transparency = transparency
		local tween = TweenService:Create(clone, tweenInfo, self.EndProperities)
		tween:Play()
		tween.Completed:Once(function()
			clone.Size = self.Properities.Size or createVector(1, 1, 1)
			clone.Transparency = 1
		end)
	end
end

function MeshEmit:EmitRate(p: number, duration: number, p2)
	local total = 0
	local heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		total += dt
		local v = total

		if p / 60 < v then
			total = 0
			self:Emit(p2)
		end
	end)
	task.delay(duration, function()
		heartbeatConnection:Disconnect()
	end)
	return heartbeatConnection
end

local function computeSpawnCFrame(p, instance)
	local v = typeof(p) == "CFrame" and p or p.CFrame

	if instance then
		local offset = instance:GetAttribute("Offset")

		if typeof(offset) == "Vector3" then
			return v * CFrame.new(offset)
		end
	end

	return v
end

function MeshEmit.EmitAt(p, instance)
	local v = MeshEmit.new(instance)
	local v2 = typeof(p) == "CFrame" and p or p.CFrame

	if instance then
		local offset = instance:GetAttribute("Offset")

		if typeof(offset) == "Vector3" then
			v2 *= CFrame.new(offset)
		end
	end

	v:Emit(v2)
end

function MeshEmit.EnableAt(p: number, p2: number, instance, p3)
	local v = MeshEmit.new(instance)
	local v2 = typeof(p3) == "CFrame" and p3 or p3.CFrame

	if instance then
		local offset = instance:GetAttribute("Offset")

		if typeof(offset) == "Vector3" then
			v2 *= CFrame.new(offset)
		end
	end

	v:EmitRate(p, p2, v2)
end

return MeshEmit