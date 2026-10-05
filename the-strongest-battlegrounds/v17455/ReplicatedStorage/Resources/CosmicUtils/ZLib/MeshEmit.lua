local createVector = vector.create
local MeshEmit = {}
MeshEmit.__index = MeshEmit
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local debris = game.Debris
local VFX = workspace:FindFirstChild("VFX") or workspace:FindFirstChild("Thrown") or workspace
local new = CFrame.new
local angles = CFrame.Angles
local rad = math.rad
local random = math.random
local new2 = TweenInfo.new
local easingStyle = Enum.EasingStyle
local easingDirection = Enum.EasingDirection
require(script.Types)

local function GetType(instance)
	local type = instance:GetAttribute("Type")

	if typeof(type) == "string" then
		return type
	end

	if instance.Start:IsA("Part") and instance.Start:FindFirstChildOfClass("SpecialMesh") then
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

local function GenerateInRange(range: NumberRange)
	if range then
		return random(range.Min, range.Max)
	end

	return 0
end

local function RetrieveProperities(start, part)
	local v = {}

	if GetPartType(part) == "SpecialMesh" then
		local specialMesh = part:FindFirstChildOfClass("SpecialMesh")

		if specialMesh then
			v.Scale = specialMesh.Scale
			return v
		end

		if start.Size ~= part.Size then
			v.Size = part.Size
		end

		if start.Color ~= part.Color then
			v.Color = part.Color
			return v
		end
	else
		if start.Size ~= part.Size then
			v.Size = part.Size
		end

		if start.Color ~= part.Color then
			v.Color = part.Color
		end
	end

	return v
end

local v = {}
local v2 = {}
local v3 = {}
local preRenderConnection = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function StartMasterLoop()
	if preRenderConnection then
		return
	end

	preRenderConnection = RunService.PreRender:Connect(function(dt)
		for i = #v, 1, -1 do
			local v4 = v[i]
			v4.Passed += dt

			if v4.Passed >= v4.Rate then
				v4.Passed = 0
				v4.Emitter:Emit(v4.CFrame)
			end

			v4.TimeLeft -= dt

			if not (v4.TimeLeft <= 0) then
				continue
			end

			v4.Emitter.RateAdd = nil
			table.remove(v, i)
		end

		for i = #v2, 1, -1 do
			local v4 = v2[i]
			v4.Part.CFrame *= angles(0, rad(v4.Speed), 0)
			v4.TimeLeft -= dt

			if v4.TimeLeft <= 0 then
				table.remove(v2, i)
			end
		end

		for i = #v3, 1, -1 do
			local v4 = v3[i]
			local value = math.round(v4.Frame.Value)

			if #v4.Frames <= value then
				table.remove(v3, i)
				v4.Frame:Destroy()
			end

			v4.Decal.Texture = v4.Frames[value]
		end

		if #v == 0 and #v2 == 0 and #v3 == 0 and preRenderConnection ~= nil then
			preRenderConnection:Disconnect()
			preRenderConnection = nil
		end
	end)
end

function MeshEmit.new(instance)
	local type = instance:GetAttribute("Type")

	if typeof(type) ~= "string" then
		type = instance.Start:IsA("Part") and instance.Start:FindFirstChildOfClass("SpecialMesh") and "SpecialMesh" or "Mesh"
	end

	local v4 = {
		Model = instance,
		Type = type,
		EndProperities = RetrieveProperities(instance.Start, instance.End),
		Settings = instance:GetAttributes()
	}
	return (setmetatable(v4, MeshEmit))
end

function MeshEmit.RandomizeSize(p, vector2: Vector3, vector3: Vector3)
	if p.Type == "SpecialMesh" then
		p.EndProperities.Scale = new(
			random(vector2.X, vector3.X),
			random(vector2.Y, vector3.Y),
			random(vector2.Z, vector3.Z)
		)
	else
		p.EndProperities.Size = new(
			random(vector2.X, vector3.X),
			random(vector2.Y, vector3.Y),
			random(vector2.Z, vector3.Z)
		)
	end
