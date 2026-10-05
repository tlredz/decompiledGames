local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CollectionService = game:GetService("CollectionService")
local FlowingPalmServer = {
	Id = {}
}
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local Checker = require(ReplicatedStorage.CAM.Global.Checker)
local Combat_Util = require(ServerStorage.SAM.Services.Combat_Util)
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local ManuelCancel = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.ManuelCancel)
local ProjectileHoming = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.ProjectileHoming)
local Config = require(script.Parent.Config)
local name = script.Parent.Name
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include

local function getEndCFrame(character, lookVector: Vector3)
	local primaryPart = character.PrimaryPart
	local tagged = CollectionService:GetTagged("Humanoids")
	local index = table.find(tagged, character)

	if index then
		table.remove(tagged, index)
	end

	raycastParams.FilterDescendantsInstances = tagged
	local spherecast = workspace:Spherecast(
		primaryPart.Position - lookVector * 5,
		4,
		lookVector * (Config.DASH_DIST + 5),
		raycastParams
	)

	if spherecast then
		local find_character_from_descendant = Utility.find_character_from_descendant(spherecast.Instance)

		if Checker.check_can_select(script, character, find_character_from_descendant) then
			return Utility.SafeLookAt(
				primaryPart.Position,
				find_character_from_descendant.HumanoidRootPart.Position,
				primaryPart.CFrame
			) * CFrame.new(0, 0, -(spherecast.Distance - 4.5))
		end

		return nil
	else
		local raycastResult = workspace:Raycast(
			primaryPart.Position - lookVector * 5,
			lookVector * (Config.DASH_DIST + 5),
			RaycastHelper.Crater
		)

		if raycastResult then
			return Utility.SafeLookAt(primaryPart.Position, raycastResult.Position, primaryPart.CFrame) * CFrame.new(
				0,
				character.Humanoid.HipHeight,
				-(raycastResult.Distance - 10)
			)
		end

		return nil
	end
end

local function landingFor(character, instance)
	local primaryPart = character.PrimaryPart
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return nil
	end

	local v = (humanoidRootPart.Position - primaryPart.Position) * createVector(1, 0, 1)

	if v.Magnitude < 0.01 then
		return nil
	end

	local unit = v.Unit
	local v2 = math.clamp(v.Magnitude - Config.TARGET_STANDOFF, 0, Config.DASH_DIST)
	local raycastResult = workspace:Raycast(primaryPart.Position, unit * v2, RaycastHelper.Crater)

	if raycastResult ~= nil then
		v2 = math.max(raycastResult.Distance - 3, 0)
	end

	return Utility.SafeLookAt(primaryPart.Position, humanoidRootPart.Position, primaryPart.CFrame) * CFrame.new(
		0,
		0,
		-v2
	)
end

function FlowingPalmServer.Hold(player, _, p)
	if not player or p == nil then
		return
	end

	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	p.holding = true
	p.lock = ProjectileHoming.HoldLock({
		Pick = {
			Script = script,
			Caster = character,
			Origin = humanoidRootPart.Position,
			Range = Config.SCAN_RADIUS,
			Radius = Config.AIM_PICK_RADIUS,
			Select = true,
			KeepUntilGone = true
		},
		Origin = function()
			return humanoidRootPart.Position
		end,
		Aim = function()
			return humanoidRootPart.Position + humanoidRootPart.CFrame.LookVector * Config.SCAN_RADIUS
		end,
		While = function()
			return p.holding == true and humanoidRootPart.Parent ~= nil
		end,
		Tick = Config.LOCK_TICK
	})
end

