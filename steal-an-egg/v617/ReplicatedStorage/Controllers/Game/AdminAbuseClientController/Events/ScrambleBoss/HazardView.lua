local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ScrambleBossHazards = require(ReplicatedStorage.Shared.Util.ScrambleBossHazards)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Kit = require(script.Parent.Kit)
local Vfx = require(script.Parent.Vfx)
local color = Color3.fromRGB(255, 40, 40)
local color2 = Color3.fromRGB(110, 255, 70)
local v = {
	Missile = 2.2,
	Puddle = 3
}
local v2 = {
	Floor = true,
	Mech = true,
	LeaveTeleport = true,
	BossSpawn = true,
	PlayerSpawn = true,
	Center = true,
	HubBlocker = true
}
local localPlayer = Players.LocalPlayer

-- equivalent calls inferred from this helper; original call sites unknown
local function now()
	return Workspace:GetServerTimeNow()
end

local function segmentRing(folder, p: number, color3: Color3, transparency: number)
	local result = {}

	for i = 1, p do
		result[i] = Kit.Part({
			Name = "Segment",
			Color = color3,
			Transparency = transparency,
			Size = createVector(1, 1, 1),
			Parent = folder
		})
	end

	return result
end

local function placeRing(list, vector2: Vector3, p: number, p2: number, p3: number)
	local count = #list
	local v3 = 6.283185307179586 * math.max(p, 0.5) / count * 1.08

	for k, v4 in list do
		local v5 = k / count * 3.141592653589793 * 2
		local v6 = Vector3.new(math.cos(v5), 0, (math.sin(v5))) * p
		v4.Size = Vector3.new(p2, p3, v3)
		v4.CFrame = CFrame.lookAt(vector2 + v6, vector2 + v6 + Vector3.new(-math.sin(v5), 0, (math.cos(v5)))) * CFrame.new(
			0,
			p3 / 2,
			0
		)
	end
end

local function disc(folder, vector2: Vector3, p: number, color3: Color3, transparency: number)
	return Kit.Part({
		Name = "Disc",
		Shape = Enum.PartType.Cylinder,
		Color = color3,
		Transparency = transparency,
		Size = Vector3.new(0.2, p * 2, p * 2),
		CFrame = CFrame.new(vector2) * CFrame.Angles(0, 0, 1.5707963267948966),
		Parent = folder
	})
end

local function triangle(folder, vector2: Vector3, vector3: Vector3, vector4: Vector3, color3: Color3)
	local vector5 = vector3 - vector2
	local vector6 = vector4 - vector2
	local vector7 = vector4 - vector3
	local dot = vector5:Dot(vector5)
	local dot2 = vector6:Dot(vector6)
	local dot3 = vector7:Dot(vector7)

	if dot2 < dot and dot3 < dot then
		vector4, vector2 = vector2, vector4
	elseif dot3 < dot2 and dot < dot2 then
		vector2, vector3 = vector3, vector2
	end

	local vector8 = vector3 - vector2
	local vector9 = vector4 - vector2
	local vector10 = vector4 - vector3
	local unit = vector9:Cross(vector8).Unit
	local unit2 = vector10:Cross(unit).Unit
	local unit3 = vector10.Unit
	local v3 = math.abs((vector8:Dot(unit2)))
	local result = {}

	for i = 1, 2 do
		local wedgePart = Instance.new("WedgePart")
		wedgePart.Anchored = true
		wedgePart.CanCollide = false
		wedgePart.CanQuery = false
		wedgePart.CanTouch = false
		wedgePart.CastShadow = false
		wedgePart.Material = Enum.Material.Neon
		wedgePart.Color = color3
		wedgePart.Transparency = 0.6

		if i == 1 then
			wedgePart.Size = Vector3.new(0.2, v3, (math.abs((vector8:Dot(unit3)))))
			wedgePart.CFrame = CFrame.fromMatrix((vector2 + vector3) / 2, unit, unit2, unit3)
		else
			wedgePart.Size = Vector3.new(0.2, v3, (math.abs((vector9:Dot(unit3)))))
			wedgePart.CFrame = CFrame.fromMatrix((vector2 + vector4) / 2, -unit, unit2, -unit3)
		end

		wedgePart.Parent = folder
		table.insert(result, wedgePart)
	end

	return result
