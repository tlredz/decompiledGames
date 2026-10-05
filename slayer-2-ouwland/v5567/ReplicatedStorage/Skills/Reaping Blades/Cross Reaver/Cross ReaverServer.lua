local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Config = require(script.Parent.Config)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local Checker = require(ReplicatedStorage.CAM.Global.Checker)
local Combat_Util = require(ServerStorage.SAM.Services.Combat_Util)
local Combat_presets = require(ReplicatedStorage.CAM.Global.Combat_presets)
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local ManuelCancel = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.ManuelCancel)
local hit_priority_handler = require(ServerStorage.SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local CrossReaverServer = {
	Id = {},
	Hold = function(player, _, p)
		if not player then
			return
		end

		p.cancelled = false
		local character = player.Character

		if not character then
			return
		end

		EffectsEvent.ToAllInRange(player, "Cross Reaver_effs", character, "Initial")
	end
}

function CrossReaverServer.UnHold(player, p, p2)
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

	local getvaluesfolder = Utility.getvaluesfolder(character)
	local v2, v3 = ManuelCancel.new(player, Config.DELAY + 0.5)
	v2:Connect(function()
		CrossReaverServer.Cancel(player, p, p2)
		v3()
	end)
	task.wait(Config.DELAY)

	if p2.cancelled or humanoidRootPart.Parent == nil then
		v3()
		return
	end

	EffectsEvent.ToAllInRange(player, "Cross Reaver_effs", character, "Throw")
	local lookVector = humanoidRootPart.CFrame.LookVector
	local vector = Vector3.new(lookVector.X, 0, lookVector.Z)

	if vector.Magnitude > 0.001 then
		lookVector = vector.Unit or lookVector
	end

	local hitboxCFrame = CFrame.lookAt(humanoidRootPart.Position, humanoidRootPart.Position + lookVector) * CFrame.new(
		0,
		0,
		-(Config.DISTANCE / 2) + 4
	)
	local vector2 = Vector3.new(Config.HITBOX_WIDTH, Config.HITBOX_WIDTH, Config.DISTANCE)
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = hitboxCFrame,
		hitboxSize = vector2,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Both,
			data = {
				pv = getvaluesfolder,
				name = "Choosing_1"
			}
		},
		hitDetected = function(instance, p3, p4)
			if not instance then
				return false
			end

			local humanoid = instance:FindFirstChild("Humanoid")

			if instance == character or not humanoid then
				return false
			end

			if p4 == "Perfect" then
				Combat_Util.Perfect(script, character, instance)
				return true
			end

			if p4 == "Blocking" then
				Combat_Util.Block(script, character, instance, Config.BLOCK_BREAK)
			elseif p4 == true then
				Combat_Util.Damage(script, character, instance, {
					Base = Config.DAMAGE,
					Skill = script.Parent.Name
				})
				Combat_Util.AddStun(script, character, p3, Config.STUN)
				Combat_presets.PlayReactAnim(humanoid)
			end

			return false
		end
	})
	v3()
end

function CrossReaverServer.Cancel(player, _, p)
	if not player then
		return
	end

	if p then
		p.cancelled = true
	end

	local character = player.Character

	if character then
		EffectsEvent.ToAllInRange(player, "Cross Reaver_effs", character, "Cancel")
	end
end

return CrossReaverServer