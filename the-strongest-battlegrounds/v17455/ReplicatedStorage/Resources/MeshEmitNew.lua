local createVector = vector.create
local MeshEmitNew = {}
MeshEmitNew.__index = MeshEmitNew
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
game:GetService("Debris")
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

function MeshEmitNew.new(model)
	return (setmetatable({
		Model = model,
		Type = GetType(model),
		Properities = RetrieveProperities(model.Start),
		EndProperities = RetrieveProperities(model.End),
		Settings = model:GetAttributes()
	}, MeshEmitNew))
end

function MeshEmitNew:Emit(p)
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
	task.delay(lifetime or 10, function()
		if clone then
			clone:Destroy("")
		end
	end)
	clone.CFrame = (typeof(p) == "CFrame" and p or p.CFrame) * CFrame.Angles(math.rad(v3), math.rad(v4), (math.rad(v5)))
	clone.Parent = workspace.Thrown
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
					Transparency = transparency
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

function MeshEmitNew:EmitRate(p: number, duration: number, p2)
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
end

return MeshEmitNew