end

function MeshEmit:RotateMesh(part, speed: number, timeLeft: number)
	if speed <= 0 then
		return
	end

	table.insert(v2, {
		Part = part,
		Speed = speed,
		TimeLeft = timeLeft
	})
	StartMasterLoop() -- equivalent call inferred; original call site unknown
end

function MeshEmit:PlayFlipbook(instance)
	local __Flipbook = self.__Flipbook

	if not __Flipbook then
		return
	end

	local decal = instance:FindFirstChildOfClass("Decal")
	local v4 = Enum.EasingStyle[self.Settings.EasingStyle]
	local v5 = Enum.EasingDirection[self.Settings.EasingDirection]
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = 1
	table.insert(v3, {
		Decal = decal,
		Frame = numberValue,
		Frames = __Flipbook
	})

	if self.Settings.FlipbookRate then
		TweenService:Create(numberValue, new2(1 / self.Settings.FlipbookRate * #__Flipbook, 0, v5), {
			Value = #__Flipbook
		}):Play()
	else
		TweenService:Create(numberValue, new2(self.Settings.Lifetime, v4, v5), {
			Value = #__Flipbook
		}):Play()
	end

	StartMasterLoop() -- equivalent call inferred; original call site unknown
end

function MeshEmit:Emit(cFrame)
	if typeof(cFrame) ~= "CFrame" then
		if cFrame == nil or cFrame.Parent == nil then
			self:Destroy()
			return
		else
			cFrame = cFrame.CFrame
		end
	end

	local lifetime = self.Settings.Lifetime
	local v4 = easingStyle[self.Settings.EasingStyle]
	local v5 = easingDirection[self.Settings.EasingDirection]
	local transparency = self.Settings.Transparency or 1
	local startTransparency = self.Settings.StartTransparency or 1
	local rotationX = self.Settings.RotationX
	local v6 = not rotationX and 0 or random(rotationX.Min, rotationX.Max)
	local rotationY = self.Settings.RotationY
	local v7 = not rotationY and 0 or random(rotationY.Min, rotationY.Max)
	local rotationZ = self.Settings.RotationZ
	local v8 = not rotationZ and 0 or random(rotationZ.Min, rotationZ.Max)
	local tweenInfo = new2(lifetime, v4, v5)
	local clone = self.Model.Start:Clone()
	local moduleScript = self.Model:FindFirstChildOfClass("ModuleScript")

	if moduleScript then
		self.__Flipbook = require(moduleScript)
		self:PlayFlipbook(clone)
	end

	clone.CFrame = cFrame * new(self.Model:GetAttribute("Offset") or createVector(0, 0, 0)) * angles(
		rad(v6),
		rad(v7),
		(rad(v8))
	)
	clone.Parent = VFX
	debris:AddItem(clone, lifetime)
	local objectSpace = self.Model.Start.CFrame:ToObjectSpace(self.Model.End.CFrame)

	if self.Settings.RotationSpeed then
		self:RotateMesh(clone, self.Settings.RotationSpeed, lifetime)
	end

	if self.Type == "SpecialMesh" then
		local specialMesh = clone:FindFirstChildOfClass("SpecialMesh")
		local decal = clone:FindFirstChildOfClass("Decal")

		if decal then
			decal.Transparency = startTransparency
			TweenService:Create(
				decal,
				new2(
					lifetime,
					easingStyle[self.Settings.TransparencyEasingStyle],
					easingDirection[self.Settings.TransparencyEasingDirection]
				),
				{
					Transparency = transparency,
					Color3 = self.Model.End:FindFirstChildOfClass("Decal").Color3
				}
			):Play()

			if specialMesh then
				TweenService:Create(specialMesh, tweenInfo, self.EndProperities):Play()
				TweenService:Create(clone, tweenInfo, {
					CFrame = clone.CFrame * objectSpace
				}):Play()
			else
				if self.Settings.Movement then
					self.EndProperities.CFrame = clone.CFrame * objectSpace
				end

				TweenService:Create(clone, tweenInfo, self.EndProperities):Play()
			end
		end
	else
		clone.Transparency = startTransparency
		new2(
			lifetime,
			easingStyle[self.Settings.TransparencyEasingStyle],
			easingDirection[self.Settings.TransparencyEasingDirection]
		)

		if self.Settings.Movement then
			self.EndProperities.CFrame = clone.CFrame * objectSpace
		end

		self.EndProperities.Transparency = transparency
		TweenService:Create(clone, tweenInfo, self.EndProperities):Play()
	end
