local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local simplesignal = require(ReplicatedStorage.Packages.simplesignal)
local RunService = game:GetService("RunService")
local AntiCheat

if RunService:IsServer() then
	local ServerStorage = game:GetService("ServerStorage")
	AntiCheat = require(ServerStorage.SAM.AntiCheat)
else
	AntiCheat = nil
end

local ProjectileModeler = {
	WhitelistType = {
		Humanoids = 1,
		Map = 2,
		HumanoidsAndMap = 3
	}
}
local workspace2 = workspace

if workspace:FindFirstChild("Debree") ~= nil then
	workspace2 = workspace.Debree:FindFirstChild("Projectiles") or workspace.Debree
end

local map = workspace:FindFirstChild("Map") or workspace
local humanoids = workspace:FindFirstChild("Humanoids") or workspace

function CheckWhitelist(p, instance)
	if instance == nil then
		return
	end

	if p == ProjectileModeler.WhitelistType.Humanoids then
		return instance:IsDescendantOf(humanoids)
	end

	if p == ProjectileModeler.WhitelistType.Map then
		return instance:IsDescendantOf(map)
	end

	if p == ProjectileModeler.WhitelistType.HumanoidsAndMap then
		return instance:IsDescendantOf(humanoids) or instance:IsDescendantOf(map)
	end

	return true
end

local class = {}
class.__index = class

function class:Destroy(flag: boolean?)
	if not self.IsActive then
		return
	end

	self.IsActive = false

	if self.Destroying then
		self.Destroying:Fire()
		self.Destroying:Destroy()
		self.Destroying = nil
	end

	if self.thread ~= nil then
		if not flag then
			task.cancel(self.thread)
		end

		self.thread = nil
	end

	if self.TouchedConnection ~= nil then
		self.TouchedConnection:Disconnect()
		self.TouchedConnection = nil
	end

	if self.Instance ~= nil then
		self.Instance:Destroy()
	end

	table.clear(self)
	setmetatable(self, nil)
end

function class:Reach()
	if self.LaunchSpeed == nil or self.Origin == nil then
		return nil
	end

	return math.max(self.LaunchSpeed, self.Mover == nil and 0 or self.Mover.VectorVelocity.Magnitude) * (os.clock() - self.LaunchedAt) + self.Radius + 25
end

function class:Position()
	local instance = self.Instance

	if instance == nil or instance.Parent == nil then
		return nil
	end

	local reach = self:Reach()
	local v

	if reach ~= nil then
		v = instance.Position - self.Origin
	end

	if v == nil or v.Magnitude <= reach then
		return instance.Position
	end

	return self.Origin + v.Unit * reach
end

local v = {
	Projectile = {
		Size = createVector(1, 1, 1),
		Massless = false,
		CanCollide = false,
		Transparency = 1,
		Position = createVector(0, 1, 0),
		Name = "UnknownProjectile"
	},
	Mover = {
		ForceLimitMode = Enum.ForceLimitMode.Magnitude,
		MaxForce = 1000,
		RelativeTo = Enum.ActuatorRelativeTo.World,
		VelocityConstraintMode = Enum.VelocityConstraintMode.Vector,
		Enabled = true,
		VectorVelocity = createVector(0, 0, 0)
	},
	Rotator = {
		MaxTorque = 10000,
		Enabled = true,
		CFrame = CFrame.new(),
		Mode = Enum.OrientationAlignmentMode.OneAttachment,
		AlignType = Enum.AlignType.AllAxes
	}
}

