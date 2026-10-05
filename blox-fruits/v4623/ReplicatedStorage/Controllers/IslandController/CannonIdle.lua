local createVector = vector.create
local RunService = game:GetService("RunService")
local Effect = require(game.ReplicatedStorage.Effect)
local Maid = require(game.ReplicatedStorage.Util.Maid)
local Sound = require(game.ReplicatedStorage.Util.Sound)
local numberRange = NumberRange.new(1.6, 4.2)
local numberRange2 = NumberRange.new(0.28, 0.6)
local numberRange3 = NumberRange.new(-2.5, 0)
local numberRange4 = NumberRange.new(0.35, 1.1)
local numberRange5 = NumberRange.new(0.14, 0.3)
local numberRange6 = NumberRange.new(-4.5, 1.5)
local numberRange7 = NumberRange.new(0.4188790204786391, 0.8377580409572782)
local corrodedMetal = Enum.Material.CorrodedMetal
local numberRange8 = NumberRange.new(0.5, 1.1)
local numberRange9 = NumberRange.new(380, 470)
local numberRange10 = NumberRange.new(0.2792526803190927, 0.4537856055185257)
local color = Color3.fromRGB(32, 29, 31)
local color2 = Color3.fromRGB(255, 168, 62)
local color3 = Color3.fromRGB(48, 42, 38)
local flag = false
local maid = Maid.new()
local v = nil
local v2 = {}
local v3 = {}
local vector2 = createVector(0, 0, 0)
local v4 = 0
local now = 0
local v5 = nil
local v6 = nil
local now2 = 0
local v7 = nil
local v8 = {}
local v9 = {}
local v10 = nil
local v11 = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function randRange(range: NumberRange)
	return range.Min + math.random() * (range.Max - range.Min)
end

local function easeOutBack(p: number)
	local v12 = p - 1
	return v12 * 2.70158 * v12 * v12 + 1 + v12 * 1.70158 * v12
end

local function easeInOutCubic(p: number)
	if p < 0.5 then
		return p * 4 * p * p
	end

	local v12 = p * -2 + 2
	return 1 - v12 * v12 * v12 / 2
end

local function easeOutCubic(p: number)
	local v12 = 1 - p
	return 1 - v12 * v12 * v12
end

local function corrode()
	for _, v12 in v2 do
		for _, part in v12.inst:GetDescendants() do
			if not (part:IsA("BasePart") and part.Material ~= corrodedMetal) then
				continue
			end

			table.insert(v8, {
				part = part,
				material = part.Material
			})
			part.Material = corrodedMetal
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function uncorrode()
	for _, v12 in v8 do
		if v12.part.Parent then
			v12.part.Material = v12.material
		end
	end

	table.clear(v8)
end

local function ensureShellFolder()
	local v12 = v10

	if v12 and v12.Parent then
		return v12
	end

	local folder = Instance.new("Folder")
	folder.Name = "MainCannonBarrage"
	folder.Parent = workspace
	v10 = folder
	return folder
end

-- equivalent calls inferred from this helper; original call sites unknown
local function outwardOf(position: Vector3)
	local vector3 = Vector3.new(position.X - vector2.X, 0, position.Z - vector2.Z)

	if vector3.Magnitude > 0.001 then
		return vector3.Unit
	end

	return createVector(0, 0, 1)
end

local function muzzleOf(folder)
	local v12 = -1e999
	local v13 = nil

	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		local position = part.Position
		local magnitude = Vector3.new(position.X - vector2.X, 0, position.Z - vector2.Z).Magnitude

		if not (v12 < magnitude) then
			continue
		end

		v13 = part
		v12 = magnitude
	end

	return v13
end

