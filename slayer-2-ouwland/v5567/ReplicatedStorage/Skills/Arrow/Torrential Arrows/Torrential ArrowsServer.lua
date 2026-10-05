local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("CollectionService")
local _ = ReplicatedStorage.Communication
local EffectsEvent = require(ReplicatedStorage2.Communication.ServerAndClient.Effects.EffectsEvent)
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local Checker = require(CAM.Global.Checker)
local Utility = require(CAM.Global.Utility)
require(CAM.Global.Combat_presets)
local DebrisModule = require(CAM.DebrisModule)
local ManuelCancel = require(CAM.Global.Subsets.Gameplay.ManuelCancel)
require(SAM.Utility.SkillStorage)
local Combat_Util = require(SAM.Services.Combat_Util)
local RaycastHelper = require(ReplicatedStorage2.CAM.Global.RaycastHelper)
local ProjectileHoming = require(ReplicatedStorage2.CAM.Global.Subsets.Gameplay.ProjectileHoming)
local Server_Mouse_Pos = require(SAM.Services.Server_Mouse_Pos)
local CharGrabPosCorrector = require(ReplicatedStorage2.CAM.Global.Subsets.Gameplay.CharGrabPosCorrector)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local Cutscene_camera_handler = require(SAM.Game_Play.Cutscene_camera_handler)
local Config = require(script.Parent.Config)
CFrame.new(0, 0, -10)
local script2 = script

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

local TorrentialArrowsServer = {
	Id = {}
}
local object = setmetatable({}, {
	__mode = "k"
})

local function usableMark(instance)
	if instance == nil or instance.Parent == nil or not instance:IsDescendantOf(workspace) or instance:FindFirstChild("HumanoidRootPart") == nil then
		return nil
	end

	return instance
end

function TorrentialArrowsServer.Hold(player, vector2: Vector3, state)
	state.stage = "Hold"
	local character = player.Character
	local rootPart = character:FindFirstChild("Humanoid").RootPart
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
			Origin = rootPart.Position,
			Range = Config.AIM_RANGE,
			Radius = Config.AIM_PICK_RADIUS,
			Downcast = Config.AIM_DOWNCAST,
			Select = true,
			KeepUntilGone = true
		},
		Origin = function()
			return rootPart.Position
		end,
		Aim = aimPoint,
		While = function()
			local lock2 = state.lock
			local marked

			if lock2 ~= nil then
				marked = lock2:Target()
			end

			if marked ~= nil then
				state.marked = marked
				object[player] = marked
			end

			return state.holding == true and rootPart.Parent ~= nil
		end,
		Tick = Config.AIM_TICK
	})
end