local function GetDirection(mover)
	local velocityConstraintMode = mover.VelocityConstraintMode
	local magnitude = 1
	local unit

	if velocityConstraintMode == Enum.VelocityConstraintMode.Vector then
		magnitude = mover.VectorVelocity.Magnitude
		unit = mover.VectorVelocity.Unit
	elseif velocityConstraintMode == Enum.VelocityConstraintMode.Line then
		magnitude = mover.LineVelocity
		unit = mover.LineDirection
	else
		unit = createVector(0, 0, -1)
	end

	local position = nil
	local position2 = nil

	if mover.RelativeTo == Enum.ActuatorRelativeTo.Attachment0 and mover.Attachment0 ~= nil then
		position = mover.Attachment0.Position
		position2 = (mover.Attachment0.WorldCFrame * CFrame.new(unit.X, unit.Y, unit.Z)).Position
	elseif mover.RelativeTo == Enum.ActuatorRelativeTo.Attachment1 and mover.Attachment1 ~= nil then
		position = mover.Attachment1.Position
		position2 = (mover.Attachment1.WorldCFrame * CFrame.new(unit.X, unit.Y, unit.Z)).Position
	end

	if position ~= nil then
		unit = vector.normalize(position2 - position)
	end

	return unit, magnitude
end

local object = setmetatable({}, {
	__mode = "k"
})