local function buildShellPart(position: Vector3)
	local part = Instance.new("Part")
	part.Name = "DeckGunShell"
	part.Shape = Enum.PartType.Ball
	part.Size = createVector(2.6, 2.6, 2.6)
	part.Color = color
	part.Material = Enum.Material.Metal
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.CFrame = CFrame.new(position)
	local attachment = Instance.new("Attachment")
	attachment.Position = createVector(0, 1.3, 0)
	attachment.Parent = part
	local attachment2 = Instance.new("Attachment")
	attachment2.Position = createVector(0, -1.3, 0)
	attachment2.Parent = part
	local trail = Instance.new("Trail")
	trail.Attachment0 = attachment
	trail.Attachment1 = attachment2
	trail.Lifetime = 0.6
	trail.MinLength = 0
	trail.FaceCamera = true
	trail.LightEmission = 0.35
	trail.Color = ColorSequence.new(color2, color3)
	trail.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(1, 1) })
	trail.Parent = part
	local parent = v10

	if not (parent and parent.Parent) then
		parent = Instance.new("Folder")
		parent.Name = "MainCannonBarrage"
		parent.Parent = workspace
		v10 = parent
	end

	part.Parent = parent
	return part
end

local function fireDeckGun(inst)
	local v12 = muzzleOf(inst)

	if not v12 then
		return
	end

	local v13 = outwardOf(v12.Position) -- equivalent call inferred; original call site unknown
	local v14 = (math.random() - 0.5) * 2 * 0.15707963267948966
	local v15 = CFrame.Angles(0, v14, 0) * v13
	local v17 = randRange(numberRange10) -- equivalent call inferred; original call site unknown
	local position = v12.Position + v15 * 6
	local v19 = v15 * math.cos(v17) + createVector(0, 1, 0) * math.sin(v17)
	local v21 = {
		part = buildShellPart(position),
		position = position,
		velocity = 0,
		born = 0
	}
	local range = numberRange9
	v21.velocity = v19 * randRange(range)
	v21.born = os.clock()
	table.insert(v9, v21)
	Sound:Play("ShortExplosion", position, 950, 1, 0.65)
	Effect.new("FireExplosion"):play({
		Position = position,
		Emit = 14,
		Speed = 26,
		Scale = 1.6
	})
end

local function retireShell(i: number)
	local v12 = v9[i]

	if not v12 then
		return
	end

	table.remove(v9, i)
	v12.part:Destroy()
	local impact = v12.impact

	if not impact then
		Effect.new("Water.Splash"):play({
			CFrame = CFrame.new(v12.position.X, -4, v12.position.Z),
			Scale = 4,
			Duration = 1.2
		})
		return
	end

	Sound:Play("Explosion2", impact)
	Effect.new("DustExplosion"):play({
		CFrame = CFrame.new(impact),
		Size = { 0, 34 },
		Duration = 1.2
	})
end

local function clearShells()
	for _, v12 in v9 do
		v12.part:Destroy()
	end

	table.clear(v9)
	local v12 = v10
	v10 = nil

	if v12 then
		v12:Destroy()
	end
end

