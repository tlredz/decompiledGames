local createVector = vector.create

local function fn()
	return {
		_connections = {},
		add = function(self, p2)
			table.insert(self._connections, p2)
		end,
		cleanup = function(self)
			for _, _connection in pairs(self._connections) do
				_connection:Disconnect()
			end
		end
	}
end

local import = _G.import("iterUtil")
local import2 = _G.import("cframeUtil")
local import3 = _G.import("cameraUtil")
local import4 = _G.import("animUtil")
local import5 = _G.import("mathUtil")
local import6 = _G.import("modelUtil")
local import7 = _G.import("promise")
local import8 = _G.import("iterator")
local import9 = _G.import("animationData")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local BodyUtil = {
	animate = function(instance, p, options)
		if not instance.Parent then
			return
		end

		local v = options or {}
		local v2 = import9[p] or p
		local animation = Instance.new("Animation")
		animation.AnimationId = "rbxassetid://" .. v2
		local humanoid = instance:FindFirstChild("Humanoid") or instance:FindFirstChild("AnimationController")

		if not humanoid then
			return
		end

		v.SelfStopped = v.SelfStopped or function() end
		local track = humanoid:LoadAnimation(animation)
		track.Looped = v.Looped or false

		if v.Priority then
			track.Priority = Enum.AnimationPriority[v.Priority]
		end

		if not v.NoOverwrite then
			for _, v3 in pairs(humanoid:GetPlayingAnimationTracks()) do
				if v3.Priority == track.Priority then
					v3:Stop()
				end
			end
		end

		if v.Stopped then
			local v3 = fn()

			local function stop()
				v.Stopped()
				v3:cleanup()
			end

			v3:add(track.Stopped:Connect(stop), track.Ended:Connect(stop))
		end

		if v.Stationary then
			if humanoid.MoveDirection ~= createVector(0, 0, 0) then
				return track
			end

			local runningConnection = nil
			runningConnection = humanoid.Running:connect(function(p2)
				if p2 > 0 then
					runningConnection:disconnect()
					track:Stop(v.EndFade or 0.2)
					track:Destroy()
					v.SelfStopped()
				end
			end)
		end

		track:Play(v.StartFade or 0.1, v.Weight, v.Speed)
		track.TimePosition = v.TimePosition or track.TimePosition

		if v.Speed then
			track:AdjustSpeed(v.Speed)
		end

		if v.Duration then
			task.delay(v.Duration, function()
				track:Stop(v.EndFade or 0.1)
				track:Destroy()
				v.SelfStopped()
			end)
		end

		return track
	end,
	stopAllAnimations = function(instance)
		for _, v in pairs(instance.Humanoid:GetPlayingAnimationTracks()) do
			v:Stop()
		end
	end,
	stopAnimations = function(instance, p)
		for _, v in pairs(instance.Humanoid:GetPlayingAnimationTracks()) do
			if v.Animation.AnimationId == "rbxassetid://" .. (import9[p] or p) then
				v:Stop()
			end
		end
	end,
	stopAnimationsInSet = function(instance, p)
		for _, v in pairs(instance.Humanoid:GetPlayingAnimationTracks()) do
			if p[v.Animation.AnimationId] then
				v:Stop()
			end
		end
	end,
	rig = function(parent, p, p2)
		local clone = game.ReplicatedStorage.ReplicatedAssets.Rigs[p]:Clone()
		local v = {}

		for _, descendant in pairs(clone:GetDescendants()) do
			local child = parent:FindFirstChild(descendant.Name)

			for _, child2 in pairs(descendant:GetChildren()) do
				local part1 = child2.Part1
				local part = p2[part1.Name]
				part.Name = part1.Name
				part.Parent = parent
				child2.C1 = part.PivotOffset
				child2.Part0 = child
				child2.Part1 = part
				child2.Parent = child
				table.insert(v, child2)
				table.insert(v, part)
			end
		end

		return {
			Destroy = function()
				for _, v2 in pairs(v) do
					v2:Destroy()
				end
			end
		}
	end
}

local function clearForces(humanoidRootPart)
	for _, child in pairs(humanoidRootPart:GetChildren()) do
		if child.ClassName == "LinearVelocity" and child.ClassName == "AlignPosition" then
			child:Destroy()
		end
	end
end

