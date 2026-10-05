local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VFX = require(ReplicatedStorage.Shared.Utils.VFX)
local Kit = require(script.Parent.Kit)
local scrambleBossVFX = ReplicatedStorage.Assets.Particles:WaitForChild("ScrambleBossVFX")
local v = {
	Slam = { "MechBoss", "Slam" },
	ToxicOrb = { "MechBoss", "ToxicOrb", "ToxicOrb" },
	ToxicSplat = { "MechBoss", "ToxicOrb", "ToxicOrbSplat" },
	ToxicPuddle = { "MechBoss", "ToxicPuddle" },
	SpiderLane = { "MechBoss", "SpiderRush", "SpiderRushIndicator" },
	SpiderSlashes = { "MechBoss", "SpiderRush", "SpiderRushSlashes" },
	BossSwipe = { "MechBoss", "BossSwipe" },
	LaserPillar = { "MechBoss", "LaserPillar" },
	LaserBeam = { "MechBoss", "LaserBeam" },
	LaserSweep = { "MechBoss", "LaserSweep" },
	DroneSummon = { "MechBoss", "DroneSummon" },
	CrocTarget = { "Croc", "Target" },
	CrocLeap = { "Croc", "LeapIn" },
	CrocBite = { "Croc", "BiteIndicator" },
	CrocTail = { "Croc", "TailSwipe" },
	BallTrail = { "BallTrail" },
	LightningSurge = { "LightningSurge", "Lightning Surge" }
}
local total = 0.016666666666666666
local Vfx = {
	Template = function(p: string)
		local child = scrambleBossVFX

		for _, childName in v[p] or {} do
			child = child and child:FindFirstChild(childName)
		end

		return child
	end
}

function Vfx.Frame(p: string, position: Vector3, vector: Vector3?)
	local part = Vfx.Template(p)
	local rotation

	if part and part:IsA("BasePart") then
		rotation = part.CFrame.Rotation
	else
		rotation = CFrame.identity
	end

	local v2

	if vector and vector.Magnitude > 0.001 then
		v2 = CFrame.lookAt(position, position + vector.Unit)
	else
		v2 = CFrame.new(position)
	end

	return v2 * rotation
end

function Vfx:Scale(p: number)
	if p == 1 then
		return
	end

	if self:IsA("BasePart") then
		self.Size *= p
	end

	for _, descendant in self:GetDescendants() do
		if descendant:IsA("ParticleEmitter") then
			VFX.Rescale(descendant, p)
		elseif descendant:IsA("Beam") then
			descendant.Width0 *= p
			descendant.Width1 *= p
			descendant.CurveSize0 *= p
			descendant.CurveSize1 *= p

			if descendant.TextureMode ~= Enum.TextureMode.Stretch then
				descendant.TextureLength *= p
			end
		elseif descendant:IsA("Attachment") then
			descendant.Position *= p
		elseif descendant:IsA("PointLight") or descendant:IsA("SpotLight") then
			descendant.Range = math.min(descendant.Range * p, 60)
		end
	end
end

function Vfx.Sample(p: number)
	total += (math.min(p, 0.25) - total) * 0.1
end

local function keepVisible(folder)
	local v2 = total * 4

	for _, emitter in folder:GetDescendants() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local lifetime = emitter.Lifetime

		if not (lifetime.Max < v2) then
			continue
		end

		local v3 = v2 / math.max(lifetime.Max, 0.001)
		emitter.Lifetime = NumberRange.new(lifetime.Min * v3, v2)
	end
end

local function settleSeconds(folder)
	local v2 = 0

	for _, effect in folder:GetDescendants() do
		if effect:IsA("ParticleEmitter") then
			v2 = math.max(v2, effect.Lifetime.Max / math.max(effect.TimeScale, 0.01))
		elseif effect:IsA("Trail") then
			v2 = math.max(v2, effect.Lifetime)
		end
	end

	return v2 + 0.4
end

local function stage(p: string, cFrame: CFrame, value: number?, p2)
	local template = Vfx.Template(p)

	if template == nil then
		return nil
	end

	local clone = template:Clone()

	if clone:IsA("BasePart") then
		clone.Anchored = true
		clone.CanCollide = false
		clone.CanQuery = false
		clone.CanTouch = false
		clone.CastShadow = false
		clone.Transparency = 1
		clone.CFrame = cFrame
	end

	Vfx.Scale(clone, value or 1)
	clone.Parent = p2 or Kit.Debris()
	return clone
end

local function authoredBeams(folder)
	local transparenciesByBeam = {}

	for _, beam in folder:GetDescendants() do
		if beam:IsA("Beam") then
			transparenciesByBeam[beam] = beam.Transparency
		end
	end

	return transparenciesByBeam
end

local function beamFade(folder, items, p: number, flag: boolean)
	local function apply(p2: number)
		for k, item in items do
			local numberSequenceKeypoints = {}

			for k2, keypoint in item.Keypoints do
				numberSequenceKeypoints[k2] = NumberSequenceKeypoint.new(
					keypoint.Time,
					1 - (1 - keypoint.Value) * p2,
					keypoint.Envelope
				)
			end

			k.Transparency = NumberSequence.new(numberSequenceKeypoints)
		end
	end

	local lastTime = os.clock()
	apply(flag and 0 or 1)
	local renderSteppedConnection = nil
	renderSteppedConnection = RunService.RenderStepped:Connect(function()
		local v2 = math.clamp((os.clock() - lastTime) / p, 0, 1)
		local v3 = 1 - (1 - v2) ^ 2

		if folder.Parent == nil or folder:GetAttribute("Fading") ~= flag then
			if renderSteppedConnection then
				renderSteppedConnection:Disconnect()
			end
		else
			if not flag then
				v3 = 1 - v3
			end

			apply(v3)

			if v2 >= 1 then
				if renderSteppedConnection then
					renderSteppedConnection:Disconnect()
				end

				for k, item in items do
					if flag then
						k.Transparency = item
					else
						k.Enabled = false
					end
				end
			end
		end
	end)
