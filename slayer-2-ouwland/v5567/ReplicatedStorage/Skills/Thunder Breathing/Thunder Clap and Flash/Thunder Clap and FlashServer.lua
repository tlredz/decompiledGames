local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage:WaitForChild("CAM")
local SAM = ServerStorage:WaitForChild("SAM")
local global = CAM:WaitForChild("Global")
local services = SAM:WaitForChild("Services")
local EffectsEvent = require(ReplicatedStorage2.Communication.ServerAndClient.Effects.EffectsEvent)
local Utility = require(global.Utility)
local Checker = require(global.Checker)
local Combat_Util = require(services.Combat_Util)
local ImpactSounds = require(SAM.Utility.ImpactSounds)
local Combat_presets = require(global.Combat_presets)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local RaycastHelper = require(ReplicatedStorage2.CAM.Global.RaycastHelper)
local Config = require(script.Parent.Config)
local ThunderClapAndFlashServer = {
	Id = {},
	Hold = function(player)
		if not player then
			return
		end

		local character = player.Character

		if not character then
			return
		end

		EffectsEvent.ToAllInRange(player, "Thunder_Clap_And_Flash_VFX", character, "Startup")
		task.wait(Config.STARTUP_DUR)
	end
}

local function fn(instance, p, p2, list)
	local v2 = list[1]
	local instances = list[2]
	local v3 = list[3]

	if instance then
		local humanoid = instance:FindFirstChild("Humanoid")
		local rootPart = humanoid.RootPart

		if p2 == "Perfect" then
			Combat_Util.Perfect(script, v2, instance)
		elseif p2 == "Blocking" then
			Combat_Util.Block(script, v2, instance, Config.DASH_BLOCK_BREAK)
		elseif p2 == true then
			local v4 = Combat_presets.PlayReactAnim(humanoid, 1, 0.8, script.Victim)
			Utility.AddValue(p, "iframe", Config.DASH_VICTIM_IFRAME, "StringValue", v2.Name)
			Combat_Util.Add_Strict_Stun(script, v2, p, Config.DASH_STUN, true)
			Combat_Util.Damage(script, v2, instance, {
				Base = Config.DASH_DAMAGE,
				Skill = script.Parent.Name
			})
			Combat_Util.Knockback(
				script,
				v2,
				rootPart,
				vector.create(0, Config.DASH_KNOCKUP, 0),
				Config.DASH_KNOCKUP_DUR
			)
			table.insert(v3, v4)
			table.insert(instances, instance)
		end
	end
end

function ThunderClapAndFlashServer.UnHold(player, p)
	if not player then
		return
	end

	local character = player.Character

	if not character then
		return
	end

	local getvaluesfolder = Utility.getvaluesfolder(player)
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local v2 = ThunderClapAndFlashServer.Id[player.UserId]
	local air_combo_bp = humanoidRootPart:FindFirstChild("air_combo_bp")

	if air_combo_bp then
		air_combo_bp:Destroy()
	end

	local cFrame = humanoidRootPart.CFrame
	local v3 = vector.normalize(p - cFrame.Position) * Config.MAX_DISTANCE
	local cframe = CFrame.new(cFrame.Position, cFrame.Position + v3)
	local raycastResult = workspace:Raycast(cFrame.Position, v3, RaycastHelper.Crater)
	local MAX_DISTANCE = Config.MAX_DISTANCE
	local v4

	if raycastResult then
		local v5 = raycastResult.Position - cFrame.Position
		MAX_DISTANCE = vector.magnitude(v5)
		v4 = cFrame.Position + vector.normalize(v5) * MAX_DISTANCE
	else
		v4 = cFrame.Position + v3
	end

	local v5 = CFrame.new(v4) * cframe.Rotation
	EffectsEvent.ToAllInRange(player, "Thunder_Clap_And_Flash_VFX", character, "DashOrCancel", { cFrame, v5 })
	task.wait(0.1)

	if ThunderClapAndFlashServer.Id[player.UserId] ~= v2 then
		return
	end

	local v6 = MAX_DISTANCE + 6
	local vector2 = Vector3.new(Config.DASH_HITBOX_WIDTH, Config.DASH_HITBOX_HEIGHT, v6)
	local hitboxCFrame = CFrame.new(cFrame.Position, v4) * CFrame.new(0, 2, -v6 / 2)
	local v8 = {}
	local v9 = {}
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = hitboxCFrame,
		hitboxSize = vector2,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		TreeDestruction = true,
		hitDetected = fn,
		extraArgs = { character, v8, v9 },
		After = function(p2, list)
			if p2 then
				ImpactSounds.Play(character, script.Parent.Name, list[1])
			end
		end
	})

	if #v8 > 0 then
		EffectsEvent.ToAllInRange(player, "Thunder_Clap_And_Flash_VFX", character, "WindUpvictimEFfect", v8)
		local raycastResult2 = workspace:Raycast(v5.Position + v5.UpVector * 5, v5.UpVector * -10, RaycastHelper.Crater)
		local v10

		if raycastResult2 == nil then
			v10 = v5 * CFrame.new(0, 2.5, 0)
		else
			v10 = CFrame.new(raycastResult2.Position + v5.UpVector * 3) * v5.Rotation
		end

		Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.GRAB_DURATION)
		Utility.AddValue(getvaluesfolder, "iframe", Config.GRAB_DURATION)
		Utility.lock(humanoidRootPart, v10, Config.GRAB_DURATION)
		character.Humanoid.Animator:LoadAnimation(script.Player):Play()
		task.wait(Config.LASTSLASH_AT)

		if ThunderClapAndFlashServer.Id[player.UserId] ~= v2 then
			return
		end

		EffectsEvent.ToAllInRange(player, "Thunder_Clap_And_Flash_VFX", character, "LastSlash", { cFrame, v5 })
		task.wait(Config.FINAL_HIT_DELAY)

		if ThunderClapAndFlashServer.Id[player.UserId] ~= v2 then
			return
		end

		for _, v11 in ipairs(v9) do
			v11:Stop()
		end

		EffectsEvent.ToAllInRange(player, "Thunder_Clap_And_Flash_VFX", character, "DamageHit", v8)
		local v11 = nil

		for _, v12 in ipairs(v8) do
			if Checker.check_victim(script, character, v12) == nil then
				continue
			end

			local getvaluesfolder2 = Utility.getvaluesfolder(v12)
			Combat_Util.Damage(script, character, v12, {
				Base = Config.FINAL_DAMAGE,
				Skill = script.Parent.Name
			})
			Combat_Util.Knockback(
				script,
				character,
				v12.HumanoidRootPart,
				v5.LookVector * -Config.FINAL_KNOCKBACK + vector.create(0, Config.FINAL_KNOCKUP, 0),
				Config.FINAL_KNOCKBACK_DUR
			)
			Combat_Util.RagDoll(script, character, getvaluesfolder2, Config.FINAL_RAGDOLL)
			v11 = v11 or v12
		end

		if v11 ~= nil then
			ImpactSounds.Play(character, script.Parent.Name, v11)
		end
	end
end

function ThunderClapAndFlashServer.Cancel(player)
	if not player then
		return
	end

	local character = player.Character

	if not character then
		return
	end

	EffectsEvent.ToAllInRange(player, "Thunder_Clap_And_Flash_VFX", character, "Cancel")
end

return ThunderClapAndFlashServer