function BodyUtil.force(p, p2, p3, p4)
	local humanoidRootPart = p.HumanoidRootPart
	clearForces(humanoidRootPart)
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Velocity = p2 * p3 / p4
	bodyVelocity.MaxForce = createVector(1e999, 1e999, 1e999)
	bodyVelocity.Parent = humanoidRootPart

	if p4 then
		Debris:AddItem(bodyVelocity, p4)
	end

	return bodyVelocity
end

function BodyUtil.pos(p, position, maxVelocity, callback)
	local humanoidRootPart = p.HumanoidRootPart
	clearForces(humanoidRootPart)
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 1
	part.CFrame = CFrame.new(position)
	part.Parent = workspace
	local alignPosition = Instance.new("AlignPosition")
	alignPosition.Attachment0 = Instance.new("Attachment")
	alignPosition.Attachment1 = Instance.new("Attachment")
	alignPosition.Attachment0.Parent = humanoidRootPart
	alignPosition.Attachment1.Parent = part
	alignPosition.MaxVelocity = maxVelocity
	alignPosition.ApplyAtCenterOfMass = true
	alignPosition.MaxForce = 1e999
	alignPosition.Responsiveness = 100
	alignPosition.Parent = humanoidRootPart
	local v = (alignPosition.Attachment0.WorldPosition - position).magnitude / maxVelocity
	import2.onReach(p.HumanoidRootPart, position, v, function()
		alignPosition.Attachment0:Destroy()
		alignPosition.Attachment1:Destroy()
		alignPosition:Destroy()
		part:Destroy()
		callback()
	end)
end

function BodyUtil.getHumHeight(instance)
	return instance.Humanoid.HipHeight + instance.HumanoidRootPart.Size.Y / 2
end

function BodyUtil.characters()
	local children = workspace.Dummies:GetChildren()

	for _, v in pairs(game.Players:GetPlayers()) do
		table.insert(children, v.Character)
	end

	return import.new(children)
end

local v = {
	freeze = function(instance)
		local parent = instance.Parent
		local position = parent.Position
		local P = instance:GetAttribute("P")
		local velocity = parent.Velocity
		local _, v2 = import3.rayGround(parent.Position, 4)

		if v2 then
			P = Vector3.new(position.X, P.Y, position.Z)
			instance:SetAttribute("P", P)
			parent.Velocity = Vector3.new(velocity.X, 0, velocity.Z)
		else
			parent.Velocity = createVector(0, 0, 0)
		end

		parent.CFrame = parent.CFrame - position + P
	end,
	freezeRot = function(instance)
		local parent = instance.Parent
		parent.CFrame = instance:GetAttribute("Rot") + parent.Position
	end,
	bodyLook = function(instance)
		local parent = instance.Parent
		parent.CFrame = CFrame.new(parent.Position, parent.Position + instance:GetAttribute("Dir"))
	end,
	suspend = function(instance)
		local parent = instance.Parent
		local Y = parent.Position.Y
		local v2 = math.max(instance:GetAttribute("Y"), Y)
		local velocity = parent.Velocity
		parent.Velocity = Vector3.new(velocity.X, math.max(0, velocity.Y), velocity.Z)
		parent.CFrame += Vector3.new(0, v2 - Y, 0)
		instance:SetAttribute("Y", v2)
	end,
	boneWeld = function(instance)
		instance.Parent.CFrame = instance.Value.TransformedWorldCFrame * instance:GetAttribute("C0")
	end,
	toMouse = function(p)
		BodyUtil.toMouse(p.Parent)
	end,
	toLoc = function(instance)
		BodyUtil.toLoc(instance.Parent, instance:GetAttribute("loc"))
	end,
	clientWeld = function(instance)
		if not instance.Parent then
			return
		end

		instance.Parent.CFrame = instance.Value.CFrame * instance:GetAttribute("C0")
	end,
	posWeld = function(instance)
		local parent = instance.Parent
		local value = instance.Value
		parent.CFrame = parent.CFrame - parent.Position + value.Position + instance:GetAttribute("Offset")
	end,
	boneMatch = function(p)
		p.Parent.TransfomedWorldCFrame = p.Value.TransformedWorldCFrame
	end
}
local v2 = {}

for k, _ in pairs(v) do
	v2[k] = {}
end

local function makeObject(class)
	local objectValue = Instance.new("ObjectValue")
	objectValue:SetAttribute("Class", class)
	v2[class][objectValue] = true
	objectValue.AncestryChanged:Connect(function()
		if objectValue.Parent then
			return
		end

		v2[class][objectValue] = nil
	end)
	return objectValue
