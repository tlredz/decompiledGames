local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local PredatorClawsServer = {
	Id = {}
}
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local Checker = require(ReplicatedStorage.CAM.Global.Checker)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local Combat_Util = require(ServerStorage.SAM.Services.Combat_Util)
local Combat_presets = require(ReplicatedStorage.CAM.Global.Combat_presets)
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local Server_Mouse_Pos = require(ServerStorage.SAM.Services.Server_Mouse_Pos)
local hit_priority_handler = require(ServerStorage.SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local Config = require(script.Parent.Config)
local v2 = { "Slice1", "Slice2" }

-- equivalent calls inferred from this helper; original call sites unknown
local function applyBlock(p, p2, instance, humanoidRootPart)
	Combat_Util.Block(script, p, instance, Config.BLOCK_BREAK)
	Combat_Util.Knockback(
		script,
		p,
		humanoidRootPart,
		p2.LookVector * Config.BLOCK_KNOCKBACK_SPEED,
		Config.BLOCK_KNOCKBACK_DURATION,
		"combat_knockback"
	)
end

local function applyHit(p, p2, instance, p3, humanoidRootPart, base, p5, p6, list)
	if list and not table.find(list, instance) then
		table.insert(list, instance)
	end

	Combat_Util.Damage(script, p, instance, {
		Base = base,
		Skill = script.Parent.Name
	})
	Combat_Util.AddStun(script, p, p3, p5)
	EffectsEvent.ToAllInRange(p, "Normal_Sickle_Slash_Effect", humanoidRootPart, -1)

	if p6 then
		Combat_Util.RagDoll(script, p, p3, p5)
		local v3 = p2.LookVector * Config.FINAL_KNOCKBACK_SPEED
		Combat_Util.Knockback(
			script,
			p,
			humanoidRootPart,
			Vector3.new(v3.X, Config.FINAL_KNOCKBACK_UP, v3.Z),
			0.2,
			"combat_knockbackLast"
		)
	else
		Combat_Util.Knockback(
			script,
			p,
			humanoidRootPart,
			Config.REACT_UP_VELOCITY + p2.LookVector * Config.REACT_FORWARD_SPEED,
			Config.REACT_KNOCK_DURATION,
			"combat_knockback"
		)
		local humanoid = instance:FindFirstChild("Humanoid")

		if humanoid then
			Combat_presets.PlayReactAnim(humanoid)
		end
	end
end

local function doHit(character, p, getvaluesfolder, hitboxSize, base, p4, targets)
	local v3 = {}
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = p * CFrame.new(0, 0, -hitboxSize.Z / 2 + 6),
		hitboxSize = hitboxSize,
		checker = Checker,
		targets = targets,
		hitPriorityHandler = {
			callback = v.Both,
			data = {
				pv = getvaluesfolder,
				name = "Choosing_1"
			}
		},
		hitDetected = function(instance, p6, p7)
			if instance == character or not instance:FindFirstChild("Humanoid") then
				return false
			end

			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return false
			end

			if p7 == true then
				applyHit(character, p, instance, p6, humanoidRootPart, base, p4, false, v3)
			elseif p7 == "Blocking" then
				applyBlock(character, p, instance, humanoidRootPart) -- equivalent call inferred; original call site unknown
			elseif p7 == "Perfect" then
				Combat_Util.Perfect(script, character, instance)
				return true
			end

			return false
		end
	})
	return v3
end

