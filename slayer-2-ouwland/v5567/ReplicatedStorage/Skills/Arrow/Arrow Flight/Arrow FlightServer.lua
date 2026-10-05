local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CollectionService = game:GetService("CollectionService")
local ArrowFlightServer = {
	Id = {}
}
local ServerClientPortal = require(ReplicatedStorage.CAM.Global.ServerClientPortal)
local name = script.Parent.Name
local v = script.Parent.Name .. " - Projectile"
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local Combat_Util = require(ServerStorage.SAM.Services.Combat_Util)
local hit_priority_handler = require(ServerStorage.SAM.Game_Play.hit_priority_handler)
local v2 = hit_priority_handler.new(script)
local Checker = require(ReplicatedStorage.CAM.Global.Checker)
require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.ManuelCancel)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local ProjectileModeler = require(ReplicatedStorage.CAM.Global.ProjectileModeler)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local Skill_Switch_Adder = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Skill_Switch_Adder)
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local Config = require(script.Parent.Config)
local insert = table.insert
local find = table.find
local script2 = script

function ArrowFlightServer.Hold(player, _, state)
	state.Link = ServerClientPortal.Create(player, name, 5)
	local character = player.Character
	local humanoidRootPart = character.HumanoidRootPart
	local v3 = ArrowFlightServer.Id[player.UserId]
	local getvaluesfolder = Utility.getvaluesfolder(player)
	state.Link:Once(function()
		if character == nil or humanoidRootPart == nil or humanoidRootPart.Parent == nil or ArrowFlightServer.Id[player.UserId] ~= v3 then
			return
		end

		state.Flight = true
		state.Direction = nil
		state.Thrown = nil
		EffectsEvent.ToAllInRange(player, "Arrow Flight VFX", character, "RideRock")
		local part = Instance.new("Part")
		part.TopSurface = Enum.SurfaceType.Smooth
		part.BottomSurface = Enum.SurfaceType.Smooth
		part.CanCollide = false
		part.Anchored = false
		part.Massless = true
		part.Transparency = 1
		part.Size = Config.RIDE_PART_SIZE
		part.Name = player.Name .. v
		local folder = Instance.new("Folder", part)
		folder.Name = "AttachedVictims"
		folder.Parent = part
		local touchedConnection = nil

		function state.explode(vector2: Vector3, vector3: Vector3, p)
			if touchedConnection ~= nil then
				touchedConnection:Disconnect()
				touchedConnection = nil
			end

			local v4 = vector3 or createVector(0, 1, 0)
			EffectsEvent.ToAllInRange(player, "Arrow Flight VFX", character, "RideRockExplode", vector2, v4, p)
			local v5 = CFrame.new(vector2, vector2 + v4) * CFrame.Angles(-1.5707963267948966, 0, 0)
			local targets = {}

			for _, child in ipairs(part.AttachedVictims:GetChildren()) do
				if child.Value ~= nil then
					insert(targets, child.Value)
				end
			end

			if part ~= nil and part.Parent ~= nil then
				part:Destroy()
			end

			task.wait()
			local v7 = {}
			Utility.CreateHitbox({
				caster = character,
				hitboxCFrame = v5 * Config.EXPLOSION_HITBOX_OFFSET,
				hitboxSize = Config.EXPLOSION_HITBOX_SIZE,
				checker = Checker,
				hitPriorityHandler = {
					callback = v2.Exists,
					data = "Choosing_1"
				},
				targets = targets,
				hitDetected = function(victim, values, p4, _)
					if victim ~= nil and p4 ~= nil then
						insert(v7, {
							Victim = victim,
							Values = values
						})
					end
				end
			})

			for _, v8 in ipairs(v7) do
				local victim = v8.Victim
				local values = v8.Values
				local humanoid = victim:FindFirstChild("Humanoid")
				local rootPart

				if humanoid ~= nil then
					rootPart = humanoid.RootPart or nil
				end

				if not (rootPart ~= nil and rootPart.Parent ~= nil) then
					continue
				end

				local v9 = v4 * Config.EXPLOSION_NORMAL_KNOCKBACK + vector.normalize(humanoidRootPart.Position - rootPart.Position) * math.min(
					Config.EXPLOSION_PULL_MAX,
					vector.magnitude(humanoidRootPart.Position - rootPart.Position) * 2
				)
				Combat_Util.RagDoll(script2, character, values, Config.EXPLOSION_RAGDOLL)
				Combat_Util.AddStun(script2, character, values, Config.EXPLOSION_STUN)
				Combat_Util.Damage(script2, character, victim, {
					Base = Config.EXPLOSION_DAMAGE,
					Skill = script.Parent.Name
				})
				Combat_Util.Knockback(script2, character, rootPart, v9, 0.15)
			end

			state.explode = nil
			state.Direction = nil
			state.Thrown = nil
		end

		local weld = Instance.new("Weld")
		weld.Part0 = humanoidRootPart
		weld.Part1 = part
		weld.Name = "weldd"
		weld.Parent = part
		weld.C0 = Config.RIDE_PART_OFFSET
		part.Parent = workspace.Debree.Projectiles
		local attachment = Instance.new("Attachment", part)
		attachment.CFrame = CFrame.new(0, 0, -5)
		local v4 = false
		local v5 = {}
		local v6 = {}
		local v7 = {}
		touchedConnection = part.Touched:Connect(function(otherPart)
			local find_character_from_descendant = Utility.find_character_from_descendant(otherPart)

			if find_character_from_descendant == nil or find_character_from_descendant == character then
				if find_character_from_descendant == nil and otherPart:IsDescendantOf(workspace.Map) and state.Thrown == true and state.Direction ~= nil then
					local position = part.Position
					local v8 = state.Direction * 15
					local v9 = position + state.Direction * -5
					local raycastResult = workspace:Raycast(v9, v8, RaycastHelper.Crater)
					local v10 = position + state.Direction * vector.magnitude(part.Size) / 2

					if state.Thread ~= nil then
						task.cancel(state.Thread)
						state.Thread = nil
					end

					if raycastResult == nil or raycastResult.Position == nil then
						state.explode(v10)
					else
						state.explode(raycastResult.Position, raycastResult.Normal, raycastResult.Instance)
					end
				end
			else
				local humanoid = find_character_from_descendant:FindFirstChild("Humanoid")
				local humanoidRootPart2 = find_character_from_descendant:FindFirstChild("HumanoidRootPart")

				if humanoid == nil or humanoidRootPart2 == nil then
					return
				end

				if vector.magnitude(otherPart.Position - part.Position) > (vector.magnitude(part.Size) + vector.magnitude(otherPart.Size)) / 2 + 75 then
					return
				end

				if find(v7, find_character_from_descendant) then
					return
				end

				insert(v7, find_character_from_descendant)
				local getvaluesfolder2 = Utility.getvaluesfolder(find_character_from_descendant)

				if getvaluesfolder2 == nil then
					return
				end

				local name2 = script.Parent.Name .. "cd_" .. v3

				if find_character_from_descendant:FindFirstChild(name2) then
					return
				end

				local check_victim, _ = Checker.check_victim(script, character, find_character_from_descendant)

				if check_victim == true then
					if v2.Both(getvaluesfolder2, {
						pv = getvaluesfolder,
						lifetime = 0.1,
						name = "Carry_choose",
						add = true
					}) == true then
						return
					end

					local boolValue = Instance.new("BoolValue")
					boolValue.Name = "NOMouvementlines"
					boolValue.Parent = getvaluesfolder2
					insert(v6, boolValue)
					DebrisModule:AddItem(boolValue, Config.RIDE_CARRY_DUR)
					local boolValue2 = Instance.new("BoolValue")
					boolValue2.Name = name2
					boolValue2.Parent = find_character_from_descendant
					DebrisModule:AddItem(boolValue2, Config.RIDE_PICKUP_CD)
					EffectsEvent.ToAllInRange(player, "Arrow Flight VFX", character, "PickupVfx", humanoidRootPart2)
					local add_Strict_Stun = Combat_Util.Add_Strict_Stun(
						script,
						character,
						getvaluesfolder2,
						Config.RIDE_CARRY_DUR
					)
					local boolValue3 = Instance.new("BoolValue")
					boolValue3.Name = "pause_gameplay"
					boolValue3.Parent = getvaluesfolder2
					DebrisModule:AddItem(boolValue3, Config.RIDE_CARRY_DUR)
					insert(v6, boolValue3)
					insert(v6, add_Strict_Stun)
					local objectValue = Instance.new("ObjectValue", folder)
					objectValue.Name = find_character_from_descendant.Name
					objectValue.Value = find_character_from_descendant

					for _, v9 in ipairs(CollectionService:GetTagged("OuwWeld")) do
						if v9.Value ~= nil and v9.Value:IsDescendantOf(find_character_from_descendant) then
							v9:Destroy()
						end
					end

					local v9 = Utility.AddValue(getvaluesfolder2, "noragdoll", Config.RIDE_CARRY_DUR)
					insert(v6, v9)
					local destroyingConnection = Utility.CreateOuwWeld(
						part,
						humanoidRootPart2,
						CFrame.new(0, Config.RIDE_WELD_DROP, Config.RIDE_WELD_FORWARD),
						Config.RIDE_CARRY_DUR
					).Destroying:Connect(function()
						if boolValue3 then
							boolValue3:Destroy()
						end

						if add_Strict_Stun then
							add_Strict_Stun:Destroy()
						end

						if v9 then
							v9:Destroy()
						end

						if objectValue then
							objectValue:Destroy()
						end

						local index = table.find(v7, find_character_from_descendant)

						if index then
							table.remove(v7, index)
						end
					end)
					insert(v5, destroyingConnection)
				elseif check_victim == "Perfect" or check_victim == "Blocking" then
					Combat_Util.Block(script2, character, find_character_from_descendant, Config.RIDE_BLOCK_BREAK)
				end
			end
		end)

		local function Delete()
			if v4 == false then
				v4 = true

				if state.Thread ~= nil then
					task.cancel(state.Thread)
					state.Thread = nil
				end

				if v6 then
					for _, v8 in pairs(v6) do
						v8:Destroy()
					end

					v6 = nil
				end

				if v5 then
					for _, connection in pairs(v5) do
						connection:Disconnect()
					end

					v5 = nil
				end

				if part then
					part:Destroy()
				end
			end
		end

		local parentChangedConnection = part:GetPropertyChangedSignal("Parent"):Connect(Delete)
		insert(v5, parentChangedConnection)
	end)