end

function Vfx.Burst(p: string, cframe: CFrame, p2: number?, value: number?, p3)
	local folder = stage(p, cframe, p2, p3)

	if folder == nil then
		return nil
	end

	for _, descendant in folder:GetDescendants() do
		if descendant:IsA("ParticleEmitter") then
			if descendant.Enabled then
				descendant.Enabled = false

				if descendant:GetAttribute("EmitCount") == nil then
					descendant:SetAttribute("EmitCount", descendant.Rate * (value or 0.25))
				end
			end
		elseif descendant:IsA("Beam") or descendant:IsA("Trail") then
			descendant.Enabled = false
		elseif descendant:IsA("Light") then
			descendant.Enabled = false
		end
	end

	keepVisible(folder)
	local v2 = VFX.EmitTree(folder, 0.5)
	Debris:AddItem(folder, math.max(v2, (settleSeconds(folder))) + 0.4)
	return folder
end

function Vfx.Hold(p: string, cframe: CFrame, p2: number?, p3, flag: boolean?)
	local folder = stage(p, cframe, p2, p3)

	if folder == nil then
		return nil
	end

	local descendants = {}
	local descendants2 = {}

	for _, descendant in folder:GetDescendants() do
		if descendant:IsA("ParticleEmitter") then
			if descendant.Enabled then
				table.insert(descendants, descendant)
			elseif not flag then
				VFX.EmitOne(descendant, 0.5)
			end
		elseif descendant:IsA("Light") then
			table.insert(descendants2, descendant)
		end
	end

	local v2 = authoredBeams(folder)
	folder:SetAttribute("Fading", true)
	beamFade(folder, v2, 0.12, true)
	local flag2 = false
	return {
		Root = folder,
		Move = function(_, cFrame: CFrame)
			if folder:IsA("BasePart") then
				folder.CFrame = cFrame
			end
		end,
		Stop = function(self)
			if flag2 then
				return
			end

			flag2 = true

			for _, v3 in descendants do
				v3.Enabled = false
			end

			for _, trail in folder:GetDescendants() do
				if trail:IsA("Trail") then
					trail.Enabled = false
				end
			end

			for _, v3 in descendants2 do
				TweenService:Create(v3, TweenInfo.new(0.22), {
					Brightness = 0
				}):Play()
			end

			folder:SetAttribute("Fading", false)
			beamFade(folder, v2, 0.22, false)
			Debris:AddItem(folder, (settleSeconds(folder)))
		end
	}
end

function Vfx.Stamp(p: string, parent, p2: number, flag: boolean?)
	local template = Vfx.Template(p)

	if template == nil then
		return nil
	end

	local clone = template:Clone()
	local v2 = {}

	if clone:IsA("Attachment") then
		table.insert(v2, clone)
	end

	for _, attachment in clone:GetDescendants() do
		if attachment:IsA("Attachment") and attachment.Parent == clone then
			table.insert(v2, attachment)
		end
	end

	for _, folder in v2 do
		folder.Parent = parent

		for _, emitter in folder:GetDescendants() do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter.Enabled = false
			emitter.Lifetime = NumberRange.new(p2)

			if flag then
				emitter.LockedToPart = true
			end

			emitter:Emit(1)
		end

		Debris:AddItem(folder, p2 + 0.4)
	end

	clone:Destroy()
	return v2[1]
end

function Vfx.Pulse(folder, p: number)
	for _, emitter in folder:GetDescendants() do
		if not emitter:IsA("ParticleEmitter") or emitter.Enabled then
			continue
		end

		emitter.Lifetime = NumberRange.new(p)
		emitter:Emit(1)
	end
end

function Vfx.Toggle(folder, enabled: boolean)
	for _, effect in folder:GetDescendants() do
		if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
			effect.Enabled = enabled
		end
	end
end

function Vfx.CrocScale(instance)
	local croc = instance:FindFirstChild("Croc")
	local croc2 = scrambleBossVFX:FindFirstChild("Croc")
	local referenceLength = croc2 and croc2:GetAttribute("ReferenceLength")

	if croc == nil or not croc:IsA("Model") or typeof(referenceLength) ~= "number" then
		return 1
	end

	local _, v2 = croc:GetBoundingBox()
	return math.max(v2.X, v2.Z) / referenceLength
end

function Vfx.Trail(parent, p: number)
	local template = Vfx.Template("BallTrail")
	local result = {}
	local referenceWidth = template and template:GetAttribute("ReferenceWidth")

	if template == nil or typeof(referenceWidth) ~= "number" then
		return result
	end

	local clone = template:Clone()
	Vfx.Scale(clone, p / referenceWidth)

	for _, attachment in clone:GetChildren() do
		if not attachment:IsA("Attachment") then
			continue
		end

		attachment.Parent = parent
		table.insert(result, attachment)
	end

	for _, trail in clone:GetChildren() do
		if not trail:IsA("Trail") then
			continue
		end

		trail.Parent = parent
		table.insert(result, trail)
	end

	clone:Destroy()
	return result
end

function Vfx.Glitch(position: Vector3, p: number?, value: number?)
	local hold = Vfx.Hold("DroneSummon", CFrame.new(position), p)

	if hold then
		task.delay(value or 0.45, function()
			hold:Stop()
		end)
	end
end

function Vfx.Ground(vector: Vector3, p: number?)
	return (Vector3.new(vector.X, p or vector.Y, vector.Z))
end

return Vfx