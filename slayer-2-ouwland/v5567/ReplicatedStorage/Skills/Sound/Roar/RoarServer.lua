local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local global = ReplicatedStorage2:WaitForChild("CAM"):WaitForChild("Global")
local hit_priority_handler = require(ServerStorage.SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local Combat_Util = require(ServerStorage.SAM.Services.Combat_Util)
local Checker = require(ReplicatedStorage.CAM.Global.Checker)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local ManuelCancel = require(global.Subsets.Gameplay.ManuelCancel)
local CombatMode = require(ReplicatedStorage.CAM.Global.CombatMode)
local Config = require(script.Parent.Config)
local RoarServer = {
	Id = {},
	Hold = function(player, _, p)
		local character = player.Character

		if not (character and character:FindFirstChild("HumanoidRootPart")) then
			return
		end

		EffectsEvent.ToAllInRange(player, "RoarVFX", character, "Start")
		p.Clock = os.clock()
	end
}

function RoarServer.UnHold(player, p, p2)
	local character = player.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local v2 = not CombatMode.InPvPMode(player) and 0 or Config.PVP_WINDUP
	local getvaluesfolder = Utility.getvaluesfolder(character)
	Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.ENDLAG + v2)
	local v3 = RoarServer.Id[player.UserId]
	local v4, v5 = ManuelCancel.new(player, 1, nil, script.Parent.Name)
	v4:Connect(function()
		v3 = -1
		RoarServer.Cancel(player, p, p2)
		v5()
	end)
	task.wait(Config.BLAST_AT + v2)

	if v3 ~= RoarServer.Id[player.UserId] or humanoidRootPart.Parent == nil then
		return
	end

	EffectsEvent.ToAllInRange(player, "RoarVFX", character, "Explode")
	local hitboxCFrame = humanoidRootPart.CFrame * Config.BLAST_HITBOX_OFFSET
	task.wait(0.05)
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = hitboxCFrame,
		hitboxSize = Config.BLAST_HITBOX_SIZE,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_3"
		},
		hitDetected = function(instance, p3, p4)
			local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")

			if p4 == "Perfect" then
				Combat_Util.Perfect(script, character, instance)
			elseif p4 == "Blocking" then
				Combat_Util.Block(script, character, instance, Config.BLAST_BLOCK_BREAK)
			elseif p4 == true then
				Combat_Util.Damage(script, character, instance, {
					Base = Config.BLAST_DAMAGE,
					Skill = script.Parent.Name
				})
				Combat_Util.AddStun(script, character, p3, Config.BLAST_STUN)
				Combat_Util.RagDoll(script, character, p3, Config.BLAST_RAGDOLL)
				Combat_Util.Knockback(
					script,
					character,
					humanoidRootPart2,
					hitboxCFrame.LookVector * Config.BLAST_KNOCKBACK + vector.create(0, Config.BLAST_KNOCKUP, 0),
					Config.BLAST_KNOCKBACK_DURATION
				)
			end
		end
	})
	v5()
end

function RoarServer.Cancel(player, _, _)
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

	EffectsEvent.ToAllInRange(player, "RoarVFX", character, "Cancel")
	humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
	humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
end

return RoarServer