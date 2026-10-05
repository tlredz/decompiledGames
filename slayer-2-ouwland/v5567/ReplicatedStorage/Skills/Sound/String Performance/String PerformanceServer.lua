local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CAM = ReplicatedStorage:WaitForChild("CAM")
local SAM = ServerStorage:WaitForChild("SAM")
local global = CAM:WaitForChild("Global")
local services = SAM:WaitForChild("Services")
local Utility = require(global.Utility)
local Checker = require(global.Checker)
local Combat_Util = require(services.Combat_Util)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local DebrisModule = require(CAM:FindFirstChild("DebrisModule"))
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local Config = require(script.Parent.Config)
local StringPerformanceServer = {
	Id = {}
}

local function lock(part, cframe: CFrame, p: number?, childName: string?)
	part:PivotTo(cframe)
	local clone = childName and workspace.Debree:FindFirstChild(childName)

	if not clone then
		clone = script.Parent.Parent.Parent.LOCK:Clone()
		clone.Name = childName or "LOCK"
		clone.Parent = workspace.Debree
		clone.Transparency = 1
	end

	clone:PivotTo(cframe)

	if p then
		DebrisModule:AddItem(clone, p)
	end

	clone.Weld.part1 = part
	return clone
end

function StringPerformanceServer.Hold(player, _, state)
	if player == nil or player.Character == nil or player.Character.PrimaryPart == nil or player.Character:FindFirstChild("Humanoid") == nil then
		return
	end

	local character = player.Character
	local humanoid = character.Humanoid
	local rootPart = humanoid.RootPart
	local getvaluesfolder = Utility.getvaluesfolder(character)
	local v2 = StringPerformanceServer.Id[player.UserId]
	state.Unheld = false
	state.Value_Table = {}
	local instances = { character }
	local v3 = false

	local function fn(instance, p, p2, _)
		if not instance then
			return
		end

		local humanoid2 = instance:FindFirstChild("Humanoid")
		local rootPart2 = humanoid2.RootPart

		if p2 == "Perfect" or p2 == "Blocking" then
			Combat_Util.Block(script, character, instance, Config.BLOCK_BREAK)
			v3 = true
		else
			if p2 ~= true then
				return
			end

			local v4 = state.Unheld == false
			table.insert(instances, instance)
			local cFrame = rootPart.CFrame

			for _, v5 in ipairs({ "pause_gameplay", "iframe" }) do
				Utility.AddValue(p, v5, Config.ANIM_DURATION)
			end

			local IMPACT_AT = Config.IMPACT_AT
			rootPart2:PivotTo(cFrame)
			local clone = nil

			if not clone then
				clone = script.Parent.Parent.Parent.LOCK:Clone()
				clone.Name = "LOCK"
				clone.Parent = workspace.Debree
				clone.Transparency = 1
			end

			clone:PivotTo(cFrame)

			if IMPACT_AT then
				DebrisModule:AddItem(clone, IMPACT_AT)
			end

			clone.Weld.part1 = rootPart2
			table.insert(state.Value_Table, clone)
			local animator = humanoid2:FindFirstChild("Animator")
			local track

			if animator then
				track = animator:LoadAnimation(script.Victim)
				track:Play()
				table.insert(state.Value_Table, track)
			else
				track = nil
			end

			task.delay(Config.SPIN_START, function()
				if rootPart2 == nil or rootPart2.Parent == nil or rootPart == nil or rootPart.Parent == nil then
					return
				end

				for _ = 1, Config.SPIN_TICK_COUNT do
					if rootPart2 == nil or rootPart2.Parent == nil then
						break
					end

					Combat_Util.Damage(script, character, instance, {
						Base = Config.SPIN_TICK_DAMAGE,
						Skill = script.Parent.Name
					})
					task.wait(Config.SPIN_TICK)
				end
			end)
			task.delay(Config.IMPACT_AT, function()
				if rootPart2 == nil or rootPart2.Parent == nil or rootPart == nil or rootPart.Parent == nil then
					return
				end

				if clone then
					clone:Destroy()
				end

				if track then
					track:Stop()
				end

				Combat_Util.AddStun(script, character, p, Config.IMPACT_STUN)
				Combat_Util.RagDoll(script, character, p, Config.IMPACT_RAGDOLL)
				Combat_Util.Damage(script, character, instance, {
					Base = Config.IMPACT_DAMAGE,
					Skill = script.Parent.Name
				})
				local v5 = rootPart.CFrame.LookVector * Config.IMPACT_KNOCKBACK_FORWARD + vector.create(
					0,
					Config.IMPACT_KNOCKBACK_UP,
					0
				)
				Combat_Util.Knockback(script, character, rootPart2, v5, Config.IMPACT_KNOCKBACK_DURATION)
			end)

			if v4 then
				EffectsEvent.ToAllInRange(character, "String PerformanceVFX", character, "Grab")
				local part = rootPart
				local ANIM_DURATION = Config.ANIM_DURATION
				part:PivotTo(cFrame)
				local clone2 = nil

				if not clone2 then
					clone2 = script.Parent.Parent.Parent.LOCK:Clone()
					clone2.Name = "LOCK"
					clone2.Parent = workspace.Debree
					clone2.Transparency = 1
				end

				clone2:PivotTo(cFrame)

				if ANIM_DURATION then
					DebrisModule:AddItem(clone2, ANIM_DURATION)
				end

				clone2.Weld.part1 = part

				for _, v6 in ipairs({ "pause_gameplay", "iframe", "CameralessCutscene" }) do
					Utility.AddValue(getvaluesfolder, v6, Config.ANIM_DURATION)
				end

				local animator2 = humanoid:FindFirstChild("Animator")

				if animator2 then
					local track2 = animator2:LoadAnimation(script.Attacker)
					track2:Play()
					table.insert(state.Value_Table, track2)
				end

				if StringPerformanceServer.Id[player.UserId] == v2 then
					EffectsEvent.ToClient(player, "force_skill_actions_server", script.Parent.Name, "UnHold", nil)
				end

				state.Unheld = true
				task.delay(Config.ANIM_DURATION, function()
					if state.Value_Table == nil then
						return
					end

					for _, v6 in state.Value_Table do
						v6:Destroy()
					end

					state.Unheld = nil
					state.Value_Table = nil
				end)
			end
		end
	end

	local boolValue = Instance.new("BoolValue")
	boolValue.Name = "pause_gameplay"
	boolValue.Parent = getvaluesfolder
	table.insert(state.Value_Table, boolValue)
	EffectsEvent.ToAllInRange(character, "String PerformanceVFX", character, "Start")

	while v2 == StringPerformanceServer.Id[player.UserId] and state.Unheld == false and not v3 and rootPart.Parent ~= nil do
		Utility.CreateHitbox({
			caster = character,
			hitboxCFrame = rootPart.CFrame * Config.LOOP_HITBOX_OFFSET,
			hitboxSize = Config.LOOP_HITBOX_SIZE,
			checker = Checker,
			hitPriorityHandler = {
				callback = v.Exists,
				data = "Choosing_1"
			},
			hitDetected = fn
		})
		task.wait(Config.LOOP_INTERVAL)
	end

	if state.Unheld then
		return true
	end

	if v3 and StringPerformanceServer.Id[player.UserId] == v2 then
		EffectsEvent.ToClient(player, "force_skill_actions_server", script.Parent.Name, "UnHold", nil)
	end
end

function StringPerformanceServer.UnHold(...)
	StringPerformanceServer.Cancel(...)
end

function StringPerformanceServer.Cancel(player, _, state)
	if state.Unheld == true then
		return
	end

	EffectsEvent.ToAllInRange(player.Character, "String PerformanceVFX", player.Character, "Cancel")

	if state.Value_Table ~= nil then
		for _, animationTrack in state.Value_Table do
			if animationTrack:IsA("AnimationTrack") then
				animationTrack:Stop()
			end

			animationTrack:Destroy()
		end
	end

	state.Value_Table = nil
	state.Unheld = nil

	if not player then
		return
	end

	if player.Character then
	end
end

return StringPerformanceServer