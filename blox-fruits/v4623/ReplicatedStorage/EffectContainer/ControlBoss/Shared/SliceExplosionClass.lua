local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local shared = script.Parent.Parent.Shared
local utility = shared.Utility
local VisualHelper = require(utility.VisualHelper)
local MathHelper = require(utility.MathHelper)
require(shared.Textures)
local Rocks = require(shared.Rocks)
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local cDagger = FX:WaitForChild("ControlRework").CDagger
local _ = workspace._WorldOrigin
local HexsStormClass = require(script.Parent.Parent.Shared:WaitForChild("HexsStormClass"))
local maid = Util.Maid
local lightningBoltShafi = Util.LightningBoltShafi
local _ = workspace.CurrentCamera
local cameraShaker = Util.CameraShaker

function Debris(p, p2: number)
	Util.Debris:AddItem(p, p2)
end

local random = Random.new()
local SliceExplosionClass = {
	TemplateModel = FX:WaitForChild("ControlRework"):WaitForChild("Gameplay"):WaitForChild("SliceExplosionClassModel"),
	Stored = {}
}
SliceExplosionClass.__index = SliceExplosionClass
local HttpService = game:GetService("HttpService")
local model = nil

function SliceExplosionClass.new(_, parent, player, cframe: CFrame?, value: number?, p2: number?, proxy)
	local maid2 = maid.new()
	model = Instance.new("Model", parent)
	local model2 = maid2:GiveTask(SliceExplosionClass.TemplateModel:Clone())
	model2.Name = `Slice-Explosion-Model: {HttpService:GenerateGUID()}`
	model2.Parent = model
	local attachment = Instance.new("Attachment", model2.Main)
	attachment.Name = "Link"
	local boltExplosion = maid2:GiveTask(cDagger.Phase2.BoltExplosionBig:Clone())
	boltExplosion.Parent = model
	local object = setmetatable({
		Player = player,
		Maid = maid2,
		DebrisTime = 0,
		Model = model2,
		Impact = model2.Impact,
		BeamsPackets = { model2.Main.Beams:GetChildren(), model2.Main.Winds:GetChildren() },
		HexsStorm = maid2:GiveTask(HexsStormClass.new(model2.Main)),
		BoltExplosion = boltExplosion,
		Proxy = proxy
	}, SliceExplosionClass)

	for i = -1, 1, 0.1 do
		object.HexsStorm:AddHex(i > 0.3 and "Gradient" or "Normal", i, 0, i * 360, random:NextNumber(50, 450))
	end

	for _, child in object.Impact.Meshs:GetChildren() do
		local transparency = child.Decal.Transparency
		child.Decal.Transparency = 1
		child:SetAttribute("Transparency", transparency)
	end

	if cframe then
		object:PivotTo(cframe)
		object:EmitWave(true)
	end

	object:ScaleTo(value or 1)
	object:ResetTime(p2)
	maid2:GiveTask(RunService.Heartbeat:Connect(function(dt)
		object:Update(dt)
	end))
	SliceExplosionClass.Stored[model2] = object
	return object
end

function SliceExplosionClass:PivotTo(cframe: CFrame?)
	local pivot = cframe or CFrame.new()
	self.Pivot = pivot
	local model2 = self.Model
	local floor = model2.Main.Floor
	model2:PivotTo(pivot * CFrame.new(0, 25, 0))
	floor.WorldCFrame = pivot * CFrame.new(0, 0.75, 0)
end