local function stepBarrage(dt: number)
	local now3 = os.clock()
	local gravity = workspace.Gravity

	for i = #v9, 1, -1 do
		local v12 = v9[i]
		v12.velocity -= Vector3.new(0, gravity * dt, 0)
		v12.position += v12.velocity * dt
		local dieAt = v12.dieAt
		local v13

		if dieAt then
			v13 = dieAt <= now3
		else
			v13 = v12.position.Y <= -4
		end

		if v13 or now3 - v12.born > 9 then
			retireShell(i)
		else
			v12.part.CFrame = CFrame.lookAt(v12.position, v12.position + v12.velocity)
		end
	end

	if v5 == nil or v6 ~= nil or #v2 == 0 or now3 < v11 then
		return
	end

	local range = numberRange8
	v11 = now3 + randRange(range)
	fireDeckGun(v2[math.random(#v2)].inst)
end

local function getCalmAngle(p: number)
	local v12 = p % 84
	local v13 = math.floor(v12 / 10.5)
	local v14 = math.clamp((v12 - v13 * 10.5) / 4, 0, 1)
	local v15

	if v14 < 0.5 then
		v15 = v14 * 4 * v14 * v14
	else
		local v16 = v14 * -2 + 2
		v15 = 1 - v16 * v16 * v16 / 2
	end

	return (v13 + v15) * 0.7853981633974483 % 6.283185307179586
end

local function getAgitatedAngle(p: number, p2: number)
	local v12 = math.max(p2 - p, 0)
	local v13 = math.floor(v12 / 3)
	local v14 = math.clamp((v12 - v13 * 3) / 0.85, 0, 1)
	local v15 = p % 84
	local v16 = math.floor(v15 / 10.5)
	local v17 = math.clamp((v15 - v16 * 10.5) / 4, 0, 1)
	local v18

	if v17 < 0.5 then
		v18 = v17 * 4 * v17 * v17
	else
		local v19 = v17 * -2 + 2
		v18 = 1 - v19 * v19 * v19 / 2
	end

	local v19 = (v16 + v18) * 0.7853981633974483 % 6.283185307179586
	local v20

	if v14 < 0.5 then
		v20 = v14 * 4 * v14 * v14
	else
		local v21 = v14 * -2 + 2
		v20 = 1 - v21 * v21 * v21 / 2
	end

	return (v19 + (v13 + v20) * 0.7853981633974483) % 6.283185307179586
end

local function acquireModel()
	local map = workspace:FindFirstChild("Map")
	local marineBase = map and map:FindFirstChild("MarineBase")
	local mainCannons = marineBase and marineBase:FindFirstChild("MainCannons")

	if mainCannons and mainCannons:IsA("Model") then
		return mainCannons
	end

	return nil
end

local function build(mainCannons)
	v2 = {}
	v3 = {}
	local baseCircle = mainCannons:FindFirstChild("BaseCircle")
	local v12

	if baseCircle and baseCircle:IsA("BasePart") then
		v12 = baseCircle.Position
	else
		v12 = mainCannons:GetPivot().Position
	end

	vector2 = v12

	for _, child in mainCannons:GetChildren() do
		if child:IsA("BasePart") then
			child.Anchored = true
		end

		for _, part in child:GetDescendants() do
			if part:IsA("BasePart") then
				part.Anchored = true
			end
		end

		if child:IsA("Model") and child.Name == "Cannon" then
			local pivot = child:GetPivot()
			local vector3 = Vector3.new(pivot.Position.X - vector2.X, 0, pivot.Position.Z - vector2.Z)
			local v13 = v2
			local v14 = {
				inst = child,
				restCF = pivot,
				radialDir = not (vector3.Magnitude > 0.001) and createVector(0, 0, 0) or vector3.Unit,
				droop = 0,
				droopTo = 0,
				skew = 0,
				skewTo = 0,
				yaw = 0,
				pitch = 0,
				ext = 0,
				fromYaw = 0,
				fromPitch = 0,
				fromExt = 0,
				toYaw = 0,
				toPitch = 0,
				toExt = 0,
				t = 1,
				dur = 1,
				wait = 0
			}
			local range = numberRange7
			v14.droopTo = randRange(range)
			v14.skewTo = (math.random() - 0.5) * 2 * 0.24434609527920614
			local range2 = numberRange
			v14.wait = randRange(range2)
			table.insert(v13, v14)
		elseif child:IsA("BasePart") then
			table.insert(v3, {
				inst = child,
				restCF = child:GetPivot()
			})
		end
	end

	local serverTimeNow = workspace:GetServerTimeNow()
	local v13 = v5
	local v14

	if v13 then
		local v15 = math.max(serverTimeNow - v13, 0)
		local v16 = math.floor(v15 / 3)
		local v17 = math.clamp((v15 - v16 * 3) / 0.85, 0, 1)
		local v18 = v13 % 84
		local v19 = math.floor(v18 / 10.5)
		local v20 = math.clamp((v18 - v19 * 10.5) / 4, 0, 1)
		local v21

		if v20 < 0.5 then
			v21 = v20 * 4 * v20 * v20
		else
			local v22 = v20 * -2 + 2
			v21 = 1 - v22 * v22 * v22 / 2
		end

		local v22 = (v19 + v21) * 0.7853981633974483 % 6.283185307179586
		local v23

		if v17 < 0.5 then
			v23 = v17 * 4 * v17 * v17
		else
			local v24 = v17 * -2 + 2
			v23 = 1 - v24 * v24 * v24 / 2
		end

		v14 = (v22 + (v16 + v23) * 0.7853981633974483) % 6.283185307179586
	else
		local v15 = serverTimeNow % 84
		local v16 = math.floor(v15 / 10.5)
		local v17 = math.clamp((v15 - v16 * 10.5) / 4, 0, 1)
		local v18

		if v17 < 0.5 then
			v18 = v17 * 4 * v17 * v17
		else
			local v19 = v17 * -2 + 2
			v18 = 1 - v19 * v19 * v19 / 2
		end

		v14 = (v16 + v18) * 0.7853981633974483 % 6.283185307179586
	end

	v4 = -((v14 + 3.141592653589793) % 6.283185307179586 - 3.141592653589793)
	now = os.clock()

	if v6 then
		corrode()
	end
end

local function applyFrame(dt: number)
	local v12 = math.clamp((os.clock() - now) / 1.2, 0, 1)
	local serverTimeNow = workspace:GetServerTimeNow()
	local v13 = v5
	local v14

	if v13 then
		local v15 = math.max(serverTimeNow - v13, 0)
		local v16 = math.floor(v15 / 3)
		local v17 = math.clamp((v15 - v16 * 3) / 0.85, 0, 1)
		local v18 = v13 % 84
		local v19 = math.floor(v18 / 10.5)
		local v20 = math.clamp((v18 - v19 * 10.5) / 4, 0, 1)
		local v21

		if v20 < 0.5 then
			v21 = v20 * 4 * v20 * v20
		else
			local v22 = v20 * -2 + 2
			v21 = 1 - v22 * v22 * v22 / 2
		end

		local v22 = (v19 + v21) * 0.7853981633974483 % 6.283185307179586
		local v23

		if v17 < 0.5 then
			v23 = v17 * 4 * v17 * v17
		else
			local v24 = v17 * -2 + 2
			v23 = 1 - v24 * v24 * v24 / 2
		end

		v14 = (v22 + (v16 + v23) * 0.7853981633974483) % 6.283185307179586
	else
		local v15 = serverTimeNow % 84
		local v16 = math.floor(v15 / 10.5)
		local v17 = math.clamp((v15 - v16 * 10.5) / 4, 0, 1)
		local v18

		if v17 < 0.5 then
			v18 = v17 * 4 * v17 * v17
		else
			local v19 = v17 * -2 + 2
			v18 = 1 - v19 * v19 * v19 / 2
		end

		v14 = (v16 + v18) * 0.7853981633974483 % 6.283185307179586
	end

	local v15 = v4
	local v16

	if v12 < 0.5 then
		v16 = v12 * 4 * v12 * v12
	else
		local v17 = v12 * -2 + 2
		v16 = 1 - v17 * v17 * v17 / 2
	end

	local v17 = v14 + v15 * (1 - v16)
	local v18 = v6 ~= nil

	if v18 then
		if not v7 then
			v7 = v17
		end

		v17 = v7
	end

	local v19 = CFrame.new(vector2) * CFrame.Angles(0, v17, 0) * CFrame.new(-vector2)
	local v20

	if v18 then
		local v21 = 1 - math.clamp((os.clock() - now2) / 0.6, 0, 1)
		v20 = 1 - v21 * v21 * v21
	else
		v20 = 0
	end

	for _, v21 in v2 do
		if v18 then
			v21.droop = v21.droopTo * v20
			v21.skew = v21.skewTo * v20
		elseif v21.t < v21.dur then
			v21.t += dt
			local v22 = math.min(v21.t / v21.dur, 1) - 1
			local v23 = v22 * 2.70158 * v22 * v22 + 1 + v22 * 1.70158 * v22
			v21.yaw = v21.fromYaw + (v21.toYaw - v21.fromYaw) * v23
			v21.pitch = v21.fromPitch + (v21.toPitch - v21.fromPitch) * v23
			v21.ext = v21.fromExt + (v21.toExt - v21.fromExt) * v23
		else
			v21.wait -= dt

			if v21.wait <= 0 then
				local v22 = v5 ~= nil
				v21.fromYaw = v21.yaw
				v21.fromPitch = v21.pitch
				v21.fromExt = v21.ext
				v21.toYaw = (math.random() - 0.5) * 2 * (v22 and 0.5934119456780721 or 0.2617993877991494)
				v21.toPitch = (math.random() - 0.5) * 2 * (v22 and 0.4537856055185257 or 0.2617993877991494)
				local v23

				if v22 then
					v23 = numberRange6
				else
					v23 = numberRange3
				end

				v21.toExt = randRange(v23)
				v21.t = 0
				local v24

				if v22 then
					v24 = numberRange5
				else
					v24 = numberRange2
				end

				v21.dur = randRange(v24)
				local v25

				if v22 then
					v25 = numberRange4
				else
					v25 = numberRange
				end

				v21.wait = randRange(v25)
			end
		end

		local v22 = v19 * (v21.restCF + v21.radialDir * v21.ext) * CFrame.Angles(v21.pitch, v21.yaw, 0)

		if v21.droop > 0 then
			local position = v22.Position
			local vector3 = Vector3.new(position.X - vector2.X, 0, position.Z - vector2.Z)
			local cross = (not (vector3.Magnitude > 0.001) and createVector(1, 0, 0) or vector3.Unit):Cross(createVector(
				0,
				1,
				0
			))

			if cross.Magnitude > 0.001 then
				local v23 = CFrame.fromAxisAngle(cross.Unit, -v21.droop) * CFrame.Angles(0, v21.skew, 0)
				v22 = CFrame.new(position) * v23 * CFrame.new(-position) * v22
			end
		end

		v21.inst:PivotTo(v22)
	end

	for _, v21 in v3 do
		v21.inst:PivotTo(v19 * v21.restCF)
	end
end

local function restore(instance)
	if not instance:IsDescendantOf(workspace) then
		return
	end

	for _, v12 in v2 do
		v12.inst:PivotTo(v12.restCF)
	end

	for _, v12 in v3 do
		v12.inst:PivotTo(v12.restCF)
	end
end

local function aimGunAt(vector3: Vector3)
	local v12 = 1e999
	local v13 = nil
	local v14 = nil
	local v15 = 0

	for _, v16 in v2 do
		local v17 = muzzleOf(v16.inst)

		if not v17 then
			continue
		end

		local position = v17.Position
		local vector4 = Vector3.new(vector3.X - position.X, 0, vector3.Z - position.Z)

		if vector4.Magnitude < 0.001 then
			continue
		end

		local vector5 = outwardOf(position) -- equivalent call inferred; original call site unknown
		local unit = vector4.Unit
		local v18 = math.atan2(vector5:Cross(unit).Y, (math.clamp(vector5:Dot(unit), -1, 1)))
		local v19 = math.abs(v18)

		if not (v19 < v12) then
			continue
		end

		v15 = v18
		v14 = v17
		v13 = v16
		v12 = v19
	end

	return v13, v14, (math.clamp(v15, -1.2217304763960306, 1.2217304763960306))
end

local CannonIdle = {
	LoadForLocations = { "Marine Starter", "Marine Fortress" },
	Maid = Maid.new(),
	getSpinAngle = function(p: number, p2: number?)
		if p2 then
			local v12 = math.max(p - p2, 0)
			local v13 = math.floor(v12 / 3)
			local v14 = math.clamp((v12 - v13 * 3) / 0.85, 0, 1)
			local v15 = p2 % 84
			local v16 = math.floor(v15 / 10.5)
			local v17 = math.clamp((v15 - v16 * 10.5) / 4, 0, 1)
			local v18

			if v17 < 0.5 then
				v18 = v17 * 4 * v17 * v17
			else
				local v19 = v17 * -2 + 2
				v18 = 1 - v19 * v19 * v19 / 2
			end

			local v19 = (v16 + v18) * 0.7853981633974483 % 6.283185307179586
			local v20

			if v14 < 0.5 then
				v20 = v14 * 4 * v14 * v14
			else
				local v21 = v14 * -2 + 2
				v20 = 1 - v21 * v21 * v21 / 2
			end

			return (v19 + (v13 + v20) * 0.7853981633974483) % 6.283185307179586
		else
			local v12 = p % 84
			local v13 = math.floor(v12 / 10.5)
			local v14 = math.clamp((v12 - v13 * 10.5) / 4, 0, 1)
			local v15

			if v14 < 0.5 then
				v15 = v14 * 4 * v14 * v14
			else
				local v16 = v14 * -2 + 2
				v15 = 1 - v16 * v16 * v16 / 2
			end

			return (v13 + v15) * 0.7853981633974483 % 6.283185307179586
		end
	end,
	getSpinCenter = function(instance)
		local baseCircle = instance:FindFirstChild("BaseCircle")

		if baseCircle and baseCircle:IsA("BasePart") then
			return baseCircle.Position
		end

		return instance:GetPivot().Position
	end,
	setWrecked = function(p: number?)
		if v6 == p then
			return
		end

		v6 = p

		if p == nil then
			v7 = nil
			uncorrode() -- equivalent call inferred; original call site unknown

			for _, v12 in v2 do
				v12.droop = 0
				v12.skew = 0
				v12.t = 1
				v12.dur = 1
				local range = numberRange
				v12.wait = randRange(range)
			end
		else
			now2 = os.clock()
			v7 = nil

			for _, v12 in v2 do
				local range = numberRange7
				v12.droopTo = randRange(range)
				v12.skewTo = (math.random() - 0.5) * 2 * 0.24434609527920614
			end

			corrode()
		end
	end,
	setAgitated = function(p: number?)
		if v5 == p then
			return
		end

		local v12 = v5
		v5 = p

		if p ~= nil or v12 == nil then
			return
		end

		local serverTimeNow = workspace:GetServerTimeNow()
		local v13

		if v12 then
			local v14 = math.max(serverTimeNow - v12, 0)
			local v15 = math.floor(v14 / 3)
			local v16 = math.clamp((v14 - v15 * 3) / 0.85, 0, 1)
			local v17 = v12 % 84
			local v18 = math.floor(v17 / 10.5)
			local v19 = math.clamp((v17 - v18 * 10.5) / 4, 0, 1)
			local v20

			if v19 < 0.5 then
				v20 = v19 * 4 * v19 * v19
			else
				local v21 = v19 * -2 + 2
				v20 = 1 - v21 * v21 * v21 / 2
			end

			local v21 = (v18 + v20) * 0.7853981633974483 % 6.283185307179586
			local v22

			if v16 < 0.5 then
				v22 = v16 * 4 * v16 * v16
			else
				local v23 = v16 * -2 + 2
				v22 = 1 - v23 * v23 * v23 / 2
			end

			v13 = (v21 + (v15 + v22) * 0.7853981633974483) % 6.283185307179586
		else
			local v14 = serverTimeNow % 84
			local v15 = math.floor(v14 / 10.5)
			local v16 = math.clamp((v14 - v15 * 10.5) / 4, 0, 1)
			local v17

			if v16 < 0.5 then
				v17 = v16 * 4 * v16 * v16
			else
				local v18 = v16 * -2 + 2
				v17 = 1 - v18 * v18 * v18 / 2
			end

			v13 = (v15 + v17) * 0.7853981633974483 % 6.283185307179586
		end

		local v14 = serverTimeNow % 84
		local v15 = math.floor(v14 / 10.5)
		local v16 = math.clamp((v14 - v15 * 10.5) / 4, 0, 1)
		local v17

		if v16 < 0.5 then
			v17 = v16 * 4 * v16 * v16
		else
			local v18 = v16 * -2 + 2
			v17 = 1 - v18 * v18 * v18 / 2
		end

		v4 = (v13 - (v15 + v17) * 0.7853981633974483 % 6.283185307179586 + 3.141592653589793) % 6.283185307179586 - 3.141592653589793
		now = os.clock()
	end,
	bombard = function(vector3: Vector3, wait: number)
		local v12 = v

		if not flag or v6 ~= nil or #v2 == 0 then
			return false
		end

		if not (v12 and v12:IsDescendantOf(workspace)) then
			return false
		end

		local v13, v14, toYaw = aimGunAt(vector3)

		if not (v13 and v14) then
			return false
		end

		v13.fromYaw = v13.yaw
		v13.fromPitch = v13.pitch
		v13.fromExt = v13.ext
		v13.toYaw = toYaw
		v13.toPitch = v13.pitch
		v13.toExt = v13.ext
		v13.t = 0
		v13.dur = 0.35
		v13.wait = wait
		local v16 = math.max(wait, 0.35)
		local position = v14.Position
		local vector4 = Vector3.new(vector3.X - position.X, 0, vector3.Z - position.Z)
		local v17

		if vector4.Magnitude > 0.001 then
			v17 = vector4.Unit
		else
			v17 = outwardOf(position)
		end

		local position2 = position + v17 * 6
		local velocity = (vector3 - position2) / v16 + Vector3.new(0, 0.5 * workspace.Gravity * v16, 0)
		table.insert(v9, {
			part = buildShellPart(position2),
			position = position2,
			velocity = velocity,
			born = os.clock(),
			impact = vector3,
			dieAt = os.clock() + v16
		})
		Sound:Play("ShortExplosion", position2, 950, 1, 0.65)
		Effect.new("FireExplosion"):play({
			Position = position2,
			Emit = 14,
			Speed = 26,
			Scale = 1.6
		})
		return true
	end,
	start = function()
		if flag then
			return
		end

		maid:DoCleaning()
		flag = true
		maid:GiveTask(task.spawn(function()
			while flag do
				local map = workspace:FindFirstChild("Map")
				local marineBase = map and map:FindFirstChild("MarineBase")
				local mainCannons = marineBase and marineBase:FindFirstChild("MainCannons")

				if not (mainCannons and mainCannons:IsA("Model")) then
					mainCannons = nil
				end

				if mainCannons then
					build(mainCannons)
					v = mainCannons
					local v12 = mainCannons
					maid.Heartbeat = RunService.Heartbeat:Connect(function(dt)
						if flag and v12:IsDescendantOf(workspace) then
							applyFrame(dt)
							stepBarrage(dt)
						end
					end)

					while flag and mainCannons:IsDescendantOf(workspace) do
						task.wait(0.5)
					end

					maid.Heartbeat = nil
					restore(mainCannons)

					if v == mainCannons then
						v = nil
					end
				else
					task.wait(1)
				end
			end
		end))
	end,
	stop = function()
		flag = false
		v5 = nil
		v6 = nil
		v7 = nil
		uncorrode() -- equivalent call inferred; original call site unknown
		clearShells()
		maid:DoCleaning()
		local v12 = v
		v = nil

		if v12 then
			restore(v12)
		end
	end
}

function CannonIdle.RegionEntered(_)
	CannonIdle.start()
end

function CannonIdle.RegionLeaving(_)
	CannonIdle.stop()
end

return CannonIdle