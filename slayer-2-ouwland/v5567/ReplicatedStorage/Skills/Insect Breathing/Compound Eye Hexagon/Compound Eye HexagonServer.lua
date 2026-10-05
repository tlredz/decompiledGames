local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
game:GetService("RunService")
game:GetService("CollectionService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage:WaitForChild("CAM")
local SAM = ServerStorage:WaitForChild("SAM")
local global = CAM:WaitForChild("Global")
local services = SAM:WaitForChild("Services")
local Utility = require(global.Utility)
local Checker = require(global.Checker)
local Combat_Util = require(services.Combat_Util)
local ImpactSounds = require(SAM.Utility.ImpactSounds)
local Combat_presets = require(CAM.Global.Combat_presets)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local ManuelCancel = require(global.Subsets.Gameplay.ManuelCancel)
local AppliedTicks = require(global.Subsets.Gameplay.AppliedTicks)
local Clans = require(CAM.Clans)
local DebrisModule = require(CAM:FindFirstChild("DebrisModule"))
require(ReplicatedStorage2.CAM.Global.Character_info_provider)
local EffectsEvent = require(ReplicatedStorage2.Communication.ServerAndClient.Effects.EffectsEvent)
local Config = require(script.Parent.Config)
ReplicatedStorage:FindFirstChild("Assets"):FindFirstChild("Animations")
local CompoundEyeHexagonServer = {
	Id = {}
}
local script2 = script

function CompoundEyeHexagonServer.Hold(player, _, _)
	if not player then
		return
	end

	local character = player.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not (humanoidRootPart and character:FindFirstChild("Animator", true)) then
		return
	end

	Utility.getvaluesfolder(character)
	local v2 = CompoundEyeHexagonServer.Id[player.UserId]
	EffectsEvent.ToAllInRange(player, "Compound_Eye_Hexagon_VFX", character, "Loop")

	local function fn(instance, p, p2, _)
		if instance then
			local humanoid = instance:FindFirstChild("Humanoid")
			local rootPart = humanoid.RootPart

			if p2 == "Blocking" then
				Combat_Util.Block(script2, character, instance, Config.LOOP_BLOCK_BREAK)
			elseif p2 == "Perfect" then
				Combat_Util.Perfect(script2, character, instance)
			elseif p2 == true then
				local v3 = CFrame.new(rootPart.Position).UpVector * Config.LOOP_KNOCKUP
				EffectsEvent.ToAllInRange(player, "Normal_Sword_Slash_Effect", rootPart, -1)
				Combat_Util.AddStun(script2, character, p, Config.LOOP_STUN, true)
				Combat_Util.Damage(script2, character, instance, {
					Base = Config.LOOP_DAMAGE,
					Skill = script.Parent.Name
				})

				if Clans.HasPassive(character:GetAttribute("Clan"), "Insect Affinity") then
					local v4 = Utility.AddValue(
						p,
						AppliedTicks.ByName.Poison.Value,
						Config.POISON_DURATION,
						"ObjectValue",
						character
					)
					v4:SetAttribute("Damage", Config.POISON_TICK_DAMAGE)
					v4:SetAttribute("Skill", script.Parent.Name)
				end

				Combat_Util.Knockback(script2, character, rootPart, v3, Config.LOOP_KNOCKBACK_DUR)

				if humanoid then
					local v4 = math.random(1, 4)
					Combat_presets.PlayReactAnim(humanoid, v4)
				end
			end
		end
	end

	task.wait(Config.WINDUP)
	local position = humanoidRootPart.Position

	while humanoidRootPart:IsDescendantOf(workspace) and CompoundEyeHexagonServer.Id[player.UserId] == v2 do
		Utility.CreateHitbox({
			caster = character,
			visualize = false,
			hitboxCFrame = CFrame.new(position.X, humanoidRootPart.Position.Y, position.Z) * humanoidRootPart.CFrame.Rotation * Config.LOOP_HITBOX_OFFSET,
			hitboxSize = Config.LOOP_HITBOX_SIZE,
			checker = Checker,
			hitPriorityHandler = {
				callback = v.Exists,
				data = "Choosing_1"
			},
			hitDetected = fn
		})
		task.wait(Config.LOOP_TICK_INTERVAL)
	end
end

function CompoundEyeHexagonServer.UnHold(player, p, p2)
	if not player then
		return
	end

	local character = player.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not (humanoidRootPart and character:FindFirstChild("Animator", true)) then
		return
	end

	local getvaluesfolder = Utility.getvaluesfolder(character)
	local v2, _ = ManuelCancel.new(character, Config.UNHOLD_CANCEL_WINDOW)
	local v3 = CompoundEyeHexagonServer.Id[player.UserId]
	v2:Connect(function()
		v3 = -1
		CompoundEyeHexagonServer.Cancel(player, p, p2)
	end)
	p2.Value_Table = {}
	local boolValue = Instance.new("BoolValue")
	boolValue.Name = "pause_gameplay"
	boolValue.Parent = getvaluesfolder
	DebrisModule:AddItem(boolValue, Config.UNHOLD_LOCK_DURATION)
	table.insert(p2.Value_Table, boolValue)
	local boolValue2 = Instance.new("BoolValue")
	boolValue2.Name = "NR"
	boolValue2.Parent = getvaluesfolder
	table.insert(p2.Value_Table, boolValue2)
	DebrisModule:AddItem(boolValue2, Config.UNHOLD_LOCK_DURATION)
	EffectsEvent.ToAllInRange(player, "Compound_Eye_Hexagon_VFX", character, "End")
	task.wait(Config.DASH_START_AT)

	local function fn(instance, p3, p4, p5)
		if instance then
			local rootPart = instance:FindFirstChild("Humanoid").RootPart

			if p4 == "Perfect" then
				Combat_Util.Perfect(script2, character, instance)
			elseif p4 == "Blocking" then
				Combat_Util.Block(script2, character, instance, Config.DASH_BLOCK_BREAK)
			elseif p4 == true then
				local v4 = p5.lookVector * Config.DASH_KNOCKBACK
				EffectsEvent.ToAllInRange(player, "Normal_Sword_Slash_Effect", rootPart, -1)
				Combat_Util.AddStun(script2, character, p3, Config.DASH_STUN, true)
				Combat_Util.Damage(script2, character, instance, {
					Base = Config.DASH_DAMAGE,
					Skill = script.Parent.Name
				})
				Combat_Util.RagDoll(script2, character, p3, Config.DASH_RAGDOLL)
				Combat_Util.Knockback(
					script2,
					character,
					rootPart,
					Vector3.new(v4.X, Config.DASH_KNOCKUP, v4.Z),
					Config.DASH_KNOCKBACK_DUR
				)
			end
		end
	end

	local v4 = humanoidRootPart.CFrame * Config.DASH_HITBOX_START_OFFSET * CFrame.new(0, 0, -(Config.DASH_DISTANCE / 2))
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = v4,
		hitboxSize = Vector3.new(
			Config.DASH_HITBOX_SIZE.X,
			Config.DASH_HITBOX_SIZE.Y,
			Config.DASH_DISTANCE + Config.DASH_HITBOX_SIZE.Z
		),
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = fn,
		extraArgs = v4,
		After = function(p3, list)
			if p3 then
				ImpactSounds.Play(character, script.Parent.Name, list[1])
			end
		end
	})
	task.wait(Config.DASH_SWEEP_DURATION)
end

function CompoundEyeHexagonServer.Cancel(player, _, p)
	if not player then
		return
	end

	local character = player.Character

	if not character then
		return
	end

	EffectsEvent.ToAllInRange(player, "Compound_Eye_Hexagon_VFX", character, "Cancel")

	if p.Value_Table then
		for _, v2 in p.Value_Table do
			v2:Destroy()
		end
	end
end

return CompoundEyeHexagonServer