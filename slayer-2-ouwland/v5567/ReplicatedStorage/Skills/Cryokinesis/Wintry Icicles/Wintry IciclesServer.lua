local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local Combat_presets = require(ReplicatedStorage.CAM.Global.Combat_presets)
local Checker = require(CAM.Global.Checker)
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local CombatMode = require(CAM.Global.CombatMode)
local ManuelCancel = require(CAM.Global.Subsets.Gameplay.ManuelCancel)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local Skill_Switch_Adder = require(CAM.Global.Subsets.Gameplay.Skill_Switch_Adder)
local Utility = require(CAM.Global.Utility)
local Server_Mouse_Pos = require(SAM.Services.Server_Mouse_Pos)
local Combat_Util = require(SAM.Services.Combat_Util)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local Config = require(script.Parent.Config)
local WintryIciclesServer = {
	Id = {}
}

local function randomPointInCircleOnPlane(position: Vector3, p: number, cframe: CFrame)
	local v2 = math.random() * 3.141592653589793 * 2
	local v3 = math.sqrt((math.random())) * p
	local v4 = math.cos(v2) * v3
	local v5 = math.sin(v2) * v3
	local lookVector = cframe.LookVector
	return position - lookVector * (position - cframe.Position):Dot(lookVector) + cframe.RightVector * v4 + cframe.UpVector * v5
end

function WintryIciclesServer.Hold(player, _: Vector3, p)
	local cleanIt = p.CleanIt or cleanit.new()
	p.CleanIt = cleanIt
	cleanIt:Clean()
	local character = player.Character
	Server_Mouse_Pos.Create_Pos_Part(character, script.Parent.Name, Config.ZONE_DURATION)
	cleanIt:Add(function()
		Server_Mouse_Pos.Delete_Pos_Part(character, script.Parent.Name)
	end)
end

function WintryIciclesServer.UnHold(player, vector2: Vector3, p)
	local cleanIt = p.CleanIt or cleanit.new()
	p.CleanIt = cleanIt
	local v2 = WintryIciclesServer.Id[player.UserId]
	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local v3 = Server_Mouse_Pos.Find(character, script.Parent.Name)
	local defaultPos = v3 and v3:GetAttribute("DefaultPos")
	local cframe

	if v3 and defaultPos and (v3.Position - defaultPos).Magnitude > 1 then
		local v4
		v4, cframe = Server_Mouse_Pos.Aim(character, script.Parent.Name, Config.MOUSE_RANGE)
	end

	if not cframe then
		local MOUSE_RANGE

		if typeof(vector2) == "Vector3" then
			MOUSE_RANGE = math.min(Config.MOUSE_RANGE, (vector2 - humanoidRootPart.Position).Magnitude)
		else
			MOUSE_RANGE = Config.MOUSE_RANGE
		end

		local maximizeRayServer, v4 = RaycastHelper.MaximizeRayServer(
			character,
			humanoidRootPart.Position,
			vector2,
			MOUSE_RANGE,
			false,
			1,
			nil,
			nil,
			RaycastHelper.Crater
		)

		if not v4 then
			maximizeRayServer, v4 = RaycastHelper.MaximizeRayServer(
				character,
				humanoidRootPart.Position,
				vector2,
				MOUSE_RANGE,
				false,
				1,
				Config.GROUND_SNAP,
				nil,
				RaycastHelper.Crater
			)
		end

		if maximizeRayServer and v4 then
			cframe = CFrame.lookAt(maximizeRayServer, maximizeRayServer + v4.Unit)
		else
			return
		end
	end

	p.ZoneCFrame = cframe
	local v4 = not CombatMode.IsRanked(player) and 0 or Config.RANKED_WINDUP
	cleanIt:Add(Skill_Switch_Adder.Add(player, script.Parent.Name, v4 + Config.ZONE_DURATION))
	local v5, v6 = ManuelCancel.new(player, v4 + Config.ZONE_DURATION)
	v5:Connect(function()
		WintryIciclesServer.Id[player.UserId] = -1
		WintryIciclesServer.Cancel(player, vector2, p)
	end)
	EffectsEvent.ToAllInRange(humanoidRootPart, "Wintry Icicles VFX", character, "Start", cframe)

	if v4 > 0 then
		task.wait(v4)

		if WintryIciclesServer.Id[player.UserId] ~= v2 then
			return
		end
	end

	local lastTime = os.clock()
	local v7 = 0

	while os.clock() - lastTime < Config.ZONE_DURATION and WintryIciclesServer.Id[player.UserId] == v2 do
		local v8 = {}

		for _, v9 in Utility.GetModelInRegion(
			cframe + cframe.LookVector * (Config.EXPLOSION_HITBOX_SIZE.Z / 2),
			Config.EXPLOSION_HITBOX_SIZE
		) do
			if v9 ~= character and Checker.check_victim(script, character, v9) then
				table.insert(v8, v9)
			end
		end

		local position = randomPointInCircleOnPlane(cframe.Position, Config.ZONE_RADIUS, cframe)

		if #v8 > 0 then
			v7 = v7 % #v8 + 1
			position = randomPointInCircleOnPlane(v8[v7]:GetPivot().Position, Config.TARGET_JITTER_RADIUS, cframe)
		end

		local raycastResult = workspace:Raycast(
			position + cframe.LookVector * Config.ZONE_HEIGHT,
			cframe.LookVector * -Config.ZONE_HEIGHT * 1.5,
			RaycastHelper.Crater
		)

		if raycastResult then
			position = raycastResult.Position
		end

		local normal

		if raycastResult then
			normal = raycastResult.Normal
		else
			normal = cframe.LookVector
		end

		local cframe2 = CFrame.lookAt(position, position + normal)
		EffectsEvent.ToAllInRange(humanoidRootPart, "Wintry Icicles VFX", character, "Drop", cframe2)
		Utility.CreateHitbox({
			caster = character,
			hitboxCFrame = cframe2 + normal.Unit * (Config.DROP_HITBOX_SIZE.Y / 2),
			hitboxSize = Config.DROP_HITBOX_SIZE,
			checker = Checker,
			hitPriorityHandler = {
				callback = v.Exists,
				data = "Choosing_1"
			},
			hitDetected = function(instance, p2, p3)
				if p3 == "Perfect" then
					Combat_Util.Perfect(script, character, instance)
				elseif p3 == "Blocking" then
					Combat_Util.Block(script, character, instance, 0.75)
				elseif p3 == true then
					Combat_Util.Damage(script, character, instance, {
						Base = Config.DROP_DAMAGE,
						Skill = script.Parent.Name
					})
					Combat_presets.PlayReactAnim(instance.Humanoid)
					Combat_Util.AddStun(script, character, p2, Config.DROP_STUN)
				end
			end
		})
		local v9 = Config.DROP_INTERVAL_MIN + math.random() * (Config.DROP_INTERVAL_MAX - Config.DROP_INTERVAL_MIN)
		task.wait(v9)
	end

	if WintryIciclesServer.Id[player.UserId] ~= v2 then
		return
	end

	v6()
	cleanIt:Clean()