function PredatorClawsServer.Hold(player, position)
	if not player then
		return
	end

	local v3 = PredatorClawsServer.Id[player.UserId]
	local character = player.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local getvaluesfolder = Utility.getvaluesfolder(character)
	Server_Mouse_Pos.Create_Pos_Part(character, script.Parent.Name, Config.POS_PART_LIFETIME, position)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function cleanupPointer()
		Server_Mouse_Pos.Delete_Pos_Part(character, script.Parent.Name)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function dashTo(p, DASH_DURATION)
		Combat_Util.Add_air_combo_bp(humanoidRootPart, nil, 0, p, DASH_DURATION, {
			MaxAxesForce = createVector(40000, 40000, 40000)
		})
	end

	local function clampTravel(p, p2)
		local raycastResult = workspace:Raycast(
			humanoidRootPart.Position,
			p * (p2 + Config.DASH_WALL_CLEARANCE),
			RaycastHelper.Crater
		)

		if raycastResult == nil then
			return p2
		end

		return (math.max((raycastResult.Position - humanoidRootPart.Position).Magnitude - Config.DASH_WALL_CLEARANCE, 0))
	end

	task.wait(Config.STARTUP_AT)

	if v3 ~= PredatorClawsServer.Id[player.UserId] then
		cleanupPointer() -- equivalent call inferred; original call site unknown
		return
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function facingToward(p)
		if p then
			return Utility.SafeLookAt(
				humanoidRootPart.Position,
				Vector3.new(p.X, humanoidRootPart.Position.Y, p.Z),
				humanoidRootPart.CFrame
			)
		end

		return humanoidRootPart.CFrame
	end

	local function livePos()
		local v4 = Server_Mouse_Pos.Find(character, script.Parent.Name)
		return v4 and v4.Position or position
	end

	local v4 = nil

	for i = 1, 2 do
		if Config.SLASH_WAITS[i] ~= 0 then
			task.wait(Config.SLASH_WAITS[i])
		end

		if v3 ~= PredatorClawsServer.Id[player.UserId] then
			cleanupPointer() -- equivalent call inferred; original call site unknown
			return
		end

		local position2

		if i == 1 then
			position2 = position
		else
			local v5 = Server_Mouse_Pos.Find(character, script.Parent.Name)

			if v5 then
				position2 = v5.Position or position
			else
				position2 = position
			end
		end

		local v5 = facingToward(position2) -- equivalent call inferred; original call site unknown
		v4 = doHit(
			character,
			v5,
			getvaluesfolder,
			Config.SLASH_SIZES[i],
			Config.SLASH_DAMAGES[i],
			Config.SLASH_STUNS[i],
			v4
		)
		Combat_Util.Knockback(
			script,
			character,
			humanoidRootPart,
			v5.LookVector * Config.SLASH_LUNGE_MAGNITUDE + createVector(0, 0.01, 0),
			Config.SLASH_LUNGE_DURATION,
			"combat_knockback"
		)
		EffectsEvent.ToAllInRange(player, "PredatorClaws_effs", character, v2[i])
	end

	task.wait(Config.DASH_DELAY)

	if v3 ~= PredatorClawsServer.Id[player.UserId] then
		cleanupPointer() -- equivalent call inferred; original call site unknown
		return
	end

	local function dashHit(hitboxCFrame, p2, vector2, p3, p4, targets)
		local v5 = {}
		Utility.CreateHitbox({
			caster = character,
			hitboxCFrame = hitboxCFrame,
			hitboxSize = vector2,
			checker = Checker,
			targets = targets,
			hitPriorityHandler = {
				callback = v.Both,
				data = {
					pv = getvaluesfolder,
					name = "Choosing_1"
				}
			},
			hitDetected = function(instance, p6, p7)
				if instance == character or not instance:FindFirstChild("Humanoid") then
					return false
				end

				local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")

				if not humanoidRootPart2 then
					return false
				end

				if p7 == true then
					applyHit(character, p2, instance, p6, humanoidRootPart2, Config.DASH_DAMAGE, p3, p4, v5)
				elseif p7 == "Blocking" then
					applyBlock(character, p2, instance, humanoidRootPart2) -- equivalent call inferred; original call site unknown
				elseif p7 == "Perfect" then
					Combat_Util.Perfect(script, character, instance)
					return true
				end

				return false
			end
		})
		return v5
	end

	local v5 = Server_Mouse_Pos.Find(character, script.Parent.Name)
	local v6

	if v5 then
		v6 = v5.Position or position
	else
		v6 = position
	end

	local v7 = facingToward(v6) -- equivalent call inferred; original call site unknown
	local lookVector = v7.LookVector
	local DASH_FORWARD_STUDS = Config.DASH_FORWARD_STUDS
	local raycastResult = workspace:Raycast(
		humanoidRootPart.Position,
		lookVector * (DASH_FORWARD_STUDS + Config.DASH_WALL_CLEARANCE),
		RaycastHelper.Crater
	)

	if raycastResult ~= nil then
		DASH_FORWARD_STUDS = math.max(
			(raycastResult.Position - humanoidRootPart.Position).Magnitude - Config.DASH_WALL_CLEARANCE,
			0
		)
	end

	local v8 = DASH_FORWARD_STUDS + Config.DASH_REACH_MARGIN * 2
	dashTo(humanoidRootPart.Position + v7.LookVector * DASH_FORWARD_STUDS, Config.DASH_DURATION) -- equivalent call inferred; original call site unknown
	local targets2 = dashHit(
		v7 * CFrame.new(0, 0, -DASH_FORWARD_STUDS / 2),
		v7,
		Vector3.new(Config.DASH_WIDTH, Config.DASH_WIDTH, v8),
		Config.DASH_REACT_STUN,
		false,
		v4
	)
	EffectsEvent.ToAllInRange(player, "PredatorClaws_effs", character, "Slice3")
	task.wait(Config.DASH_DURATION)

	if v3 ~= PredatorClawsServer.Id[player.UserId] then
		cleanupPointer() -- equivalent call inferred; original call site unknown
		return
	end

	local v11 = Server_Mouse_Pos.Find(character, script.Parent.Name)

	if v11 then
		position = v11.Position or position
	end

	local v12 = facingToward(position) -- equivalent call inferred; original call site unknown
	local v13 = -v12.LookVector
	local DASH_BACK_STUDS = Config.DASH_BACK_STUDS
	local raycastResult2 = workspace:Raycast(
		humanoidRootPart.Position,
		v13 * (DASH_BACK_STUDS + Config.DASH_WALL_CLEARANCE),
		RaycastHelper.Crater
	)

	if raycastResult2 ~= nil then
		DASH_BACK_STUDS = math.max(
			(raycastResult2.Position - humanoidRootPart.Position).Magnitude - Config.DASH_WALL_CLEARANCE,
			0
		)
	end

	local v14 = DASH_BACK_STUDS + Config.DASH_REACH_MARGIN * 2
	dashTo(humanoidRootPart.Position - v12.LookVector * DASH_BACK_STUDS, Config.DASH_DURATION) -- equivalent call inferred; original call site unknown
	dashHit(
		v12 * CFrame.new(0, 0, DASH_BACK_STUDS / 2),
		v12,
		Vector3.new(Config.DASH_WIDTH, Config.DASH_WIDTH, v14),
		Config.FINAL_STUN,
		true,
		targets2
	)
	EffectsEvent.ToAllInRange(player, "PredatorClaws_effs", character, "Slash4")
	task.wait(Config.DASH_DURATION)
	cleanupPointer() -- equivalent call inferred; original call site unknown
end

function PredatorClawsServer.UnHold(_, _) end

function PredatorClawsServer.Cancel(player)
	if not player then
		return
	end

	PredatorClawsServer.Id[player.UserId] = nil
	local character = player.Character

	if character then
		Server_Mouse_Pos.Delete_Pos_Part(character, script.Parent.Name)
		EffectsEvent.ToAllInRange(player, "PredatorClaws_effs", character, "Cancel")
	end
end

return PredatorClawsServer