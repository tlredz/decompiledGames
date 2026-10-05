local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("CollectionService")
local EffectsEvent = require(ReplicatedStorage2.Communication.ServerAndClient.Effects.EffectsEvent)
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local Checker = require(CAM.Global.Checker)
local Utility = require(CAM.Global.Utility)
require(CAM.Global.Combat_presets)
require(CAM.DebrisModule)
require(SAM.Utility.SkillStorage)
local Combat_Util = require(SAM.Services.Combat_Util)
local ImpactSounds = require(SAM.Utility.ImpactSounds)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local Config = require(script.Parent.Config)
local SeismicBurstServer = {
	Id = {}
}
local script2 = script
require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Subsets"):WaitForChild("Gameplay"):WaitForChild("ManuelCancel"))

function SeismicBurstServer.Hold(player, _: Vector3, _)
	local character = player.Character
	local humanoid = character:FindFirstChild("Humanoid")
	local rootPart = humanoid.RootPart
	humanoid:FindFirstChild("Animator")
	local v2 = SeismicBurstServer.Id[player.UserId]
	local getvaluesfolder = Utility.getvaluesfolder(character)
	task.delay(0.05, function()
		if v2 ~= SeismicBurstServer.Id[player.UserId] then
			return
		end

		EffectsEvent.ToAllInRange(player, "Seismic BurstVFX", character, "Start")
		task.wait(0.2)

		if v2 ~= SeismicBurstServer.Id[player.UserId] then
			return
		end

		EffectsEvent.ToAllInRange(player, "Seismic BurstVFX", character, "DustTrail")
	end)
	local v3 = false

	while v2 == SeismicBurstServer.Id[player.UserId] and v3 == false do
		local modelInRegion = Utility.GetModelInRegion(
			rootPart.CFrame * Config.DASH_HITBOX_OFFSET,
			Config.DASH_HITBOX_SIZE,
			nil,
			nil,
			false
		)

		for _, v5 in pairs(modelInRegion) do
			if v3 == true then
				break
			end

			if v5 == character then
				continue
			end

			local getvaluesfolder2 = Utility.getvaluesfolder(v5)

			if not (v.Both(getvaluesfolder2, {
				pv = getvaluesfolder,
				name = "Choosing_1"
			}) ~= true and Checker.check_victim(script2, character, v5) ~= nil) then
				continue
			end

			if SeismicBurstServer.Id[player.UserId] == v2 then
				EffectsEvent.ToClient(player, "force_skill_actions_server", script.Parent.Name, "UnHold", nil)
				v3 = true
			end

			break
		end

		task.wait(0.1)
	end
end

function SeismicBurstServer.UnHold(player, _: Vector3, p)
	local character = player.Character

	if character == nil then
		return
	end

	p.Cancelled = false
	EffectsEvent.ToAllInRange(player, "Seismic BurstVFX", character, "Slash")
	local getvaluesfolder = Utility.getvaluesfolder(character)
	local v2 = character.HumanoidRootPart.CFrame * Config.SLASH_HITBOX_OFFSET
	local modelInRegion = Utility.GetModelInRegion(v2, Config.SLASH_HITBOX_SIZE, nil, nil, false)
	local v3 = false
	local v4 = nil

	for _, v5 in pairs(modelInRegion) do
		if v3 == true then
			break
		end

		if not (v5 ~= player.Character and v5:FindFirstChild("Humanoid") ~= nil) then
			continue
		end

		local humanoidRootPart = v5:FindFirstChild("HumanoidRootPart")
		local humanoid = v5:FindFirstChild("Humanoid")
		local check_victim, _ = Checker.check_victim(script, character, v5)
		local getvaluesfolder2 = Utility.getvaluesfolder(v5)

		if v.Both(getvaluesfolder2, {
			pv = getvaluesfolder,
			name = "Choosing_1"
		}) == true then
			continue
		end

		local humanoidRootPart2 = character:FindFirstChild("HumanoidRootPart")

		if not (humanoidRootPart ~= nil and humanoid ~= nil and humanoidRootPart2 ~= nil) then
			continue
		end

		if check_victim == "Blocking" then
			Combat_Util.Block(script, character, v5, Config.SLASH_BLOCK_BREAK)
		elseif check_victim == "Perfect" then
			Combat_Util.Perfect(script, character, v5)
			v3 = true
		elseif check_victim == true then
			EffectsEvent.ToAllInRange(player, "Normal_Sword_Slash_Effect", humanoidRootPart, -1)
			Combat_Util.RagDoll(script, character, getvaluesfolder2, Config.SLASH_RAGDOLL)
			Combat_Util.Add_Strict_Stun(script, character, getvaluesfolder2, Config.SLASH_STUN)
			Combat_Util.Damage(script, character, v5, {
				Base = Config.SLASH_DAMAGE,
				Skill = script.Parent.Name
			})
			local v6 = humanoidRootPart2.CFrame.lookVector * Config.SLASH_KNOCKBACK
			Combat_Util.Knockback(
				script,
				character,
				humanoidRootPart,
				Vector3.new(v6.X, 0, v6.Z),
				Config.SLASH_KNOCKBACK_DURATION
			)
			v4 = v4 or v5
		end
	end

	if v4 ~= nil then
		ImpactSounds.Play(character, script.Parent.Name, v4)
	end
end

function SeismicBurstServer.Cancel(player, _: Vector3, _)
	local character = player.Character

	if character == nil then
		return
	end

	SeismicBurstServer.Id[player.UserId] = 3
	EffectsEvent.ToAllInRange(player, "Seismic BurstVFX", character, "Cancel")
end

return SeismicBurstServer