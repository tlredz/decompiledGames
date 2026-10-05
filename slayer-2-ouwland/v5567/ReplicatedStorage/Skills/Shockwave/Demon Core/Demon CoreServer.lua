local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local ManuelCancel = require(CAM.Global.Subsets.Gameplay.ManuelCancel)
local Server_Mouse_Pos = require(SAM.Services.Server_Mouse_Pos)
local Combat_Util = require(SAM.Services.Combat_Util)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local Combat_presets = require(CAM.Global.Combat_presets)
local ProjectileModeler = require(CAM.Global.ProjectileModeler)
local Checker = require(CAM.Global.Checker)
local Utility = require(CAM.Global.Utility)
local cleanit = require(game.ReplicatedStorage.Packages.cleanit)
local DebrisModule = require(CAM.DebrisModule)
local Config = require(script.Parent.Config)
local DemonCoreServer = {
	Id = {}
}
local demonCorep2 = script.DemonCorep2

local function spawnCloseWave(caster, p2, vector2: Vector3, vector3: Vector3)
	local v2 = {}
	local hitboxCFrame = CFrame.lookAt(vector3, vector3 + vector2) * CFrame.new(0, 0, -5)
	Utility.CreateHitbox({
		caster = caster,
		hitboxCFrame = hitboxCFrame,
		hitboxSize = Config.BARRAGE_CLOSE_WAVE_SIZE,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = function(instance, p3, p4)
			if v2[instance] then
				return
			end

			v2[instance] = true
			local humanoid = instance:FindFirstChild("Humanoid")
			local rootPart = humanoid and humanoid.RootPart

			if p4 == "Perfect" then
				Combat_Util.Perfect(script, caster, instance)
			elseif p4 == "Blocking" then
				Combat_Util.Block(script, caster, instance, 0.25)
			elseif p4 == true then
				EffectsEvent.ToAllInRange(p2, "Normal_Punch_Effect", rootPart, -1)
				Combat_Util.Damage(script, caster, instance, {
					Base = Config.BARRAGE_CLOSE_WAVE_DAMAGE,
					Skill = script.Parent.Name
				})
				Combat_Util.AddStun(script, caster, p3, 0.4)
				Combat_Util.Knockback(
					script,
					caster,
					rootPart,
					vector2 * Config.BARRAGE_CLOSE_WAVE_KNOCKBACK + createVector(0, 0.1, 0),
					0.5
				)
				Combat_presets.PlayReactAnim(humanoid)
			end
		end
	})
end

local function spawnFinisherWave(character, rootPart, p, cframe: CFrame)
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = cframe,
		hitboxSize = Config.BARRAGE_CLOSE_WAVE_FINISH_SIZE,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = function(instance, p2, p3)
			if p[instance] then
				return
			end

			p[instance] = true
			local humanoid = instance:FindFirstChild("Humanoid")
			local rootPart2 = humanoid and humanoid.RootPart

			if p3 == "Perfect" then
				Combat_Util.Perfect(script, character, instance)
			elseif p3 == "Blocking" then
				Combat_Util.Block(script, character, instance, 1)
			elseif p3 == true then
				EffectsEvent.ToAllInRange(rootPart, "Normal_Punch_Effect", rootPart2, -1)
				Combat_Util.Damage(script, character, instance, {
					Base = Config.BARRAGE_CLOSE_WAVE_DAMAGE,
					Skill = script.Parent.Name
				})
				Combat_Util.AddStun(script, character, p2, 0.4)
				Combat_Util.Knockback(
					script,
					character,
					rootPart2,
					cframe.LookVector * Config.BARRAGE_CLOSE_WAVE_FINISH_KNOCKBACK,
					0.15
				)
				Combat_Util.RagDoll(script, character, p2, 1.5)
			end
		end
	})
end