function FlowingPalmServer.UnHold(player, _, p)
	if not player then
		return
	end

	local v = FlowingPalmServer.Id[player.UserId]
	local character = player.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")

	if not (humanoidRootPart and humanoid) then
		return
	end

	local lock

	if p ~= nil then
		lock = p.lock or nil
	end

	local v2

	if lock ~= nil then
		v2 = lock:Target()
	end

	if p ~= nil then
		p.holding = false
		p.lock = nil
	end

	local getvaluesfolder = Utility.getvaluesfolder(character)
	local v3 = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function add(p2)
		if p2 then
			table.insert(v3, p2)
		end
	end

	local function cleanup()
		for _, v4 in v3 do
			if v4 and v4.Parent then
				v4:Destroy()
			end
		end

		table.clear(v3)
		local air_combo_bp = humanoidRootPart:FindFirstChild("air_combo_bp")

		if air_combo_bp then
			air_combo_bp:Destroy()
		end
	end

	add(Utility.AddValue(getvaluesfolder, "NR", 3)) -- equivalent call inferred; original call site unknown
	local v5, v6 = ManuelCancel.new(player, Config.WINDUP + Config.RELEASE_GAP + 1)
	v5:Connect(function()
		v = -1
		cleanup()
		FlowingPalmServer.Cancel(player)
		v6()
	end)
	add(Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.WINDUP)) -- equivalent call inferred; original call site unknown
	add(Utility.AddValue(getvaluesfolder, "skill_stand_still", Config.WINDUP)) -- equivalent call inferred; original call site unknown
	task.wait(Config.WINDUP)

	if v == FlowingPalmServer.Id[player.UserId] then
		local v9

		if not (v2 == nil or v2.Parent == nil) then
			v9 = landingFor(character, v2)
		end

		local v10 = v9 or getEndCFrame(character, humanoidRootPart.CFrame.LookVector) or humanoidRootPart.CFrame + humanoidRootPart.CFrame.LookVector * (Config.DASH_DIST - 5)
		EffectsEvent.ToAllInRange(player, "FlowingPalm_effs", character, "Dash")
		humanoidRootPart:PivotTo(v10)
		local v11 = Config.RELEASE_GAP + 0.5
		Combat_Util.Add_air_combo_bp(humanoidRootPart, nil, 0, nil, v11)
		add(Utility.AddValue(getvaluesfolder, "skill_stand_still", v11)) -- equivalent call inferred; original call site unknown
		add(Utility.AddValue(getvaluesfolder, "pause_gameplay", v11)) -- equivalent call inferred; original call site unknown
		task.wait(0.05)

		if v == FlowingPalmServer.Id[player.UserId] then
			EffectsEvent.ToAllInRange(player, "FlowingPalm_effs", character, "Hit")
			Utility.CreateHitbox({
				caster = character,
				hitboxCFrame = humanoidRootPart.CFrame * Config.HITBOX_OFFSET,
				hitboxSize = Config.HITBOX_SIZE,
				checker = Checker,
				hitDetected = function(instance, p2, p3)
					if instance == character or not instance:FindFirstChild("Humanoid") then
						return false
					end

					local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")

					if not humanoidRootPart2 then
						return false
					end

					if p3 == true then
						local v14 = math.max(Config.RELEASE_GAP, Config.STUN) + 0.5
						Combat_Util.Damage(script, character, instance, {
							Base = Config.DAMAGE * 0.4,
							Skill = name
						})
						Combat_Util.Add_Strict_Stun(script, character, p2, v14)
						Combat_Util.RagDoll(script, character, p2, v14)
						local lookVector = humanoidRootPart.CFrame.LookVector
						Combat_Util.Knockback(
							script,
							character,
							humanoidRootPart2,
							Vector3.new(lookVector.X, 0.01, lookVector.Z),
							v14
						)
					elseif p3 == "Blocking" then
						Combat_Util.Block(script, character, instance, Config.BLOCK_BREAK)
					elseif p3 == "Perfect" then
						Combat_Util.Perfect(script, character, instance)
					end

					return false
				end
			})
			EffectsEvent.ToAllInRange(player, "FlowingPalm_effs", character, "HandThing")
			task.wait(Config.RELEASE_GAP)

			if v == FlowingPalmServer.Id[player.UserId] then
				EffectsEvent.ToAllInRange(player, "FlowingPalm_effs", character, "FinalHit")
				Utility.CreateHitbox({
					caster = character,
					hitboxCFrame = humanoidRootPart.CFrame * Config.FINAL_HITBOX_OFFSET,
					hitboxSize = Config.FINAL_HITBOX_SIZE,
					checker = Checker,
					hitDetected = function(instance, p2, p3)
						if instance == character or not instance:FindFirstChild("Humanoid") then
							return false
						end

						local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")

						if not humanoidRootPart2 then
							return false
						end

						if p3 == true then
							Combat_Util.Damage(script, character, instance, {
								Base = Config.DAMAGE * 0.6,
								Skill = name
							})
							Combat_Util.RagDoll(script, character, p2, Config.STUN)
							Combat_Util.Knockback(
								script,
								character,
								humanoidRootPart2,
								humanoidRootPart.CFrame.LookVector * Config.KNOCKBACK + createVector(0, 15, 0),
								0.15
							)
						elseif p3 == "Blocking" then
							Combat_Util.Block(script, character, instance, Config.BLOCK_BREAK)
						elseif p3 == "Perfect" then
							Combat_Util.Perfect(script, character, instance)
						end

						return false
					end
				})
			end
		end

		cleanup()
		v6()
	else
		cleanup()
		v6()
	end
end

function FlowingPalmServer.Cancel(player, _, p)
	if not player then
		return
	end

	FlowingPalmServer.Id[player.UserId] = nil

	if p ~= nil then
		p.holding = false
		p.lock = nil
	end

	local character = player.Character

	if character then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		local air_combo_bp = humanoidRootPart and humanoidRootPart:FindFirstChild("air_combo_bp")

		if air_combo_bp then
			air_combo_bp:Destroy()
		end

		EffectsEvent.ToAllInRange(player, "FlowingPalm_effs", character, "Cancel")
	end
end

return FlowingPalmServer