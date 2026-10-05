local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local global = ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global")
local hit_priority_handler = require(ServerStorage.SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local Combat_Util = require(ServerStorage.SAM.Services.Combat_Util)
local Checker = require(ReplicatedStorage.CAM.Global.Checker)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local ManuelCancel = require(global.Subsets.Gameplay.ManuelCancel)
local Config = require(script.Parent.Config)
local SelfDestructServer = {
	Id = {}
}

-- equivalent calls inferred from this helper; original call sites unknown
local function awayFrom(instance, humanoidRootPart)
	local v2 = humanoidRootPart.Position - instance.Position
	local vector2 = Vector3.new(v2.X, 0, v2.Z)

	if vector2.Magnitude <= 0 then
		return instance.CFrame.LookVector
	end

	return vector2.Unit
end

local function randomSelfFling()
	local v2 = math.random() * 3.141592653589793 * 2
	local v3 = math.random() * (Config.SELF_KNOCKBACK_MAX - Config.SELF_KNOCKBACK_MIN) + Config.SELF_KNOCKBACK_MIN
	local v4 = math.random() * (Config.SELF_KNOCKUP_MAX - Config.SELF_KNOCKUP_MIN) + Config.SELF_KNOCKUP_MIN
	return (Vector3.new(math.cos(v2) * v3, v4, math.sin(v2) * v3))
end

function SelfDestructServer.Hold(player, _, _)
	local character = player.Character

	if character == nil then
		return false
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")

	if humanoidRootPart == nil or humanoid == nil then
		return false
	end

	local getvaluesfolder = Utility.getvaluesfolder(character)
	Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.WINDUP)
	local v2 = SelfDestructServer.Id[player.UserId]
	local v3, v4 = ManuelCancel.new(player, 1)
	v3:Connect(function()
		v2 = -1
		v4()
	end)
	task.wait(Config.WINDUP)

	if v2 ~= SelfDestructServer.Id[player.UserId] or humanoidRootPart.Parent == nil then
		v4()
		return false
	end

	EffectsEvent.ToAllInRange(player, "SelfDestructVFX", character)
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = CFrame.new(humanoidRootPart.Position),
		hitboxSize = Config.HITBOX_SIZE,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = function(instance, p, p2)
			local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")

			if p2 == "Perfect" then
				Combat_Util.Perfect(script, character, instance)
			elseif p2 == "Blocking" then
				Combat_Util.Block(script, character, instance, Config.BLOCK_BREAK)
			elseif p2 == true then
				local humanoid2 = instance:FindFirstChildOfClass("Humanoid")
				local v5 = humanoid2 == nil and 0 or humanoid2.Health
				Combat_Util.Damage(script, character, instance, {
					Base = Config.DAMAGE,
					Skill = script.Parent.Name
				})

				if humanoid2 ~= nil and humanoid.Health > 0 then
					local v6 = v5 - humanoid2.Health

					if v6 > 0 then
						humanoid.Health = math.max(1, humanoid.Health - v6 * Config.SELF_DAMAGE_SHARE)
					end
				end

				Combat_Util.AddStun(script, character, p, Config.IMPACT_STUN)
				Combat_Util.RagDoll(script, character, p, Config.IMPACT_STUN)
				Utility.AddValue(p, Config.BURN_VALUE, Config.BURN_DURATION, "ObjectValue", character):SetAttribute(
					"Skill",
					script.Parent.Name
				)
				local v7 = awayFrom(humanoidRootPart, humanoidRootPart2) -- equivalent call inferred; original call site unknown
				Combat_Util.Knockback(
					script,
					character,
					humanoidRootPart2,
					v7 * Config.KNOCKBACK + Vector3.new(0, Config.KNOCKUP, 0),
					Config.KNOCKBACK_DURATION
				)
			end
		end
	})
	Combat_Util.AddStun(script, character, getvaluesfolder, Config.IMPACT_STUN)
	Combat_Util.RagDoll(script, character, getvaluesfolder, Config.IMPACT_STUN)
	Combat_Util.Knockback(script, character, humanoidRootPart, randomSelfFling(), Config.KNOCKBACK_DURATION)
	v4()
	return true
end

function SelfDestructServer.Cancel(player, _, _)
	if player == nil then
		return
	end

	local character = player.Character

	if character == nil then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
	humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
end

return SelfDestructServer