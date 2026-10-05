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
local Combat_presets = require(CAM.Global.Combat_presets)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local ServerClientPortal = require(global.ServerClientPortal)
local DebrisModule = require(CAM:FindFirstChild("DebrisModule"))
local AppliedTicks = require(global.Subsets.Gameplay.AppliedTicks)
local Clans = require(CAM.Clans)
local EffectsEvent = require(ReplicatedStorage2.Communication.ServerAndClient.Effects.EffectsEvent)
local StatTypes = require(CAM.Global.Types.StatTypes)
local Config = require(script.Parent.Config)
ReplicatedStorage:FindFirstChild("Assets"):FindFirstChild("Animations")
local HundredLeggedZigzagServer = {
	Id = {}
}
local v2 = script.Parent.Name .. "Hold"

local function lock(part, cframe: CFrame, p: number?, childName: string?)
	part:PivotTo(cframe)
	local clone = childName and workspace.Debree:FindFirstChild(childName)

	if not clone then
		clone = script.LOCK:Clone()
		clone.Name = childName or "LOCK"
		clone.Parent = workspace.Debree
		clone.Transparency = 1
	end

	clone:PivotTo(cframe)

	if p then
		DebrisModule:AddItem(clone, p)
	end

	local weld = clone.Weld
	weld.Part0 = clone
	weld.Part1 = part
	return clone
end

