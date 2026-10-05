local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("CollectionService")
local _ = ReplicatedStorage.Communication
require(ReplicatedStorage2.Communication.ServerAndClient.Effects.EffectsEvent)
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local Checker = require(CAM.Global.Checker)
local Utility = require(CAM.Global.Utility)
local Combat_presets = require(CAM.Global.Combat_presets)
require(CAM.DebrisModule)
local ManuelCancel = require(CAM.Global.Subsets.Gameplay.ManuelCancel)
require(SAM.Utility.SkillStorage)
local Combat_Util = require(SAM.Services.Combat_Util)
local Server_Mouse_Pos = require(SAM.Services.Server_Mouse_Pos)
local EffectsEvent = require(ReplicatedStorage2.Communication.ServerAndClient.Effects.EffectsEvent)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local RaycastHelper = require(ReplicatedStorage2.CAM.Global.RaycastHelper)
local ProjectileHoming = require(ReplicatedStorage2.CAM.Global.Subsets.Gameplay.ProjectileHoming)
local Config = require(script.Parent.Config)
local script2 = script
local object = setmetatable({}, {
	__mode = "k"
})

local function usableMark(instance)
	if instance == nil or instance.Parent == nil or not instance:IsDescendantOf(workspace) or instance:FindFirstChild("HumanoidRootPart") == nil then
		return nil
	end

	return instance
end

local ArrowSmackdownServer = {}
ArrowSmackdownServer.Id = {}

function ArrowSmackdownServer.Hold(player, vector2: Vector3, state)
	local character = player.Character
	EffectsEvent.ToAllInRange(player, "Arrow Smackdown VFX", character, "Start")
	local humanoidRootPart

	if character == nil then
		humanoidRootPart = false
	else
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	if humanoidRootPart ~= nil then
		Server_Mouse_Pos.Create_Pos_Part(character, script.Parent.Name, 8)

		if typeof(vector2) ~= "Vector3" then
			vector2 = nil
		end

		local function aimPoint()
			local v2 = Server_Mouse_Pos.Find(character, script.Parent.Name)
			local position = vector2

			if v2 ~= nil then
				local defaultPos = v2:GetAttribute("DefaultPos")

				if defaultPos == nil or (v2.Position - defaultPos).Magnitude > 1 or position == nil then
					position = v2.Position
				end
			end

			return Server_Mouse_Pos.Clamp(character, position, Config.AIM_RANGE)
		end

		object[player] = nil
		state.marked = nil
		state.holding = true
		state.lock = ProjectileHoming.HoldLock({
			Pick = {
				Script = script,
				Caster = character,
				Origin = humanoidRootPart.Position,
				Range = Config.AIM_RANGE,
				Radius = Config.AIM_PICK_RADIUS,
				Downcast = Config.AIM_DOWNCAST,
				Select = true,
				KeepUntilGone = true
			},
			Origin = function()
				return humanoidRootPart.Position
			end,
			Aim = aimPoint,
			While = function()
				local lock = state.lock
				local marked

				if lock ~= nil then
					marked = lock:Target()
				end

				if marked ~= nil then
					state.marked = marked
					object[player] = marked
				end

				return state.holding == true and humanoidRootPart.Parent ~= nil
			end,
			Tick = Config.AIM_TICK
		})
	end
end

