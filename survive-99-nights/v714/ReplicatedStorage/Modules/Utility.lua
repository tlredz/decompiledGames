local createVector = vector.create
local Utility = {}
local random = Random.new()
local CollectionService = game:GetService("CollectionService")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CollisionUtility = require(script.Parent.CollisionUtility)
local childrenByName = {}

function Utility.CanGiveItemToChild(_, instance)
	if instance:GetAttribute("LockedHotbarSlot") then
		return
	end

	if instance:GetAttribute("NoDropping") then
		return
	else
		return true
	end
end

function Utility.IsFlameActive(value)
	local v = "Flame_" .. string.gsub(value, " ", "_")

	if workspace:GetAttribute(v) then
		return true
	end
end

function Utility.ClearProperties(instance)
	for _, tag in pairs(instance:GetTags()) do
		instance:RemoveTag(tag)
	end

	for k, _ in pairs(instance:GetAttributes()) do
		if string.sub(k, 1, 4) ~= "RBX_" then
			instance:SetAttribute(k, nil)
		end
	end
end

function Utility.IsInDarkness(player)
	if workspace:GetAttribute("State") == "Night" or player.Character and player.Character:GetPivot().Y <= -400 then
		return true
	end

	return false
end

function Utility.HasQuest(instance, p)
	if not (instance and p) then
		return
	end

	if not (instance:GetAttribute("TrackedQuest" .. 1) ~= p and instance:GetAttribute("TrackedQuest" .. 2) ~= p and instance:GetAttribute("TrackedQuest" .. 3) ~= p) then
		return true
	end
end

function Utility.GetQuestClass(instance, p)
	if not (instance and p) then
		return
	end

	local dailyQuests = instance:FindFirstChild("DailyQuests")

	if dailyQuests == nil then
		return
	end

	for _, child in pairs(dailyQuests:GetChildren()) do
		if child:GetAttribute("QuestId") == p then
			return child:GetAttribute("ClassRequired")
		end
	end
end

function Utility.GetDayTimestamp()
	local now = os.time()
	local universalTime = DateTime.fromUnixTimestamp(now + 23400):ToUniversalTime()
	local unixTimestamp = DateTime.fromUniversalTime(universalTime.Year, universalTime.Month, universalTime.Day).UnixTimestamp
	local v = unixTimestamp - 23400
	local universalTime2 = DateTime.fromUnixTimestamp(unixTimestamp + 86400):ToUniversalTime()
	return
		v,
		DateTime.fromUniversalTime(universalTime2.Year, universalTime2.Month, universalTime2.Day).UnixTimestamp - 23400
end

function Utility.IsDisabled(instance)
	if instance:GetAttribute("HalloweenTransformed") then
		return true
	end

	return false
end

function Utility.IsPublicServer()
	if RunService:IsStudio() then
		return false
	end

	if game.PrivateServerId == nil or game.PrivateServerId == "" then
		return true
	end
end

function Utility.HasTalent(instance, p)
	if instance then
		return instance:GetAttribute("Talent") == p
	end

	return false
end

function Utility.IsInvincible(instance)
	if not instance then
		return
	end

	if instance:GetAttribute("Undead") or Utility.IsDisabled(instance) or instance:GetAttribute("Invincible") then
		return true
	end

	local tempInvincible = instance:GetAttribute("TempInvincible")

	if tempInvincible then
		if workspace:GetServerTimeNow() < tempInvincible then
			return true
		else
			instance:SetAttribute("TempInvincible", nil)
		end
	end
end

function Utility.ViewPoints(p, p2)
	local part = Instance.new("Part")
	local magnitude = (p - p2).Magnitude
	part.Size = Vector3.new(0.2, 0.2, magnitude)
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CFrame = CFrame.lookAt(p, p2) * CFrame.new(0, 0, -magnitude / 2)
	part.Parent = workspace.Particles
	task.delay(4, function()
		part:Destroy()
	end)
end