local function report(part, playerFromCharacter, p: string, p2)
	if AntiCheat == nil or playerFromCharacter == nil then
		return
	end

	local success, networkOwner = pcall(part.GetNetworkOwner, part)

	if not success or networkOwner ~= playerFromCharacter then
		return
	end

	if p2 ~= nil then
		local success2, networkOwner2 = pcall(p2.GetNetworkOwner, p2)

		if success2 and networkOwner2 ~= nil and networkOwner2 ~= networkOwner then
			return
		end
	end

	local now = os.clock()
	local nows = object[networkOwner] or {}
	object[networkOwner] = nows

	if now - (nows[#nows] or -1e999) < 10 then
		return
	end

	while nows[1] ~= nil and now - nows[1] > 300 do
		table.remove(nows, 1)
	end

	table.insert(nows, now)

	if #nows < 3 then
		return
	end

	AntiCheat.Report(networkOwner, "Reach", {
		detail = `{part.Name} {p}`,
		refused = `{#nows} times in {math.round(now - nows[1])} s`,
		ping = string.format("%d ms", (math.round(networkOwner:GetNetworkPing() * 1000)))
	})
end

function ProjectileModeler.new(instance, fallback, value: number?, p, player, p2, flag: boolean?)
	local v2 = instance ~= nil
	local part = Instance.new("Part")
	local attachment = Instance.new("Attachment", part)
	part.Parent = v2 and instance.Parent or workspace2
	local object2 = setmetatable({
		Instance = part,
		Fallback = fallback,
		IsActive = true,
		Destroying = simplesignal.new()
	}, class)
	local massless = v2 and instance.Massless or v.Projectile.Massless
	local size = v2 and instance.Size or v.Projectile.Size
	local canCollide = v2 and instance.CanCollide or v.Projectile.CanCollide
	local transparency = v2 and instance.Transparency or v.Projectile.Transparency
	local name = v2 and instance.Name or v.Projectile.Name
	local position = v2 and instance.Position or v.Projectile.Position
	local cFrame = v2 and instance.CFrame
	part.Massless = massless
	part.Size = size
	part.CanCollide = canCollide
	part.CastShadow = false
	part.Transparency = transparency
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Name = name

	if position ~= nil then
		part.Position = position
	end

	if cFrame ~= nil then
		part.CFrame = cFrame
	end

	local mover = v2 and instance.Mover

	if mover ~= nil then
		local v4 = typeof(mover) == "table"
		local linearVelocity = Instance.new("LinearVelocity")
		linearVelocity.Parent = part
		linearVelocity.Name = "Mover"
		object2.Mover = linearVelocity
		local forceLimitMode = v4 and mover.ForceLimitMode or v.Mover.ForceLimitMode
		local maxForce = v4 and mover.MaxForce or v.Mover.MaxForce
		local relativeTo = v4 and mover.RelativeTo or v.Mover.RelativeTo
		local velocityConstraintMode = v4 and mover.VelocityConstraintMode or v.Mover.VelocityConstraintMode
		local enabled = v4 and mover.Enabled or v.Mover.Enabled
		local vectorVelocity = v4 and mover.VectorVelocity or v.Mover.VectorVelocity

		if v4 and mover.VectorVelocity ~= nil then
			object2.LaunchSpeed = vector.magnitude(mover.VectorVelocity)
		end

		local attachment0

		if v4 then
			attachment0 = mover.Attachment0 or attachment
		else
			attachment0 = attachment
		end

		linearVelocity.ForceLimitMode = forceLimitMode

		if forceLimitMode == v.Mover.ForceLimitMode then
			linearVelocity.MaxForce = maxForce
		end

		linearVelocity.Attachment0 = attachment0
		linearVelocity.RelativeTo = relativeTo
		linearVelocity.VelocityConstraintMode = velocityConstraintMode
		linearVelocity.Enabled = enabled

		if velocityConstraintMode == v.Mover.VelocityConstraintMode then
			linearVelocity.VectorVelocity = vectorVelocity
		end

		if v4 then
			if mover.MaxAxesForce ~= nil then
				linearVelocity.MaxAxesForce = mover.MaxAxesForce
			end

			if mover.Attachment1 ~= nil then
				linearVelocity.Attachment1 = mover.Attachment1
			end

			if mover.LineDirection ~= nil then
				linearVelocity.LineDirection = mover.LineDirection
			end

			if mover.LineVelocity ~= nil then
				linearVelocity.LineVelocity = mover.LineVelocity
			end

			if mover.PlaneVelocity ~= nil then
				linearVelocity.PlaneVelocity = mover.PlaneVelocity
			end

			if mover.PrimaryTangentAxis ~= nil then
				linearVelocity.PrimaryTangentAxis = mover.PrimaryTangentAxis
			end

			if mover.SecondaryTangentAxis ~= nil then
				linearVelocity.SecondaryTangentAxis = mover.SecondaryTangentAxis
			end
		end
	end

	local rotator = v2 and instance.Rotator

	if rotator ~= nil then
		local v4 = typeof(rotator) == "table"
		local alignOrientation = Instance.new("AlignOrientation")
		alignOrientation.Parent = part
		alignOrientation.Name = "Rotator"
		object2.Rotator = alignOrientation
		local maxTorque = v4 and rotator.MaxTorque or v.Rotator.MaxTorque
		local enabled = v4 and rotator.Enabled or v.Rotator.Enabled
		local cFrame2 = v4 and rotator.CFrame or v.Rotator.CFrame
		local mode = v4 and rotator.Mode or v.Rotator.Mode
		local alignType = v4 and rotator.AlignType or v.Rotator.AlignType

		if v4 then
			attachment = rotator.Attachment0 or attachment
		end

		alignOrientation.MaxTorque = maxTorque
		alignOrientation.Attachment0 = attachment
		alignOrientation.Enabled = enabled
		alignOrientation.CFrame = cFrame2
		alignOrientation.Mode = mode
		alignOrientation.AlignType = alignType

		if v4 then
			if rotator.MaxAngularVelocity ~= nil then
				alignOrientation.MaxAngularVelocity = rotator.MaxAngularVelocity
			end

			if rotator.Responsiveness ~= nil then
				alignOrientation.Responsiveness = rotator.Responsiveness
			end

			if rotator.Attachment1 ~= nil then
				alignOrientation.Attachment1 = rotator.Attachment1
			end
		end
	end

	local v4 = value or 5
	local radius = vector.magnitude(part.Size) / 2

	if instance ~= nil and instance.Speed ~= nil then
		object2.LaunchSpeed = instance.Speed
	end

	if object2.LaunchSpeed ~= nil and object2.LaunchSpeed ~= object2.LaunchSpeed then
		object2.LaunchSpeed = 0
	end

	local v6

	if object2.LaunchSpeed == nil then
		v6 = nil
	else
		v6 = object2.LaunchSpeed * v4 + radius + 25
	end

	object2.Radius = radius
	object2.LaunchedAt = os.clock()
	local position2 = nil
	task.defer(function()
		if part.Parent ~= nil then
			position2 = part.Position
			object2.Origin = position2
		end
	end)

	local function tooFar(vector2: Vector3)
		return v6 ~= nil and position2 ~= nil and v6 < (vector2 - position2).Magnitude
	end

	local function refusal(terrain)
		local magnitude = (terrain.Position - part.Position).Magnitude

		if not (terrain:IsA("Terrain") or magnitude <= radius + terrain.Size.Magnitude / 2 + 300) then
			return `touched a part {math.round(magnitude)} studs away`, terrain
		end

		local reach = object2:Reach()
		local v7 = (reach == nil or position2 == nil) and 0 or (part.Position - position2).Magnitude

		if reach == nil or v7 <= reach then
			return nil
		end

		return (`flew {math.round(v7)} studs in {string.format("%.2f", os.clock() - object2.LaunchedAt)} s, reach {math.round(reach)}`)
	end

	local playerFromCharacter

	if player == nil then
		playerFromCharacter = nil
	elseif player.Parent == game.Players then
		playerFromCharacter = player
	else
		playerFromCharacter = game.Players:GetPlayerFromCharacter(player)
	end

	if flag and object2.Fallback then
		object2.thread = task.delay(v4, function()
			local direction = GetDirection(object2.Mover)
			local v8 = part.Position + direction * radius
			local v9

			if v6 == nil or position2 == nil then
				v9 = false
			else
				v9 = v6 < (v8 - position2).Magnitude
			end

			if v9 then
				v8 = position2 + (v8 - position2).Unit * v6
			end

			object2.Fallback(v8, direction * -1)
			object2.thread = nil
			object2:Destroy()
		end)
	else
		object2.thread = task.delay(v4, object2.Destroy, object2, true)
	end

	if object2.Fallback ~= nil then
		object2.TouchedConnection = part.Touched:Connect(function(otherPart)
			if not object2.IsActive then
				return
			end

			if player == nil or player.Parent == game.Players and player.Character ~= nil and not otherPart:IsDescendantOf(player.Character) or player.Parent ~= game.Players and not otherPart:IsDescendantOf(player) then
				if not CheckWhitelist(p, otherPart) then
					return
				end

				local v7, v8 = refusal(otherPart)

				if v7 ~= nil then
					report(part, playerFromCharacter, v7, v8)
					return
				end

				local position3 = nil
				local instance2 = nil
				local normal = nil
				local v9, v10 = GetDirection(object2.Mover)

				if p2 ~= nil and object2.Mover ~= nil then
					local v11 = math.max(radius, 2)
					local v12 = part.Position - v9 * v11
					local v13 = v9 * math.max(v10 + v11, (math.max(v11 + 5, 15)))
					local raycastResult

					if v2 and instance.UseRaycast then
						raycastResult = workspace:Raycast(v12, v13, p2)
					elseif part:IsA("Part") and part.Shape == Enum.PartType.Ball then
						raycastResult = workspace:Spherecast(v12, part.Size.X / 2, v13, p2)
					else
						local v14 = part.CFrame + (v12 - part.Position)
						raycastResult = workspace:Blockcast(v14, part.Size, v13, p2)
					end

					if raycastResult ~= nil then
						position3 = raycastResult.Position
						instance2 = raycastResult.Instance
						normal = raycastResult.Normal
					end
				end

				local v11 = part.Position + v9 * radius
				local v12 = position3 or v11
				local v13

				if v6 == nil or position2 == nil then
					v13 = false
				else
					v13 = v6 < (v12 - position2).Magnitude
				end

				if v13 then
					return
				end

				if object2.Fallback(position3 or v11, normal or v9 * -1, otherPart or instance2) and object2.Destroy ~= nil then
					object2:Destroy()
				end
			end
		end)
	end

	return object2
end

return ProjectileModeler