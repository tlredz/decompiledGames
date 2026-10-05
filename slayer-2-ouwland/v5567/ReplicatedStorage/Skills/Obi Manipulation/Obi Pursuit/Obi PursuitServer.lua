local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("CollectionService")
local _ = ReplicatedStorage.Communication
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
require(ReplicatedStorage2.Communication.ServerAndClient.Effects.EffectsEvent)
local Checker = require(CAM.Global.Checker)
local Utility = require(CAM.Global.Utility)
require(CAM.Global.Combat_presets)
require(CAM.DebrisModule)
require(SAM.Utility.SkillStorage)
local Combat_Util = require(SAM.Services.Combat_Util)
local EffectsEvent = require(ReplicatedStorage2.Communication.ServerAndClient.Effects.EffectsEvent)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local Config = require(script.Parent.Config)
local ObiPursuitServer = {
	Id = {}
}
local _ = script
local ManuelCancel = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Subsets"):WaitForChild("Gameplay"):WaitForChild("ManuelCancel"))

function ObiPursuitServer.Hold(player, _: Vector3, _)
	local character = player.Character
	local humanoid = character:FindFirstChild("Humanoid")
	local rootPart = humanoid.RootPart
	humanoid:FindFirstChild("Animator")
	local v2 = ObiPursuitServer.Id[player.UserId]
	Utility.getvaluesfolder(character)
	EffectsEvent.ToAllInRange(player, "ObiPursuit_effs", character, "Start")
	local formatted = `{player.Name}-{script.Parent.Name}-{math.random(1, 99)}`
	task.wait(Config.DASH_START_AT)

	if v2 ~= ObiPursuitServer.Id[player.UserId] then
		return
	end

	while v2 == ObiPursuitServer.Id[player.UserId] do
		local cFrame = rootPart.CFrame

		if Utility.SinglePartHitbox({
			Caster = character,
			ParamsName = formatted,
			Origin = cFrame * Config.CONTACT_HITBOX_OFFSET,
			BoxSize = Config.CONTACT_HITBOX_SIZE
		}) then
			EffectsEvent.ToClient(player, "force_skill_actions_server", script.Parent.Name, "UnHold", nil)
			break
		else
			task.wait(0.1)
		end
	end
end

function ObiPursuitServer.UnHold(player, _: Vector3, _)
	local character = player.Character

	if character == nil then
		return
	end

	local v3 = false
	ManuelCancel.new(player, Config.SLASH_CANCEL_WINDOW):Connect(function()
		v3 = true
	end)
	local v4 = ObiPursuitServer.Id[player.UserId]
	EffectsEvent.ToAllInRange(player, "ObiPursuit_effs", character, "Release")
	task.wait(Config.SLASH_DELAY)

	if ObiPursuitServer.Id[player.UserId] ~= v4 or (v3 == true or character == nil) then
		return
	end

	EffectsEvent.ToAllInRange(player, "ObiPursuit_effs", character, "Slash")
	local getvaluesfolder = Utility.getvaluesfolder(character)
	local v5 = character.HumanoidRootPart.CFrame * Config.SLASH_HITBOX_OFFSET
	local modelInRegion = Utility.GetModelInRegion(v5, Config.SLASH_HITBOX_SIZE, nil, nil)
	local v6 = false

	for _, v7 in pairs(modelInRegion) do
		if v6 == true then
			break
		end

		if not (v7 ~= player.Character and v7:FindFirstChild("Humanoid") ~= nil) then
			continue
		end

		local humanoidRootPart = v7:FindFirstChild("HumanoidRootPart")
		local humanoid = v7:FindFirstChild("Humanoid")
		local check_victim, _ = Checker.check_victim(script, character, v7)

		if check_victim == nil then
			continue
		end

		local getvaluesfolder2 = Utility.getvaluesfolder(v7)

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
			Combat_Util.Block(script, character, v7, Config.SLASH_BLOCK_BREAK)
		elseif check_victim == "Perfect" then
			Combat_Util.Perfect(script, character, v7)
			v6 = true
		elseif check_victim == true then
			EffectsEvent.ToAllInRange(player, "ObiPursuit_effs", character, "Hit", v7:GetPivot())
			Combat_Util.RagDoll(script, character, getvaluesfolder2, Config.SLASH_RAGDOLL)
			Combat_Util.Add_Strict_Stun(script, character, getvaluesfolder2, Config.SLASH_STUN)
			Combat_Util.Damage(script, character, v7, {
				Base = Config.SLASH_DAMAGE,
				Skill = script.Parent.Name
			})
			local v8 = humanoidRootPart2.CFrame.lookVector * Config.SLASH_KNOCKBACK
			Combat_Util.Knockback(script, character, humanoidRootPart, Vector3.new(v8.X, 0, v8.Z), 0.35)
		end
	end
end

function ObiPursuitServer.Cancel(player, _: Vector3, _)
	local character = player.Character

	if character == nil then
		return
	end

	EffectsEvent.ToAllInRange(player, "ObiPursuit_effs", character, "Cancel")
end

return ObiPursuitServer