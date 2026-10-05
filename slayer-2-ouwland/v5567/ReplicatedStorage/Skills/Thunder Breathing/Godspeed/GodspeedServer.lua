local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
game:GetService("RunService")
game:GetService("CollectionService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage:WaitForChild("CAM")
local SAM = ServerStorage:WaitForChild("SAM")
local global = CAM:WaitForChild("Global")
local services = SAM:WaitForChild("Services")
local EffectsEvent = require(ReplicatedStorage2.Communication.ServerAndClient.Effects.EffectsEvent)
local Utility = require(global.Utility)
local RaycastHelper = require(global.RaycastHelper)
local Checker = require(global.Checker)
local CombatMode = require(global.CombatMode)
local ManuelCancel = require(global.Subsets.Gameplay.ManuelCancel)
local Combat_Util = require(services.Combat_Util)
require(CAM.Global.Combat_presets)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local DebrisModule = require(CAM:FindFirstChild("DebrisModule"))
local Config = require(script.Parent.Config)
local GodspeedServer = {
	Id = {}
}

function GodspeedServer.Hold(player, _, p)
	if not player then
		return
	end

	local character = player.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local humanoid = character:FindFirstChild("Humanoid")

	if humanoid == nil then
		return
	end

	local getvaluesfolder = Utility.getvaluesfolder(character)
	local v2 = GodspeedServer.Id[player.UserId]
	EffectsEvent.ToAllInRange(player, "Godspeed_VFX", character, "Start")
	local stringValue = Instance.new("StringValue")
	stringValue.Name = "Transparent"
	stringValue.Value = script.Parent.Name
	stringValue.Parent = getvaluesfolder
	DebrisModule:AddItem(stringValue, Config.HOLD_MAX_DUR)
	p.Invis = stringValue
	local v3 = Utility.AddValue(
		getvaluesfolder,
		"Stamina Drain Rate",
		Config.HOLD_MAX_DUR,
		"NumberValue",
		Config.STAMINA_DRAIN_RATE
	)
	local instances = {}
	local count = 0
	local v4 = nil

	local function fn(instance, p2, p3, _)
		if instance then
			local humanoid2 = instance:FindFirstChild("Humanoid")
			local rootPart = humanoid2.RootPart

			if p3 == "Blocking" then
				Combat_Util.Block(script, character, instance, Config.BLOCK_BREAK)
			elseif p3 == "Perfect" then
				Combat_Util.Perfect(script, character, instance)
			elseif p3 == true then
				count += 1

				if count == 1 then
					v4 = RaycastHelper.ResolveGrabPin(
						humanoidRootPart.Position,
						humanoidRootPart.CFrame,
						Config.GRAB_WALL_CLEARANCE
					)

					if stringValue ~= nil then
						stringValue:Destroy()
						stringValue = nil
					end

					if v3 ~= nil then
						v3:Destroy()
						v3 = nil
					end

					EffectsEvent.ToClient(player, "force_skill_actions_server", script.Parent.Name, "UnHold")
					Utility.lock(humanoidRootPart, v4, Config.ANIM_DURATION)
					humanoid.Animator:LoadAnimation(script.User):Play()
					Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.ANIM_DURATION)
					Utility.AddValue(getvaluesfolder, "iframe", Config.ANIM_DURATION)
				end

				table.insert(instances, instance)
				local animator = humanoid2:FindFirstChild("Animator")

				if animator then
					animator:LoadAnimation(script.Victim):Play(0.1, 1, 0.5)
				end

				local v5 = Utility.AddValue(p2, "noragdoll", Config.ANIM_DURATION)
				local v6 = Utility.lock(rootPart, v4, Config.ANIM_DURATION)
				local v7 = Utility.AddValue(p2, "pause_gameplay", Config.ANIM_DURATION)
				local v8 = Utility.AddValue(p2, "iframe", Config.ANIM_DURATION, "StringValue", player.Name)
				task.delay(Config.FINAL_HIT_AT, function()
					if Checker.check_victim(script, character, instance) ~= nil then
						local v9 = v4.lookVector * Config.FINAL_KNOCKBACK + vector.create(0, Config.FINAL_KNOCKUP, 0)

						if v6 ~= nil then
							v6:Destroy()
							v6 = nil
						end

						if v7 ~= nil then
							v7:Destroy()
							v7 = nil
						end

						if v8 ~= nil then
							v8:Destroy()
							v8 = nil
						end

						if v5 ~= nil then
							v5:Destroy()
							v5 = nil
						end

						Combat_Util.AddStun(script, character, p2, Config.FINAL_STUN)
						Combat_Util.Damage(script, character, instance, {
							Base = Config.FINAL_DAMAGE,
							Skill = script.Parent.Name
						})
						Combat_Util.RagDoll(script, character, p2, Config.FINAL_RAGDOLL)
						Combat_Util.Knockback(script, character, rootPart, v9, Config.FINAL_KNOCKBACK_DUR)
					end
				end)
			end
		end
	end

	local lastTime = os.clock()
	local DASH_HITBOX_SIZE = Config.DASH_HITBOX_SIZE
	local stamina = getvaluesfolder:FindFirstChild("Stamina")
	local v5 = false
	local v6, v7 = ManuelCancel.new(player, Config.HOLD_MAX_DUR)
	v6:Connect(function()
		v5 = true
	end)
	local v8 = not CombatMode.IsRanked(player) and 0 or Config.RANKED_WINDUP
	task.spawn(function()
		if v8 > 0 then
			task.wait(v8)
		end

		while v2 == GodspeedServer.Id[player.UserId] and not v5 and os.clock() - lastTime < Config.HOLD_MAX_DUR and count == 0 do
			Utility.CreateHitbox({
				caster = character,
				hitboxCFrame = humanoidRootPart.CFrame * Config.DASH_HITBOX_OFFSET,
				hitboxSize = DASH_HITBOX_SIZE,
				After = function()
					if count > 0 then
						EffectsEvent.ToAllInRange(player, "Godspeed_VFX", character, "Success", nil, instances)
					end
				end,
				checker = Checker,
				hitPriorityHandler = {
					callback = v.Exists,
					data = "Choosing_1"
				},
				hitDetected = fn
			})
			task.wait(Config.SCAN_INTERVAL)

			if not (stamina ~= nil and stamina.Value <= 0) then
				continue
			end

			EffectsEvent.ToClient(player, "force_skill_actions_server", script.Parent.Name, "UnHold")
			break
		end

		v7()

		if stringValue ~= nil then
			stringValue:Destroy()
			stringValue = nil
		end

		if v3 ~= nil then
			v3:Destroy()
			v3 = nil
		end
	end)
end

function GodspeedServer.UnHold(player, _, _)
	if not player then
		return
	end

	local character = player.Character

	if not character then
		return
	end

	EffectsEvent.ToAllInRange(player, "Godspeed_VFX", character, "Cancel")
end

function GodspeedServer.Cancel(player, _, p)
	if not player then
		return
	end

	local character = player.Character

	if not character then
		return
	end

	EffectsEvent.ToAllInRange(player, "Godspeed_VFX", character, "Cancel")

	if p ~= nil and p.Invis ~= nil then
		p.Invis:Destroy()
		p.Invis = nil
	end
end

return GodspeedServer