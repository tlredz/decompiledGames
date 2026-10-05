game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("CollectionService")
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local Checker = require(CAM.Global.Checker)
local Utility = require(CAM.Global.Utility)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local Combat_presets = require(CAM.Global.Combat_presets)
require(CAM.DebrisModule)
require(SAM.Utility.SkillStorage)
local Combat_Util = require(SAM.Services.Combat_Util)
local ImpactSounds = require(SAM.Utility.ImpactSounds)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local ManuelCancel = require(CAM.Global.Subsets.Gameplay.ManuelCancel)
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local Config = require(script.Parent.Config)
local StoneWallServer = {
	Id = {}
}

function StoneWallServer.Hold(player, _: Vector3, p)
	local character = player.Character
	local _ = character:FindFirstChild("Humanoid").RootPart
	Utility.AddValue(Utility.getvaluesfolder(character), "CounterWindup", Config.WINDUP)
	local v2 = StoneWallServer.Id[player.UserId]
	p.startClock = os.clock()
	task.delay(Config.HOLD_DURATION, function()
		if StoneWallServer.Id[player.UserId] == v2 then
			EffectsEvent.ToAllInRange(player, "Stone GrabVfx", character, "Start")
		end
	end)
end

require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.CharGrabPosCorrector)

function StoneWallServer.Counter(player, _, instance)
	if player == nil or player.Character == nil then
		return
	end

	local character = player.Character
	local humanoidRootPart = player.Character.HumanoidRootPart
	local _ = humanoidRootPart.CFrame
	local humanoidRootPart2 = instance.HumanoidRootPart
	local getvaluesfolder = Utility.getvaluesfolder(instance)
	local getvaluesfolder2 = Utility.getvaluesfolder(player)
	local humanoid = character:FindFirstChild("Humanoid")
	local humanoid2 = instance:FindFirstChild("Humanoid")
	local grabPin = RaycastHelper.ResolveGrabPin(
		humanoidRootPart.Position,
		humanoidRootPart.CFrame,
		Config.GRAB_WALL_CLEARANCE
	)
	EffectsEvent.ToAllInRange(player, "Stone GrabVfx", character, "Hit", instance)
	Utility.lock(humanoidRootPart, grabPin, Config.GRAB_DURATION)
	humanoid.Animator:LoadAnimation(script.StoneGrabUser):Play()
	Utility.AddValue(getvaluesfolder2, "pause_gameplay", Config.GRAB_DURATION)
	Utility.AddValue(getvaluesfolder2, "iframe", Config.GRAB_DURATION)
	task.delay(Config.SLAM_VFX_AT, function()
		if character == nil or humanoidRootPart == nil or humanoidRootPart.Parent == nil then
			return
		end

		EffectsEvent.ToAllInRange(player, "Stone GrabVfx", character, "Slam")
	end)
	local animator = humanoid2:FindFirstChild("Animator")

	if animator then
		animator:LoadAnimation(script.StoneGrabTarget):Play()
	end

	local v2 = Utility.AddValue(getvaluesfolder, "noragdoll", Config.GRAB_DURATION)
	local v3 = Utility.lock(humanoidRootPart2, grabPin * Config.GRAB_VICTIM_OFFSET, Config.GRAB_DURATION)
	local v4 = Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.GRAB_DURATION)
	Combat_Util.Cancel(script, getvaluesfolder, true)
	local v5 = Utility.AddValue(getvaluesfolder, "iframe", Config.GRAB_DURATION, "StringValue", player.Name)
	local v6 = Utility.AddValue(getvaluesfolder, "InvisibleItem", Config.GRAB_DURATION, "StringValue", "all")
	task.delay(Config.SLAM_AT, function()
		if Checker.check_victim(script, character, instance) ~= nil then
			local v7 = grabPin.lookVector * Config.SLAM_KNOCKBACK + vector.create(0, Config.SLAM_KNOCKUP, 0)

			if v3 ~= nil then
				v3:Destroy()
				v3 = nil
			end

			if v4 ~= nil then
				v4:Destroy()
				v4 = nil
			end

			if v5 ~= nil then
				v5:Destroy()
				v5 = nil
			end

			if v2 ~= nil then
				v2:Destroy()
				v2 = nil
			end

			if v6 ~= nil then
				v6:Destroy()
				v6 = nil
			end

			Combat_Util.AddStun(script, character, getvaluesfolder, Config.SLAM_STUN)
			Combat_Util.Damage(script, character, instance, {
				Base = Config.SLAM_DAMAGE,
				Skill = script.Parent.Name
			})
			Combat_Util.RagDoll(script, character, getvaluesfolder, Config.SLAM_RAGDOLL)
			Combat_Util.Knockback(script, character, humanoidRootPart2, v7, Config.SLAM_KNOCKBACK_DURATION)
		end
	end)