end

function BodyUtil.clearMovers(instance, p)
	for _, child in pairs(instance:GetChildren()) do
		if child:GetAttribute("Class") == p then
			child:Destroy()
		end
	end
end

function BodyUtil.npcStates(instance)
	local humanoid = instance.Humanoid

	for _, v3 in pairs({
		"FallingDown",
		"Climbing",
		"GettingUp",
		"Ragdoll",
		"Landed",
		"Freefall",
		"Seated",
		"Swimming"
	}) do
		humanoid:SetStateEnabled(Enum.HumanoidStateType[v3], false)
	end
end

function BodyUtil.bodyLook(dir, parent)
	local object = makeObject("bodyLook")
	object:SetAttribute("Dir", dir)
	object.Parent = parent
	return object
end

function BodyUtil.suspend(p, parent, p2)
	local object = makeObject("suspend")
	object:SetAttribute("Y", p)

	if p2 then
		Debris:AddItem(object, p2)
	end

	object.Parent = parent
	return object
end

function BodyUtil.freeze(parent, p)
	local object = makeObject("freeze")
	object:SetAttribute("P", parent.Position)

	if p then
		Debris:AddItem(object, p)
	end

	object.Parent = parent
	return object
end

function BodyUtil.freezeRot(parent, p)
	local object = makeObject("freezeRot")
	object:SetAttribute("Rot", parent.CFrame - parent.Position)

	if p then
		Debris:AddItem(object, p)
	end

	object.Parent = parent
	return object
end

function BodyUtil.boneWeld(p, C0, parent)
	local object = makeObject("boneWeld")
	object:SetAttribute("C0", C0)
	object.Value = p
	object.Parent = parent
	return object
end

function BodyUtil.clientWeld(p, parent, p2)
	local object = makeObject("clientWeld")
	object:SetAttribute("C0", p2 or CFrame.new(0, 0, 0))
	object.Value = p
	object.Parent = parent
	return object
end

function BodyUtil.posWeld(p, parent, p2)
	local object = makeObject("posWeld")
	object:SetAttribute("Offset", p2 or createVector(0, 0, 0))
	object.Value = p
	object.Parent = parent
	return object
end

function BodyUtil.toMouseObj(parent)
	local object = makeObject("toMouse")
	object.Parent = parent
	BodyUtil.toMouse(parent)
	return object
end

function BodyUtil.toLocObj(parent, loc)
	local object = makeObject("toLoc")
	object:SetAttribute("loc", loc)
	object.Parent = parent
	BodyUtil.toLoc(parent, loc)
	return object
end

function BodyUtil.getGroundedCFrame(data)
	local rayGround = import3.rayGround(data.HumanoidRootPart.Position, 4)
	return CFrame.new(rayGround.p) + Vector3.new(0, data.Torso.Size.Y / 2 + data["Right Arm"].Size.Y, 0)
end

function BodyUtil.grounded(p)
	local rayGround, v3 = import3.rayGround(p.HumanoidRootPart.Position, 4)
	return v3, rayGround
end

BodyUtil.onGrounded = import7.promisify(function(p, value)
	local total = 0
	local v3 = value or 1e999

	while p.Parent and not BodyUtil.grounded(p) and total < v3 do
		task.wait(0)
		total += v3
	end
end)

function BodyUtil.camDir(p, _)
	local humanoidRootPart = p.HumanoidRootPart
	return ((import3.hitWhite({ workspace.Meta.Floor }).p - humanoidRootPart.Position).unit * createVector(1, 0, 1)).unit
end

function BodyUtil.toMouse(p)
	local humanoidRootPart = p.HumanoidRootPart
	humanoidRootPart.CFrame = CFrame.new(
		humanoidRootPart.Position,
		humanoidRootPart.Position + BodyUtil.camDir(p, true)
	)
end

function BodyUtil.toLoc(p, vector2)
	local humanoidRootPart = p.HumanoidRootPart

	if BodyUtil.grounded(p) then
		vector2 = Vector3.new(vector2.X, humanoidRootPart.Position.Y, vector2.Z)
	end

	humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position, vector2)
end

function BodyUtil.toMouseDur(p, duration)
	local postSimulationConnection = RunService.PostSimulation:Connect(function()
		BodyUtil.toMouse(p)
	end)
	task.delay(duration, function()
		postSimulationConnection:Disconnect()
	end)