function SliceExplosionClass:Update(p: number)
	self.DebrisTime += p
	self.HexsStorm:Update(p)
	local model2 = self.Model

	for _, beamsPacket in self.BeamsPackets do
		for _, v in beamsPacket do
			v.CFrame *= CFrame.Angles(0, math.rad(p * 260), 0)
		end
	end

	local v = math.abs(math.sin(os.clock() * 6) * 10)

	for _, v2 in self.HexsStorm.Data do
		v2.Range = v2.DefaultRange + v
	end

	if self.DebrisTime < 0.08 then
		return
	end

	self.DebrisTime = 0
	cameraShaker:Shake("Fast")
	local v2 = model2.Main.Size.X / 2
	local clone = cDagger.Phase2.SliceGround:Clone()
	clone:ScaleTo(random:NextNumber(0.8, 3.5))
	clone:PivotTo(self.Pivot * CFrame.new(math.random(-v2, v2), 0.2, math.random(-v2, v2)) * CFrame.Angles(
		0,
		math.rad((math.random(360))),
		0
	))
	clone.Parent = model
	VisualHelper:EmitAll(clone)
	local size = clone.SliceGround.Size
	clone.SliceGround.Size = createVector(0, 0, 0)
	VisualHelper:Tween(clone.SliceGround, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
		Size = size
	})
	task.delay(0.15, function()
		VisualHelper:Tween(clone.SliceGround.Decal, TweenInfo.new(0.2), {
			Color3 = Color3.fromRGB()
		})
		VisualHelper:Tween(clone.SliceGround, TweenInfo.new(0.25), {
			Size = Vector3.new(0, 0, clone.SliceGround.Size.Z)
		})
		task.wait(0.25)
		clone:Destroy()
	end)
	self.ThunderTime = not self.ThunderTime

	if not self.ThunderTime then
		return
	end

	local boltExplosion = self.BoltExplosion
	local v3 = v2 + 55
	local v4 = self.Pivot * CFrame.Angles(0, math.random() * 3.141592653589793 * 2, 0) * CFrame.new(
		0,
		1,
		-math.random(v2, v3)
	)
	local rayCast = MathHelper:RayCast(v4.Position, v4.UpVector * -10, { model }, Enum.RaycastFilterType.Exclude)

	if rayCast then
		boltExplosion.CFrame = CFrame.new(rayCast.Position + createVector(0, 0.05, 0))
		VisualHelper:EmitAll(boltExplosion)
	end

	local v5 = v2 * 4

	for i = 1, 3 do
		local v6 = 0.2 + math.random(5) * 0.03 - i * 0.05
		local position2 = model2.Main.Position + Vector3.new(
			math.random(-v5, v5),
			math.random(-v5, v5),
			math.random(-v5, v5)
		)
		local position = model2.Main.Position
		local clone2 = cDagger.Phase2.Vault.HexTrailSpecsMove2:Clone()
		clone2.Parent = workspace.Terrain
		clone2.Position = position2
		Debris(clone2, v6 + 0.5)
		local magnitude = (position2 - position).Magnitude
		local cframe = CFrame.lookAt(position2, position)
		local v12 = cframe * CFrame.new(math.random(-65, 65), math.random(-65, 65), -magnitude * 0.25).Position
		local v13 = cframe * CFrame.new(math.random(-65, 65), math.random(-65, 65), -magnitude * 0.75).Position
		VisualHelper:TweenNumberValue(1, TweenInfo.new(v6, Enum.EasingStyle.Sine), function(p2: number)
			clone2.Position = MathHelper:CubicBezier(p2, position2, v12, v13, position)
		end)
	end
end

function SliceExplosionClass:ScaleTo(p: number)
	local model2 = self.Model
	model2:ScaleTo(p)
	self.HexsStorm.YFactor = model2.Main.Size.Y / 2

	for k, v in self.HexsStorm.Data do
		v.Range = model2.Main.Size.X / 1.9
		VisualHelper:Tween(k, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
			Size = createVector(7.743, 0, 6.669) * p
		})
		v.DefaultRange = v.Range
	end

	local function NewBolt(p2, p3, value: number?)
		local v = lightningBoltShafi.new(p2, p3, value or 35, p * 0.7, model)
		local curveSize = -math.random(5, 7)
		local curveSize2 = math.random(5, 7)
		v.CurveSize0 = curveSize
		v.CurveSize1 = curveSize2
		v.MinRadius = 1
		v.MaxRadius = 3
		v.Frequency = 0.5
		v.AnimationSpeed = math.random(5, 9)
		local maxThicknessMultiplier = 0.3 + math.random() * 0.75
		v.MinThicknessMultiplier = 0.1
		v.MaxThicknessMultiplier = maxThicknessMultiplier
		v.MinTransparency = 0
		v.MaxTransparency = 1
		v.PulseSpeed = 40
		v.PulseLength = 1000000
		v.FadeLength = 0.2
		v.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(125, 164, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 93, 255))
		})
		v.ContractFrom = 0.5
		v.ColorOffsetSpeed = 3
		return v
	end

	self:PivotTo(self.Pivot)
end

function SliceExplosionClass:GetScale()
	return self.Model:GetScale()
end

function SliceExplosionClass:ResetTime(value: number?)
	local thread = self.Thread

	if thread then
		task.cancel(thread)
	end

	self.Thread = task.delay(value or 1.5, function()
		self:Destroy()
	end)
