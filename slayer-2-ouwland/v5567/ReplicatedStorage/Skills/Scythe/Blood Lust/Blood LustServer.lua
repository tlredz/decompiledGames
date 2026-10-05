local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local Checker = require(CAM.Global.Checker)
local Utility = require(CAM.Global.Utility)
local Combat_presets = require(CAM.Global.Combat_presets)
local Combat_Util = require(SAM.Services.Combat_Util)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local Config = require(script.Parent.Config)
local name = script.Parent.Name
local BloodLustServer = {
	Id = {}
}

local function travelHitbox(character, position, p, fn)
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local v2 = p - position
	local magnitude = v2.Magnitude
	local unit

	if magnitude > 0.5 then
		unit = v2.Unit
	else
		unit = humanoidRootPart.CFrame.LookVector
	end

	local midpoint = (position + p) / 2
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = CFrame.lookAt(midpoint, midpoint + unit) * Config.SLASH_OFFSET,
		hitboxSize = Vector3.new(Config.SLASH_WIDTH, Config.SLASH_HEIGHT, magnitude + Config.SLASH_LENGTH_PADDING) + Config.SLASH_EXTRA_SIZE,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = fn
	})
end

local function aoeHitbox(caster, hitboxCFrame, hitboxSize, hitDetected)
	Utility.CreateHitbox({
		caster = caster,
		hitboxCFrame = hitboxCFrame,
		hitboxSize = hitboxSize,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = hitDetected
	})
end

local function makeSlash(p, p2, data)
	return function(instance, p3, p4)
		if not instance then
			return
		end

		local humanoid = instance:FindFirstChild("Humanoid")
		local rootPart = humanoid and humanoid.RootPart

		if not rootPart then
			return
		end

		if p4 == "Blocking" then
			Combat_Util.Block(script, p, instance, 2)
			return
		elseif p4 == "Perfect" then
			Combat_Util.Perfect(script, p, instance)
			return true
		end

		if p4 == true then
			Combat_Util.Damage(script, p, instance, {
				Base = data.damage,
				Skill = name
			})
			Combat_Util.AddStun(script, p, p3, data.stun)
			local v2 = p2.CFrame.LookVector * data.knockFwd
			Combat_Util.Knockback(script, p, rootPart, Vector3.new(v2.X, data.knockUp, v2.Z), data.knockDur)
			Combat_presets.PlayReactAnim(humanoid)
		end
	end
end

local function makeFinisher(p, p2, data)
	return function(instance, p3, p4)
		if not instance then
			return
		end

		local humanoid = instance:FindFirstChild("Humanoid")
		local rootPart = humanoid and humanoid.RootPart

		if not rootPart then
			return
		end

		if p4 == "Blocking" then
			Combat_Util.Block(script, p, instance, 3)
			return
		elseif p4 == "Perfect" then
			Combat_Util.Perfect(script, p, instance)
			return true
		end

		if p4 == true then
			Combat_Util.Damage(script, p, instance, {
				Base = data.damage,
				Skill = name
			})
			Combat_Util.RagDoll(script, p, p3, data.ragdoll)
			Combat_Util.Add_Strict_Stun(script, p, p3, data.ragdoll, true)
			local v2 = p2.CFrame.LookVector * data.knockFwd
			Combat_Util.Knockback(script, p, rootPart, Vector3.new(v2.X, data.knockUp, v2.Z), data.knockDur)
		end
	end
end