function Utility.LerpColor3(data, data2, p)
	return Color3.new(data.R + data2.R * p, data.G + data2.G * p, data.B + data2.B * p)
end

function Utility.RunParticles(folder, options)
	local v = options or {}

	for _, emitter in pairs(folder:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v2 = emitter
		task.spawn(function()
			if v.Color then
				v2.Color = v.Color
			end

			if v.TimeScale then
				v2.TimeScale = v.TimeScale
			end

			local emitDelay = v2:GetAttribute("EmitDelay")

			if emitDelay and emitDelay > 0 then
				task.wait(emitDelay)
			end

			local emitDuration = v2:GetAttribute("EmitDuration") or 0
			local emitCount = v2:GetAttribute("EmitCount") or 0

			if emitCount > 0 then
				v2:Emit(emitCount)
			end

			if emitDuration > 0 then
				v2.Enabled = true
				task.wait(emitDuration)
				v2.Enabled = false
			end
		end)
	end
end

function Utility.SpawnParticles(p, p2, options)
	if not childrenByName[p] then
		return
	end

	local v = options or {}
	local clone = childrenByName[p]:Clone()
	clone:PivotTo(CFrame.new(p2.Position))
	clone.CanCollide = false
	clone.CanQuery = false
	clone.CanTouch = false
	clone.Parent = workspace.Particles
	local duration = v.Duration or 10
	Utility.RunParticles(clone, v)
	task.delay(duration, function()
		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end
	end)
	task.delay(duration + 5, function()
		clone:Destroy()
	end)
end

task.spawn(function()
	local ScanFolder

	ScanFolder = function(instance)
		for _, child in pairs(instance:GetChildren()) do
			if child:IsA("BasePart") then
				childrenByName[child.Name] = child
			elseif child:IsA("Folder") then
				ScanFolder(child)
			end
		end
	end

	ScanFolder(game.ReplicatedStorage.Assets.Particles)
end)

function Utility.WeldParticle(instance, p)
	local clone = game.ReplicatedStorage.Assets.Particles[p]:Clone()
	task.delay(10, function()
		clone:Destroy()
	end)
	clone.Parent = workspace.Particles
	clone:PivotTo(instance:GetPivot())
	local weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Parent = clone
	weldConstraint.Part0 = clone
	weldConstraint.Part1 = instance.PrimaryPart

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount") or 10)
		end
	end
end

function Utility.GetDistanceToItem(player, instance)
	local position

	if typeof(player) == "Instance" and player:IsA("Player") then
		if player.Character == nil then
			return nil
		else
			position = player.Character:GetPivot().Position
		end
	else
		position = player
		player = nil
	end

	if instance:GetAttribute("Destroyed") or instance.Parent == nil then
		return nil
	end

	if instance:GetAttribute("Owner") == player.UserId or instance:GetAttribute("InBag") then
		return 0
	end

	return (position - instance:GetPivot().Position).Magnitude
end

function Utility.GetItemBagSpace(instance, instance2)
	local capacity = instance:GetAttribute("Capacity")

	if instance:GetAttribute("EasterBasket") then
		return capacity
	end

	if instance2:GetAttribute("Class") == "Scavenger" then
		capacity += 2
	end

	if instance2:GetAttribute("Class") == "Explorer" then
		capacity += 2
	end

	if instance2:GetAttribute("Class") == "Alien Scientist" then
		capacity += 4
	end

	if Utility.HasTalent(instance2, "2SackSpace") then
		capacity += 2
	end

	return capacity
end

local v = {
	Log = true,
	["Super Log"] = true
}

function Utility.GetItemBagUsedSpace(list, instance)
	if instance:GetAttribute("Class") ~= "Woodsman" or not ((instance:GetAttribute("ClassLevel") or 1) >= 2) then
		return #list
	end

	local count = 0

	for _, v2 in pairs(list) do
		if not v[v2.Name] then
			count += 1
		end
	end

	return count
end

function Utility.ItemNeedsBagSpace(p, instance)
	if instance:GetAttribute("Class") == "Woodsman" and (instance:GetAttribute("ClassLevel") or 1) >= 2 then
		return not v[p.Name]
	end

	return true
end

function Utility.GetPlatform()
	if GuiService:IsTenFootInterface() then
		return "Console"
	end

	if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
		return "Mobile"
	end

	return "Desktop"
end

function Utility.IsToolDowngrade(instance, instance2)
	if instance:GetAttribute("ToolPriority") and instance2:GetAttribute("ToolPriority") then
		if instance2:GetAttribute("ToolPriority") >= instance:GetAttribute("ToolPriority") then
			return false
		end

		if instance:GetAttribute("UniqueToolType") == instance2:GetAttribute("UniqueToolType") and instance2:GetAttribute("ToolPriority") < instance:GetAttribute("ToolPriority") then
			return true
		end
	end

	if instance:GetAttribute("ToolName") == "GenericAxe" and instance2:GetAttribute("ToolName") == "Chainsaw" then
		return false
	end

	if instance:GetAttribute("ToolName") == "Chainsaw" and instance2:GetAttribute("ToolName") == "GenericAxe" then
		return true
	end

	if instance:GetAttribute("ToolName") == "Fishing Rod" and instance2:GetAttribute("ToolName") == "Fishing Rod" and instance2:GetAttribute("ToolTier") <= instance:GetAttribute("ToolTier") then
		return true
	end

	if instance:GetAttribute("ToolName") == "Taming Flute" and instance2:GetAttribute("ToolName") == "Taming Flute" and instance2:GetAttribute("ToolTier") <= instance:GetAttribute("ToolTier") then
		return true
	end

	if instance.Name == "Infernal Crossbow" and instance2.Name == "Crossbow" then
		return true
	end

	if instance.Name == "Crossbow" and instance2.Name == "Infernal Crossbow" then
		return false
	end

	if instance.Name == "Obsidiron Hammer" and (instance2.Name == "Spear" or instance2.Name == "Poison Spear") or instance.Name == "Obsidiron Hammer" and (instance2.Name == "Trident" or instance2.Name == "Ice Sword") then
		return true
	end

	if instance.Name == "Morningstar" and (instance2.Name == "Spear" or instance2.Name == "Poison Spear") or instance.Name == "Poison Spear" and instance2.Name == "Spear" or instance.Name == "Trident" and (instance2.Name == "Spear" or instance2.Name == "Poison Spear") then
		return true
	end

	if instance.Name == "Ice Sword" and instance2.Name == "Spear" then
		return true
	end

	if instance:GetAttribute("WeaponResourceDamage") and instance2:GetAttribute("WeaponResourceDamage") and instance2:GetAttribute("WeaponResourceDamage") <= instance:GetAttribute("WeaponResourceDamage") then
		return true
	end

	if instance:GetAttribute("MaxBattery") and instance2:GetAttribute("MaxBattery") and instance2:GetAttribute("MaxBattery") <= instance:GetAttribute("MaxBattery") then
		return true
	end

	if instance:GetAttribute("Capacity") and instance2:GetAttribute("Capacity") and instance2:GetAttribute("Capacity") <= instance:GetAttribute("Capacity") then
		return true
	end

	if instance.Name == "Iron Body" and instance2.Name == "Poison Armour" or instance2.Name == "Iron Body" and instance.Name == "Poison Armour" then
		return false
	end

	if instance:GetAttribute("Armour") and instance2:GetAttribute("Armour") then
		local armour = instance:GetAttribute("Armour")
		local armour2 = instance2:GetAttribute("Armour")

		if instance:GetAttribute("GoldTrimmed") then
			armour -= 0.05
		end

		if armour2 <= armour then
			return true
		end
	end

	if instance:GetAttribute("Warmth") and instance2:GetAttribute("Warmth") and instance2:GetAttribute("Warmth") <= instance:GetAttribute("Warmth") then
		return true
	end

	return false
end

function Utility.GetAngleBetweenVectors(vector2, p)
	local v2 = math.acos((vector2:Dot(p)))
	local v3 = IsNaN(v2) and 0 or v2
	local magnitude = (vector2 - p).Magnitude
	return v3 < 0.001 and magnitude > 0.1 and 3.141592653589793 or v3, vector2:Cross(p).Y < 0 and -1 or 1
end

function IsNaN(p)
	return p ~= p
end

function Utility.SecondsToMS(p)
	local v2 = math.floor(p / 60)
	local v3 = p % 60
	return string.format("%d:%02d", v2, v3)
end

function Utility.GetGroundPos(p)
	local v2 = p + createVector(0, 10, 0)
	local raycastResult = workspace:Raycast(v2, createVector(0, -40, 0), CollisionUtility.DefaultParams)

	if raycastResult and raycastResult.Instance.Name == "Grass" then
		return raycastResult.Position
	end
end

function Utility.GetDistanceToMachine(player, instance, instance2, value)
	local v2 = value or 25
	local position = instance2:GetPivot().Position
	local magnitude = (position - instance:GetPivot().Position).Magnitude

	if instance:GetAttribute("InBag") and v2 < magnitude then
		magnitude = (position - player.Character:GetPivot().Position).Magnitude
	end

	if magnitude <= v2 then
		return true
	end
end

local v2 = {
	"K",
	"M",
	"B",
	"T",
	"Q",
	"Qn",
	"Sx",
	"Sp",
	"O",
	"N",
	"D"
}

function Utility.GetShortNumber(p)
	local v3 = math.floor(p)
	local v4 = math.floor((math.log(v3, 1000)))

	if not (v4 > 0) then
		return tostring(v3), v3
	end

	local v5 = string.sub(tostring(v3), 1, -(v4 * 3 + 1))

	if string.len(v5) < 3 then
		local v6 = string.len(v5) + 1
		v5 ..= "." .. string.sub(tostring(v3), v6, v6)
	end

	return v5 .. v2[v4], tonumber(v5) * 10 ^ (v4 * 3)
end

function Utility.WalkIntoRange(player, p, p2, value)
	local character = player.Character

	if character == nil then
		return
	end

	local position = character:GetPivot().Position

	if ((p - position) * createVector(1, 0, 1)).Magnitude <= p2 then
		return true
	end

	local v4 = p + (position - p).Unit * p2 * (value or 0.5)
	character.Humanoid:MoveTo(v4)
	local v5 = false
	local moveDirectionChangedConnection = nil
	moveDirectionChangedConnection = character.Humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
		v5 = true
		moveDirectionChangedConnection:Disconnect()
		moveDirectionChangedConnection = nil
	end)

	while player.Character == character do
		wait(0.1)
		local magnitude = (character.HumanoidRootPart.Velocity * createVector(1, 0, 1)).Magnitude

		if v5 or magnitude < 1 then
			break
		end

		if ((p - character:GetPivot().Position) * createVector(1, 0, 1)).Magnitude <= p2 then
			return true
		end
	end
