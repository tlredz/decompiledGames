local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local UnknowingFireServer = {
	Id = {}
}
require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Utility"))
local Checker = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Checker"))
require(game.ServerStorage:WaitForChild("SAM"):WaitForChild("Services"):WaitForChild("Server_Mouse_Pos"))
local hit_priority_handler = require(game.ServerStorage:WaitForChild("SAM"):WaitForChild("Game_Play"):WaitForChild("hit_priority_handler"))
local v = hit_priority_handler.new(script)
local ManuelCancel = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.ManuelCancel)
local Combat_Util = require(ServerStorage.SAM.Services.Combat_Util)
local ImpactSounds = require(ServerStorage.SAM.Utility.ImpactSounds)
local Config = require(script.Parent.Config)
game:GetService("CollectionService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Combat_presets = require(ReplicatedStorage2.CAM.Global.Combat_presets)
local _ = table.find
local _ = table.remove
local _ = Vector3.new
local _ = tick
local EffectsEvent = require(ReplicatedStorage2.Communication.ServerAndClient.Effects.EffectsEvent)
local Utility = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Utility"))
local _ = table.find
local _ = table.remove

function UnknowingFireServer.Hold(player)
	local character = player.Character
	character:FindFirstChild("HumanoidRootPart")
	character:FindFirstChild("Humanoid")
	local v2 = UnknowingFireServer.Id[player.UserId]
	task.wait(0.13)

	if v2 == UnknowingFireServer.Id[player.UserId] then
		EffectsEvent.ToAllInRange(player, "Unknowing FireVFX", player.Character, "Start")
	end
end

local RaycastHelper = require(ReplicatedStorage2.CAM.Global.RaycastHelper)

function UnknowingFireServer.UnHold(player, p, state)
	if player.Character == nil then
		return
	end

	local v2 = UnknowingFireServer.Id[player.UserId]
	local character = player.Character

	if character == nil then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")

	if humanoidRootPart == nil or humanoid == nil or p == nil then
		return
	end

	local getvaluesfolder = Utility.getvaluesfolder(character)
	local cFrame = humanoidRootPart.CFrame
	local position = cFrame.Position
	local maximizeRayServer, _, _, _ = RaycastHelper.MaximizeRayServer(
		character,
		position,
		p,
		Config.AIM_RANGE,
		true,
		5,
		7,
		3
	)
	local _ = (maximizeRayServer - position).unit
	local boolValue = Instance.new("BoolValue")
	boolValue.Name = "NOMouvementlines"
	boolValue.Parent = getvaluesfolder
	EffectsEvent.ToAllInRange(player, "Unknowing FireVFX", player.Character, "Release", cFrame)
	state.NR = Utility.AddValue(getvaluesfolder, "NR", Config.CAST_LOCK_DURATION)
	state.pause_gameplay = Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.CAST_LOCK_DURATION)
	local v3, v4 = ManuelCancel.new(player, Config.CAST_LOCK_DURATION, nil, script.Parent.Name)
	v3:Connect(function()
		UnknowingFireServer.Id[player.UserId] = -1
		UnknowingFireServer.Cancel(player, p, state)
	end)
	task.wait(Config.SLASH_AT)
	boolValue:Destroy()

	if UnknowingFireServer.Id[player.UserId] ~= v2 then
		return
	end

	EffectsEvent.ToAllInRange(player, "Unknowing FireVFX", player.Character, "Slash")
	local v5 = false
	local instances = {}
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = humanoidRootPart.CFrame,
		hitboxSize = Config.SLASH_HITBOX_SIZE,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		TreeDestruction = true,
		hitDetected = function(instance, p2, p3)
			if instance then
				local humanoid2 = instance:FindFirstChild("Humanoid")
				local rootPart = humanoid2.RootPart

				if p3 == "Blocking" then
					Combat_Util.Block(script, character, instance, Config.SLASH_BLOCK_BREAK)
				elseif p3 == "Perfect" then
					Combat_Util.Perfect(script, character, instance)
				elseif p3 == true then
					table.insert(instances, instance)
					local v6 = humanoidRootPart.CFrame.LookVector * Config.SLASH_KNOCKBACK + vector.create(
						0,
						Config.SLASH_KNOCKUP,
						0
					)
					v5 = true
					Combat_Util.AddStun(script, character, p2, Config.SLASH_STUN)
					Combat_Util.Damage(script, character, instance, {
						Base = Config.SLASH_DAMAGE,
						Skill = script.Parent.Name
					})
					Combat_Util.Knockback(script, character, rootPart, v6, 1)
					Combat_presets.PlayReactAnim(humanoid2)
				end
			end
		end,
		After = function(p2, list)
			if p2 then
				ImpactSounds.Play(character, script.Parent.Name, list[1])
			end
		end
	})
	task.wait(Config.COMBO_START_DELAY)

	if UnknowingFireServer.Id[player.UserId] ~= v2 then
		return
	end

	if v5 == false then
		UnknowingFireServer.Cancel(player, p, state)
		return
	end

	local position2 = humanoidRootPart.Position
	state.Anim = humanoid.Animator:LoadAnimation(script.Connect)
	state.Anim:Play()
	task.wait(Config.UPSLASH1_DELAY)

	if UnknowingFireServer.Id[player.UserId] ~= v2 then
		return
	end

	EffectsEvent.ToAllInRange(player, "Unknowing FireVFX", player.Character, "UpSlash1")
	v5 = false
	local v6 = {}
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = humanoidRootPart.CFrame * Config.UPSLASH_HITBOX_OFFSET,
		hitboxSize = Config.UPSLASH1_HITBOX_SIZE,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = function(instance, p2, p3)
			if instance then
				local humanoid2 = instance:FindFirstChild("Humanoid")
				local rootPart = humanoid2.RootPart

				if p3 == "Blocking" then
					Combat_Util.Block(script, character, instance, Config.UPSLASH_BLOCK_BREAK)
				elseif p3 == "Perfect" then
					Combat_Util.Perfect(script, character, instance)
				elseif p3 == true then
					v5 = true
					v6[instance] = true
					Combat_Util.Add_air_combo_bp(rootPart, humanoidRootPart, Config.UPDRAFT_HEIGHT, position2)
					Combat_Util.AddStun(script, character, p2, Config.UPSLASH_STUN)
					Combat_Util.Damage(script, character, instance, {
						Base = Config.UPSLASH_DAMAGE,
						Skill = script.Parent.Name
					})
					Combat_presets.PlayReactAnim(humanoid2)
				end
			end
		end,
		After = function(_, list)
			local v7 = list[1]

			for _, v8 in ipairs(instances) do
				local humanoidRootPart2 = v8:FindFirstChild("HumanoidRootPart")

				if not (v6[v8] == nil and humanoidRootPart2 ~= nil and Checker.check_victim(script, character, v8) == true) then
					continue
				end

				local getvaluesfolder2 = Utility.getvaluesfolder(v8)
				v5 = true
				v6[v8] = true
				Combat_Util.Add_air_combo_bp(humanoidRootPart2, humanoidRootPart, Config.UPDRAFT_HEIGHT, position2)
				Combat_Util.AddStun(script, character, getvaluesfolder2, Config.UPSLASH_STUN)
				Combat_Util.Damage(script, character, v8, {
					Base = Config.UPSLASH_DAMAGE,
					Skill = script.Parent.Name
				})
				v7 = v7 or v8
				local humanoid2 = v8:FindFirstChild("Humanoid")

				if humanoid2 then
					Combat_presets.PlayReactAnim(humanoid2)
				end
			end

			if v7 ~= nil then
				ImpactSounds.Play(character, script.Parent.Name, v7)
			end

			if v5 == true then
				Combat_Util.Add_air_combo_bp(humanoidRootPart, humanoidRootPart, Config.UPDRAFT_HEIGHT, position2)
			end
		end
	})
	task.wait(Config.UPSLASH2_DELAY)

	if UnknowingFireServer.Id[player.UserId] ~= v2 then
		return
	end

	if v5 == false then
		UnknowingFireServer.Cancel(player, p, state)
		return
	end

	EffectsEvent.ToAllInRange(player, "Unknowing FireVFX", player.Character, "UpSlash2")
	v5 = false
	local v7 = {}
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = humanoidRootPart.CFrame * Config.UPSLASH_HITBOX_OFFSET,
		hitboxSize = Config.UPSLASH2_HITBOX_SIZE,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = function(instance, p2, p3)
			if instance then
				local humanoid2 = instance:FindFirstChild("Humanoid")
				local rootPart = humanoid2.RootPart

				if p3 == "Blocking" then
					Combat_Util.Block(script, character, instance, Config.UPSLASH_BLOCK_BREAK)
				elseif p3 == "Perfect" then
					Combat_Util.Perfect(script, character, instance)
				elseif p3 == true then
					v5 = true
					v7[instance] = true
					Combat_Util.Add_air_combo_bp(rootPart, humanoidRootPart, Config.UPDRAFT_HEIGHT)
					Combat_Util.AddStun(script, character, p2, Config.UPSLASH_STUN)
					Combat_Util.Damage(script, character, instance, {
						Base = Config.UPSLASH_DAMAGE,
						Skill = script.Parent.Name
					})
					Combat_presets.PlayReactAnim(humanoid2)
				end
			end
		end,
		After = function(_, list)
			local v8 = list[1]

			for _, v9 in ipairs(instances) do
				local humanoidRootPart2 = v9:FindFirstChild("HumanoidRootPart")

				if not (v7[v9] == nil and humanoidRootPart2 ~= nil and Checker.check_victim(script, character, v9) == true) then
					continue
				end

				local getvaluesfolder2 = Utility.getvaluesfolder(v9)
				v5 = true
				v7[v9] = true
				Combat_Util.Add_air_combo_bp(humanoidRootPart2, humanoidRootPart, Config.UPDRAFT_HEIGHT)
				Combat_Util.AddStun(script, character, getvaluesfolder2, Config.UPSLASH_STUN)
				Combat_Util.Damage(script, character, v9, {
					Base = Config.UPSLASH_DAMAGE,
					Skill = script.Parent.Name
				})
				v8 = v8 or v9
				local humanoid2 = v9:FindFirstChild("Humanoid")

				if humanoid2 then
					Combat_presets.PlayReactAnim(humanoid2)
				end
			end

			if v8 ~= nil then
				ImpactSounds.Play(character, script.Parent.Name, v8)
			end

			if v5 == true then
				Combat_Util.Add_air_combo_bp(humanoidRootPart, humanoidRootPart, Config.UPDRAFT_HEIGHT)
			end
		end
	})
	task.wait(Config.RECOVERY_DUR)

	if UnknowingFireServer.Id[player.UserId] ~= v2 then
		return
	end

	state.NR:Destroy()
	state.pause_gameplay:Destroy()
	v4()
end

function UnknowingFireServer.Cancel(player, _, state)
	if player.Character == nil then
		return
	end

	if state.NR ~= nil then
		state.NR:Destroy()
		state.NR = nil
	end

	if state.Anim then
		state.Anim:Stop()
		state.Anim = nil
	end

	if state.pause_gameplay ~= nil then
		state.pause_gameplay:Destroy()
		state.pause_gameplay = nil
	end
end

return UnknowingFireServer