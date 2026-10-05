local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("ServerStorage")
local EffectsEvent = require(ReplicatedStorage2.Communication.ServerAndClient.Effects.EffectsEvent)
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local Checker = require(CAM.Global.Checker)
local Utility = require(CAM.Global.Utility)
local Combat_Util = require(SAM.Services.Combat_Util)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local ManuelCancel = require(ReplicatedStorage2.CAM.Global.Subsets.Gameplay.ManuelCancel)
local Config = require(script.Parent.Config)
local PhantomStepServer = {
	Id = {}
}

function PhantomStepServer.Hold(player, _: Vector3, p)
	local character = player.Character
	local rootPart = character:FindFirstChild("Humanoid").RootPart
	EffectsEvent.ToAllInRange(player, "Phantom StepVFX", player.Character, "Start")
	p.Held = nil
	local v2 = PhantomStepServer.Id[player.UserId]
	task.wait(Config.STARTUP_AT)

	if PhantomStepServer.Id[player.UserId] ~= v2 then
		return
	end

	EffectsEvent.ToAllInRange(player, "Phantom StepVFX", player.Character, "Step")
	task.wait(Config.ZIGZAG_DELAY)

	if PhantomStepServer.Id[player.UserId] ~= v2 then
		return
	end

	EffectsEvent.ToAllInRange(player, "Phantom StepVFX", player.Character, "ZigZag")
	local v3 = PhantomStepServer.Id[player.UserId]
	local formatted = `{player.Name}-{script.Parent.Name}-{math.random(1, 99)}`

	while v3 == PhantomStepServer.Id[player.UserId] do
		local cFrame = rootPart.CFrame
		local singlePartHitbox = Utility.SinglePartHitbox({
			Caster = character,
			ParamsName = formatted,
			Origin = cFrame * Config.SCAN_HITBOX_OFFSET,
			BoxSize = Config.SCAN_HITBOX_SIZE
		})

		if singlePartHitbox then
			p.Held = Utility.find_character_from_descendant(singlePartHitbox)
			EffectsEvent.ToClient(player, "force_skill_actions_server", script.Parent.Name, "UnHold", nil)
			break
		else
			task.wait(0.1)
		end
	end
end

function PhantomStepServer.UnHold(player, _: Vector3, p)
	EffectsEvent.ToAllInRange(player, "Phantom StepVFX", player.Character, "End")
	local character = player.Character

	if character == nil then
		return
	end

	local primaryPart = character.PrimaryPart

	if not (primaryPart ~= nil and character:FindFirstChild("Humanoid") ~= nil) then
		return
	end

	local v2 = PhantomStepServer.Id[player.UserId]
	local v3, v4 = ManuelCancel.new(player, 0.5)
	v3:Connect(function()
		v2 = -1
	end)
	local getvaluesfolder = Utility.getvaluesfolder(player)
	task.wait(Config.HITS_START_DELAY)

	if PhantomStepServer.Id[player.UserId] ~= v2 then
		return
	end

	local v5 = Utility.AddValue(getvaluesfolder, "iframe", Config.HITS_IFRAME)
	local instances = {}

	for _ = 1, Config.HIT_COUNT do
		if PhantomStepServer.Id[player.UserId] == v2 then
			Utility.CreateHitbox({
				caster = character,
				hitboxCFrame = primaryPart.CFrame * Config.HIT_HITBOX_OFFSET,
				hitboxSize = Config.HIT_HITBOX_SIZE,
				targets = p.Held,
				checker = Checker,
				hitPriorityHandler = {
					callback = v.Exists,
					data = "Choosing_1"
				},
				hitDetected = function(instance, p2, p3)
					if instance then
						if table.find(instances, instance) then
							return
						end

						table.insert(instances, instance)
						local rootPart = instance:FindFirstChild("Humanoid").RootPart

						if p3 == "Blocking" or p3 == "Perfect" then
							Combat_Util.Block(script, character, instance, Config.HIT_BLOCK_BREAK)
						elseif p3 == true then
							local v6 = primaryPart.CFrame.LookVector * Config.HIT_KNOCKBACK + vector.create(
								0,
								Config.HIT_KNOCKUP,
								0
							)
							EffectsEvent.ToAllInRange(player, "SonidoVFX", character, "hit", rootPart.CFrame)
							Combat_Util.AddStun(script, character, p2, Config.HIT_STUN)
							Combat_Util.Damage(script, character, instance, {
								Base = Config.HIT_DAMAGE,
								Skill = script.Parent.Name
							})
							Combat_Util.Knockback(script, character, rootPart, v6, Config.HIT_KNOCKBACK_TIME)
							Combat_Util.RagDoll(script, character, p2, Config.HIT_RAGDOLL)
						end
					end
				end
			})
			task.wait(Config.HIT_INTERVAL)
		else
			v5:Destroy()
			return
		end
	end

	if PhantomStepServer.Id[player.UserId] ~= v2 then
		return
	end

	v5:Destroy()
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = primaryPart.CFrame * Config.FINAL_HITBOX_OFFSET,
		hitboxSize = Config.FINAL_HITBOX_SIZE,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		targets = instances,
		hitDetected = function(instance, p2, p3)
			if instance then
				local rootPart = instance:FindFirstChild("Humanoid").RootPart

				if p3 == "Blocking" or p3 == "Perfect" then
					Combat_Util.Block(script, character, instance, Config.FINAL_BLOCK_BREAK)
				elseif p3 == true then
					local v6 = vector.normalize(rootPart.Position - primaryPart.Position) * Config.FINAL_KNOCKBACK + vector.create(
						0,
						Config.FINAL_KNOCKUP,
						0
					)
					EffectsEvent.ToAllInRange(player, "SonidoVFX", character, "hit", rootPart.CFrame)
					Combat_Util.AddStun(script, character, p2, Config.FINAL_STUN)
					Combat_Util.Damage(script, character, instance, {
						Base = Config.FINAL_DAMAGE,
						Skill = script.Parent.Name
					})
					Combat_Util.Knockback(script, character, rootPart, v6, Config.FINAL_KNOCKBACK_TIME)
					Combat_Util.RagDoll(script, character, p2, Config.FINAL_RAGDOLL)
				end
			end
		end
	})
	v4()
end

function PhantomStepServer.Cancel(player, _: Vector3, _)
	EffectsEvent.ToAllInRange(player, "Phantom StepVFX", player.Character, "Cancel")
end

return PhantomStepServer