end

function Utility.NormalDistribution(min, max, value)
	local v4, v5

	repeat
		v4 = 2 * random:NextNumber() - 1
		local v6 = 2 * random:NextNumber() - 1
		v5 = v4 * v4 + v6 * v6
	until v5 < 1

	local v6 = v4 * math.sqrt(math.log(v5) * -2 / v5)
	local midpoint = (min + max) / 2
	return (math.clamp(v6 * ((max - midpoint) / (value or 3)) + midpoint, min, max))
end

function Utility.RoundToGrid(p, p2, p3, p4)
	local v3 = (p2 + 1) % 2 * (p4 / 2)
	local v4 = (p3 + 1) % 2 * (p4 / 2)
	local v5 = math.round(p.X / p4) * p4
	local v6 = math.round(p.Z / p4) * p4
	local v7 = p.X - v5 < 0 and -1 or 1
	local v8 = p.Z - v6 < 0 and -1 or 1
	return v5 + v3 * v7, v6 + v4 * v8
end

function Utility.GetRandomSpotAroundPosition(position, value, value2)
	local v3 = value or 0
	local v4 = value2 or 3

	for _ = 1, 10 do
		local v5 = CFrame.new(position) * CFrame.Angles(0, random:NextNumber() * 2 * 3.141592653589793, 0) * CFrame.new(
			0,
			0,
			-v3
		) + createVector(0, 0.5, 0)
		local v6 = v5 * CFrame.new(0, 0, -(random:NextNumber() * v4))
		local v7 = v6.Position + createVector(0, 10, 0)

		if CollisionUtility.HasLineOfSight(v7, v6.Position) then
			local groundPosition = CollisionUtility.GetGroundPosition(v7)

			if groundPosition then
				return v5, v6 - v6.Position + groundPosition
			else
				print("no ground pos")
			end
		else
			print("no line of sight")
		end
	end