function ArrowSmackdownServer.UnHold(player, vector2: Vector3, state)
	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local position, v2, _, _ = RaycastHelper.MaximizeRayServer(
		character,
		humanoidRootPart.Position,
		vector2,
		Config.AIM_RANGE,
		true,
		4,
		15
	)
	local lock = state.lock
	local marked

	if lock ~= nil then
		marked = lock:Target()
	end

	if marked == nil or marked.Parent == nil or not marked:IsDescendantOf(workspace) then
		marked = nil
	elseif marked:FindFirstChild("HumanoidRootPart") == nil then
		marked = nil
	end

	if not marked then
		marked = state.marked

		if marked == nil or marked.Parent == nil or not marked:IsDescendantOf(workspace) then
			marked = nil
		elseif marked:FindFirstChild("HumanoidRootPart") == nil then
			marked = nil
		end

		if not marked then
			marked = object[player]

			if marked == nil or marked.Parent == nil or not marked:IsDescendantOf(workspace) then
				marked = nil
			elseif marked:FindFirstChild("HumanoidRootPart") == nil then
				marked = nil
			end
		end
	end

	if marked == nil then
		marked = ProjectileHoming.Pick({
			Script = script,
			Caster = character,
			Origin = humanoidRootPart.Position,
			Aim = vector2,
			Range = Config.AIM_RANGE,
			Radius = Config.AIM_PICK_RADIUS,
			Downcast = Config.AIM_DOWNCAST,
			Select = true
		})

		if marked == nil or marked.Parent == nil or not marked:IsDescendantOf(workspace) then
			marked = nil
		elseif marked:FindFirstChild("HumanoidRootPart") == nil then
			marked = nil
		end
	end

	state.holding = false
	object[player] = nil
	state.marked = nil
	Server_Mouse_Pos.Delete_Pos_Part(character, script.Parent.Name)

	if marked ~= nil then
		local humanoidRootPart2 = marked:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart2 ~= nil then
			position = humanoidRootPart2.Position
		end
	end

	local function solveCF(position2: Vector3)
		local raycastResult = workspace:Raycast(
			position2 + createVector(0, 5, 0),
			createVector(0, -20, 0),
			RaycastHelper.Crater
		)

		if raycastResult == nil or raycastResult.Instance == nil then
			return
				CFrame.new(position2, position2 + (v2 or createVector(0, 1, 0))) * CFrame.Angles(
					-1.5707963267948966,
					0,
					0
				),
				nil
		end

		return
			CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal) * CFrame.Angles(
				-1.5707963267948966,
				0,
				0
			),
			raycastResult.Instance
	end

	local humanoidRootPart2

	if marked ~= nil then
		humanoidRootPart2 = marked:FindFirstChild("HumanoidRootPart")
	end

	local v3, v4 = solveCF(position)
	EffectsEvent.ToAllInRange(player, "Arrow Smackdown VFX", character, "Initiate", v3, v4, humanoidRootPart2)
	local flag = false
	ManuelCancel.new(player, Config.CANCEL_WINDOW):Connect(function()
		flag = true
	end)
	task.wait(Config.FIRST_HIT_AT)

	if flag then
		return
	end

	if marked ~= nil and marked.Parent ~= nil then
		local humanoidRootPart3 = marked:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart3 ~= nil then
			v3 = solveCF(humanoidRootPart3.Position)
		end
	end

	local flag2 = false
	local targets = {}
	Utility.CreateHitbox({
		caster = character,
		hitboxSize = Config.STRIKE_HITBOX_SIZE,
		hitboxCFrame = v3 * Config.STRIKE_HITBOX_OFFSET,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = function(p, p2, p3)
			if p3 == "Perfect" then
				Combat_Util.Perfect(script2, character, p)
				flag2 = true
				return true
			else
				if p3 == true then
					Combat_Util.RagDoll(script2, character, p2, Config.FIRST_HIT_RAGDOLL)
					Combat_Util.AddStun(script2, character, p2, Config.FIRST_HIT_STUN)
					Combat_Util.Damage(script2, character, p, {
						Base = Config.FIRST_HIT_DAMAGE,
						Skill = script.Parent.Name
					})
				elseif p3 == "Blocking" then
					Combat_Util.Block(script2, character, p, Config.FIRST_HIT_BLOCK_BREAK)
				end

				table.insert(targets, p)
			end
		end
	})

	if flag2 then
		return
	end

	task.wait(Config.AIR_UP_DELAY)

	if character == nil or character.Parent == nil then
		return
	end

	EffectsEvent.ToAllInRange(player, "Arrow Smackdown VFX", character, "Hit", v3)
	Utility.CreateHitbox({
		caster = character,
		hitboxSize = Config.STRIKE_HITBOX_SIZE,
		hitboxCFrame = v3 * Config.STRIKE_HITBOX_OFFSET,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = function(instance, p, p2)
			if p2 == true then
				Combat_Util.AddStun(script2, character, p, Config.AIR_UP_STUN)
				Combat_presets.PlayReactAnim(instance.Humanoid, 5, 0.25)
				Combat_Util.Damage(script2, character, instance, {
					Base = Config.AIR_UP_DAMAGE,
					Skill = script.Parent.Name
				})
			elseif p2 == "Blocking" then
				Combat_Util.Block(script2, character, instance, Config.AIR_UP_BLOCK_BREAK)
			end

			local _ = instance.HumanoidRootPart.Position
			Combat_Util.Add_air_combo_bp(
				instance.HumanoidRootPart,
				nil,
				Config.AIR_UP_HEIGHT,
				nil,
				Config.AIR_UP_FLOAT_DUR,
				nil,
				10
			)
		end,
		targets = targets
	})
	task.wait(Config.AIR_DOWN_DELAY)

	if character == nil or character.Parent == nil then
		return
	end

	Utility.CreateHitbox({
		caster = character,
		hitboxSize = Config.STRIKE_HITBOX_SIZE,
		hitboxCFrame = v3 * Config.STRIKE_HITBOX_OFFSET,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = function(p, p2, p3)
			if p3 == true then
				Combat_Util.AddStun(script2, character, p2, Config.AIR_DOWN_STUN)
				Combat_Util.Damage(script2, character, p, {
					Base = Config.AIR_DOWN_DAMAGE,
					Skill = script.Parent.Name
				})
			elseif p3 == "Blocking" then
				Combat_Util.Block(script2, character, p, Config.AIR_DOWN_BLOCK_BREAK)
			end

			Combat_Util.Air_combo_slam(character, p, p.HumanoidRootPart.CFrame, Config.AIR_DOWN_SLAM_OFFSET, true)
		end,
		targets = targets
	})
	task.wait(Config.STRIKE_VFX_DELAY)
	EffectsEvent.ToAllInRange(player, "Arrow Smackdown VFX", character, "InitiateStrike", v3, v4)
end

function ArrowSmackdownServer.Cancel(player, _: Vector3, p)
	if p ~= nil then
		p.holding = false
		p.lock = nil
	end

	local character = player.Character

	if character ~= nil then
		Server_Mouse_Pos.Delete_Pos_Part(character, script.Parent.Name)
	end
end

return ArrowSmackdownServer