function BloodLustServer.Hold(player, _, _)
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

	local v2 = BloodLustServer.Id[player.UserId]

	local function alive()
		return v2 == BloodLustServer.Id[player.UserId] and humanoidRootPart.Parent ~= nil
	end

	task.wait(Config.STARTUP)
	local v3

	if v2 == BloodLustServer.Id[player.UserId] then
		v3 = humanoidRootPart.Parent ~= nil
	else
		v3 = false
	end

	if not v3 then
		return
	end

	local position = humanoidRootPart.Position

	for _, SLASH in Config.SLASHES do
		EffectsEvent.ToAllInRange(player, "BloodLust_effs", character, SLASH.dash)
		local v4 = SLASH
		task.delay(Config.STRIKE_VFX_GAP, function()
			if v2 == BloodLustServer.Id[player.UserId] then
				EffectsEvent.ToAllInRange(player, "BloodLust_effs", character, v4.strike)
			end
		end)
		task.wait(SLASH.windup)
		local v5

		if v2 == BloodLustServer.Id[player.UserId] then
			v5 = humanoidRootPart.Parent ~= nil
		else
			v5 = false
		end

		if not v5 then
			return
		end

		local position2 = humanoidRootPart.Position
		local v7 = SLASH
		travelHitbox(
			character,
			position,
			position2 + humanoidRootPart.CFrame.LookVector * Config.SLASH_LEAD,
			function(instance, p, p2)
				if not instance then
					return
				end

				local humanoid = instance:FindFirstChild("Humanoid")
				local rootPart = humanoid and humanoid.RootPart

				if not rootPart then
					return
				end

				if p2 == "Blocking" then
					Combat_Util.Block(script, character, instance, 2)
					return
				elseif p2 == "Perfect" then
					Combat_Util.Perfect(script, character, instance)
					return true
				end

				if p2 == true then
					Combat_Util.Damage(script, character, instance, {
						Base = v7.damage,
						Skill = name
					})
					Combat_Util.AddStun(script, character, p, v7.stun)
					local v8 = humanoidRootPart.CFrame.LookVector * v7.knockFwd
					Combat_Util.Knockback(script, character, rootPart, Vector3.new(v8.X, v7.knockUp, v8.Z), v7.knockDur)
					Combat_presets.PlayReactAnim(humanoid)
				end
			end
		)
		task.wait(SLASH.gap - SLASH.windup)
		local v8

		if v2 == BloodLustServer.Id[player.UserId] then
			v8 = humanoidRootPart.Parent ~= nil
		else
			v8 = false
		end

		if not v8 then
			return
		end

		position = position2
	end

	local FINISHER = Config.FINISHER
	EffectsEvent.ToAllInRange(player, "BloodLust_effs", character, FINISHER.dash)
	task.wait(FINISHER.windup)
	local v4

	if v2 == BloodLustServer.Id[player.UserId] then
		v4 = humanoidRootPart.Parent ~= nil
	else
		v4 = false
	end

	if not v4 then
		return
	end

	task.wait(FINISHER.aoeGap)
	local v5

	if v2 == BloodLustServer.Id[player.UserId] then
		v5 = humanoidRootPart.Parent ~= nil
	else
		v5 = false
	end

	if not v5 then
		return
	end

	EffectsEvent.ToAllInRange(player, "BloodLust_effs", character, FINISHER.strikeB)
	local hitboxCFrame = humanoidRootPart.CFrame * FINISHER.outer.offset
	local size = FINISHER.outer.size
	local outer = FINISHER.outer
	aoeHitbox(character, hitboxCFrame, size, function(instance, p, p2)
		if not instance then
			return
		end

		local humanoid = instance:FindFirstChild("Humanoid")
		local rootPart = humanoid and humanoid.RootPart

		if not rootPart then
			return
		end

		if p2 == "Blocking" then
			Combat_Util.Block(script, character, instance, 3)
			return
		elseif p2 == "Perfect" then
			Combat_Util.Perfect(script, character, instance)
			return true
		end

		if p2 == true then
			Combat_Util.Damage(script, character, instance, {
				Base = outer.damage,
				Skill = name
			})
			Combat_Util.RagDoll(script, character, p, outer.ragdoll)
			Combat_Util.Add_Strict_Stun(script, character, p, outer.ragdoll, true)
			local v8 = humanoidRootPart.CFrame.LookVector * outer.knockFwd
			Combat_Util.Knockback(script, character, rootPart, Vector3.new(v8.X, outer.knockUp, v8.Z), outer.knockDur)
		end
	end)
end

function BloodLustServer.UnHold(_, _, _) end

function BloodLustServer.Cancel(player, _, _)
	if not player then
		return
	end

	BloodLustServer.Id[player.UserId] = nil
	local character = player.Character

	if character then
		EffectsEvent.ToAllInRange(player, "BloodLust_effs", character, "Cancel")
	end
end

return BloodLustServer