end

function Utility.ScaleScrapToItemDurability(instance, max)
	local durability = instance:GetAttribute("Durability")

	if durability then
		return (math.clamp(math.floor(max * ((durability + 100 / max / 2) / 100)), 1, max))
	end

	return max
end

function Utility.ForAllTagged(tag, callback, p, callback2)
	for _, v3 in pairs(CollectionService:GetTagged(tag)) do
		local v4 = v3
		task.spawn(function()
			callback(v4)
		end)
	end

	if callback2 then
		callback2()
	end

	CollectionService:GetInstanceAddedSignal(tag):Connect(callback)

	if p then
		CollectionService:GetInstanceRemovedSignal(tag):Connect(p)
	end
end

function Utility.GetModelMass(folder)
	local total = 0

	for _, part in pairs(folder:GetDescendants()) do
		if part:IsA("BasePart") then
			total += part:GetMass()
		end
	end

	return total
end

function Utility.ScaleModelAxes(instance, vector2: Vector3)
	local parts = {}

	for _, part in pairs(instance:GetChildren()) do
		if part:IsA("BasePart") then
			table.insert(parts, part)
		end
	end

	local pivot = instance:GetPivot()

	for _, v3 in pairs(parts) do
		local objectSpace = pivot:ToObjectSpace(v3.CFrame)
		local position = objectSpace.Position
		local v4 = objectSpace - position
		v3.Size *= vector2
		local enabled

		if v3:FindFirstChild("WeldConstraint") then
			enabled = v3.WeldConstraint.Enabled
			v3.WeldConstraint.Enabled = false
		end

		v3.CFrame = pivot * CFrame.new(position.X * vector2.X, position.Y * vector2.Y, position.Z * vector2.Z) * v4

		if v3:FindFirstChild("WeldConstraint") then
			v3.WeldConstraint.Enabled = enabled
		end
	end