end

local HazardView = {}
HazardView.__index = HazardView

function HazardView:new(arena)
	local folder = Instance.new("Folder")
	folder.Name = "ScrambleHazards"
	folder.Parent = Kit.Debris()
	self:Add(folder)
	local object = setmetatable({
		Views = {},
		Folder = folder,
		Arena = arena,
		Handles = {},
		SoundAt = {}
	}, HazardView)
	self:Connect(RunService.RenderStepped, function()
		object:Step()
	end)
	self:Add(function()
		for k in object.Handles do
			k:Stop()
		end

		table.clear(object.Handles)
	end)
	return object
end

function HazardView.Hold(p, p2: string, cframe: CFrame, p3: number?, flag: boolean?)
	local hold = Vfx.Hold(p2, cframe, p3, nil, flag)

	if hold then
		p.Handles[hold] = true
	end

	return hold
end

function HazardView:SoundOnce(p2: string, p3, p4: number?, p5: number)
	local now2 = os.clock()

	if now2 - (self.SoundAt[p2] or -1e999) < p5 then
		return
	end

	self.SoundAt[p2] = now2
	Kit.Sound(p2, p3, p4)
end

function HazardView:Release(object)
	if object and self.Handles[object] then
		self.Handles[object] = nil
		object:Stop()
	end
end

function HazardView:BeamCore(folder, p: string)
	if self.CoreMech ~= folder then
		self.CoreMech = folder
		self.Cores = {}
	end

	local core = self.Cores[p]

	if core and core.Capsule:IsDescendantOf(folder) then
		return core
	end

	local capsule = nil
	local base = nil

	for _, bone in folder:GetDescendants() do
		if not bone:IsA("Bone") then
			continue
		end

		if bone.Name == "Capsule3." .. p then
			capsule = bone
		elseif bone.Name == "SideArmPivot5." .. p then
			base = bone
		end
	end

	if capsule == nil or base == nil then
		return nil
	end

	local v5 = {
		Capsule = capsule,
		Base = base
	}
	self.Cores[p] = v5
	return v5
end

function HazardView:Muzzle(p)
	local mech = self.Arena:FindFirstChild("Mech")
	local side = p.Side or "R"
	local v3 = mech and self:BeamCore(mech, side)

	if v3 then
		local transformedWorldCFrame = v3.Capsule.TransformedWorldCFrame
		local magnitude = (transformedWorldCFrame.Position - v3.Base.TransformedWorldCFrame.Position).Magnitude
		return transformedWorldCFrame.Position + transformedWorldCFrame.YVector * magnitude
	else
		local child = mech and mech:FindFirstChild("Claw" .. side)
		local muzzle = child and child:FindFirstChild("Muzzle")

		if muzzle and muzzle:IsA("Attachment") then
			return muzzle.WorldPosition
		end

		return p.From
	end
end

function HazardView.BeamHeading(p, p2, p3: number, vector2: Vector3?)
	local beamHeading = ScrambleBossHazards.BeamHeading(p2, p3)
	local mech = p.Arena:FindFirstChild("Mech")
	local primaryPart = mech and mech:IsA("Model") and mech.PrimaryPart

	if primaryPart == nil or vector2 == nil then
		return beamHeading
	end

	local flat = Kit.Flat(vector2 - primaryPart.Position)

	if flat.Magnitude < 4 or flat.Unit:Dot(beamHeading) < 0.8660254037844387 then
		return beamHeading
	end

	return flat.Unit
end