end

function StoneWallServer.UnHold(player, vector2: Vector3, p)
	local character = player.Character
	local getvaluesfolder = Utility.getvaluesfolder(character)
	local humanoid = character:FindFirstChild("Humanoid")
	local rootPart = humanoid.RootPart
	local v2 = os.clock() - p.startClock
	local v3 = StoneWallServer.Id[player.UserId]
	local v4, v5 = ManuelCancel.new(player, 1.5)
	v4:Connect(function()
		v3 = -1
		StoneWallServer.Cancel(player, vector2, p)
	end)

	if v2 < Config.HOLD_DURATION then
		task.wait(Config.WALL_STARTUP)

		if StoneWallServer.Id[player.UserId] ~= v3 then
			return
		end

		EffectsEvent.ToAllInRange(player, "Stone WallVFX", character, "Wall")
		local hitboxCFrame = rootPart.CFrame * Config.WALL_HITBOX_OFFSET
		local instances = {}
		Utility.CreateHitbox({
			caster = character,
			hitboxCFrame = hitboxCFrame,
			hitboxSize = Config.WALL_HITBOX_SIZE,
			checker = Checker,
			hitPriorityHandler = {
				callback = v.Exists,
				data = "Choosing_1"
			},
			hitDetected = function(instance, p2, p3)
				if instance then
					local humanoid2 = instance:FindFirstChild("Humanoid")
					local rootPart2 = humanoid2.RootPart

					if p3 == "Blocking" then
						Combat_Util.Block(script, character, instance, Config.WALL_BLOCK_BREAK)
						Combat_Util.Knockback(
							script,
							character,
							rootPart2,
							rootPart.CFrame.lookVector * Config.WALL_BLOCK_KNOCKBACK,
							0.2
						)
					elseif p3 == "Perfect" then
						Combat_Util.Perfect(script, character, instance)
					elseif p3 == true then
						table.insert(instances, instance)
						local v7 = rootPart.CFrame.LookVector * Config.WALL_KNOCKBACK + vector.create(
							0,
							Config.WALL_KNOCKUP,
							0
						)
						Combat_Util.AddStun(script, character, p2, Config.WALL_STUN)
						Combat_Util.Damage(script, character, instance, {
							Base = Config.WALL_DAMAGE,
							Skill = script.Parent.Name
						})
						Combat_Util.Knockback(script, character, rootPart2, v7, Config.WALL_KNOCKBACK_DURATION)
						Combat_presets.PlayReactAnim(humanoid2)
					end
				end
			end,
			After = function(p2, list)
				if p2 then
					ImpactSounds.Play(character, script.Parent.Name, list[1])
				end
			end
		})
		task.wait(Config.BREAK_DELAY)

		if StoneWallServer.Id[player.UserId] ~= v3 then
			return
		end

		EffectsEvent.ToAllInRange(player, "Stone WallVFX", character, "Break")
		Utility.CreateHitbox({
			caster = character,
			hitboxCFrame = hitboxCFrame * Config.BREAK_HITBOX_OFFSET,
			hitboxSize = Config.BREAK_HITBOX_SIZE,
			targets = instances,
			checker = Checker,
			hitPriorityHandler = {
				callback = v.Exists,
				data = "Choosing_1"
			},
			hitDetected = function(instance, p2, p3)
				if instance then
					local rootPart2 = instance:FindFirstChild("Humanoid").RootPart

					if p3 == "Blocking" then
						Combat_Util.Block(script, character, instance, Config.BREAK_BLOCK_BREAK)
						Combat_Util.Knockback(
							script,
							character,
							rootPart2,
							rootPart.CFrame.lookVector * Config.BREAK_BLOCK_KNOCKBACK,
							0.2
						)
					elseif p3 == "Perfect" then
						Combat_Util.Perfect(script, character, instance)
					elseif p3 == true then
						table.insert(instances, instance)
						local v7 = rootPart.CFrame.LookVector * Config.BREAK_KNOCKBACK + vector.create(
							0,
							Config.BREAK_KNOCKUP,
							0
						)
						Combat_Util.AddStun(script, character, p2, Config.BREAK_STUN)
						Combat_Util.Damage(script, character, instance, {
							Base = Config.BREAK_DAMAGE,
							Skill = script.Parent.Name
						})
						Combat_Util.Knockback(script, character, rootPart2, v7, Config.BREAK_KNOCKBACK_DURATION)
						Combat_Util.RagDoll(script, character, p2, Config.BREAK_RAGDOLL)
						Utility.AddTimedValue(p2, "PierceBlock", Config.BREAK_PIERCE_DURATION):SetAttribute(
							"Skill",
							script.Parent.Name
						)
					end
				end
			end,
			After = function(p2, list)
				if p2 then
					ImpactSounds.Play(character, script.Parent.Name, list[1])
				end
			end
		})
	else
		local v6 = nil
		local count = 0
		Utility.CreateHitbox({
			caster = character,
			hitboxCFrame = rootPart.CFrame * Config.GRAB_HITBOX_OFFSET,
			hitboxSize = Config.GRAB_HITBOX_SIZE,
			After = function()
				if count == 0 then
					EffectsEvent.ToAllInRange(player, "Stone GrabVfx", character, "Miss")
				end
			end,
			checker = Checker,
			hitPriorityHandler = {
				callback = v.Exists,
				data = "Choosing_1"
			},
			hitDetected = function(instance, p2, p3, _)
				if instance then
					local humanoid2 = instance:FindFirstChild("Humanoid")
					local rootPart2 = humanoid2.RootPart

					if p3 == "Blocking" then
						Combat_Util.Block(script, character, instance, Config.GRAB_BLOCK_BREAK)
					elseif p3 == "Perfect" then
						Combat_Util.Perfect(script, character, instance)
					elseif p3 == true then
						count += 1

						if count == 1 then
							v6 = RaycastHelper.ResolveGrabPin(
								rootPart.Position,
								rootPart.CFrame,
								Config.GRAB_WALL_CLEARANCE
							)
							EffectsEvent.ToAllInRange(player, "Stone GrabVfx", character, "Hit", instance)
							Utility.lock(rootPart, v6, Config.GRAB_DURATION)
							humanoid.Animator:LoadAnimation(script.StoneGrabUser):Play()
							Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.GRAB_DURATION)
							Utility.AddValue(getvaluesfolder, "iframe", Config.GRAB_DURATION)
							task.delay(Config.SLAM_VFX_AT, function()
								if character == nil or rootPart == nil or rootPart.Parent == nil then
									return
								end

								EffectsEvent.ToAllInRange(player, "Stone GrabVfx", character, "Slam")
							end)
						end

						local animator = humanoid2:FindFirstChild("Animator")

						if animator then
							animator:LoadAnimation(script.StoneGrabTarget):Play()
						end

						local v7 = Utility.AddValue(p2, "noragdoll", Config.GRAB_DURATION)
						local v8 = Utility.AddValue(p2, "InvisibleItem", Config.GRAB_DURATION, "StringValue", "all")
						local v9 = Utility.lock(rootPart2, v6 * Config.GRAB_VICTIM_OFFSET, Config.GRAB_DURATION)
						local v10 = Utility.AddValue(p2, "pause_gameplay", Config.GRAB_DURATION)
						local v11 = Utility.AddValue(p2, "iframe", Config.GRAB_DURATION, "StringValue", player.Name)
						task.delay(Config.SLAM_AT, function()
							if Checker.check_victim(script, character, instance) ~= nil then
								local v12 = v6.lookVector * Config.SLAM_KNOCKBACK + vector.create(
									0,
									Config.SLAM_KNOCKUP,
									0
								)

								if v9 ~= nil then
									v9:Destroy()
									v9 = nil
								end

								if v8 ~= nil then
									v8:Destroy()
								end

								if v10 ~= nil then
									v10:Destroy()
									v10 = nil
								end

								if v11 ~= nil then
									v11:Destroy()
									v11 = nil
								end

								if v7 ~= nil then
									v7:Destroy()
									v7 = nil
								end

								Combat_Util.AddStun(script, character, p2, Config.SLAM_STUN)
								Combat_Util.Damage(script, character, instance, {
									Base = Config.SLAM_DAMAGE,
									Skill = script.Parent.Name
								})
								Combat_Util.RagDoll(script, character, p2, Config.SLAM_RAGDOLL)
								Combat_Util.Knockback(script, character, rootPart2, v12, Config.SLAM_KNOCKBACK_DURATION)
							end
						end)
					end
				end
			end
		})
	end

	v5()
end

function StoneWallServer.Cancel(player, _: Vector3, _)
	if player.Character == nil then
		return
	end

	EffectsEvent.ToAllInRange(player, "Stone GrabVfx", player.Character, "Cancel")
end

return StoneWallServer