end

function BodyUtil.getForwardTarget(p, p2, value)
	local humanoidRootPart = p.HumanoidRootPart
	local position = humanoidRootPart.Position
	local lookVector = humanoidRootPart.CFrame.lookVector
	local v3 = 1e999
	local v4 = nil
	local v5 = nil

	for _, v6 in BodyUtil.characters() do
		if v6 == p then
			continue
		end

		local position2 = v6.HumanoidRootPart.Position
		local vector2 = position2 - position
		local v7 = vector2:Dot(lookVector) / lookVector.magnitude

		if v7 < 0 then
			continue
		end

		local v8 = v7 + math.acos(vector2:Dot(lookVector) / (vector2.magnitude * lookVector.magnitude)) * 100

		if v3 < v8 then
			continue
		end

		v5 = v6
		v4 = position2
		v3 = v8
	end

	return
		v4 and CFrame.new(v4 + (position - v4).unit * (value or 4), v4) or humanoidRootPart.CFrame + (lookVector * createVector(
			1,
			0,
			1
		)).unit * p2,
		v5
end

function BodyUtil.charactersWithin(p, p2, options)
	local v3 = options or {}
	local v4 = {}

	for _, v5 in BodyUtil.characters() do
		if not import2.within(v5.HumanoidRootPart, p, p2) or v3[v5] then
			continue
		end

		table.insert(v4, v5)
	end

	return import.new(v4)
end

function BodyUtil:jump(p2, p3, p4, p5)
	local p6 = p3.p
	local p7 = p4.p
	import4.animate(p2, function(p8)
		self.C0 = p3 - p6 + import5.bezier2D(p8, p6, (p6 + p7) / 2 + Vector3.new(0, p5, 0), p7)
	end)
end

function BodyUtil.onCollide(instance, callback)
	local touchedConnection = nil
	touchedConnection = instance.Humanoid.Touched:Connect(function(otherPart)
		if otherPart.CollisionGroup ~= "Default" and otherPart.CollisionGroup ~= "CharacterCollide" or not otherPart.CanCollide or otherPart == workspace.Meta.Floor then
			return
		end

		callback(otherPart, touchedConnection)
	end)
end

function BodyUtil.destroyIfExists(instance, childName)
	local child = instance:FindFirstChild(childName)

	if not child then
		return
	end

	child:Destroy()
end

function BodyUtil.onClothing(instance, callback, p)
	for _, accoutrement in pairs(instance:GetChildren()) do
		if accoutrement:IsA("Accoutrement") then
			(p or callback)(accoutrement)
		end
	end

	for _, childName in pairs({ "Body Colors", "Shirt", "Pants" }) do
		local child = instance:FindFirstChild(childName)

		if child then
			callback(child)
		end
	end
end

local _ = {
	HairAttachment = "Head"
}

function BodyUtil.applyCharacterLook(folder, p)
	BodyUtil.onClothing(folder, function(instance)
		instance:Destroy()
	end)
	BodyUtil.onClothing(p, function(instance)
		local clone = instance:Clone()
		clone.Parent = folder
	end, function(instance)
		local clone = instance:Clone()
		BodyUtil.destroyIfExists(clone.Handle, "AccessoryWeld")
		clone.Parent = folder
		local attachment = clone.Handle:FindFirstChildOfClass("Attachment")
		local v3 = import8.values(folder:GetDescendants()):find(function(p2)
			return p2.Name == attachment.Name
		end)
		local manualWeld = import6.manualWeld(clone.Handle, v3.Parent, attachment.CFrame, v3.CFrame)
		manualWeld.Name = "AccessoryWeld"
	end)
end

function BodyUtil.playerRig(_)
	local folder = game.Players:CreateHumanoidModelFromDescription(
		game.Players:GetHumanoidDescriptionFromUserId(game.Players.LocalPlayer.UserId),
		Enum.HumanoidRigType.R6
	)
	folder.Name = "CharacterModel"
	folder.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	folder.HumanoidRootPart.Anchored = true

	for _, part in pairs(folder:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CastShadow = false
		end
	end

	return folder
end

BodyUtil.clearForces = clearForces
RunService.PostSimulation:Connect(function(_)
	for k, v3 in pairs(v) do
		for k2, _ in pairs(v2[k]) do
			v3(k2)
		end
	end
end)
return BodyUtil