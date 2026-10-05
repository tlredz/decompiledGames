local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local Checker = require(CAM.Global.Checker)
local Utility = require(CAM.Global.Utility)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local ProjectileModeler = require(CAM.Global.ProjectileModeler)
local ServerClientPortal = require(CAM.Global.ServerClientPortal)
local Combat_Util = require(SAM.Services.Combat_Util)
local Combat_presets = require(CAM.Global.Combat_presets)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local Config = require(script.Parent.Config)
local PeoniesOfFutilityServer = {
	Id = {}
}
local name = script.Parent.Name

function PeoniesOfFutilityServer.Hold(player, _: Vector3?, p)
	local cleanIt = p.CleanIt or cleanit.new()
	p.CleanIt = cleanIt
	cleanIt:Clean()
	p.cancelled = false
	local character = player.Character
	local v2 = character and Utility.getvaluesfolder(character)

	if v2 == nil then
		return
	end

	cleanIt:Add(Utility.AddValue(v2, "pause_gameplay", Config.MAX_HOLD + 1))
end

function PeoniesOfFutilityServer.UnHold(player, _: Vector3?, state)
	local cleanIt = state.CleanIt or cleanit.new()
	state.CleanIt = cleanIt
	cleanIt:Clean()
	local v2 = PeoniesOfFutilityServer.Id[player.UserId]
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local v3 = character and Utility.getvaluesfolder(character)

	if humanoidRootPart == nil or v3 == nil then
		return
	end

	local function stillCasting()
		local v4 = not state.cancelled

		if v4 then
			if PeoniesOfFutilityServer.Id[player.UserId] == v2 and character.Parent ~= nil then
				return humanoidRootPart.Parent ~= nil
			else
				return false
			end
		end

		return v4
	end

	cleanIt:Add(Utility.AddValue(v3, "pause_gameplay", Config.RELEASE_LOCK))
	cleanIt:Add(Utility.AddValue(v3, "skill_stand_still", Config.RELEASE_LOCK))
	task.wait(Config.RELEASE_WINDUP)
	local v4 = not state.cancelled

	if v4 then
		if PeoniesOfFutilityServer.Id[player.UserId] == v2 and character.Parent ~= nil then
			v4 = humanoidRootPart.Parent ~= nil
		else
			v4 = false
		end
	end

	if not v4 then
		return
	end

	EffectsEvent.ToAllInRange(humanoidRootPart, "Peonies of Futility VFX", character, "Slash", humanoidRootPart.CFrame)
	local v5 = humanoidRootPart.CFrame.LookVector * createVector(1, 0, 1)
	local v6 = not (v5.Magnitude > 0.001) and createVector(0, 0, 1) or v5.Unit
	local instances = {}
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -Config.SLASH_OFFSET),
		hitboxSize = Config.SLASH_HITBOX_SIZE,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = function(instance, p, p2)
			local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart2 == nil then
				return
			end

			if p2 == "Perfect" then
				Combat_Util.Perfect(script, character, instance)
			elseif p2 == "Blocking" then
				Combat_Util.Block(script, character, instance, Config.SLASH_BLOCK_BREAK)
			elseif p2 == true then
				Combat_Util.Damage(script, character, instance, {
					Base = Config.SLASH_DAMAGE,
					Skill = name
				})
				Combat_Util.AddStun(script, character, p, Config.CATCH_STUN)
				Combat_Util.RagDoll(script, character, p, Config.SLASH_RAGDOLL)
				Combat_Util.Knockback(
					script,
					character,
					humanoidRootPart2,
					v6 * Config.SLASH_KNOCKBACK + Vector3.new(0, Config.SLASH_KNOCKUP, 0),
					Config.SLASH_KNOCK_DURATION
				)
				Combat_presets.PlayReactAnim((instance:FindFirstChild("Humanoid")))
				EffectsEvent.ToAllInRange(humanoidRootPart, "Normal_Sword_Slash_Effect", humanoidRootPart2, -1)
				table.insert(instances, instance)
			end
		end
	})
	ServerClientPortal.ToClient(player, name, #instances > 0)

	if #instances == 0 then
		return
	end

	local v7 = instances[1]
	local now = os.clock()
	cleanIt:Add(Utility.AddValue(v3, "pause_gameplay", Config.THROW_LOCK))
	cleanIt:Add(Utility.AddValue(v3, "skill_stand_still", Config.THROW_LOCK))
	task.wait(Config.JUMP_RISE_AT)
	local v8 = not state.cancelled

	if v8 then
		if PeoniesOfFutilityServer.Id[player.UserId] == v2 and character.Parent ~= nil then
			v8 = humanoidRootPart.Parent ~= nil
		else
			v8 = false
		end
	end

	if not v8 then
		return
	end

	EffectsEvent.ToAllInRange(humanoidRootPart, "Peonies of Futility VFX", character, "Rise", humanoidRootPart.CFrame)
	Combat_Util.Add_air_combo_bp(
		humanoidRootPart,
		humanoidRootPart,
		Config.UPDRAFT_HEIGHT,
		nil,
		Config.UPDRAFT_DURATION
	)
	local v9 = now + Config.THROW_AT - os.clock()

	if v9 > 0 then
		task.wait(v9)
	end

	local v10 = not state.cancelled

	if v10 then
		if PeoniesOfFutilityServer.Id[player.UserId] == v2 and character.Parent ~= nil then
			v10 = humanoidRootPart.Parent ~= nil
		else
			v10 = false
		end
	end

	if not v10 then
		return
	end

	local humanoidRootPart2 = v7:FindFirstChild("HumanoidRootPart")
	local position

	if humanoidRootPart2 == nil then
		position = (humanoidRootPart.CFrame * CFrame.new(0, 0, -10)).Position
	else
		position = humanoidRootPart2.Position
	end

	local cFrame = Utility.SafeLookAt(humanoidRootPart.Position, position, humanoidRootPart.CFrame) * Config.SPAWN_OFFSET
	local v12 = position - cFrame.Position
	local unit

	if v12.Magnitude > 0.1 then
		unit = v12.Unit
	else
		unit = humanoidRootPart.CFrame.LookVector
	end

	local formatted = `{player.Name} Peonies of Futility`
	local flag = false

	local function explode(position2: Vector3, flag2: boolean)
		local v13

		if flag2 then
			v13 = position2 + Vector3.new(0, Config.IMPACT_FLOOR_LIFT, 0)
		else
			v13 = position2
		end

		EffectsEvent.ToAllInRange(humanoidRootPart, "Peonies of Futility VFX", character, "Explode", v13)
		local now2 = os.clock()
		local v14 = math.max(math.round(Config.BARRAGE_DURATION / Config.BARRAGE_INTERVAL), 1)

		for i = 1, v14 do
			local v15 = not state.cancelled

			if v15 then
				if PeoniesOfFutilityServer.Id[player.UserId] == v2 and character.Parent ~= nil then
					v15 = humanoidRootPart.Parent ~= nil
				else
					v15 = false
				end
			end

			if not v15 then
				break
			end

			local v16 = i
			Utility.CreateHitbox({
				caster = character,
				hitboxCFrame = CFrame.new(position2),
				hitboxSize = Config.BARRAGE_HITBOX_SIZE,
				targets = instances,
				checker = Checker,
				hitPriorityHandler = {
					callback = v.Exists,
					data = "Choosing_1"
				},
				hitDetected = function(instance, p, p2)
					local humanoidRootPart3 = instance:FindFirstChild("HumanoidRootPart")

					if humanoidRootPart3 == nil then
						return
					end

					if p2 == "Perfect" then
						Combat_Util.Perfect(script, character, instance)
					elseif p2 == "Blocking" then
						Combat_Util.Block(script, character, instance, Config.BARRAGE_BLOCK_BREAK)
					elseif p2 == true then
						Combat_Util.Damage(script, character, instance, {
							Base = Config.BARRAGE_DAMAGE,
							Skill = name
						})

						if v16 == v14 then
							Combat_Util.AddStun(script, character, p, Config.FINAL_STUN)
							Combat_Util.RagDoll(script, character, p, Config.FINAL_RAGDOLL)
							local v17 = (humanoidRootPart3.Position - humanoidRootPart.Position) * createVector(1, 0, 1)
							local v18

							if v17.Magnitude > 0.001 then
								v18 = v17.Unit
							else
								v18 = v6
							end

							Combat_Util.Knockback(
								script,
								character,
								humanoidRootPart3,
								v18 * Config.FINAL_KNOCKBACK + Vector3.new(0, Config.FINAL_KNOCKUP, 0),
								Config.FINAL_KNOCK_DURATION
							)
						else
							Combat_Util.AddStun(script, character, p, Config.BARRAGE_STUN)
						end

						Combat_presets.PlayReactAnim((instance:FindFirstChild("Humanoid")))
						EffectsEvent.ToAllInRange(humanoidRootPart, "Normal_Sword_Slash_Effect", humanoidRootPart3, -1)
					end
				end
			})
			local v17 = now2 + i * Config.BARRAGE_INTERVAL - os.clock()

			if i < v14 and v17 > 0 then
				task.wait(v17)
			end
		end
	end

	local v13 = nil
	v13 = ProjectileModeler.new({
		Name = formatted,
		Size = Config.PROJECTILE_SIZE,
		Transparency = Config.PROJECTILE_TRANSPARENCY,
		CFrame = cFrame,
		Mover = {
			MaxForce = 1000000000,
			VectorVelocity = unit * Config.PROJECTILE_SPEED
		},
		Rotator = {
			Responsiveness = 75,
			CFrame = CFrame.lookAt(cFrame.Position, cFrame.Position + unit)
		}
	}, function(vector2: Vector3?, _: Vector3?, p)
		if flag then
			return true
		end

		local v14 = p and Utility.find_character_from_descendant(p)

		if v14 == character then
			return false
		end

		flag = true
		local humanoidRootPart3 = v14 and v14:FindFirstChild("HumanoidRootPart")
		local position2 = v13 and v13.Instance and v13.Instance.Position
		local position3

		if humanoidRootPart3 == nil then
			position3 = vector2 or position2 or cFrame.Position
		else
			position3 = humanoidRootPart3.Position
		end

		task.spawn(explode, position3, p ~= nil and humanoidRootPart3 == nil)
		return true
	end, Config.PROJECTILE_DURATION, ProjectileModeler.WhitelistType.HumanoidsAndMap, character, RaycastHelper.Crater)
	v13.Instance:SetNetworkOwner(player)
	EffectsEvent.ToAllInRange(humanoidRootPart, "Peonies of Futility VFX", character, "Throw", formatted, v13.Instance)
	task.spawn(function()
		while v13.IsActive and not flag do
			local v14 = not state.cancelled

			if v14 then
				if PeoniesOfFutilityServer.Id[player.UserId] == v2 and character.Parent ~= nil then
					v14 = humanoidRootPart.Parent ~= nil
				else
					v14 = false
				end
			end

			if not v14 then
				break
			end

			local instance = v13.Instance

			if instance == nil or instance.Parent == nil then
				break
			end

			local humanoidRootPart3 = v7:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart3 == nil or humanoidRootPart3.Parent == nil then
				break
			end

			local v15 = humanoidRootPart3.Position - instance.Position

			if v15.Magnitude > 0.1 then
				local mover = v13.Mover or instance:FindFirstChild("Mover")

				if mover ~= nil then
					mover.VectorVelocity = v15.Unit * Config.PROJECTILE_SPEED
				end
			end

			task.wait(Config.TRACK_TICK)
		end
	end)
end

function PeoniesOfFutilityServer.Cancel(player, _: Vector3?, p)
	p.cancelled = true
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and character then
		EffectsEvent.ToAllInRange(humanoidRootPart, "Peonies of Futility VFX", character, "Cancel")
	end

	if p.CleanIt then
		p.CleanIt:Clean()
	end
end

return PeoniesOfFutilityServer