function HundredLeggedZigzagServer.Hold(player, p, state)
	if player == nil or player.Character == nil or player.Character.PrimaryPart == nil or player.Character:FindFirstChild("Humanoid") == nil then
		return
	end

	local character = player.Character
	local humanoid = character.Humanoid
	local rootPart = humanoid.RootPart
	local animator = humanoid.Animator
	local v3 = HundredLeggedZigzagServer.Id[player.UserId]
	local getvaluesfolder = Utility.getvaluesfolder(character)
	state.Unheld = false
	state.Value_Table = {}
	local v4 = Utility.AddValue(getvaluesfolder, Config.STAMINA_DRAIN_VALUE)
	v4:AddTag(StatTypes.ValueStatTag)
	v4:SetAttribute(StatTypes.StatToAttribute("Stamina Drain Rate"), Config.STAMINA_DRAIN_RATE)
	table.insert(state.Value_Table, v4)
	local boolValue = Instance.new("BoolValue")
	boolValue.Name = "pause_gameplay"
	boolValue.Parent = getvaluesfolder
	table.insert(state.Value_Table, boolValue)
	local boolValue2 = Instance.new("BoolValue")
	boolValue2.Name = "skill_stand_still"
	boolValue2.Parent = getvaluesfolder
	table.insert(state.Value_Table, boolValue2)
	EffectsEvent.ToAllInRange(player, "Hundred-Legged_Zigzag_VFX", character, "Dashing", Config.WINDUP)
	local track = animator:LoadAnimation(script["Miss Start"])
	track:Play()
	table.insert(state.Value_Table, track)
	task.delay(Config.DASH_CAMSUBJECT_AT, function()
		if not (v3 == HundredLeggedZigzagServer.Id[player.UserId] and state.Unheld ~= true) then
			return
		end

		local objectValue = Instance.new("ObjectValue")
		objectValue.Value = character:FindFirstChild("UpperTorso")
		objectValue.Name = "camsubject"
		objectValue.Parent = getvaluesfolder
		table.insert(state.Value_Table, objectValue)
	end)
	state.InWindup = true
	task.wait(Config.WINDUP)
	state.InWindup = nil

	if state.Value_Table == nil then
		return
	end

	local safeLookAt = Utility.SafeLookAt(
		rootPart.Position,
		Vector3.new(p.X, rootPart.Position.Y, p.Z),
		rootPart.CFrame
	)
	local count = 0

	local function fn(instance, parent, p2, _)
		if instance then
			local rootPart2 = instance:FindFirstChild("Humanoid").RootPart

			if p2 == true then
				count += 1

				for _, v5 in ipairs({ "pause_gameplay", "iframe" }) do
					Utility.AddValue(parent, v5, Config.GRAB_DURATION - Config.WINDUP)
				end

				task.delay(Config.GRAB_CAMSUBJECT_AT - Config.WINDUP, function()
					if v3 ~= HundredLeggedZigzagServer.Id[player.UserId] then
						return
					end

					local objectValue = Instance.new("ObjectValue")
					objectValue.Value = character:FindFirstChild("UpperTorso")
					objectValue.Name = "camsubject"
					objectValue.Parent = parent
					DebrisModule:AddItem(objectValue, Config.GRAB_CAMSUBJECT_DUR)
					table.insert(state.Value_Table, objectValue)
				end)
				local v5 = safeLookAt
				local v6 = Config.GRAB_DURATION - Config.WINDUP
				rootPart2:PivotTo(v5)
				local clone = nil

				if not clone then
					clone = script.LOCK:Clone()
					clone.Name = "LOCK"
					clone.Parent = workspace.Debree
					clone.Transparency = 1
				end

				clone:PivotTo(v5)

				if v6 then
					DebrisModule:AddItem(clone, v6)
				end

				local weld = clone.Weld
				weld.Part0 = clone
				weld.Part1 = rootPart2
				table.insert(state.Value_Table, clone)
				local animator2 = instance:FindFirstChild("Humanoid"):FindFirstChild("Animator")

				if animator2 then
					local track2 = animator2:LoadAnimation(script["Grab Victim"])
					track2:Play(nil, nil, 0.01)
					task.delay(Config.GRAB_VICTIM_ANIM_RESUME_AT - Config.WINDUP, function()
						track2:AdjustSpeed(1)
					end)
				end

				if count == 1 then
					track:Stop()
					EffectsEvent.ToAllInRange(player, "Hundred-Legged_Zigzag_VFX", character, "Grab", Config.WINDUP)
				end

				task.delay(Config.GRAB_SLASH_AT - Config.WINDUP, function()
					if rootPart2 == nil or rootPart2.Parent == nil or rootPart == nil or rootPart.Parent == nil then
						return
					end

					Combat_Util.Damage(script, character, instance, {
						Base = Config.GRAB_SLASH_DAMAGE,
						Skill = script.Parent.Name
					})
					task.wait(Config.GRAB_THRUST_DELAY)

					if rootPart2 == nil or rootPart2.Parent == nil or rootPart == nil or rootPart.Parent == nil then
						return
					end

					Combat_Util.Damage(script, character, instance, {
						Base = Config.GRAB_THRUST_DAMAGE,
						Skill = script.Parent.Name
					})
					task.wait(Config.GRAB_FINISHER_DELAY)

					if rootPart2 == nil or rootPart2.Parent == nil or rootPart == nil or rootPart.Parent == nil then
						return
					end

					local v7 = rootPart.CFrame.LookVector * Config.GRAB_FINISHER_KNOCKBACK

					if clone ~= nil then
						clone:Destroy()
						clone = nil
					end

					Combat_Util.AddStun(script, character, parent, Config.GRAB_FINISHER_STUN, true)
					Combat_Util.Damage(script, character, instance, {
						Base = Config.GRAB_FINISHER_DAMAGE,
						Skill = script.Parent.Name
					})

					if Clans.HasPassive(character:GetAttribute("Clan"), "Insect Affinity") then
						local v8 = Utility.AddValue(
							parent,
							AppliedTicks.ByName.Poison.Value,
							Config.POISON_DURATION,
							"ObjectValue",
							character
						)
						v8:SetAttribute("Damage", Config.POISON_TICK_DAMAGE)
						v8:SetAttribute("Skill", script.Parent.Name)
					end

					Combat_Util.RagDoll(script, character, parent, Config.GRAB_FINISHER_RAGDOLL)
					Combat_Util.Knockback(script, character, rootPart2, v7, Config.GRAB_FINISHER_KNOCKBACK_DUR)
				end)

				if count == 1 then
					if HundredLeggedZigzagServer.Id[player.UserId] == v3 then
						EffectsEvent.ToClient(
							player,
							"force_skill_actions_server",
							script.Parent.Name,
							"Cancel",
							nil,
							false
						)
					end

					state.Unheld = true
					task.delay(Config.GRAB_SLASH_AT + Config.GRAB_THRUST_DELAY + 0.55 - Config.WINDUP, function()
						if state.Value_Table == nil then
							return
						end

						for _, v7 in state.Value_Table do
							v7:Destroy()
						end

						state.Unheld = nil
						state.Value_Table = nil
					end)
					local animator3 = character:FindFirstChild("Humanoid"):FindFirstChild("Animator")

					if animator3 then
						local track2 = animator3:LoadAnimation(script["Grab User"])
						track2:Play()
						track2.TimePosition = Config.WINDUP
						table.insert(state.Value_Table, track2)
					end

					local part = rootPart
					local v8 = safeLookAt
					local v9 = Config.GRAB_DURATION - Config.WINDUP
					part:PivotTo(v8)
					local clone2 = nil

					if not clone2 then
						clone2 = script.LOCK:Clone()
						clone2.Name = "LOCK"
						clone2.Parent = workspace.Debree
						clone2.Transparency = 1
					end

					clone2:PivotTo(v8)

					if v9 then
						DebrisModule:AddItem(clone2, v9)
					end

					local weld2 = clone2.Weld
					weld2.Part0 = clone2
					weld2.Part1 = part

					for _, v10 in ipairs({ "pause_gameplay", "iframe" }) do
						Utility.AddValue(getvaluesfolder, v10, Config.GRAB_DURATION - Config.WINDUP)
					end

					task.delay(Config.GRAB_CAMSUBJECT_AT - Config.WINDUP, function()
						if rootPart == nil or rootPart.Parent == nil then
							return
						end

						local objectValue = Instance.new("ObjectValue")
						objectValue.Value = character:FindFirstChild("UpperTorso")
						objectValue.Name = "camsubject"
						objectValue.Parent = getvaluesfolder
						DebrisModule:AddItem(objectValue, Config.GRAB_CAMSUBJECT_DUR)
						table.insert(state.Value_Table, objectValue)
					end)
				end
			end
		end
	end

	local function fn2(instance, p2, p3, _)
		if instance then
			local humanoid2 = instance:FindFirstChild("Humanoid")
			local rootPart2 = humanoid2.RootPart

			if p3 == "Blocking" or p3 == "Perfect" and count > 0 then
				Combat_Util.Block(script, character, instance, Config.DASH_BLOCK_BREAK)
			elseif p3 == "Perfect" then
				if count == 0 then
					Combat_Util.Perfect(script, character, instance)
					return true
				end
			elseif p3 == true then
				count += 1
				local part = rootPart
				local cFrame = rootPart.CFrame
				local DASH_HIT_LOCK_DURATION = Config.DASH_HIT_LOCK_DURATION
				part:PivotTo(cFrame)
				local clone = nil

				if not clone then
					clone = script.LOCK:Clone()
					clone.Name = "LOCK"
					clone.Parent = workspace.Debree
					clone.Transparency = 1
				end

				clone:PivotTo(cFrame)

				if DASH_HIT_LOCK_DURATION then
					DebrisModule:AddItem(clone, DASH_HIT_LOCK_DURATION)
				end

				local weld = clone.Weld
				weld.Part0 = clone
				weld.Part1 = part

				for _, v6 in ipairs({ "pause_gameplay", "iframe" }) do
					Utility.AddValue(p2, v6, Config.DASH_HIT_LOCK_DURATION)
				end

				if count == 1 then
					EffectsEvent.ToAllInRange(player, "Hundred-Legged_Zigzag_VFX", character, "Miss Success")
				end

				local v6 = math.random(1, 4)
				Combat_presets.PlayReactAnim(humanoid2, v6, 1.5)
				task.delay(Config.DASH_HIT_AT, function()
					if rootPart == nil or rootPart.Parent == nil or rootPart2 == nil or rootPart2.Parent == nil then
						return
					end

					Combat_Util.Damage(script, character, instance, {
						Base = Config.DASH_HIT_DAMAGE,
						Skill = script.Parent.Name
					})
					task.wait(Config.DASH_FINISHER_DELAY)

					if rootPart == nil or rootPart.Parent == nil or rootPart2 == nil or rootPart2.Parent == nil then
						return
					end

					local v7 = rootPart.CFrame.LookVector * Config.DASH_FINISHER_KNOCKBACK

					if clone ~= nil then
						clone:Destroy()
						clone = nil
					end

					Combat_Util.Add_Strict_Stun(script, character, p2, Config.DASH_FINISHER_STUN)
					Combat_Util.Damage(script, character, instance, {
						Base = Config.DASH_FINISHER_DAMAGE,
						Skill = script.Parent.Name
					})

					if Clans.HasPassive(character:GetAttribute("Clan"), "Insect Affinity") then
						local v8 = Utility.AddValue(
							p2,
							AppliedTicks.ByName.Poison.Value,
							Config.POISON_DURATION,
							"ObjectValue",
							character
						)
						v8:SetAttribute("Damage", Config.POISON_TICK_DAMAGE)
						v8:SetAttribute("Skill", script.Parent.Name)
					end

					Combat_Util.RagDoll(script, character, p2, Config.DASH_FINISHER_RAGDOLL)
					Combat_Util.Knockback(script, character, rootPart2, v7, Config.DASH_FINISHER_KNOCKBACK_DUR)
				end)

				if count == 1 then
					if HundredLeggedZigzagServer.Id[player.UserId] == v3 then
						EffectsEvent.ToClient(
							player,
							"force_skill_actions_server",
							script.Parent.Name,
							"Cancel",
							nil,
							false
						)
					end

					task.delay(0.4, function()
						if state.Value_Table == nil then
							return
						end

						for _, v7 in state.Value_Table do
							v7:Destroy()
						end

						state.Unheld = nil
						state.Value_Table = nil
					end)
					state.Unheld = true
					ServerClientPortal.ToClient(player, v2, 2)
					local animator2 = character:FindFirstChild("Humanoid"):FindFirstChild("Animator")

					if animator2 then
						animator2:LoadAnimation(script["Miss End"]):Play()
					end

					local part2 = rootPart
					local cFrame2 = rootPart.CFrame
					local DASH_HIT_LOCK_DURATION2 = Config.DASH_HIT_LOCK_DURATION
					part2:PivotTo(cFrame2)
					local clone2 = nil

					if not clone2 then
						clone2 = script.LOCK:Clone()
						clone2.Name = "LOCK"
						clone2.Parent = workspace.Debree
						clone2.Transparency = 1
					end

					clone2:PivotTo(cFrame2)

					if DASH_HIT_LOCK_DURATION2 then
						DebrisModule:AddItem(clone2, DASH_HIT_LOCK_DURATION2)
					end

					local weld2 = clone2.Weld
					weld2.Part0 = clone2
					weld2.Part1 = part2

					for _, v8 in ipairs({ "pause_gameplay", "iframe" }) do
						Utility.AddValue(getvaluesfolder, v8, Config.DASH_HIT_LOCK_DURATION)
					end
				end
			end
		end
	end

	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = rootPart.CFrame * Config.GRAB_HITBOX_OFFSET,
		hitboxSize = Config.GRAB_HITBOX_SIZE,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = fn
	})

	if count == 0 and state.Unheld == false and v3 == HundredLeggedZigzagServer.Id[player.UserId] then
		track:Stop()
		ServerClientPortal.ToClient(player, v2, 1)

		while v3 == HundredLeggedZigzagServer.Id[player.UserId] and state.Unheld == false and rootPart.Parent ~= nil do
			Utility.CreateHitbox({
				caster = character,
				visualize = false,
				hitboxCFrame = rootPart.CFrame * Config.DASH_HITBOX_OFFSET,
				hitboxSize = Config.DASH_HITBOX_SIZE,
				checker = Checker,
				hitPriorityHandler = {
					callback = v.Exists,
					data = "Choosing_1"
				},
				hitDetected = fn2
			})
			task.wait(0.1)
		end
	end

	if state.Unheld then
		return true
	end
end

function HundredLeggedZigzagServer.UnHold(p, p2, p3)
	while p3.InWindup do
		task.wait()
	end

	HundredLeggedZigzagServer.Cancel(p, p2, p3)
end

function HundredLeggedZigzagServer.Cancel(player, _, state)
	if state.Unheld == true then
		return
	end

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

	local character = player.Character

	if not character then
		return
	end

	EffectsEvent.ToAllInRange(player, "Hundred-Legged_Zigzag_VFX", character, "Cancel")
end

return HundredLeggedZigzagServer