end

function MeshEmit:EmitRate(p2: number, timeLeft: number, cFrame)
	local rate = p2 / 60
	local rateAdd = {
		Emitter = self,
		Rate = rate,
		TimeLeft = timeLeft,
		CFrame = cFrame,
		Passed = rate + 1
	}
	self.RateAdd = rateAdd
	table.insert(v, rateAdd)
	StartMasterLoop() -- equivalent call inferred; original call site unknown
end

function MeshEmit:Destroy()
	if self.Destroyed then
		return
	end

	local index = table.find(v, self.RateAdd)

	if index then
		table.remove(v, index)
	end

	table.clear(self)
	self.Destroyed = true
end

local BeamEmit = require(script.Parent:WaitForChild("BeamEmit"))

function MeshEmit:QuickEmit(model, p)
	if model:FindFirstChildWhichIsA("Beam", true) then
		local rotationX = model:GetAttribute("RotationX")
		local v4 = not rotationX and 0 or random(rotationX.Min, rotationX.Max)
		local rotationY = model:GetAttribute("RotationY")
		local v5 = not rotationY and 0 or random(rotationY.Min, rotationY.Max)
		local rotationZ = model:GetAttribute("RotationZ")
		local v6 = not rotationZ and 0 or random(rotationZ.Min, rotationZ.Max)
		model.CFrame = (typeof(p) == "CFrame" and p or p.CFrame) * CFrame.new(model:GetAttribute("Offset")) * CFrame.Angles(
			math.rad(v4),
			math.rad(v5),
			(math.rad(v6))
		)
		return BeamEmit(model, {
			Properties = {
				Brightness = model:GetAttribute("Brightness"),
				LightEmission = model:GetAttribute("LightEmission", 1),
				TextureSpeed = model:GetAttribute("TextureSpeed", 0.45),
				Width0 = model:GetAttribute("Width0", 2),
				Width1 = model:GetAttribute("Width", 15)
			},
			RotationSpeed = model:GetAttribute("RotationSpeed"),
			Rotation = model:GetAttribute("Rotation"),
			Offset = model:GetAttribute("FinalOffset"),
			Duration = model:GetAttribute("Duration"),
			Easing = model:GetAttribute("Easing"),
			EasingDirection = model:GetAttribute("EasingDirection")
		}, model.CFrame)
	else
		if not model:IsA("Model") then
			return
		end

		local v4 = MeshEmit.new(model)
		local duration = model:GetAttribute("Duration")
		local rate = model:GetAttribute("Rate")

		if duration and rate then
			v4:EmitRate(rate, duration, p)
			return v4
		end

		v4:Emit(p)
		v4:Destroy()
	end
end

function MeshEmit:GroupEmit(items, p)
	local result = {}
	local result2 = {}

	for _, item in items do
		local quickEmit = self:QuickEmit(item, p)

		if typeof(quickEmit) == "table" then
			table.insert(result2, quickEmit)
		elseif typeof(quickEmit) == "Instance" then
			table.insert(result, quickEmit)
		end
	end

	return result2, result
end

return MeshEmit