end

function ArrowFlightServer.UnHold(player, p, state)
	local character = player.Character

	if state.Link ~= nil and state.Link.__Active then
		state.Link:Destroy()
	end

	state.Link = nil
	local primaryPart = character.PrimaryPart

	if primaryPart == nil then
		state.Flight = nil
		return
	end

	if state.Flight then
		local v3 = primaryPart.CFrame * CFrame.new(0, -5, 0)
		local vectorVelocity = v3.lookVector * Config.RIDE_THROW_SPEED + vector.create(0, -Config.RIDE_THROW_DROP, 0)
		EffectsEvent.ToAllInRange(player, "Arrow Flight VFX", character, "RideRockThrow", v3, vectorVelocity)
		local child = game.Workspace.Debree.Projectiles:FindFirstChild(player.Name .. v)

		if child == nil then
			return
		end

		child.Name = "--"
		child.Size = Config.THROW_PART_SIZE
		state.Direction = vector.normalize(vectorVelocity)
		state.Thrown = true
		local halfSize = child.Size / 2
		local direction = state.Direction
		local v6 = math.abs(direction.X) * halfSize.X + math.abs(direction.Y) * halfSize.Y + math.abs(direction.Z) * halfSize.Z
		local raycastResult = workspace:Raycast(
			primaryPart.Position,
			v3.Position - primaryPart.Position,
			RaycastHelper.Crater
		) or workspace:Raycast(v3.Position, direction * (v6 + 1), RaycastHelper.Crater)

		if raycastResult == nil or state.explode == nil then
			state.Thread = task.delay(Config.ROCK_EXPLODE_FUSE, function()
				if state.explode == nil then
					if child ~= nil and child.Parent ~= nil then
						child:Destroy()
					end
				else
					local normalized = vector.normalize(vectorVelocity)
					local v7 = normalized * -1
					local v8 = child.Position + normalized * vector.magnitude(child.Size) / 2
					state.explode(v8, v7)
				end
			end)
			local weldd = child:FindFirstChild("weldd")

			if weldd ~= nil then
				weldd:Destroy()
			end

			local cframe = CFrame.new(v3.Position, v3.Position + vectorVelocity)
			child.CFrame = cframe
			local attachment = child.Attachment
			local linearVelocity = Instance.new("LinearVelocity", child)
			linearVelocity.MaxForce = 50000
			linearVelocity.Attachment0 = attachment
			linearVelocity.VectorVelocity = vectorVelocity
			local alignOrientation = Instance.new("AlignOrientation")
			alignOrientation.Mode = "OneAttachment"
			alignOrientation.Attachment0 = attachment
			alignOrientation.MaxTorque = 400000
			alignOrientation.CFrame = cframe
			alignOrientation.Parent = attachment
			child.Parent = workspace.Debree.Projectiles
			child:SetNetworkOwner(nil)
		else
			state.explode(raycastResult.Position, raycastResult.Normal)
			state.Flight = nil
			return
		end
	else
		local v3

		if typeof(p) == "Vector3" then
			v3 = math.min(Config.ROCKUP_RANGE, (p - primaryPart.Position).Magnitude)
		else
			v3 = Config.ROCKUP_RANGE
		end

		local maximizeRayServer, v4, v5 = RaycastHelper.MaximizeRayServer(
			character,
			primaryPart.Position,
			p,
			v3,
			nil,
			nil,
			15,
			nil,
			RaycastHelper.Crater
		)
		local CF = CFrame.new(maximizeRayServer, maximizeRayServer + (v4 or createVector(0, 1, 0))) * CFrame.Angles(
			-1.5707963267948966,
			0,
			0
		)
		state.CF = CF
		EffectsEvent.ToAllInRange(player, "Arrow Flight VFX", character, "rockup", CF, v5)
		Skill_Switch_Adder.Add(player, script.Parent.Name, Config.ROCKUP_LIFETIME)
		state.DeletionThread = task.delay(Config.ROCKUP_LIFETIME, function()
			EffectsEvent.ToAllInRange(player, "Arrow Flight VFX", character, "expired", CF, v5)

			if state.CF ~= nil then
				state.CF = nil
			end

			if state.DeletionThread ~= nil then
				state.DeletionThread = nil
			end
		end)
	end

	state.Flight = nil