function TorrentialArrowsServer.UnHold(player, vector2: Vector3, state)
	state.stage = "Release"
	local character = player.Character
	local getvaluesfolder = Utility.getvaluesfolder(character)
	local humanoid = character:FindFirstChild("Humanoid")
	local rootPart = humanoid.RootPart
	local animator = humanoid:FindFirstChild("Animator")
	local v2, v3 = ManuelCancel.new(player, Config.CANCEL_WINDOW)
	v2:Connect(function()
		TorrentialArrowsServer.Cancel(player, vector2, state)
	end)
	Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.RELEASE_LOCK_DUR)
	local lock2 = state.lock
	local marked

	if lock2 ~= nil then
		marked = lock2:Target()
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
			Origin = rootPart.Position,
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
	local position, normal = RaycastHelper.MaximizeRayServer(
		character,
		rootPart.Position,
		vector2,
		Config.AIM_RANGE,
		true,
		6,
		15
	)

	if marked ~= nil then
		local humanoidRootPart = marked:FindFirstChild("HumanoidRootPart")
		local raycastResult = workspace:Raycast(
			humanoidRootPart.Position + createVector(0, 2, 0),
			Vector3.new(0, -Config.AIM_DOWNCAST, 0),
			RaycastHelper.Crater
		)

		if raycastResult == nil then
			position = humanoidRootPart.Position
			normal = nil
		else
			position = raycastResult.Position
			normal = raycastResult.Normal
		end
	end

	local hitboxCFrame = CFrame.new(position, position + (normal or createVector(0, 1, 0))) * CFrame.Angles(
		-1.5707963267948966,
		0,
		0
	)
	task.wait(Config.START_VFX_DELAY)

	if state.stage == "Cancel" then
		return
	end

	local v5 = {}
	EffectsEvent.ToAllInRange(player, "Torrential Arrows VFX", character, "Start", nil, hitboxCFrame)
	task.wait(Config.HITBOX_DELAY)

	if state.stage == "Cancel" then
		return
	end

	local v6 = false
	local clone = nil

	local function fn(instance, p, p2)
		if state.stage == "Cancel" then
			return
		end

		if p2 == "Perfect" then
			Combat_Util.Perfect(script2, character, instance)
			return
		elseif p2 == "Blocking" then
			Combat_Util.Block(script2, character, instance, Config.BLOCK_BREAK)
			return
		end

		local humanoid2 = instance:FindFirstChild("Humanoid")
		local rootPart2 = humanoid2.RootPart
		local animator2 = humanoid2:FindFirstChild("Animator")
		local cFrame = rootPart.CFrame
		local v7 = cFrame * Config.VICTIM_LOCK_OFFSET
		local CUTSCENE_DUR = Config.CUTSCENE_DUR
		rootPart2:PivotTo(v7)
		local clone2 = nil

		if not clone2 then
			clone2 = script.LOCK:Clone()
			clone2.Name = "LOCK"
			clone2.Parent = workspace.Debree
			clone2.Transparency = 1
		end

		clone2:PivotTo(v7)

		if CUTSCENE_DUR then
			DebrisModule:AddItem(clone2, CUTSCENE_DUR)
		end

		local weld = clone2.Weld
		weld.Part0 = clone2
		weld.Part1 = rootPart2

		if not v6 then
			local part = rootPart
			local CUTSCENE_DUR2 = Config.CUTSCENE_DUR
			part:PivotTo(cFrame)
			local clone3 = nil

			if not clone3 then
				clone3 = script.LOCK:Clone()
				clone3.Name = "LOCK"
				clone3.Parent = workspace.Debree
				clone3.Transparency = 1
			end

			clone3:PivotTo(cFrame)

			if CUTSCENE_DUR2 then
				DebrisModule:AddItem(clone3, CUTSCENE_DUR2)
			end

			local weld2 = clone3.Weld
			weld2.Part0 = clone3
			weld2.Part1 = part
			local track = animator:LoadAnimation(script.User)
			track:Play()
			CharGrabPosCorrector.Do(character, track, nil, character)

			for _, v9 in {
				"iframe",
				"skill_stand_still",
				"noragdoll",
				"pause_gameplay"
			} do
				Utility.AddValue(getvaluesfolder, v9, Config.CUTSCENE_DUR)
			end

			EffectsEvent.ToAllInRange(player, "Torrential Arrows VFX", character, "Hit", instance)
			clone = script.CameraRig:Clone()
			clone.Parent = workspace.Debree
			clone:PivotTo(cFrame * CFrame.new(0.03887939453125, 1.9782161712646484, -0.0771484375))
			clone.RootPart.RootPart.Part0 = rootPart
			DebrisModule:AddItem(clone, Config.CUTSCENE_DUR)
			clone.AnimationController.Animator:LoadAnimation(script.Camera):Play()
			Cutscene_camera_handler.Regular(player, clone.Bone)
		end

		local track = animator2:LoadAnimation(script.Victim)
		track:Play()
		CharGrabPosCorrector.Do(instance, track, nil, character)
		local playerFromCharacter = game.Players:GetPlayerFromCharacter(instance)

		if playerFromCharacter then
			Cutscene_camera_handler.Regular(playerFromCharacter, clone.Bone)
		end

		task.spawn(function()
			if clone then
				local clone3 = table.clone(v5)
				table.insert(v5, character)
				table.insert(v5, instance)
				EffectsEvent.ToAllInRange(
					rootPart,
					"Torrential Arrows VFX",
					character,
					"UltimateCamera",
					nil,
					clone3,
					clone
				)
			end
		end)

		for _, v8 in {
			"iframe",
			"skill_stand_still",
			"noragdoll",
			"pause_gameplay"
		} do
			local v9 = Utility.AddValue(p, v8, Config.CUTSCENE_DUR, v8 == "iframe" and "StringValue" or nil)

			if v8 == "iframe" then
				v9.Value = player.Name
			end
		end

		Combat_Util.Add_Strict_Stun(script2, character, p, Config.GRAB_STUN)
		task.spawn(function()
			for _ = 1, Config.TICK_COUNT do
				task.wait(Config.TICK_INTERVAL)

				if not (state.stage ~= "Cancel" and character ~= nil and instance ~= nil and Checker.check_victim(
					script2,
					character,
					instance
				) ~= nil) then
					continue
				end

				Combat_Util.Damage(script2, character, instance, {
					Base = Config.TICK_DAMAGE,
					Skill = script.Parent.Name
				})
			end
		end)
		task.delay(Config.FINAL_HIT_AT, function()
			if state.stage == "Cancel" or character == nil or instance == nil or Checker.check_victim(
				script2,
				character,
				instance
			) == nil then
				return
			end

			Combat_Util.Damage(script2, character, instance, {
				Base = Config.FINAL_DAMAGE,
				Skill = script.Parent.Name
			})
			Combat_Util.AddStun(script2, character, p, Config.FINAL_STUN)
			v3()
		end)
		v6 = true
	end

	Utility.CreateHitbox({
		caster = character,
		hitboxSize = Config.HITBOX_SIZE,
		hitboxCFrame = hitboxCFrame,
		targets = marked ~= nil and { marked } or nil,
		checker = Checker,
		{
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = fn
	})
end

function TorrentialArrowsServer.Cancel(player, _: Vector3, p)
	p.stage = "Cancel"
	p.holding = false
	p.lock = nil

	if player.Character ~= nil then
		Server_Mouse_Pos.Delete_Pos_Part(player.Character, script.Parent.Name)
	end

	EffectsEvent.ToAllInRange(player, "Torrential Arrows VFX", player.Character, "Cancel")
end

return TorrentialArrowsServer