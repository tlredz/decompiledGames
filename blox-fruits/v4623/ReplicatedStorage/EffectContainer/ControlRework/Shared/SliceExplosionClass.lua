local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local PrepareClonedInstances = require(ReplicatedStorage.Util.PrepareClonedInstances)
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

local function RecolorControlColorSequence(player, p)
	if typeof(player) == "Instance" and player:IsA("Player") and player.Parent then
		return Util.WrapColorSequenceConstructor(p, player, "ControlFruitVFXColor")
	end

	return p
end

local random = Random.new()
local class = {}
class.__index = class

local function NewPreparedBundle(initialScale: number)
	local constructorPool = PrepareClonedInstances.new({
		{
			Template = FX:WaitForChild("ControlRework"):WaitForChild("Gameplay"):WaitForChild("SliceExplosionClassModel"),
			Prepare = function(p2)
				VisualHelper:CapEmitterRates(p2.Main, 12, true)
				VisualHelper:ThinEmitBursts(p2)
			end
		},
		cDagger.Phase2.BoltExplosionBig
	})
	local random2 = Random.new()
	local v2 = {}

	for i = 1, 32 do
		table.insert(v2, {
			Template = cDagger.Phase2.SliceGround,
			Prepare = function(instance)
				instance:ScaleTo(random2:NextNumber(0.8, 3.5))
			end
		})

		if i % 2 ~= 1 then
			continue
		end

		table.insert(v2, cDagger.Phase2.Vault.HexTrailSpecsMove2)
		table.insert(v2, cDagger.Phase2.Vault.HexTrailSpecsMove2)
		table.insert(v2, cDagger.Phase2.Vault.HexTrailSpecsMove2)
	end

	local finalExplosionPools = {}

	for i = 0, 2 do
		local v5 = initialScale * 1.5 ^ i
		finalExplosionPools[i] = PrepareClonedInstances.new({
			{
				Template = cDagger.Phase3.ExplosionModel,
				Prepare = function(instance)
					instance:ScaleTo(v5)
					VisualHelper:ThinEmitBursts(instance)
				end
			}
		})
	end

	return (setmetatable({
		InitialScale = initialScale,
		ConstructorPool = constructorPool,
		UpdatePool = PrepareClonedInstances.new(v2),
		FinalExplosionPools = finalExplosionPools,
		UpdateTick = 0,
		TrailsExpected = false,
		Destroyed = false
	}, class))
end

function class:TakeConstructor()
	assert(not self.Destroyed, "Cannot use a destroyed SliceExplosionClass prepared bundle")
	local v = self.ConstructorPool:Take()
	local v2 = self.ConstructorPool:Take()
	self.ConstructorPool:Destroy()
	return v, v2
end

function class:TakeSliceGround()
	assert(not self.Destroyed, "Cannot use a destroyed SliceExplosionClass prepared bundle")
	assert(not self.TrailsExpected, "SliceExplosionClass prepared update order is invalid")
	self.UpdateTick += 1
	self.TrailsExpected = self.UpdateTick % 2 == 1

	if self.UpdateTick > 32 then
		return nil
	end

	return self.UpdatePool:Take()
end

function class:TakeTrails()
	assert(not self.Destroyed, "Cannot use a destroyed SliceExplosionClass prepared bundle")
	assert(self.TrailsExpected, "SliceExplosionClass prepared trails were taken out of order")
	self.TrailsExpected = false

	if self.UpdateTick > 32 then
		return nil
	end

	local v = table.create(3)
	v[1] = self.UpdatePool:Take()
	v[2] = self.UpdatePool:Take()
	v[3] = self.UpdatePool:Take()
	return v
end

function class:TakeFinalExplosion(p2: number)
	assert(not self.Destroyed, "Cannot use a destroyed SliceExplosionClass prepared bundle")
	local finalExplosionPool = self.FinalExplosionPools[p2]
	assert(finalExplosionPool, (`SliceExplosionClass has no prepared final explosion for {p2} grows`))
	return finalExplosionPool:Take()
end

function class:Destroy()
	if self.Destroyed then
		return
	end

	self.Destroyed = true
	self.ConstructorPool:Destroy()
	self.UpdatePool:Destroy()

	for _, finalExplosionPool in self.FinalExplosionPools do
		finalExplosionPool:Destroy()
	end

	table.clear(self.FinalExplosionPools)
end

local SliceExplosionClass = {
	TemplateModel = FX:WaitForChild("ControlRework"):WaitForChild("Gameplay"):WaitForChild("SliceExplosionClassModel"),
	Stored = {}
}
SliceExplosionClass.__index = SliceExplosionClass

