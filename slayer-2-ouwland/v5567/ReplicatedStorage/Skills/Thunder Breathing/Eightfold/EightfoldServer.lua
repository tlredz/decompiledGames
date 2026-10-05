local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
game:GetService("RunService")
game:GetService("CollectionService")
local CAM = ReplicatedStorage:WaitForChild("CAM")
local SAM = ServerStorage:WaitForChild("SAM")
local global = CAM:WaitForChild("Global")
local services = SAM:WaitForChild("Services")
local communication = ReplicatedStorage:WaitForChild("Communication")
local Utility = require(global.Utility)
local Checker = require(global.Checker)
local Combat_Util = require(services.Combat_Util)
require(CAM.Global.Combat_presets)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local DebrisModule = require(CAM:FindFirstChild("DebrisModule"))
local Config = require(script.Parent.Config)
local EffectsEvent = require(communication.ServerAndClient.Effects.EffectsEvent)
local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = { workspace.Map }
raycastParams.FilterType = Enum.RaycastFilterType.Include
local EightfoldServer = {
	Id = {},
	Hold = function(player, _, state)
		if not player then
			return
		end

		local character = player.Character

		if not character then
			return
		end

		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		character:FindFirstChild("Head")

		if not (humanoidRootPart and character:FindFirstChild("Animator", true)) then
			return
		end

		local getvaluesfolder = Utility.getvaluesfolder(character)
		state.Cancelled = false

		if not humanoidRootPart or state.Cancelled then
			return
		end

		state.Items = {}
		local stringValue = Instance.new("StringValue")
		stringValue.Name = "Transparent"
		stringValue.Value = script.Parent.Name
		stringValue.Parent = getvaluesfolder
		DebrisModule:AddItem(stringValue, Config.HOLD_MAX_DUR)
		table.insert(state.Items, stringValue)
		EffectsEvent.ToAll("Eightfold_VFX", character, "Start")
		local lastTime = os.clock()

		local function fn(instance, p, p2, _)
			if instance then
				local _ = instance:FindFirstChild("Humanoid").RootPart

				if p2 == "Blocking" then
					Combat_Util.Block(script, character, instance, Config.TICK_BLOCK_BREAK)
				elseif p2 == "Perfect" then
					Combat_Util.Perfect(script, character, instance)
				elseif p2 == true then
					Combat_Util.AddStun(script, character, p, Config.TICK_STUN)
					Combat_Util.Damage(script, character, instance, {
						Base = Config.TICK_DAMAGE,
						Skill = script.Parent.Name
					})
					Combat_Util.RagDoll(script, character, p, Config.TICK_RAGDOLL)
				end
			end
		end

		local TICK_HITBOX_SIZE = Config.TICK_HITBOX_SIZE
		local hitboxCFrame = humanoidRootPart.CFrame * CFrame.new(0, TICK_HITBOX_SIZE.Y / 2 - 2, 0)
		task.spawn(function()
			while state.Cancelled == false and os.clock() - lastTime < Config.HOLD_MAX_DUR do
				Utility.CreateHitbox({
					caster = character,
					hitboxCFrame = hitboxCFrame,
					hitboxSize = TICK_HITBOX_SIZE,
					checker = Checker,
					hitPriorityHandler = {
						callback = v.Exists,
						data = "Choosing_1"
					},
					hitDetected = fn
				})
				task.wait(Config.TICK_INTERVAL)
			end
		end)
	end
}

function EightfoldServer.UnHold(player, _, state)
	if state.Cancelled or not player then
		return
	end

	local character = player.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	EightfoldServer.Id[player.UserId] = 2

	if not (humanoidRootPart and character:FindFirstChild("Animator", true)) then
		return
	end

	Utility.getvaluesfolder(character)

	if not humanoidRootPart or state.Cancelled then
		return
	end

	EffectsEvent.ToAll("Eightfold_VFX", character, "End")
	state.Cancelled = true

	for k, item in state.Items do
		item:Destroy()
		state.Items[k] = nil
	end

	local function fn(instance, p, p2, _)
		if instance then
			local rootPart = instance:FindFirstChild("Humanoid").RootPart

			if p2 == true or p2 == "Blocking" or p2 == "Perfect" then
				local v2 = CFrame.new(rootPart.Position).UpVector * Config.FINAL_KNOCKUP
				Combat_Util.AddStun(script, character, p, Config.FINAL_STUN)
				Combat_Util.Damage(script, character, instance, {
					Base = Config.FINAL_DAMAGE,
					Skill = script.Parent.Name
				})
				Combat_Util.RagDoll(script, character, p, Config.FINAL_RAGDOLL)
				Combat_Util.Knockback(script, character, rootPart, v2, Config.FINAL_KNOCKBACK_DUR)
			end
		end
	end

	local FINAL_HITBOX_SIZE = Config.FINAL_HITBOX_SIZE
	local hitboxCFrame = humanoidRootPart.CFrame * CFrame.new(0, FINAL_HITBOX_SIZE.Y / 2 - 2, 0)
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = hitboxCFrame,
		hitboxSize = FINAL_HITBOX_SIZE,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = fn
	})
end

function EightfoldServer.Cancel(player, _, p)
	if not player then
		return
	end

	local character = player.Character

	if not character then
		return
	end

	EffectsEvent.ToAll("Eightfold_VFX", character, "Cancel")
	p.Cancelled = true

	for k, item in p.Items do
		item:Destroy()
		p.Items[k] = nil
	end
end

return EightfoldServer