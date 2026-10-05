local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local Checker = require(CAM.Global.Checker)
local Utility = require(CAM.Global.Utility)
local Combat_Util = require(SAM.Services.Combat_Util)
local ProjectileModeler = require(CAM.Global.ProjectileModeler)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local Config = require(script.Parent.Config)
local TantoDescentServer = {
	Id = {}
}
local name = script.Parent.Name

function TantoDescentServer.Hold(player, _: Vector3?, p)
	if p.CleanIt then
		p.CleanIt:Clean()
	end

	local maid = cleanit.new()
	p.CleanIt = maid
	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local getvaluesfolder = Utility.getvaluesfolder(character)
	maid:Add(Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.THROW_FREEZE_AT + 0.5))
	EffectsEvent.ToAllInRange(humanoidRootPart, "Tanto Descent VFX", character, "Start", humanoidRootPart.CFrame)
end

function TantoDescentServer.UnHold(player, vector2: Vector3?, p)
	local cleanIt = p.CleanIt or cleanit.new()
	p.CleanIt = cleanIt
	local v = TantoDescentServer.Id[player.UserId]
	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local animator = character:FindFirstChild("Humanoid"):FindFirstChild("Animator")
	local getvaluesfolder = Utility.getvaluesfolder(character)
	local v2 = Config.PROJECTILE_LIFETIME + Config.GRAB_DURATION + 1
	cleanIt:Add(Utility.AddValue(getvaluesfolder, "pause_gameplay", v2))
	cleanIt:Add(Utility.AddValue(getvaluesfolder, "NR", v2))
	cleanIt:Add(Utility.AddValue(getvaluesfolder, "skill_stand_still", v2))
	task.wait(0.25)

	if TantoDescentServer.Id[player.UserId] ~= v then
		return
	end

	local v3 = nil

	if vector2 ~= nil then
		local _, _, _, v4 = RaycastHelper.MaximizeRayServer(
			character,
			humanoidRootPart.Position,
			vector2,
			Config.AIM_RANGE,
			true,
			Config.SPHERECAST_RADIUS,
			Config.DOWNCAST
		)

		if v4 ~= nil and v4 ~= character and v4:FindFirstChild("HumanoidRootPart") ~= nil and Checker.check_victim(
			script,
			character,
			v4
		) ~= nil then
			v3 = v4
		end
	end

	local unit

	if v3 == nil then
		if vector2 then
			unit = (vector2 - humanoidRootPart.Position).Unit
		else
			unit = humanoidRootPart.CFrame.LookVector
		end
	else
		unit = (v3.HumanoidRootPart.Position - humanoidRootPart.Position).Unit
	end

	local v4 = humanoidRootPart.Position + unit * 3
	local cframe = CFrame.lookAt(v4, v4 + unit)
	local v5 = nil
	local v6 = false
	local formatted = `{player.Name} TantoDescent`
	local v7 = ProjectileModeler.new({
		Name = formatted,
		Size = createVector(12, 12, 12),
		CFrame = cframe,
		Mover = {
			MaxForce = 1000000000,
			VectorVelocity = unit * Config.PROJECTILE_SPEED
		},
		Rotator = {
			CFrame = cframe
		}
	}, function(_, _, p2)
		if TantoDescentServer.Id[player.UserId] ~= v then
			return true
		end

		if p2 == nil or v5 ~= nil then
			return false
		end

		local find_character_from_descendant = Utility.find_character_from_descendant(p2)

		if find_character_from_descendant == nil or find_character_from_descendant == character then
			return false
		end

		local check_victim = Checker.check_victim(script, character, find_character_from_descendant)

		if check_victim == "Perfect" then
			Combat_Util.Perfect(script, character, find_character_from_descendant)
			return true
		elseif check_victim == "Blocking" then
			Combat_Util.Block(script, character, find_character_from_descendant, Config.BLOCK_BREAK)
			return true
		end

		if not (check_victim == true and find_character_from_descendant:FindFirstChild("HumanoidRootPart") ~= nil) then
			return false
		end

		v5 = find_character_from_descendant
		local humanoid = find_character_from_descendant:FindFirstChild("Humanoid")
		v6 = find_character_from_descendant.HumanoidRootPart:FindFirstChild("air_combo_bp") ~= nil or humanoid.FloorMaterial == Enum.Material.Air or humanoid.FloorMaterial == nil
		Combat_Util.Damage(script, character, find_character_from_descendant, {
			Base = Config.LAND_DAMAGE,
			Skill = name
		})
		EffectsEvent.ToAllInRange(
			find_character_from_descendant.HumanoidRootPart,
			"Tanto Descent VFX",
			character,
			"Stick",
			find_character_from_descendant
		)
		return true
	end, Config.PROJECTILE_LIFETIME, ProjectileModeler.WhitelistType.Humanoids, character)

	if v7.Instance then
		v7.Instance:SetNetworkOwner(player)
	end

	cleanIt:Add(v7)

	if v3 ~= nil then
		task.spawn(function()
			while v7.IsActive and TantoDescentServer.Id[player.UserId] == v do
				local instance = v7.Instance

				if instance == nil or instance.Parent == nil then
					break
				end

				local humanoidRootPart2 = v3:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart2 == nil or humanoidRootPart2.Parent == nil then
					break
				end

				local v8 = humanoidRootPart2.Position - instance.Position

				if v8.Magnitude > 0.1 then
					local unit2 = v8.Unit

					if v7.Mover ~= nil then
						v7.Mover.VectorVelocity = unit2 * Config.PROJECTILE_SPEED
					end

					if v7.Rotator ~= nil then
						v7.Rotator.CFrame = Utility.SafeLookAt(
							instance.Position,
							humanoidRootPart2.Position,
							instance.CFrame
						)
					end
				end

				task.wait(Config.TRACK_TICK)
			end
		end)
	end

	local v8 = Utility.AddValue(getvaluesfolder, "InvisibleItem", v2, "StringValue", "Tanto")
	cleanIt:Add(v8)
	EffectsEvent.ToAllInRange(humanoidRootPart, "Tanto Descent VFX", character, "Throw", formatted)
	v7.Destroying:Wait()

	if TantoDescentServer.Id[player.UserId] ~= v then
		return
	end

	local v9 = v5

	if v9 == nil then
		cleanIt:Clean()
		return
	end

	local humanoid = v9:FindFirstChild("Humanoid")
	local humanoidRootPart2 = v9:FindFirstChild("HumanoidRootPart")

	if humanoid == nil or humanoidRootPart2 == nil then
		cleanIt:Clean()
		return
	end

	local getvaluesfolder2 = Utility.getvaluesfolder(v9)
	local animator2 = humanoid:FindFirstChild("Animator")
	local v10 = Utility.lock(humanoidRootPart2, humanoidRootPart2.CFrame, Config.GRAB_DURATION)
	local v11 = Utility.AddValue(getvaluesfolder2, "noragdoll", Config.GRAB_DURATION)
	cleanIt:Add(v10)
	cleanIt:Add(v11)
	cleanIt:Add(Utility.AddValue(getvaluesfolder2, "NR", Config.GRAB_DURATION))
	cleanIt:Add(Utility.AddValue(getvaluesfolder2, "pause_gameplay", Config.GRAB_DURATION))
	cleanIt:Add(Utility.AddValue(getvaluesfolder2, "iframe", Config.GRAB_DURATION, "StringValue", character.Name))
	cleanIt:Add(Utility.AddValue(getvaluesfolder, "iframe", Config.GRAB_DURATION))
	cleanIt:Add(Utility.AddValue(getvaluesfolder2, "skill_stand_still", Config.GRAB_DURATION))

	if v6 then
		cleanIt:Add(Combat_Util.Add_air_combo_bp(
			humanoidRootPart2,
			nil,
			0,
			humanoidRootPart2.Position,
			Config.GRAB_DURATION
		))
	end

	Combat_Util.Cancel(script, getvaluesfolder2)
	local track = animator2:LoadAnimation(script.Victim)
	track:Play()
	cleanIt:Add(track)
	local air_combo_bp = humanoidRootPart:FindFirstChild("air_combo_bp")

	if air_combo_bp then
		air_combo_bp:Destroy()
	end

	local attachment = Instance.new("Attachment")
	attachment.Name = "air_combo_bp"
	local alignPosition = Instance.new("AlignPosition")
	alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
	alignPosition.MaxAxesForce = Vector3.new(Config.ALIGN_FORCE, Config.ALIGN_FORCE, Config.ALIGN_FORCE)
	alignPosition.Responsiveness = Config.ALIGN_RESPONSIVENESS
	alignPosition.Attachment0 = attachment
	alignPosition.Parent = attachment
	attachment.Parent = humanoidRootPart
	cleanIt:Add(function()
		attachment:Destroy()

		if humanoidRootPart.Parent then
			humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
			humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
		end
	end)
	local position = humanoidRootPart.Position
	local v12 = (humanoidRootPart2.Position - position) * createVector(1, 0, 1)
	local magnitude = v12.Magnitude
	local unit2 = v12.Unit
	local alignOrientationWithAttachment, v13 = Utility.CreateAlignOrientationWithAttachment(
		humanoidRootPart,
		"skill_look_at",
		{
			AlignType = Enum.AlignType.PrimaryAxisParallel,
			Responsiveness = 40,
			MaxTorque = 500000,
			CFrame = CFrame.lookAt(position, position + unit2)
		}
	)
	cleanIt:Add(alignOrientationWithAttachment)
	cleanIt:Add(v13)
	local track2 = animator:LoadAnimation(script.Hit)
	track2:Play()
	cleanIt:Add(track2)
	local vector3 = Vector3.new(-unit2.Z, 0, unit2.X)
	local v14 = { "Dash1", "Dash2", "Dash3" }
	local v15 = { 1, -1 }
	local v16 = { 0.35, 0.48, 0.2 }

	for i = 1, #v14 do
		if TantoDescentServer.Id[player.UserId] ~= v then
			return
		end

		if humanoidRootPart2.Parent == nil then
			break
		end

		local v17

		if i < #v14 then
			v17 = position + unit2 * (magnitude * (i / #v14)) + vector3 * (Config.ZIGZAG_WIDTH * v15[i])
		else
			v17 = humanoidRootPart2.Position - unit2 * Config.ARRIVE_DIST
		end

		local vector4 = Vector3.new(v17.X, humanoidRootPart2.Position.Y, v17.Z)
		alignPosition.Position = vector4
		EffectsEvent.ToAllInRange(humanoidRootPart, "Tanto Descent VFX", character, v14[i], vector4)
		task.wait(v16[i])
	end

	if TantoDescentServer.Id[player.UserId] ~= v then
		return
	end

	if v8.Parent then
		v8:Destroy()
	end

	EffectsEvent.ToAllInRange(humanoidRootPart, "Tanto Descent VFX", character, "Grab", humanoidRootPart.CFrame)
	task.wait(0.6)

	if TantoDescentServer.Id[player.UserId] ~= v then
		return
	end

	if v10 and v10.Parent then
		v10:Destroy()
	end

	if v11 and v11.Parent then
		v11:Destroy()
	end

	if humanoidRootPart2.Parent ~= nil then
		for _, child in humanoidRootPart2:GetChildren() do
			if child.Name == "air_combo_bp" then
				child:Destroy()
			end
		end
	end

	EffectsEvent.ToAllInRange(humanoidRootPart, "Tanto Descent VFX", character, "Kick", humanoidRootPart.CFrame)

	if v9.Parent ~= nil and humanoidRootPart2.Parent ~= nil and Checker.check_victim(script, character, v9) == true then
		Combat_Util.Damage(script, character, v9, {
			Base = Config.KICK_DAMAGE,
			Skill = name
		})
		Combat_Util.AddStun(script, character, getvaluesfolder2, Config.KICK_STUN)
		Combat_Util.RagDoll(script, character, getvaluesfolder2, Config.KICK_STUN)
		local v17 = (humanoidRootPart2.Position - humanoidRootPart.Position) * createVector(1, 0, 1)
		local v18

		if v17.Magnitude > 0.001 then
			v18 = v17.Unit
		else
			v18 = Vector3.new(humanoidRootPart.CFrame.LookVector.X, 0, humanoidRootPart.CFrame.LookVector.Z).Unit
		end

		Combat_Util.Knockback(
			script,
			character,
			humanoidRootPart2,
			v18 * Config.KICK_KNOCKBACK + Vector3.new(0, Config.KICK_UPWARD, 0),
			0.25,
			"combat_knockbackLast"
		)
	end

	task.wait(0.49)

	if TantoDescentServer.Id[player.UserId] ~= v then
		return
	end

	cleanIt:Clean()
end

function TantoDescentServer.Cancel(player, _: Vector3?, p)
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and character then
		EffectsEvent.ToAllInRange(humanoidRootPart, "Tanto Descent VFX", character, "Cancel")
	end

	if p.CleanIt then
		p.CleanIt:Clean()
	end
end

return TantoDescentServer