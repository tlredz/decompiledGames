local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RampantArcRampageServer = {
	Id = {}
}
require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Utility"))
local Checker = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Checker"))
local Combat_Util = require(game.ServerStorage:WaitForChild("SAM"):WaitForChild("Services"):WaitForChild("Combat_Util"))
local Utility = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Utility"))
local hit_priority_handler = require(game.ServerStorage:WaitForChild("SAM"):WaitForChild("Game_Play"):WaitForChild("hit_priority_handler"))
local v = hit_priority_handler.new(script)
local Combat_presets = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Combat_presets"))
local Character_info_provider = require(ReplicatedStorage.CAM.Global.Character_info_provider)
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local CombatBalance = require(ReplicatedStorage.CAM.Global.CombatBalance)
local Config = require(script.Parent.Config)

local function timedThread(fn, value)
	local thread = coroutine.create(fn)
	task.delay(value or 5, function()
		if coroutine.status(thread) == "running" then
			coroutine.close(thread)
		end
	end)
	local v2, v3 = coroutine.resume(thread)

	if not v2 then
		warn(v3)
	end

	return thread
end

local BASE_HITBOX_SIZE = Config.BASE_HITBOX_SIZE
local SIZE_MULTIPLIER = Config.SIZE_MULTIPLIER
local SCALE_TIME = Config.SCALE_TIME
local v2 = SIZE_MULTIPLIER - 1

-- equivalent calls inferred from this helper; original call sites unknown
local function calculateScale(p: number)
	return math.min((os.clock() - p) / SCALE_TIME, 1) * v2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function calculateNewSize(now: number)
	return BASE_HITBOX_SIZE + BASE_HITBOX_SIZE * calculateScale(now)
end

function RampantArcRampageServer.Hold(player)
	if player == nil then
		return
	end

	local v3 = RampantArcRampageServer.Id[player.UserId]
	local character = player.Character

	if character == nil then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")

	if humanoidRootPart == nil or humanoid == nil or v3 ~= RampantArcRampageServer.Id[player.UserId] then
		return
	end

	task.wait(Config.WINDUP_VFX_AT)

	if v3 ~= RampantArcRampageServer.Id[player.UserId] then
		return
	end

	EffectsEvent.ToAllInRange(character, "RampantArcRampage_effs", character, "Windup")
	task.wait(Config.START_VFX_AT)

	if v3 ~= RampantArcRampageServer.Id[player.UserId] then
		return
	end

	EffectsEvent.ToAllInRange(character, "RampantArcRampage_effs", character, "Start")
	timedThread(function(...)
		if v3 ~= RampantArcRampageServer.Id[player.UserId] then
			return
		end

		local getvaluesfolder = Utility.getvaluesfolder(character)
		local cFrame = humanoidRootPart.CFrame
		local now = os.clock()
		character:SetAttribute("RAR_StartHolding", now)

		while v3 == RampantArcRampageServer.Id[player.UserId] and humanoidRootPart.Parent ~= nil do
			local newSize = calculateNewSize(now) -- equivalent call inferred; original call site unknown
			local modelInRegion = Utility.GetModelInRegion(cFrame, newSize, nil, nil)

			for _, v5 in pairs(modelInRegion) do
				if v3 ~= RampantArcRampageServer.Id[player.UserId] then
					break
				end

				if not (v5 ~= character and v5:FindFirstChild("Humanoid") ~= nil) then
					continue
				end

				local humanoidRootPart2 = v5:FindFirstChild("HumanoidRootPart")
				local humanoid2 = v5:FindFirstChild("Humanoid")
				local check_victim, _ = Checker.check_victim(script, character, v5)
				local getvaluesfolder2 = Utility.getvaluesfolder(v5)

				if v.Both(getvaluesfolder2, {
					pv = getvaluesfolder,
					name = "Choosing_1"
				}) == true then
					continue
				end

				local humanoidRootPart3 = character:FindFirstChild("HumanoidRootPart")

				if not (humanoidRootPart2 ~= nil and humanoid2 ~= nil and humanoidRootPart3 ~= nil) then
					continue
				end

				if check_victim == "Perfect" then
					Combat_Util.Perfect(script, character, v5)
				elseif check_victim == true or check_victim == "Blocking" then
					if check_victim == true then
						Combat_Util.AddStun(script, character, getvaluesfolder2, Config.SPIN_STUN)
						EffectsEvent.ToAllInRange(character, "Normal_Sword_Slash_Effect", humanoidRootPart2, -1)
						Combat_Util.Damage(script, character, v5, {
							Base = Config.SPIN_DAMAGE,
							Skill = script.Parent.Name
						})
						Combat_presets.stop_extra_anims(humanoid2)
						local v6 = math.random(1, 5)
						local v7 = v6 == 5 and 6 or v6
						local track = humanoid2.Animator:LoadAnimation(Character_info_provider.get_core_anim(
							character,
							"React_" .. v7
						))
						track:AdjustSpeed(2.25)
						track:Play()
						Combat_Util.Knockback(script, character, humanoidRootPart2, createVector(0, 0.01, 0), 0.125)
					elseif check_victim == "Blocking" then
						Combat_Util.Block(script, character, v5, Config.SPIN_BLOCK_BREAK)
					end
				end
			end

			task.wait(Config.SPIN_TICK_INTERVAL)
		end
	end, 6)