local function startBarrage(player, p, position: Vector3, state, p2: number)
	local character = player.Character
	local humanoid = character:FindFirstChild("Humanoid")
	local rootPart = humanoid.RootPart
	local getvaluesfolder = Utility.getvaluesfolder(character)
	local cleanIt = state.CleanIt

	if not cleanIt then
		return
	end

	if state.barrageTrack then
		state.barrageTrack:Stop()
		state.barrageTrack:Destroy()
		state.barrageTrack = nil
	end

	local v2 = 0.25 / Config.BARRAGE_ANIM_SPEED
	local v3 = 1.7 / Config.BARRAGE_ANIM_SPEED
	local v4 = 2.12 / Config.BARRAGE_ANIM_SPEED
	local v5 = 2.57 / Config.BARRAGE_ANIM_SPEED
	cleanIt:Add(Utility.AddValue(getvaluesfolder, "Transparency", 0.3))
	cleanIt:Add(Utility.AddValue(getvaluesfolder, "pause_gameplay", v5))
	cleanIt:Add(Utility.AddValue(getvaluesfolder, "NR", v5 + 0.1))
	local animator = humanoid:FindFirstChild("Animator")

	if animator and demonCorep2 then
		state.barrageTrack = animator:LoadAnimation(demonCorep2)
		state.barrageTrack:Play()
		state.barrageTrack:AdjustSpeed(Config.BARRAGE_ANIM_SPEED)
		cleanIt:Add(state.barrageTrack)
		DebrisModule:AddItem(state.barrageTrack, v5 + 1)
	end

	local attachment = Instance.new("Attachment")
	attachment.Name = "air_combo_bp"
	cleanIt:Add(attachment)
	DebrisModule:AddItem(attachment, v5 + 1)
	local unit = ((p.Position - rootPart.Position) * createVector(1, 0, 1)).Unit
	rootPart.CFrame = Utility.SafeLookAt(rootPart.Position, rootPart.Position + unit, rootPart.CFrame)
	local alignPosition = Instance.new("AlignPosition")
	alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
	alignPosition.MaxAxesForce = createVector(20000, 20000, 20000)
	alignPosition.Responsiveness = 45
	alignPosition.Attachment0 = attachment
	alignPosition.Parent = attachment
	alignPosition.Position = p.Position - unit * 4
	cleanIt:Add(alignPosition)
	DebrisModule:AddItem(alignPosition, v5 + 1)
	attachment.Parent = rootPart
	cleanIt:Add(function()
		if rootPart then
			rootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
			rootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
		end
	end)
	local position2 = alignPosition.Position

	local function currentDirection()
		local aim = Server_Mouse_Pos.Aim(character, script.Parent.Name, Config.MOUSE_RANGE)

		if aim ~= nil then
			local v6 = (aim - position2) * createVector(1, 0, 1)

			if v6.Magnitude >= 0.01 then
				return v6.Unit
			end
		end

		return unit
	end

	EffectsEvent.ToAllInRange(rootPart, "Demon Core VFX", character, "Finish", position, true, p, unit)
	local v6 = (v3 - v2) / Config.BARRAGE_HIT_COUNT
	task.wait(v2)

	if DemonCoreServer.Id[player.UserId] ~= p2 then
		return
	end

	for i = 1, Config.BARRAGE_HIT_COUNT do
		if DemonCoreServer.Id[player.UserId] ~= p2 then
			return
		end

		local aim = Server_Mouse_Pos.Aim(character, script.Parent.Name, Config.MOUSE_RANGE)
		local unit2

		if aim == nil then
			unit2 = unit
		else
			local v8 = (aim - position2) * createVector(1, 0, 1)

			if v8.Magnitude >= 0.01 then
				unit2 = v8.Unit
			else
				unit2 = unit
			end
		end

		spawnCloseWave(character, rootPart, unit2, position2)

		if not (i < Config.BARRAGE_HIT_COUNT) then
			continue
		end

		task.wait(v6)

		if DemonCoreServer.Id[player.UserId] ~= p2 then
			return
		end
	end

	local v7 = v4 - v3
	task.wait(v7)

	if DemonCoreServer.Id[player.UserId] ~= p2 then
		return
	end

	local v8 = {}
	local v9 = (v5 - v4) / 2
	local aim = Server_Mouse_Pos.Aim(character, script.Parent.Name, Config.MOUSE_RANGE)

	if aim ~= nil then
		local v10 = (aim - position2) * createVector(1, 0, 1)

		if v10.Magnitude >= 0.01 then
			unit = v10.Unit
		end
	end

	local cframe = CFrame.lookAt(position2, position2 + unit)
	local Z = Config.BARRAGE_CLOSE_WAVE_FINISH_SIZE.Z

	for i = 0, 2 do
		if DemonCoreServer.Id[player.UserId] ~= p2 then
			return
		end

		spawnFinisherWave(character, rootPart, v8, cframe * CFrame.new(0, 0, -Z * i - 5))
		task.wait(v9)
	end

	if DemonCoreServer.Id[player.UserId] ~= p2 then
		return
	end

	cleanIt:Clean()
end

function DemonCoreServer.Hold(player, _: Vector3, state)
	if state.CleanIt then
		state.CleanIt:Destroy()
	end

	local maid = cleanit.new()
	state.CleanIt = maid
	local character = player.Character
	local rootPart = character:FindFirstChild("Humanoid").RootPart
	Server_Mouse_Pos.Create_Pos_Part(character, script.Parent.Name, 6)
	maid:Add(function()
		Server_Mouse_Pos.Delete_Pos_Part(character, script.Parent.Name)
	end)
	state.airHold = Combat_Util.Add_air_combo_bp(rootPart, nil, Config.UPDRAFT_HEIGHT, nil, Config.UPDRAFT_DURATION)
	maid:Add(state.airHold)
	EffectsEvent.ToAllInRange(rootPart, "Demon Core VFX", character, "Start", rootPart.CFrame)
end

