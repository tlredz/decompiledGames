local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local Checker = require(CAM.Global.Checker)
local Utility = require(CAM.Global.Utility)
local Combat_Util = require(SAM.Services.Combat_Util)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local StatTypes = require(CAM.Global.Types.StatTypes)
local AppliedTicks = require(CAM.Global.Subsets.Gameplay.AppliedTicks)
local Config = require(script.Parent.Config)
local WintryGaleServer = {}
WintryGaleServer.Id = {}

function WintryGaleServer.Hold(player)
	local character = player.Character

	if character == nil then
		return
	end

	Utility.AddValue(Utility.getvaluesfolder(character), "pause_gameplay", Config.CAST_DURATION)
end

function WintryGaleServer.UnHold(player, vector2: Vector3?)
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	local v2 = ((vector2 or humanoidRootPart.Position + humanoidRootPart.CFrame.LookVector * Config.MOUSE_RANGE) - humanoidRootPart.Position) * createVector(
		1,
		0,
		1
	)
	local unit

	if v2.Magnitude > 0.001 then
		unit = v2.Unit
	else
		unit = (humanoidRootPart.CFrame.LookVector * createVector(1, 0, 1)).Unit
	end

	local cframe = CFrame.lookAt(humanoidRootPart.Position, humanoidRootPart.Position + unit)
	EffectsEvent.ToAllInRange(humanoidRootPart, "Wintry Gale VFX", character, "Swirl", cframe)
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = cframe * Config.SWIRL_HITBOX_OFFSET,
		hitboxSize = Config.SWIRL_HITBOX_SIZE,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = function(instance, p, p2)
			local humanoid = instance:FindFirstChild("Humanoid")
			local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")

			if humanoid == nil or humanoidRootPart2 == nil then
				return
			end

			if p2 == "Perfect" then
				Combat_Util.Perfect(script, character, instance)
			elseif p2 == "Blocking" then
				Combat_Util.Block(script, character, instance, Config.SWIRL_BLOCK_BREAK)
			elseif p2 == true then
				Combat_Util.Damage(script, character, instance, {
					Base = Config.SWIRL_DAMAGE,
					Skill = script.Parent.Name
				})
				Combat_Util.RagDoll(script, character, p, Config.SWIRL_RAGDOLL_DURATION)
				Combat_Util.AddStun(script, character, p, Config.SWIRL_STUN)
				Combat_Util.Knockback(
					script,
					character,
					humanoidRootPart2,
					unit * Config.SWIRL_KNOCKBACK + Vector3.new(0, Config.SWIRL_LAUNCH, 0),
					0.2
				)
				Utility.AddValue(p, AppliedTicks.ByName.Frost.Value, Config.FROST_DURATION, "ObjectValue", character):SetAttribute(
					"Skill",
					script.Parent.Name
				)
				local v3 = Utility.AddValue(p, Config.SLOW_VALUE, Config.SLOW_DURATION)
				v3:AddTag(StatTypes.ValueStatTag)
				v3:SetAttribute(StatTypes.StatToAttribute("Movement Speed Factor"), Config.SLOW_FACTOR)
			end

			EffectsEvent.ToAllInRange(humanoidRootPart, "Normal_Sword_Slash_Effect", humanoidRootPart2, -1)
		end
	})
end

return WintryGaleServer