end

function Utility.ScaleModel(instance, p)
	local parts = {}

	for _, part in pairs(instance:GetChildren()) do
		if part:IsA("BasePart") then
			table.insert(parts, part)
		end
	end

	if #parts > 1 then
		local cframe = CFrame.new(instance:GetModelCFrame().p)

		for _, v3 in pairs(parts) do
			local v4 = v3.CFrame - v3.Position
			local objectSpace = cframe:ToObjectSpace(CFrame.new(v3.CFrame.p))
			v3.Size *= p
			v3.CFrame = cframe:lerp(cframe * objectSpace, p) * v4
		end
	end
end

local deepCopy

deepCopy = function(items)
	local result = {}

	for k, item in pairs(items) do
		if type(item) == "table" then
			item = deepCopy(item)
		end

		result[k] = item
	end

	return result
end

function Utility.CopyTable(p)
	return (deepCopy(p))
end

function Utility.WeldItem(model)
	local primaryPart

	if type(model) == "userdata" then
		primaryPart = model:IsA("Model") and model.PrimaryPart or model:FindFirstChild("Main") or model:FindFirstChild("Handle") or nil
	end

	local v3 = type(model) == "table" and model or model:GetChildren()

	for _, v5 in pairs(v3) do
		if v5.Name ~= "FloatingPart" then
			continue
		end

		primaryPart = v5
		break
	end

	for _, part in pairs(v3) do
		if not part:IsA("BasePart") then
			continue
		end

		if primaryPart then
			if primaryPart and part ~= primaryPart and (primaryPart.Name ~= "FloatingPart" or part.Name ~= "Handle") then
				local weld = Instance.new("Weld", part)
				weld.Parent = part
				weld.Part0 = primaryPart
				weld.Part1 = part
				weld.C0 = primaryPart.CFrame:toObjectSpace(part.CFrame)
			end
		else
			primaryPart = part
		end
	end