function DemonCoreServer.UnHold(player, vector2: Vector3, state)
	local cleanIt = state.CleanIt

	if not cleanIt then
		return
	end

	local v2 = DemonCoreServer.Id[player.UserId]
	local character = player.Character
	local rootPart = character:FindFirstChild("Humanoid").RootPart
	local v3 = (1.35 - Config.FREEZE_MARK) / Config.RELEASE_SPEED
	local getvaluesfolder = Utility.getvaluesfolder(character)
	local v4, v5 = ManuelCancel.new(player, 3)
	v4:Connect(function()
		DemonCoreServer.Id[player.UserId] = -1
		DemonCoreServer.Cancel(player, vector2, state)
	end)
	cleanIt:Add(v5)
	local v6 = Utility.AddValue(getvaluesfolder, "skillsdisabled", 7, "StringValue", "all")
	cleanIt:Add(v6)
	task.wait(v3)

	if DemonCoreServer.Id[player.UserId] ~= v2 then
		return
	end

	if state.airHold then
		cleanIt:Remove(state.airHold)
		state.airHold:Destroy()
		state.airHold = nil
	end

	local flag = false

	local function projectileOnHit(position: Vector3?, vector3: Vector3?, p)
		if v2 ~= DemonCoreServer.Id[player.UserId] or flag then
			return true
		end

		flag = true
		cleanIt:Remove(v6)
		v6:Destroy()
		local humanoidRootPart = nil
		local v7

		if p then
			v7 = Utility.find_character_from_descendant(p)

			if v7 then
				humanoidRootPart = v7:FindFirstChild("HumanoidRootPart")
			end
		end

		if humanoidRootPart then
			position = humanoidRootPart.Position
		end

		if humanoidRootPart then
			vector3 = nil
		end

		EffectsEvent.ToAllInRange(rootPart, "Demon Core VFX", character, "Impact", position, vector3)
		local v8 = nil
		local v9 = 1e999
		Utility.CreateHitbox({
			caster = character,
			hitboxCFrame = CFrame.new(position),
			hitboxSize = Config.PROJECTILE_AOE_SIZE,
			checker = Checker,
			hitPriorityHandler = {
				callback = v.Exists,
				data = "Choosing_1"
			},
			targets = v7 and { v7 } or nil,
			hitDetected = function(instance, p2, p3)
				local rootPart2 = instance:FindFirstChild("Humanoid").RootPart

				if p3 == "Perfect" then
					Combat_Util.Perfect(script, character, instance)
				elseif p3 == true or p3 == "Blocking" then
					local magnitude = (rootPart2.Position - position).Magnitude

					if magnitude < v9 then
						v9 = magnitude
						v8 = rootPart2
					end

					if p3 == "Blocking" then
						Combat_Util.Block(script, character, instance, 1)
					else
						Combat_Util.Damage(script, character, instance, {
							Base = Config.PROJECTILE_DAMAGE,
							Skill = script.Parent.Name
						})
						Combat_Util.Add_Strict_Stun(script, character, p2, Config.PROJECTILE_STUN, true)
					end
				end
			end
		})

		if v8 then
			startBarrage(player, v8, position, state, v2)
		else
			cleanIt:Destroy()
			state.CleanIt = nil
		end

		return true
	end

	local v7 = Server_Mouse_Pos.Aim(character, script.Parent.Name, Config.MOUSE_RANGE, vector2) or rootPart.Position + rootPart.CFrame.LookVector
	local position = rootPart.Position
	local lookVector

	if (v7 - position).Magnitude <= 0.01 then
		lookVector = rootPart.CFrame.LookVector
	else
		lookVector = (v7 - position).Unit
	end

	local cFrame = CFrame.lookAt(position, position + lookVector) * CFrame.new(0, 0, -4)
	local formatted = `{player.Name} Demon Core Projectile`
	local projectile = ProjectileModeler.new({
		Name = formatted,
		Size = Config.PROJECTILE_SIZE,
		CFrame = cFrame,
		Mover = {
			MaxForce = 1000000000,
			VectorVelocity = lookVector * Config.PROJECTILE_SPEED
		},
		Rotator = {
			Responsiveness = 75,
			CFrame = CFrame.lookAt(cFrame.Position, cFrame.Position + lookVector)
		}
	}, projectileOnHit, Config.PROJECTILE_DURATION, ProjectileModeler.WhitelistType.HumanoidsAndMap, character, RaycastHelper.Crater)
	projectile.Instance:SetNetworkOwner(player)
	v5()
	state.projectile = projectile
	EffectsEvent.ToAllInRange(
		rootPart,
		"Demon Core VFX",
		character,
		"WaveLong",
		v7,
		formatted,
		projectile.Instance,
		lookVector,
		projectile.Instance
	)
	task.delay(Config.PROJECTILE_DURATION, function()
		if not flag then
			if projectile.IsActive then
				projectile:Destroy()
			end

			DemonCoreServer.Cancel(player, vector2, state)
		end
	end)
end

function DemonCoreServer.Cancel(player, _: Vector3?, p)
	local cleanIt = p.CleanIt
	EffectsEvent.ToAllInRange(player, "Demon Core VFX", player.Character, "Cancel")

	if cleanIt ~= nil then
		cleanIt:Destroy()
		p.CleanIt = nil
	end
end

return DemonCoreServer