local function stretchLane(folder, length: number, p: number)
	for _, descendant in folder:GetDescendants() do
		if descendant:IsA("Attachment") and math.abs(descendant.Position.Z) > 1 then
			local position = descendant.Position
			descendant.Position = Vector3.new(position.X * p, position.Y, math.sign(position.Z) * length / 2)
		elseif descendant:IsA("Beam") then
			descendant.Width0 *= p
			descendant.Width1 *= p
		end
	end
end

local function sweepEnds(folder)
	local attachments = {}

	for _, attachment in folder:GetDescendants() do
		if attachment:IsA("Attachment") and attachment.Position.Z < -1 then
			table.insert(attachments, attachment)
		end
	end

	return attachments
end

local function taperFromHand(folder)
	for _, beam in folder:GetDescendants() do
		if beam:IsA("Beam") then
			beam.Width0 = math.min(beam.Width0, beam.Width1) * 0.2
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stretchSweep(sweepEnds2, magnitude: number)
	for _, item in sweepEnds2 do
		item.Position = Vector3.new(item.Position.X, item.Position.Y, -magnitude)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function aimedSpec(view)
	if view.Spec.Kind ~= "Beam" or view.Heading == nil then
		return view.Spec
	end

	local clone = table.clone(view.Spec)
	clone.Direction = view.Heading
	clone.Angle = 0
	return clone
end

local function coverParams(arena)
	local children = {}

	for _, child in arena:GetChildren() do
		if v2[child.Name] or child:FindFirstChildOfClass("Humanoid") ~= nil then
			continue
		end

		table.insert(children, child)
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.FilterDescendantsInstances = children
	raycastParams.RespectCanCollide = true
	return raycastParams
end

local function beamReach(data, vector2: Vector3, vector3: Vector3)
	local length = data.Spec.Length or 150

	if data.CoverParams == nil then
		return length
	end

	local raycastResult = Workspace:Raycast(
		Vector3.new(vector2.X, data.FloorY + 2.5, vector2.Z),
		vector3 * length,
		data.CoverParams
	)

	if raycastResult then
		return raycastResult.Distance
	end

	return length
end

local function beamTouches(view, position: Vector3)
	local muzzle = view.Muzzle
	local tip = view.Tip

	if view.Spec.Kind ~= "Beam" or muzzle == nil or tip == nil then
		return true
	end

	local flat = Kit.Flat(tip - muzzle)
	local magnitude = flat.Magnitude

	if magnitude < 0.001 then
		return false
	end

	local dot = Kit.Flat(position - muzzle):Dot(flat / magnitude)
	return -ScrambleBossHazards.BodyRadius <= dot and dot <= magnitude + ScrambleBossHazards.BodyRadius
end

-- equivalent calls inferred from this helper; original call sites unknown
local function covered(view, position: Vector3)
	if view.CoverParams == nil then
		return false
	end

	local v3 = view.FloorY + 2.5
	local muzzle = view.Muzzle or view.Spec.Origin
	local vector2 = Vector3.new(muzzle.X, v3, muzzle.Z)
	return Workspace:Raycast(vector2, Vector3.new(position.X, v3, position.Z) - vector2, view.CoverParams) ~= nil
end

