local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
game:GetService("RunService")
game:GetService("TweenService")
game:GetService("CollectionService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage:WaitForChild("CAM")
local SAM = ServerStorage:WaitForChild("SAM")
local global = CAM:WaitForChild("Global")
local services = SAM:WaitForChild("Services")
local EffectsEvent = require(ReplicatedStorage2.Communication.ServerAndClient.Effects.EffectsEvent)
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
require(CAM:FindFirstChild("DebrisModule"))
local ServerClientPortal = require(ReplicatedStorage2.CAM.Global.ServerClientPortal)
local RaycastHelper = require(ReplicatedStorage2.CAM.Global.RaycastHelper)
local Config = require(script.Parent.Config)
local script2 = script
local TrueFlutterServer = {
	Id = {},
	Hold = function(player, _, p)
		local character = player.Character

		if not (character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild(
			"Animator",
			true
		)) then
			return
		end

		EffectsEvent.ToAllInRange(player, "True_Flutter_VFX", character, "Hold")
		p.Clock = os.clock()
	end
}

function TrueFlutterServer.UnHold(player, p, state)
	local character = player.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local animator = character:FindFirstChild("Animator", true)

	if not animator then
		return
	end

	local air_combo_bp = humanoidRootPart:FindFirstChild("air_combo_bp")

	if air_combo_bp then
		air_combo_bp:Destroy()
	end

	local v2 = TrueFlutterServer.Id[player.UserId]
	local v3, v4 = ManuelCancel.new(player, Config.UNHOLD_CANCEL_WINDOW)
	v3:Connect(function()
		v2 = -1
		TrueFlutterServer.Cancel(player, p, state)
		v4()
	end)
	state.Value_Table = {}
	local v5 = Config.WINDUP - (os.clock() - state.Clock)

	if v5 > 0 then
		task.wait(v5)

		if TrueFlutterServer.Id[player.UserId] ~= v2 then
			return
		end
	end

	local v6 = false

	local function fn(p2, _, p3, _)
		if not p2 or p3 ~= true and p3 ~= "Blocking" and p3 ~= "Perfect" or v6 ~= false then
			return v6
		end

		v6 = true
		ServerClientPortal.ToClient(player, script.Parent.Name, true)
		local track = animator:LoadAnimation(script["In Range"])
		track:Play()
		table.insert(state.Value_Table, track)

		if TrueFlutterServer.Id[player.UserId] ~= v2 then
			return
		end

		EffectsEvent.ToAllInRange(player, "True_Flutter_VFX", character, "Uppercut")
		Combat_Util.Add_air_combo_bp(humanoidRootPart, humanoidRootPart)

		local function fn2(instance, p4, p5)
			if instance then
				local humanoid = instance:FindFirstChild("Humanoid")
				local rootPart = humanoid.RootPart

				if p5 == "Blocking" then
					Combat_Util.Block(script2, character, instance, Config.UPPERCUT_BLOCK_BREAK)
					Combat_Util.Add_air_combo_bp(rootPart, humanoidRootPart)
				elseif p5 == "Perfect" then
					Combat_Util.Perfect(script2, character, instance)
				elseif p5 == true then
					EffectsEvent.ToAllInRange(player, "Normal_Sword_Slash_Effect", rootPart, -1)
					Combat_Util.Add_air_combo_bp(rootPart, humanoidRootPart)
					Combat_Util.Damage(script2, character, instance, {
						Base = Config.UPPERCUT_DAMAGE,
						Skill = script.Parent.Name
					})
					Combat_Util.AddStun(script2, character, p4, Config.UPPERCUT_STUN)

					if Clans.HasPassive(character:GetAttribute("Clan"), "Insect Affinity") then
						local v7 = Utility.AddValue(
							p4,
							AppliedTicks.ByName.Poison.Value,
							Config.POISON_DURATION,
							"ObjectValue",
							character
						)
						v7:SetAttribute("Damage", Config.POISON_TICK_DAMAGE)
						v7:SetAttribute("Skill", script.Parent.Name)
					end

					if humanoid then
						local v7 = math.random(1, 4)
						Combat_presets.PlayReactAnim(humanoid, v7)
					end
				end
			end
		end

		Utility.CreateHitbox({
			caster = character,
			hitboxCFrame = humanoidRootPart.CFrame * Config.UPPERCUT_HITBOX_OFFSET,
			hitboxSize = Config.UPPERCUT_HITBOX_SIZE,
			checker = Checker,
			hitPriorityHandler = {
				callback = v.Exists,
				data = "Choosing_1"
			},
			hitDetected = fn2,
			After = function(p4, list)
				if p4 then
					ImpactSounds.Play(character, script.Parent.Name, list[1])
				end
			end
		})
		task.wait(Config.UPPERCUT_CLEANUP_AT)

		if TrueFlutterServer.Id[player.UserId] ~= v2 then
			return
		end

		if state.Value_Table then
			for _, v7 in state.Value_Table do
				v7:Destroy()
			end
		end

		return v6
	end

	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = humanoidRootPart.CFrame * Config.RANGE_CHECK_HITBOX_OFFSET,
		hitboxSize = Config.RANGE_CHECK_HITBOX_SIZE,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = fn
	})

	if v6 == false then
		ServerClientPortal.ToClient(player, script.Parent.Name, false)
		task.wait(Config.DASH_WINDUP)

		if TrueFlutterServer.Id[player.UserId] ~= v2 then
			return
		end

		local cFrame = humanoidRootPart.CFrame

		if TrueFlutterServer.Id[player.UserId] ~= v2 then
			return
		end

		local v7 = vector.normalize(p - cFrame.Position) * Config.MAX_DASH_DISTANCE
		local cframe = CFrame.new(cFrame.Position, cFrame.Position + v7)
		local raycastResult = workspace:Raycast(cFrame.Position, v7, RaycastHelper.Crater)
		local MAX_DASH_DISTANCE = Config.MAX_DASH_DISTANCE
		local v8

		if raycastResult then
			local v9 = raycastResult.Position - cFrame.Position
			MAX_DASH_DISTANCE = vector.magnitude(v9)
			v8 = cFrame.Position + vector.normalize(v9) * MAX_DASH_DISTANCE
		else
			v8 = cFrame.Position + v7
		end

		local v9 = CFrame.new(v8) * cframe.Rotation
		local instances = {}
		local v10 = nil

		local function fn2(instance, p2, p3, _)
			if instance and table.find(instances, instance) == nil then
				table.insert(instances, instance)
				local humanoid = instance:FindFirstChild("Humanoid")
				local rootPart = humanoid.RootPart

				if p3 == "Perfect" then
					Combat_Util.Perfect(script2, character, instance)
				elseif p3 == "Blocking" then
					Combat_Util.Block(script2, character, instance, Config.DASH_BLOCK_BREAK)
				elseif p3 == true then
					EffectsEvent.ToAllInRange(player, "Normal_Sword_Slash_Effect", rootPart, -1)
					Combat_Util.AddStun(script2, character, p2, Config.DASH_STUN)
					Combat_Util.Knockback(
						script2,
						character,
						rootPart,
						vector.create(0, Config.DASH_KNOCKUP, 0),
						Config.DASH_EXPLOSION_AT
					)

					if humanoid then
						Combat_presets.PlayReactAnim(humanoid, 6)
					end

					if v10 == nil then
						v10 = instance
					end

					task.delay(Config.DASH_EXPLOSION_AT, function()
						if Checker.check_victim(script2, character, instance) ~= nil then
							EffectsEvent.ToAllInRange(
								player,
								"True_Flutter_VFX",
								character,
								"Explosion",
								{ rootPart.CFrame }
							)
							Combat_Util.Damage(script2, character, instance, {
								Base = Config.DASH_DAMAGE,
								Skill = script.Parent.Name
							})

							if instance == v10 then
								ImpactSounds.Play(character, script.Parent.Name, instance)
							end

							if Clans.HasPassive(character:GetAttribute("Clan"), "Insect Affinity") then
								local v11 = Utility.AddValue(
									p2,
									AppliedTicks.ByName.Poison.Value,
									Config.POISON_DURATION,
									"ObjectValue",
									character
								)
								v11:SetAttribute("Damage", Config.POISON_TICK_DAMAGE)
								v11:SetAttribute("Skill", script.Parent.Name)
							end

							Combat_Util.RagDoll(script2, character, p2, Config.DASH_RAGDOLL)
						end
					end)
				end
			end
		end

		local vector2 = Vector3.new(
			Config.DASH_HITBOX_WIDTH,
			Config.DASH_HITBOX_HEIGHT,
			MAX_DASH_DISTANCE + Config.DASH_HITBOX_EXTRA_LENGTH
		)
		local v11 = Utility.SafeLookAt(cFrame.Position, v9.Position, cFrame) * CFrame.new(
			0,
			0,
			-(MAX_DASH_DISTANCE / 2 + 3)
		)
		Utility.CreateHitbox({
			caster = character,
			hitboxCFrame = v11,
			hitboxSize = vector2,
			checker = Checker,
			hitPriorityHandler = {
				callback = v.Exists,
				data = "Choosing_1"
			},
			hitDetected = fn2,
			extraArgs = v11
		})
		EffectsEvent.ToAllInRange(player, "True_Flutter_VFX", character, "Dash", { cFrame, v9 })
		task.delay(0.6, function()
			if state.Value_Table then
				for _, v12 in state.Value_Table do
					v12:Destroy()
				end
			end
		end)
	end
end

function TrueFlutterServer.Cancel(player, _, p)
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

	EffectsEvent.ToAllInRange(player, "True_Flutter_VFX", character, "Cancel")

	if p.Value_Table then
		for _, animationTrack in p.Value_Table do
			if animationTrack:IsA("AnimationTrack") then
				animationTrack:Stop()
			end

			animationTrack:Destroy()
		end
	end

	humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
	humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
end

return TrueFlutterServer