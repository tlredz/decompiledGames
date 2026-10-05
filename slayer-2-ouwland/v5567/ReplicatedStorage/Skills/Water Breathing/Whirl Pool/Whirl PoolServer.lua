local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
game:GetService("CollectionService")
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local Checker = require(CAM.Global.Checker)
local Utility = require(CAM.Global.Utility)
require(CAM.Global.Combat_presets)
require(CAM.DebrisModule)
require(SAM.Utility.SkillStorage)
local Combat_Util = require(SAM.Services.Combat_Util)
local ImpactSounds = require(SAM.Utility.ImpactSounds)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local ManuelCancel = require(CAM.Global.Subsets.Gameplay.ManuelCancel)
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local StatTypes = require(CAM.Global.Types.StatTypes)
local Config = require(script.Parent.Config)
local WhirlPoolServer = {
	Id = {},
	Hold = function(player, _: Vector3, p)
		local character = player.Character
		local _ = character:FindFirstChild("Humanoid").RootPart
		EffectsEvent.ToAllInRange(player, "Whirl Pool VFX", character, "Start")
		p.startClock = os.clock()
	end
}

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

function WhirlPoolServer.UnHold(player, vector: Vector3, p)
	local character = player.Character
	Utility.getvaluesfolder(character)
	local rootPart = character:FindFirstChild("Humanoid").RootPart
	local v2 = false
	local v3 = os.clock() - p.startClock
	local v4 = WhirlPoolServer.Id[player.UserId]
	local v5, v6 = ManuelCancel.new(player, 3)
	v5:Connect(function()
		v4 = -1
		WhirlPoolServer.Cancel(player, vector, p)
	end)

	if v3 < Config.HOLD_DURATION then
		local v7 = nil

		local function fn(instance, p2, p3)
			local rootPart2 = instance:FindFirstChild("Humanoid").RootPart

			if p3 == "Perfect" then
				Combat_Util.Perfect(script, character, instance)
			elseif p3 == "Blocking" then
				Combat_Util.Block(script, character, instance, Config.TAP_BLOCK_BREAK)
				Combat_Util.Add_air_combo_bp(rootPart2, rootPart)
				v2 = true
			elseif p3 == true then
				Combat_Util.Add_Strict_Stun(script, character, p2, Config.TAP_STUN, true)
				Combat_Util.Add_air_combo_bp(rootPart2, rootPart)
				v2 = true

				if v7 == nil then
					v7 = instance
				end

				task.spawn(function()
					for _ = 1, Config.TAP_HIT_COUNT do
						Combat_Util.Damage(script, character, instance, {
							Base = Config.TAP_DAMAGE / Config.TAP_HIT_COUNT,
							Skill = script.Parent.Name
						})

						if instance == v7 then
							ImpactSounds.Play(character, script.Parent.Name, instance)
						end

						task.wait(Config.TAP_HIT_DUR / Config.TAP_HIT_COUNT)
					end
				end)
			end
		end

		Utility.CreateHitbox({
			caster = character,
			hitboxSize = Config.TAP_HITBOX_SIZE,
			hitboxCFrame = rootPart.CFrame * Config.TAP_HITBOX_OFFSET,
			checker = Checker,
			hitPriorityHandler = {
				callback = v.Exists,
				data = "Choosing_1"
			},
			hitDetected = fn
		})
		EffectsEvent.ToAllInRange(player, "Whirl Pool VFX", character, "Release")
		local add_air_combo_bp = Combat_Util.Add_air_combo_bp
		local v10

		if v2 ~= true then
			v10 = Config.TAP_WHIFF_UPTILT_DUR or nil
		end

		add_air_combo_bp(rootPart, rootPart, nil, nil, v10)
	else
		EffectsEvent.ToAllInRange(player, "Whirl Pool VFX", character, "Basin Start")
		task.wait(Config.BASIN_START_AT)

		if v4 ~= WhirlPoolServer.Id[player.UserId] then
			return
		end

		local v7 = {}

		for i = 1, 2 do
			if v4 ~= WhirlPoolServer.Id[player.UserId] then
				return
			end

			local v8 = rootPart.CFrame * CFrame.new(0, 0, Config.BASIN_SLAM_OFFSETS[i])
			EffectsEvent.ToAllInRange(player, "Whirl Pool VFX", character, "Basin Slam", i, v8)
			local lookVector = rootPart.CFrame.LookVector
			timedThread(function()
				if v4 ~= WhirlPoolServer.Id[player.UserId] then
					return
				end

				local modelInRegion = Utility.GetModelInRegion(
					v8 * Config.BASIN_HITBOX_OFFSET,
					Config.BASIN_HITBOX_SIZE,
					nil,
					nil,
					false
				)

				for i2, v11 in ipairs(modelInRegion) do
					if table.find(v7, v11) == nil then
						table.insert(v7, v11)
					end
				end

				local v11 = nil

				for k, v12 in pairs(v7) do
					local getvaluesfolder = Utility.getvaluesfolder(character)

					if not (v12 ~= character and v12:FindFirstChild("Humanoid") ~= nil) then
						continue
					end

					local humanoidRootPart = v12:FindFirstChild("HumanoidRootPart")
					local humanoid = v12:FindFirstChild("Humanoid")
					local check_victim, v13 = Checker.check_victim(script, character, v12)
					local getvaluesfolder2 = Utility.getvaluesfolder(v12)

					if v.Both(getvaluesfolder2, {
						pv = getvaluesfolder,
						name = "Choosing_1"
					}) == true then
						continue
					end

					local humanoidRootPart2 = character:FindFirstChild("HumanoidRootPart")

					if not (humanoidRootPart ~= nil and humanoid ~= nil and humanoidRootPart2 ~= nil) then
						continue
					end

					if check_victim == true then
						Combat_Util.Add_Strict_Stun(script, character, getvaluesfolder2, Config.BASIN_STUN)
						Combat_Util.Damage(script, character, v12, {
							Base = Config.BASIN_DAMAGE,
							Skill = script.Parent.Name
						})
						Combat_Util.RagDoll(script, character, getvaluesfolder2, Config.BASIN_RAGDOLL)
						local v14 = Utility.AddValue(getvaluesfolder2, Config.SLOW_VALUE, Config.BASIN_SLOW_DURATION)
						v14:AddTag(StatTypes.ValueStatTag)
						v14:SetAttribute(StatTypes.StatToAttribute("Movement Speed Factor"), Config.BASIN_SLOW_FACTOR)
						Combat_Util.Knockback(
							script,
							character,
							humanoidRootPart,
							Vector3.new(lookVector.X, Config.BASIN_KNOCKUP_RATIO, lookVector.Z) * Config.BASIN_KNOCKBACK,
							0.5
						)
						v11 = v11 or v12
					else
						Combat_Util.Block(script, character, v12, Config.BASIN_BLOCK_BREAK)
					end
				end

				if v11 ~= nil then
					ImpactSounds.Play(character, script.Parent.Name, v11)
				end
			end, 0.1)

			if i == 1 then
				task.wait(Config.BASIN_SLAM_INTERVAL)
			end
		end
	end

	v6()
end

function WhirlPoolServer.Cancel(player, _: Vector3, _)
	EffectsEvent.ToAllInRange(player, "Whirl Pool VFX", player.Character, "Cancel")
end

return WhirlPoolServer