end

function WintryIciclesServer.Switch(player, _: Vector3, state)
	local cleanIt = state.CleanIt or cleanit.new()
	state.CleanIt = cleanIt
	cleanIt:Clean()
	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local zoneCFrame = state.ZoneCFrame

	if not zoneCFrame then
		return
	end

	EffectsEvent.ToAllInRange(humanoidRootPart, "Wintry Icicles VFX", character, "Finish", zoneCFrame)
	task.wait(0.25)
	local instances = {}
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = zoneCFrame + zoneCFrame.LookVector.Unit * (Config.EXPLOSION_HITBOX_SIZE.Z / 2),
		hitboxSize = Config.EXPLOSION_HITBOX_SIZE,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = function(instance, p, p2)
			local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")

			if p2 == "Perfect" then
				Combat_Util.Perfect(script, character, instance)
			elseif p2 == "Blocking" then
				Combat_Util.Block(script, character, instance, 1.5)
			elseif p2 == true then
				local vector2 = Vector3.new(
					humanoidRootPart2.Position.X - zoneCFrame.Position.X,
					0,
					humanoidRootPart2.Position.Z - zoneCFrame.Position.Z
				)
				local lookVector

				if vector2.Magnitude <= 0.01 then
					lookVector = humanoidRootPart and humanoidRootPart.CFrame.LookVector or createVector(0, 0, 1)
				else
					lookVector = vector2.Unit
				end

				table.insert(instances, instance)
				local v2 = lookVector * 4 + createVector(0, 2.5, 0)
				Combat_Util.Damage(script, character, instance, {
					Base = Config.EXPLOSION_DAMAGE * 0.2,
					Skill = script.Parent.Name
				})
				Combat_Util.AddStun(script, character, p, Config.EXPLOSION_STUN)
				Combat_Util.RagDoll(script, character, p, Config.EXPLOSION_STUN)
				Combat_Util.Knockback(script, character, humanoidRootPart2, v2, 1)
			end
		end
	})
	task.wait(0.75)
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = zoneCFrame + zoneCFrame.LookVector.Unit * (Config.EXPLOSION_HITBOX_SIZE.Z / 2),
		hitboxSize = Config.EXPLOSION_HITBOX_SIZE * 1.35,
		checker = Checker,
		targets = instances,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = function(instance, p, p2)
			local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")

			if p2 == "Perfect" then
				Combat_Util.Perfect(script, character, instance)
			elseif p2 == "Blocking" then
				Combat_Util.Block(script, character, instance, 0.75)
			elseif p2 == true then
				local vector2 = Vector3.new(
					humanoidRootPart2.Position.X - zoneCFrame.Position.X,
					0,
					humanoidRootPart2.Position.Z - zoneCFrame.Position.Z
				)
				local v2

				if vector2.Magnitude <= 0.01 then
					v2 = humanoidRootPart and humanoidRootPart.CFrame.LookVector or createVector(0, 0, 1)
				else
					v2 = vector2.Unit
				end

				local v3 = v2 * Config.EXPLOSION_KNOCKBACK + Vector3.new(0, Config.EXPLOSION_KNOCKBACK * 0.35, 0)
				Combat_Util.Damage(script, character, instance, {
					Base = Config.EXPLOSION_DAMAGE * 0.8,
					Skill = script.Parent.Name
				})
				Combat_Util.AddStun(script, character, p, Config.EXPLOSION_STUN)
				Combat_Util.RagDoll(script, character, p, Config.EXPLOSION_STUN)
				Combat_Util.Knockback(script, character, humanoidRootPart2, v3, 0.2)
			end
		end
	})
end

function WintryIciclesServer.Cancel(player, _: Vector3?, p)
	local cleanIt = p.CleanIt or cleanit.new()
	p.CleanIt = cleanIt
	cleanIt:Clean()
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		EffectsEvent.ToAllInRange(humanoidRootPart, "Wintry Icicles VFX", character, "Cancel")
	end
end

return WintryIciclesServer