function HazardView:Add(spec)
	local floorY = (self.Arena:GetAttribute("FloorY") or spec.Origin.Y) + 0.15
	local folder = Instance.new("Folder")
	folder.Name = `Hazard{spec.Id}`
	folder.Parent = self.Folder
	local v4 = {
		Spec = spec,
		Folder = folder,
		Parts = {},
		Reported = false,
		Struck = false,
		FloorY = floorY
	}
	local vector2 = Vector3.new(spec.Origin.X, floorY, spec.Origin.Z)

	if spec.Kind == "Ring" then
		v4.Parts.Telegraph = segmentRing(folder, 24, color, 0.35)
		v4.Parts.Warn = disc(folder, vector2, 6, color, 0.5)
		v4.Parts.Ring = segmentRing(folder, 44, color2, 0.05)

		for _, v5 in v4.Parts.Ring do
			v5.Transparency = 1
		end
	elseif spec.Kind == "Beam" then
		if spec.Cover then
			v4.CoverParams = coverParams(self.Arena)
		end
	elseif spec.Kind == "Strike" then
		v4.Parts.Fill = disc(folder, vector2, 0.5, color, 0.45)
		v4.Parts.Edge = segmentRing(folder, 20, color, 0.2)
		placeRing(v4.Parts.Edge, vector2, spec.Radius or 10, 0.6, 0.3)
	elseif spec.Kind == "Cone" and spec.Style == "Bite" then
		local unit = Kit.Flat(spec.Direction or createVector(0, 0, 1)).Unit
		local crocScale = Vfx.CrocScale(self.Arena)
		local template = Vfx.Template("CrocBite")
		local rootOffset = template and template:GetAttribute("RootOffset")
		local v5 = typeof(rootOffset) ~= "Vector3" and createVector(0, 0, 0) or rootOffset * crocScale
		local hold = self:Hold("CrocBite", CFrame.lookAt(vector2, vector2 + unit) * CFrame.new(v5), crocScale, true)

		if hold then
			Vfx.Pulse(hold.Root, spec.Warn + ScrambleBossHazards.ActiveSeconds(spec) + 0.2)
			v4.Parts.Indicator = hold
		end
	elseif spec.Kind == "Cone" then
		local unit = Kit.Flat(spec.Direction or createVector(0, 0, 1)).Unit
		local radius = spec.Radius or 30
		local v5 = math.rad((spec.Angle or 60) / 2)
		local v6 = math.max(5, (math.ceil((spec.Angle or 60) / 20)))
		local cone = {}

		for i = 0, v6 - 1 do
			local v8 = -v5 + i / v6 * v5 * 2
			local v9 = -v5 + (i + 1) / v6 * v5 * 2

			for _, v12 in triangle(
				folder,
				vector2,
				vector2 + CFrame.Angles(0, v8, 0) * unit * radius,
				vector2 + CFrame.Angles(0, v9, 0) * unit * radius,
				color
			) do
				table.insert(cone, v12)
			end
		end

		v4.Parts.Cone = cone
	elseif spec.Kind == "Missile" or spec.Kind == "Puddle" then
		v4.Parts.Fill = disc(folder, vector2, 0.5, color, 0.45)
		v4.Parts.Edge = segmentRing(folder, 20, color, 0.2)
		placeRing(v4.Parts.Edge, vector2, spec.Radius or 10, 0.6, 0.3)
		v4.Parts.Orb = self:Hold("ToxicOrb", CFrame.new(spec.From or vector2), v[spec.Kind])
		self:SoundOnce(spec.Kind == "Missile" and "RapidMissileFire" or "ToxicOrbs", spec.From or vector2, 1, 0.5)
	elseif spec.Kind == "Grab" then
		v4.Parts.Fill = disc(folder, vector2, spec.Radius or 14, color, 0.6)
		v4.Parts.Edge = segmentRing(folder, 24, color, 0.1)
		placeRing(v4.Parts.Edge, vector2, spec.Radius or 14, 1, 0.5)
		v4.Parts.Closer = segmentRing(folder, 24, color, 0.3)
	elseif spec.Kind == "Lane" then
		local unit = Kit.Flat(spec.Direction or createVector(0, 0, 1)).Unit
		local length = spec.Length or 100
		local v5 = vector2 + unit * length / 2
		local hold = self:Hold("SpiderLane", CFrame.lookAt(v5, v5 + unit))

		if hold then
			stretchLane(hold.Root, length, (spec.Width or 40) / 32)
			v4.Parts.Indicator = hold
		end
	elseif spec.Kind == "Pillars" then
		local fills = {}
		local pillars = {}

		for _, v7 in spec.Points or {} do
			local vector3 = Vector3.new(v7.X, v4.FloorY, v7.Z)
			table.insert(fills, disc(folder, vector3, spec.Radius or 10, color, 0.5))
			local hold = self:Hold("LaserPillar", Vfx.Frame("LaserPillar", vector3))

			if not hold then
				continue
			end

			local beam = hold.Root:FindFirstChild("Beam")

			if beam then
				Vfx.Toggle(beam, false)
			end

			table.insert(pillars, {
				Handle = hold,
				Beam = beam
			})
		end

		v4.Parts.Fills = fills
		v4.Parts.Pillars = pillars
	elseif spec.Kind == "Sweep" then
		v4.Parts.Edge = segmentRing(folder, 32, color, 0.25)
		placeRing(v4.Parts.Edge, vector2, spec.Radius or 40, 1.2, 0.4)
		v4.Parts.Fill = disc(folder, vector2, spec.Radius or 40, color, 0.8)
	end

	self.Views[spec.Id] = v4
	task.delay(spec.Warn + ScrambleBossHazards.ActiveSeconds(spec) + 1.2, function()
		self.Views[spec.Id] = nil

		for _, part in v4.Parts do
			if type(part) == "table" and part.Stop then
				self:Release(part)
			end
		end

		for _, v5 in v4.Parts.Pillars or {} do
			self:Release(v5.Handle)
		end

		folder:Destroy()
	end)