end

function RampantArcRampageServer.UnHold(player)
	if player == nil then
		return
	end

	local _ = RampantArcRampageServer.Id[player.UserId]
	local character = player.Character

	if character == nil then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")

	if humanoidRootPart == nil or humanoid == nil then
		return
	end

	local rAR_StartHolding = character:GetAttribute("RAR_StartHolding") or 1
	character:SetAttribute("RAR_StartHolding", nil)
	local v3 = calculateNewSize(rAR_StartHolding) * Config.FINISH_SIZE_MULT
	EffectsEvent.ToAllInRange(character, "RampantArcRampage_effs", character, "End", calculateScale(rAR_StartHolding))
	local modelInRegion = Utility.GetModelInRegion(humanoidRootPart.CFrame, v3, nil, nil)

	for _, v4 in pairs(modelInRegion) do
		local getvaluesfolder = Utility.getvaluesfolder(character)

		if not (v4 ~= character and v4:FindFirstChild("Humanoid") ~= nil) then
			continue
		end

		local humanoidRootPart2 = v4:FindFirstChild("HumanoidRootPart")
		v4:FindFirstChild("Humanoid")
		local check_victim, _ = Checker.check_victim(script, character, v4)
		local getvaluesfolder2 = Utility.getvaluesfolder(v4)

		if not (v.Both(getvaluesfolder2, {
			pv = getvaluesfolder,
			name = "Choosing_1"
		}) ~= true and humanoidRootPart2 ~= nil) then
			continue
		end

		if check_victim == "Blocking" or check_victim == "Perfect" then
			local v5

			if check_victim == "Blocking" then
				v5 = not CombatBalance.IsPvP(character, v4)
			else
				v5 = false
			end

			local block = Combat_Util.Block
			local script2 = script
			local v6

			if v5 then
				v6 = Config.PVE_FINISH_BLOCK_BREAK
			else
				v6 = Config.FINISH_BLOCK_BREAK
			end

			block(script2, character, v4, v6)
		elseif check_victim == true then
			Combat_Util.AddStun(script, character, getvaluesfolder2, Config.FINISH_STUN)
			EffectsEvent.ToAllInRange(character, "Normal_Sword_Slash_Effect", humanoidRootPart2, -1)
			Combat_Util.Damage(script, character, v4, {
				Base = Config.FINISH_DAMAGE,
				Skill = script.Parent.Name
			})
			Combat_Util.RagDoll(script, character, getvaluesfolder2, Config.FINISH_RAGDOLL)
			local v5 = (humanoidRootPart2.Position - humanoidRootPart.Position).Unit * Config.FINISH_KNOCKBACK
			Combat_Util.Knockback(
				script,
				character,
				humanoidRootPart2,
				Vector3.new(v5.X, Config.FINISH_KNOCKUP, v5.Z),
				0.35,
				"remove_airbp"
			)
		end
	end
end

function RampantArcRampageServer.Cancel(player)
	if player == nil then
		return
	end

	local character = player.Character
	character:SetAttribute("RAR_StartHolding", nil)
	EffectsEvent.ToAllInRange(character, "RampantArcRampage_effs", character, "Cancel")

	if character == nil then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")

	if humanoidRootPart == nil or humanoid == nil then
	end
end

return RampantArcRampageServer