end

function SliceExplosionClass:Grow()
	self:ScaleTo(self:GetScale() * 1.5)
	self:ResetTime()
	self:EmitWave(true)
end

function SliceExplosionClass:EmitWave(flag: boolean?)
	cameraShaker:Shake("Fast Hard")
	local beams = self.Impact.Beams
	VisualHelper:Tween(beams, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), {
		Orientation = beams.Orientation + createVector(0, 360, 0)
	})

	for _, beam in beams:GetDescendants() do
		if not beam:IsA("Beam") then
			continue
		end

		local width0 = beam:GetAttribute("Width0") or beam.Width0
		local width1 = beam:GetAttribute("Width1") or beam.Width0
		beam:SetAttribute("Width0", width0)
		beam:SetAttribute("Width1", width1)
		beam.Width0 = width0
		beam.Width1 = width1
		beam.Enabled = true
		VisualHelper:Tween(beam, TweenInfo.new(0.1 + math.random(3) * 0.025, Enum.EasingStyle.Sine), {
			Width0 = 0,
			Width1 = 0
		})
	end

	VisualHelper:EmitAll(self.Impact)

	if not flag then
		return
	end

	local model2 = self.Model
	local v = model2.Main.Size.X / 2
	local v2 = model2.Main.Size.Y / SliceExplosionClass.TemplateModel.Main.Size.Y
	Rocks:JoinRocks(CFrame.new(self.Pivot.Position), 19, v * 1.3, 2.5 * (1 + v2 * 0.2), 0.1, 1.6, { model })
end

function SliceExplosionClass:Destroy()
	local star = self.Model.Star
	star.Parent = model
	VisualHelper:EmitAll(star)
	Debris(star, 2)
	local impact = self.Model.Impact
	impact.Parent = model
	Debris(impact, 2)
	task.spawn(function()
		local clone = cDagger.Phase3.ExplosionModel:Clone()
		clone:ScaleTo(self.Model:GetScale())
		clone:PivotTo(CFrame.new(impact.Position))
		clone.Parent = model

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end
	end)
	local meshs = impact.Meshs

	for _, child in self.Impact.Meshs:GetChildren() do
		child.Decal.Transparency = child:GetAttribute("Transparency")
	end

	local airMeshHuge = meshs.AirMeshHuge
	local airMeshStorm = meshs.AirMeshStorm
	local superFlash = meshs.SuperFlash
	local flash = meshs.Flash
	VisualHelper:Tween(airMeshHuge.Mesh, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {
		Scale = airMeshHuge.Mesh.Scale * createVector(4, 1, 4)
	})
	VisualHelper:Tween(airMeshHuge.Decal, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {
		Transparency = 1
	})
	Debris(airMeshHuge, 1)
	VisualHelper:Tween(airMeshStorm.Mesh, TweenInfo.new(0.22, Enum.EasingStyle.Sine), {
		Scale = airMeshStorm.Mesh.Scale * createVector(3, 1, 3)
	})
	VisualHelper:Tween(airMeshStorm.Decal, TweenInfo.new(0.22, Enum.EasingStyle.Sine), {
		Transparency = 1
	})
	VisualHelper:Tween(airMeshStorm, TweenInfo.new(0.22, Enum.EasingStyle.Sine), {
		CFrame = airMeshStorm.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
	})
	Debris(airMeshStorm, 1)
	VisualHelper:Tween(flash.Decal, TweenInfo.new(0.22, Enum.EasingStyle.Sine), {
		Transparency = 1
	})
	VisualHelper:Tween(flash.Mesh, TweenInfo.new(0.22, Enum.EasingStyle.Sine), {
		Scale = flash.Mesh.Scale * createVector(3.5, 1, 3.5)
	})
	Debris(flash, 1)
	local scale = superFlash.Mesh.Scale * 2.25
	superFlash.Mesh.Scale /= 2
	VisualHelper:Tween(superFlash.Decal, TweenInfo.new(0.35, Enum.EasingStyle.Sine), {
		Transparency = 1
	})
	VisualHelper:Tween(superFlash.Mesh, TweenInfo.new(0.35, Enum.EasingStyle.Sine), {
		Scale = scale
	})
	Debris(superFlash, 1)
	task.delay(0.135, self.EmitWave, self)
	SliceExplosionClass.Stored[self.Model] = nil
	self.Maid:DoCleaning()
end

return SliceExplosionClass