end

function Utility.AddToolWeld(part, part2, p, p2)
	local C0 = CFrame.new(p.Position) * CFrame.fromEulerAnglesYXZ(
		math.rad(p.Orientation.X),
		math.rad(p.Orientation.Y),
		(math.rad(p.Orientation.Z))
	)
	local C1 = CFrame.new(p2.Position) * CFrame.fromEulerAnglesYXZ(
		math.rad(p2.Orientation.X),
		math.rad(p2.Orientation.Y),
		(math.rad(p2.Orientation.Z))
	)
	local weld = Instance.new("Weld", part)
	weld.Name = "ToolWeld"
	weld.Part0 = part
	weld.Part1 = part2
	weld.C0 = C0
	weld.C1 = C1
	return weld
end

function Utility.GetToolOffset(p, p2)
	return
		CFrame.new(p2.Position) * CFrame.fromEulerAnglesYXZ(
			math.rad(p2.Orientation.X),
			math.rad(p2.Orientation.Y),
			(math.rad(p2.Orientation.Z))
		),
		CFrame.new(p.Position) * CFrame.fromEulerAnglesYXZ(
			math.rad(p.Orientation.X),
			math.rad(p.Orientation.Y),
			(math.rad(p.Orientation.Z))
		)
end

function GetToolAttachment(parent)
	if parent:FindFirstChild("RightGripAttachment") then
		return parent.RightGripAttachment
	end

	for _, attachment in pairs(parent:GetChildren()) do
		if attachment:IsA("Attachment") and attachment.Name ~= "DraggingAttachment" then
			return attachment
		end
	end

	local attachment = Instance.new("Attachment")
	attachment.Name = "GeneratedAttachment"
	attachment.Parent = parent
	return attachment
end

function GetWearableAttachment(instance)
	for _, attachment in pairs(instance:GetChildren()) do
		if attachment:IsA("Attachment") and attachment.Name ~= "ProximityAttachment" and attachment.Name ~= "DraggingAttachment" and attachment.Name ~= "Attachment" and attachment.Name ~= "RightGripAttachment" then
			return attachment
		end
	end
end

function Utility.AttachTool(folder, part, p)
	local part2 = part:IsA("BasePart") and part or part:FindFirstChild("Handle") or part:FindFirstChild("Main") or part.PrimaryPart

	if part2 and not part2:FindFirstChild("AccessoryWeld") and folder then
		local cframe = CFrame.new(0, 0.5, 0)
		local cframe2 = CFrame.new(0, 0, 0)
		local rightHand = folder:FindFirstChild("RightHand")
		local v4 = p and GetWearableAttachment(part2) or GetToolAttachment(part2)

		if v4 then
			cframe = CFrame.new(v4.Position) * CFrame.fromEulerAnglesYXZ(
				math.rad(v4.Orientation.X),
				math.rad(v4.Orientation.Y),
				(math.rad(v4.Orientation.Z))
			)
			local limb = v4:GetAttribute("Limb")

			for _, attachment in pairs(folder:GetDescendants()) do
				if not (attachment:IsA("Attachment") and attachment.Name == v4.Name and attachment:IsDescendantOf(folder) and (limb == nil or attachment.Parent.Name == limb)) then
					continue
				end

				cframe2 = CFrame.new(attachment.Position) * CFrame.fromEulerAnglesYXZ(
					math.rad(attachment.Orientation.X),
					math.rad(attachment.Orientation.Y),
					(math.rad(attachment.Orientation.Z))
				)
				rightHand = attachment.Parent
				break
			end

			if rightHand == nil then
				local rightGripAttachment = folder:FindFirstChild("Right Arm") and folder["Right Arm"]:FindFirstChild("RightGripAttachment")

				if rightGripAttachment then
					cframe2 = CFrame.new(rightGripAttachment.Position) * CFrame.fromEulerAnglesYXZ(
						math.rad(rightGripAttachment.Orientation.X),
						math.rad(rightGripAttachment.Orientation.Y),
						(math.rad(rightGripAttachment.Orientation.Z))
					)
					rightHand = rightGripAttachment.Parent
				end
			end
		end

		local weld = Instance.new("Weld", part2)
		weld.Name = "ToolWeld"
		weld.Part0 = part2
		weld.Part1 = rightHand
		weld.C0 = cframe
		weld.C1 = cframe2
	elseif not part2 then
		warn(part.Name, "does not have a handle to equip to")
	end