-- equivalent calls inferred from this helper; original call sites unknown
local function DisconnectHeartbeat(state)
	local heartbeatConnection = state.HeartbeatConnection
	state.HeartbeatConnection = nil

	if heartbeatConnection then
		heartbeatConnection:Disconnect()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Discard(state)
	if state.Destroyed then
		return
	end

	state.Destroyed = true
	DisconnectHeartbeat(state) -- equivalent call inferred; original call site unknown
	local preparedInstances = state.PreparedInstances

	if preparedInstances then
		preparedInstances:Destroy()
		state.PreparedInstances = nil
	end

	SliceExplosionClass.Stored[state.Model] = nil
	state.Maid:DoCleaning()
end

function SliceExplosionClass.Prepare(initialScale: number)
	assert(initialScale > 0, "SliceExplosionClass prepared scale must be positive")
	return (NewPreparedBundle(initialScale))
end

local HttpService = game:GetService("HttpService")
local model = nil

function SliceExplosionClass.new(_, parent, player, cframe: CFrame?, value: number?, p2: number?, proxy, preparedInstances)
	local maid2 = maid.new()
	local v = value or 1
	model = Instance.new("Model", parent)
	local clone, clone2

	if preparedInstances then
		assert(
			math.abs(preparedInstances.InitialScale - v) <= 0.0001,
			"SliceExplosionClass prepared bundle scale does not match the requested scale"
		)
		clone, clone2 = preparedInstances:TakeConstructor()
	else
		clone = SliceExplosionClass.TemplateModel:Clone()
		clone2 = cDagger.Phase2.BoltExplosionBig:Clone()
		VisualHelper:CapEmitterRates(clone.Main, 12, true)
		VisualHelper:ThinEmitBursts(clone)
	end

	local model2 = maid2:GiveTask(clone)
	model2.Name = `Slice-Explosion-Model: {HttpService:GenerateGUID()}`
	Util.SetParentOverrideWithColor(model2, model, player, "ControlFruitVFXColor")
	local attachment = Instance.new("Attachment", model2.Main)
	attachment.Name = "Link"
	local boltExplosion = maid2:GiveTask(clone2)
	Util.SetParentOverrideWithColor(boltExplosion, model, player, "ControlFruitVFXColor")
	local object2 = setmetatable({
		Player = player,
		Maid = maid2,
		DebrisTime = 0,
		Model = model2,
		Impact = model2.Impact,
		BeamsPackets = { model2.Main.Beams:GetChildren(), model2.Main.Winds:GetChildren() },
		HexsStorm = maid2:GiveTask(HexsStormClass.new(model2.Main, nil, player)),
		BoltExplosion = boltExplosion,
		Proxy = proxy,
		PreparedInstances = preparedInstances,
		GrowCount = 0,
		HeartbeatConnection = nil,
		Destroyed = false
	}, SliceExplosionClass)

	for i = -1, 1, 0.1 do
		object2.HexsStorm:AddHex(i > 0.3 and "Gradient" or "Normal", i, 0, i * 360, random:NextNumber(50, 450))
	end

	for _, child in object2.Impact.Meshs:GetChildren() do
		local transparency = child.Decal.Transparency
		child.Decal.Transparency = 1
		child:SetAttribute("Transparency", transparency)
	end

	if cframe then
		object2:PivotTo(cframe)
		object2:EmitWave(true)
	end

	object2:ScaleTo(v)
	object2:ResetTime(p2)
	object2.HeartbeatConnection = maid2:GiveTask(RunService.Heartbeat:Connect(function(dt)
		object2:Update(dt)
	end))
	SliceExplosionClass.Stored[model2] = object2
	return object2
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
	if self.Destroyed then
		return
	end

	local main = self.Model:FindFirstChild("Main")

	if main then
		self.DebrisTime += p
		self.HexsStorm:Update(p)

		for _, beamsPacket in self.BeamsPackets do
			for _, v in beamsPacket do
				v.CFrame *= CFrame.Angles(0, math.rad(p * 260), 0)
			end
		end

		local v = math.abs(math.sin(os.clock() * 6) * 10)

		for _, v2 in self.HexsStorm.Data do
			v2.Range = v2.DefaultRange + v
		end

		if self.DebrisTime < 0.15 then
			return
		end

		self.DebrisTime = 0
		cameraShaker:Shake("Fast")
		local v2 = main.Size.X / 2
		local preparedInstances = self.PreparedInstances
		local clone

		if preparedInstances then
			clone = preparedInstances:TakeSliceGround()
		else
			clone = nil
		end

		if not clone then
			clone = cDagger.Phase2.SliceGround:Clone()
			clone:ScaleTo(random:NextNumber(0.8, 3.5))
		end

		clone:PivotTo(self.Pivot * CFrame.new(math.random(-v2, v2), 0.2, math.random(-v2, v2)) * CFrame.Angles(
			0,
			math.rad((math.random(360))),
			0
		))
		Util.SetParentOverrideWithColor(clone, model, self.Player, "ControlFruitVFXColor")
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
		local v4 = v2 + 55
		local v5 = self.Pivot * CFrame.Angles(0, math.random() * 3.141592653589793 * 2, 0) * CFrame.new(
			0,
			1,
			-math.random(v2, v4)
		)
		local rayCast = MathHelper:RayCast(v5.Position, v5.UpVector * -10, { model }, Enum.RaycastFilterType.Exclude)

		if rayCast then
			boltExplosion.CFrame = CFrame.new(rayCast.Position + createVector(0, 0.05, 0))
			VisualHelper:EmitAll(boltExplosion)
		end

		local v6 = v2 * 4
		local v7

		if preparedInstances then
			v7 = preparedInstances:TakeTrails()
		end

		for i = 1, 3 do
			local v8 = 0.2 + math.random(5) * 0.03 - i * 0.05
			local position2 = main.Position + Vector3.new(
				math.random(-v6, v6),
				math.random(-v6, v6),
				math.random(-v6, v6)
			)
			local position = main.Position
			local clone2

			if v7 then
				clone2 = v7[i]
			else
				clone2 = cDagger.Phase2.Vault.HexTrailSpecsMove2:Clone()
			end

			Util.SetParentOverrideWithColor(clone2, workspace.Terrain, self.Player, "ControlFruitVFXColor")
			clone2.Position = position2
			Debris(clone2, v8 + 0.5)
			local magnitude = (position2 - position).Magnitude
			local cframe = CFrame.lookAt(position2, position)
			local v14 = cframe * CFrame.new(math.random(-65, 65), math.random(-65, 65), -magnitude * 0.25).Position
			local v15 = cframe * CFrame.new(math.random(-65, 65), math.random(-65, 65), -magnitude * 0.75).Position
			VisualHelper:TweenNumberValue(1, TweenInfo.new(v8, Enum.EasingStyle.Sine), function(p2: number)
				clone2.Position = MathHelper:CubicBezier(p2, position2, v14, v15, position)
			end)
		end
	else
		Discard(self) -- equivalent call inferred; original call site unknown
	end