end

function HazardView:CheckBallContact(p)
	local arena = self.Arena

	if arena:GetAttribute("Phase") ~= "Ball" or arena:GetAttribute("BallTarget") ~= localPlayer.UserId or arena:GetAttribute("BallStunned") then
		return
	end

	local ball = arena:FindFirstChild("Ball")
	local primaryPart = ball and ball.PrimaryPart

	if primaryPart == nil or os.clock() - (self.LastContact or 0) < 0.3 then
		return
	end

	if primaryPart.Size.Y / 2 + ScrambleBossHazards.BodyRadius >= Kit.Flat(p.Position - primaryPart.Position).Magnitude then
		self.LastContact = os.clock()
		Remotes.ScrambleBoss.HazardHit:FireServer(-1)
	end
end

function HazardView:Step()
	local v3 = now() -- equivalent call inferred; original call site unknown
	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local v4

	if humanoid == nil then
		v4 = false
	else
		v4 = humanoid.FloorMaterial == Enum.Material.Air
	end

	local inScrambleArena = localPlayer:GetAttribute("InScrambleArena") == true

	if inScrambleArena and humanoidRootPart and humanoid and humanoid.Health > 0 then
		self:CheckBallContact(humanoidRootPart)
	end

	for k, view in self.Views do
		local spec = view.Spec
		local v5 = v3 - spec.At
		local v6 = math.clamp(1 + v5 / math.max(spec.Warn, 0.01), 0, 1)
		local vector2 = Vector3.new(spec.Origin.X, view.FloorY, spec.Origin.Z)
		local activeSeconds = ScrambleBossHazards.ActiveSeconds(spec)
		local v7

		if v5 >= 0 then
			v7 = v5 <= activeSeconds
		else
			v7 = false
		end

		local v8 = math.sin(v3 * 18) * 0.5 + 0.5

		if spec.Kind == "Ring" then
			if v5 < 0 then
				placeRing(view.Parts.Telegraph, vector2, v6 * 10 + 6, 0.8, 0.3)

				for _, v9 in view.Parts.Telegraph do
					v9.Transparency = v8 * 0.4 + 0.2
				end
			else
				for _, v9 in view.Parts.Telegraph do
					v9.Transparency = 1
				end

				view.Parts.Warn.Transparency = 1
				local ringRadius = ScrambleBossHazards.RingRadius(spec, v5)
				placeRing(view.Parts.Ring, vector2, ringRadius, spec.Width or 2, 2.4)
				local transparency = v7 and 0.05 or 1

				for _, v10 in view.Parts.Ring do
					v10.Transparency = transparency
				end
			end
		elseif spec.Kind == "Beam" then
			local muzzle = self:Muzzle(spec)
			local vector3 = self:BeamHeading(spec, v5, muzzle)
			view.Heading = vector3
			local muzzle2 = muzzle or vector2 + vector3 * 10 + createVector(0, 1.5, 0)
			local vector4 = Vector3.new(muzzle2.X, view.FloorY + 1.5, muzzle2.Z)
			local length = view.Spec.Length or 150

			if view.CoverParams ~= nil then
				local raycastResult = Workspace:Raycast(
					Vector3.new(muzzle2.X, view.FloorY + 2.5, muzzle2.Z),
					vector3 * length,
					view.CoverParams
				)

				if raycastResult then
					length = raycastResult.Distance
				end
			end

			local tip = vector4 + vector3 * length
			view.Muzzle = muzzle2
			view.Tip = tip
			local v11 = tip - muzzle2

			if v7 and view.Parts.Sweep == nil and not view.Struck then
				view.Struck = true
				local hold = self:Hold("LaserSweep", Vfx.Frame("LaserSweep", muzzle2, v11))

				if hold then
					taperFromHand(hold.Root)
					view.Parts.SweepEnds = sweepEnds(hold.Root)
					view.Parts.Sweep = hold
				end

				Kit.Sound("LaserBeam", muzzle2, 1.2)
				Kit.ShakeFrom(muzzle2, 3, 200)
			end

			if view.Parts.Sweep then
				view.Parts.Sweep:Move(Vfx.Frame("LaserSweep", muzzle2, v11))
				stretchSweep(view.Parts.SweepEnds, v11.Magnitude) -- equivalent call inferred; original call site unknown
			end

			if v7 and inScrambleArena and humanoidRootPart and (view.NextRumble or 0) <= v3 then
				view.NextRumble = v3 + 0.16
				local vector5 = Kit.Flat(humanoidRootPart.Position - vector2)
				local v12

				if vector5:Dot(vector3) > 0 then
					v12 = math.abs((vector5:Dot(vector3:Cross(createVector(0, 1, 0)))))
				else
					v12 = vector5.Magnitude
				end

				local v13 = math.clamp(1 - v12 / 45, 0, 1)
				Kit.Shake(v13 * 2.4 + 0.7, 18, 0.3)
			end

			if activeSeconds < v5 and not view.Ended then
				view.Ended = true
				self:Release(view.Parts.Sweep)
			end
		elseif spec.Kind == "Strike" then
			if v5 < 0 then
				local v9 = math.max((spec.Radius or 10) * v6, 0.5)
				view.Parts.Fill.Size = Vector3.new(0.2, v9 * 2, v9 * 2)
				view.Parts.Fill.Transparency = 0.55 - v6 * 0.25
			elseif not view.Struck then
				view.Struck = true
				view.Parts.Fill.Transparency = 1

				for _, v9 in view.Parts.Edge do
					v9.Transparency = 1
				end

				Kit.Sound("Strike", vector2, 0.6, 0.9 + math.random() * 0.2)
			end
		elseif spec.Kind == "Missile" or spec.Kind == "Puddle" then
			local orb = view.Parts.Orb

			if v5 < 0 then
				local v9 = math.max((spec.Radius or 10) * v6, 0.5)
				view.Parts.Fill.Size = Vector3.new(0.2, v9 * 2, v9 * 2)
				view.Parts.Fill.Transparency = 0.55 - v6 * 0.25
				local from = spec.From or vector2
				local v10 = math.max((from - vector2).Magnitude * 0.35, 25)

				if orb then
					orb:Move(CFrame.new(from:Lerp(vector2, v6) + Vector3.new(
						0,
						math.sin(v6 * 3.141592653589793) * v10,
						0
					)))
				end
			elseif not view.Struck then
				view.Struck = true
				self:Release(orb)
				view.Parts.Fill.Transparency = 1

				for _, v9 in view.Parts.Edge do
					v9.Transparency = 1
				end

				local radius = spec.Radius or 10
				Vfx.Burst("ToxicSplat", CFrame.new(vector2), radius / 6.5)

				if spec.Kind == "Missile" then
					Kit.Sound("Strike", vector2, 0.5, 1.1 + math.random() * 0.2)
					Kit.ShakeFrom(vector2, 2, 90)
				else
					self:SoundOnce("ToxicPuddles", vector2, 1, 0.35)
					view.Parts.Pool = self:Hold("ToxicPuddle", CFrame.new(vector2), radius / 6)
				end
			end

			if spec.Kind == "Puddle" and view.Parts.Pool and activeSeconds - 2 <= v5 then
				self:Release(view.Parts.Pool)
				view.Parts.Pool = nil
			end
		elseif spec.Kind == "Grab" then
			view.Parts.Fill.Transparency = not (v5 < 0) and 1 or v8 * 0.3 + 0.35

			for _, v9 in view.Parts.Edge do
				v9.Transparency = v5 < 0 and 0.05 or 1
			end

			local v9 = (spec.Radius or 14) * ((1 - v6) * 1.6 + 1)
			placeRing(view.Parts.Closer, vector2, v9, 0.8, 0.4)

			for _, v10 in view.Parts.Closer do
				v10.Transparency = v5 < 0 and 0.25 or 1
			end
		elseif spec.Kind == "Lane" then
			if activeSeconds < v5 and view.Parts.Indicator then
				self:Release(view.Parts.Indicator)
				view.Parts.Indicator = nil
			end
		elseif spec.Kind == "Pillars" then
			for _, fill in view.Parts.Fills do
				fill.Transparency = not (v5 < 0) and 1 or 0.6 - v6 * 0.3 + v8 * 0.1
			end

			if v5 >= 0 and not view.Struck then
				view.Struck = true

				for _, pillar in view.Parts.Pillars do
					if pillar.Beam then
						Vfx.Toggle(pillar.Beam, true)
					end
				end

				Kit.Sound("VerticalLasers", nil, 1)
				Kit.Shake(2, 20, 0.6)
			end

			if activeSeconds < v5 and not view.Ended then
				view.Ended = true

				for _, pillar in view.Parts.Pillars do
					self:Release(pillar.Handle)
				end
			end
		elseif spec.Kind == "Cone" and spec.Style == "Bite" then
			if activeSeconds < v5 and view.Parts.Indicator then
				self:Release(view.Parts.Indicator)
				view.Parts.Indicator = nil
			end
		elseif spec.Kind == "Cone" then
			for _, v9 in view.Parts.Cone do
				local transparency

				if v5 < 0 then
					transparency = v8 * 0.2 + 0.62
				else
					transparency = math.min(1, 0.62 + v5 * 4)
				end

				v9.Transparency = transparency
			end
		elseif spec.Kind == "Sweep" then
			view.Parts.Fill.Transparency = not (v5 < 0) and 1 or 0.85 - v6 * 0.25

			for _, v9 in view.Parts.Edge do
				v9.Transparency = not (v5 < 0) and 1 or v8 * 0.4 + 0.1
			end
		end

		if not (v7 and inScrambleArena and (not view.Reported or spec.Tick ~= nil and (view.NextReport or 0) <= v3) and humanoidRootPart ~= nil) then
			continue
		end

		if not (humanoid ~= nil and humanoid.Health > 0) then
			continue
		end

		local contains = ScrambleBossHazards.Contains
		local v9 = aimedSpec(view) -- equivalent call inferred; original call site unknown

		if not (contains(v9, v5, humanoidRootPart.Position, v4, 0) and beamTouches(view, humanoidRootPart.Position)) then
			continue
		end

		-- equivalent call inferred; original call site unknown
		if covered(view, humanoidRootPart.Position) then
			continue
		end

		view.Reported = true
		view.NextReport = v3 + (spec.Tick or 0)
		Remotes.ScrambleBoss.HazardHit:FireServer(k)
		Kit.Shake(3, 16, 0.5)
	end
end

return HazardView