end

function ArrowFlightServer.Cancel(player, _, p)
	if p.Link ~= nil and p.Link.__Active then
		p.Link:Destroy()
	end

	p.Link = nil
	p.Thread = nil
	p.Flight = nil
	p.Direction = nil
	p.explode = nil
	EffectsEvent.ToAllInRange(player, "Arrow Flight VFX", player.Character, "Cancel")
	local child = game.Workspace.Debree.Projectiles:FindFirstChild(player.Name .. v)

	if child == nil then
		return
	end

	child:Destroy()
end

function ArrowFlightServer.Switch(player, p, state)
	local character = player.Character

	if character == nil then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	if state.CF ~= nil then
		if typeof(p) ~= "Vector3" then
			return
		end

		local v3 = Utility.SafeDirection(state.CF.Position + vector.create(0, Config.SWITCH_ROCK_HEIGHT, 0), p) or humanoidRootPart.CFrame.LookVector
		local vectorVelocity = v3 * Config.SWITCH_THROW_SPEED
		local v5 = nil
		local thread = nil
		EffectsEvent.ToAllInRange(
			player,
			"Arrow Flight VFX",
			character,
			"RockThrow",
			state.CF.Position + vector.create(0, Config.SWITCH_ROCK_HEIGHT, 0),
			vectorVelocity,
			v3
		)
		local connection = nil

		local function explode(vector2: Vector3, vector3: Vector3?)
			local v6 = vector3 or createVector(0, 1, 0)
			local v7 = CFrame.new(vector2, vector2 + v6) * CFrame.Angles(-1.5707963267948966, 0, 0)

			if connection ~= nil then
				connection:Disconnect()
				connection = nil
			end

			if v5 ~= nil and v5.IsActive then
				v5:Destroy()
			end

			Utility.CreateHitbox({
				caster = character,
				hitboxCFrame = v7 * Config.EXPLOSION_HITBOX_OFFSET,
				hitboxSize = Config.EXPLOSION_HITBOX_SIZE,
				checker = Checker,
				hitPriorityHandler = {
					callback = v2.Exists,
					data = "Choosing_1"
				},
				hitDetected = function(instance, p2, p3, _)
					if instance then
						local rootPart = instance:FindFirstChild("Humanoid").RootPart

						if p3 == true then
							local v8 = v6 * Config.EXPLOSION_NORMAL_KNOCKBACK + vector.normalize(humanoidRootPart.Position - rootPart.Position) * math.min(
								Config.EXPLOSION_PULL_MAX,
								vector.magnitude(humanoidRootPart.Position - rootPart.Position) * 2
							)
							Combat_Util.RagDoll(script2, character, p2, Config.EXPLOSION_RAGDOLL)
							Combat_Util.AddStun(script2, character, p2, Config.EXPLOSION_STUN)
							Combat_Util.Damage(script2, character, instance, {
								Base = Config.EXPLOSION_DAMAGE,
								Skill = script.Parent.Name
							})
							Combat_Util.Knockback(script2, character, rootPart, v8, 0.15)
						elseif p3 == "Blocking" then
							Combat_Util.Block(script2, character, instance, Config.EXPLOSION_BLOCK_BREAK)
						elseif p3 == "Perfect" then
							Combat_Util.Perfect(script, character, instance)
						end
					end
				end
			})
			thread = nil
		end

		v5 = ProjectileModeler.new({
			Size = Config.SWITCH_ROCK_SIZE,
			Massless = true,
			CanCollide = false,
			Transparency = 1,
			Name = player.Name .. v,
			CFrame = state.CF * CFrame.new(0, Config.SWITCH_ROCK_HEIGHT, 0),
			Mover = {
				MaxForce = 50000,
				VectorVelocity = vectorVelocity
			}
		}, function(p2, p3)
			if thread ~= nil then
				task.cancel(thread)
				thread = nil
			end

			explode(p2, p3)
		end, nil, ProjectileModeler.WhitelistType.HumanoidsAndMap, character, RaycastHelper.Crater)
		local instance = v5.Instance
		instance.TopSurface = Enum.SurfaceType.Smooth
		instance.BottomSurface = Enum.SurfaceType.Smooth
		instance:SetNetworkOwner(nil)
		thread = task.delay(Config.ROCK_EXPLODE_FUSE, function()
			local v6 = v3 * -1
			explode(instance.Position + v3 * vector.magnitude(instance.Size) / 2, v6)
		end)
		state.CF = nil
	end

	if state.DeletionThread ~= nil then
		task.cancel(state.DeletionThread)
		state.DeletionThread = nil
	end
end

return ArrowFlightServer