end

function SliceExplosionClass:ScaleTo(p: number)
	local model2 = self.Model

	if math.abs(model2:GetScale() - p) > 0.0001 then
		model2:ScaleTo(p)
	end

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
		local player = self.Player
		local colorSequence = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(125, 164, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 93, 255))
		})

		if typeof(player) == "Instance" and player:IsA("Player") and player.Parent then
			colorSequence = Util.WrapColorSequenceConstructor(colorSequence, player, "ControlFruitVFXColor")
		end

		v.Color = colorSequence
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
	if self.Destroyed or self.GrowCount >= 2 then
		return false
	end

	self.GrowCount += 1
	self:ScaleTo(self:GetScale() * 1.5)
	self:ResetTime()
	self:EmitWave(true)
	return true
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
	if self.Destroyed then
		return
	end

	local model2 = self.Model
	local star = model2:FindFirstChild("Star")
	local impact = model2:FindFirstChild("Impact")

	if star and impact then
		self.Destroyed = true
		DisconnectHeartbeat(self) -- equivalent call inferred; original call site unknown
		star.Parent = model
		VisualHelper:EmitAll(star)
		Debris(star, 2)
		impact.Parent = model
		Debris(impact, 2)
		local v = nil
		local preparedInstances = self.PreparedInstances

		if preparedInstances then
			if self.GrowCount <= 2 then
				v = preparedInstances:TakeFinalExplosion(self.GrowCount)
			end

			preparedInstances:Destroy()
			self.PreparedInstances = nil
		end

		task.spawn(function()
			local folder = v or cDagger.Phase3.ExplosionModel:Clone()

			if not v then
				folder:ScaleTo(self.Model:GetScale())
				VisualHelper:ThinEmitBursts(folder)
			end

			folder:PivotTo(CFrame.new(impact.Position))
			Util.SetParentOverrideWithColor(folder, model, self.Player, "ControlFruitVFXColor")

			for _, emitter in pairs(folder:GetDescendants()) do
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
	else
		Discard(self) -- equivalent call inferred; original call site unknown
	end
end

return SliceExplosionClass