end

local v3 = {
	[Enum.BodyPart.Torso] = 82987757,
	[Enum.BodyPart.LeftArm] = 83001137,
	[Enum.BodyPart.RightArm] = 83001181
}

function Utility.HasWomanBody(instance)
	local count = 0

	for _, characterMesh in pairs(instance:GetChildren()) do
		if characterMesh:IsA("CharacterMesh") and v3[characterMesh.BodyPart] == characterMesh.MeshId then
			count += 1
		end
	end

	return count == 3
end

function Utility.CloneArmourModel(p, instance)
	local child = Utility.HasWomanBody(p) and instance.Parent.WomanVariants:FindFirstChild(instance.Name .. " Woman")

	if not child then
		return instance:Clone()
	end

	local clone = child:Clone()

	for k, v4 in pairs(instance:GetAttributes()) do
		if k:sub(1, 4) ~= "RBX_" then
			clone:SetAttribute(k, v4)
		end
	end

	return clone
end

function Utility:SelectFromChanceTable()
	if not self.ChanceSum then
		local v4 = nil
		local total = 0
		local makeDifferenceToTotal = 0

		for _, v5 in pairs(self) do
			if v4 then
				total += v5.Chance or 1
			elseif v5.MakeDifferenceToTotal then
				makeDifferenceToTotal = v5.MakeDifferenceToTotal
				v4 = v5
			else
				total += v5.Chance or 1
				makeDifferenceToTotal += v5.Chance or 1
			end
		end

		if v4 then
			v4.Chance = makeDifferenceToTotal - total
		end

		self.ChanceSum = makeDifferenceToTotal
	end

	local number = random:NextNumber(0, self.ChanceSum)
	local total = 0

	for k, v4 in pairs(self) do
		if k == "ChanceSum" then
			continue
		end

		total += v4.Chance

		if number <= total then
			return v4, k
		end
	end

	return self[#self], #self
end

function Utility.CFrameFromFront(p, vector2)
	local cross = vector2:Cross(createVector(0, 1, 0))
	return CFrame.fromMatrix(p, cross, createVector(0, 1, 0))
end

function Utility.GetFloorPositionAtRadius(p, p2, p3, callback, options)
	local cframe = CFrame.fromMatrix(p, createVector(1, 0, 0), createVector(0, 1, 0))

	for _ = 1, 10 do
		local v4 = random:NextNumber() * 3.141592653589793 * 2
		local v5 = p2 + random:NextNumber() * (p3 - p2)
		cframe *= CFrame.Angles(0, v4, 0)
		local v6 = p + cframe.LookVector * v5 + createVector(0, 10, 0)
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = options or {}
		local raycastResult = workspace:Raycast(v6, createVector(0, -50, 0), raycastParams)

		if raycastResult and (not callback or callback(raycastResult)) then
			return raycastResult.Position
		end
	end

	return nil
end

return Utility