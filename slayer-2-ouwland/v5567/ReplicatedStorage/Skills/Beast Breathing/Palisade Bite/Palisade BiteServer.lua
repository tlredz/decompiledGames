local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CollectionService = game:GetService("CollectionService")
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local ManuelCancel = require(CAM.Global.Subsets.Gameplay.ManuelCancel)
local Checker = require(CAM.Global.Checker)
local Utility = require(CAM.Global.Utility)
local Combat_presets = require(CAM.Global.Combat_presets)
local DebrisModule = require(CAM.DebrisModule)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local Combat_Util = require(SAM.Services.Combat_Util)
local ImpactSounds = require(SAM.Utility.ImpactSounds)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local Config = require(script.Parent.Config)
local PalisadeBiteServer = {
	Id = {}
}
local name = script.Parent.Name
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include

local function scan(character, humanoidRootPart)
	local tagged = CollectionService:GetTagged("Humanoids")
	local index = table.find(tagged, character)

	if index then
		table.remove(tagged, index)
	end

	raycastParams.FilterDescendantsInstances = tagged
	local lookVector = humanoidRootPart.CFrame.LookVector
	local spherecast = workspace:Spherecast(
		humanoidRootPart.Position - lookVector * 5,
		4,
		lookVector * (Config.RADIUS + 5),
		raycastParams
	)

	if spherecast == nil then
		return nil
	end

	local find_character_from_descendant = Utility.find_character_from_descendant(spherecast.Instance)

	if find_character_from_descendant == nil or not Checker.check_can_select(
		script,
		character,
		find_character_from_descendant
	) then
		return nil
	end

	return find_character_from_descendant
end

local function lockUsable(p, instance)
	if instance == nil or not instance:IsDescendantOf(workspace) or instance:FindFirstChild("HumanoidRootPart") == nil then
		return false
	end

	if Checker.check_can_select(script, p, instance) then
		return true
	end

	return false
end

local function barrageWave(caster, p2, cframe: CFrame, p3)
	local v2 = {}
	Utility.CreateHitbox({
		caster = caster,
		hitboxCFrame = CFrame.new(p2.Position) * cframe.Rotation * CFrame.new(0, 0, -Config.BARRAGE_HITBOX_OFFSET),
		hitboxSize = Config.BARRAGE_HITBOX_SIZE,
		targets = p3 and { p3 } or nil,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = function(instance, p4, p5)
			if v2[instance] then
				return
			end

			v2[instance] = true
			local humanoid = instance:FindFirstChild("Humanoid")
			local rootPart = humanoid and humanoid.RootPart

			if humanoid == nil or rootPart == nil then
				return
			end

			if p5 == "Perfect" then
				Combat_Util.Perfect(script, caster, instance)
			elseif p5 == "Blocking" then
				Combat_Util.Block(script, caster, instance, Config.BARRAGE_BLOCK_BREAK)
			elseif p5 == true then
				EffectsEvent.ToAllInRange(p2, "Normal_Sword_Slash_Effect", rootPart, -1)
				Combat_Util.Damage(script, caster, instance, {
					Base = Config.BARRAGE_DAMAGE,
					Skill = name
				})
				Combat_Util.AddStun(script, caster, p4, Config.BARRAGE_STUN)
				Combat_Util.Knockback(
					script,
					caster,
					rootPart,
					cframe.LookVector * Config.BARRAGE_KNOCKBACK + createVector(0, 0.1, 0),
					0.5
				)
				Combat_presets.PlayReactAnim(humanoid)
			end
		end,
		After = function(p4, list)
			if p4 then
				ImpactSounds.Play(caster, script.Parent.Name, list[1])
			end
		end
	})
end

local function finisher(character, humanoidRootPart, cframe: CFrame, lock)
	local hitboxCFrame = CFrame.new(humanoidRootPart.Position) * cframe.Rotation * CFrame.new(
		0,
		0,
		-Config.FINISH_HITBOX_OFFSET
	)
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = hitboxCFrame,
		hitboxSize = Config.FINISH_HITBOX_SIZE,
		targets = lock and { lock } or nil,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = function(instance, p, p2)
			local humanoid = instance:FindFirstChild("Humanoid")
			local rootPart = humanoid and humanoid.RootPart

			if humanoid == nil or rootPart == nil then
				return
			end

			if p2 == "Perfect" then
				Combat_Util.Perfect(script, character, instance)
			elseif p2 == "Blocking" then
				Combat_Util.Block(script, character, instance, Config.FINISH_BLOCK_BREAK)
			elseif p2 == true then
				EffectsEvent.ToAllInRange(humanoidRootPart, "Normal_Sword_Slash_Effect", rootPart, -1)
				Combat_Util.Damage(script, character, instance, {
					Base = Config.FINISH_DAMAGE,
					Skill = name
				})
				Combat_Util.AddStun(script, character, p, Config.FINISH_STUN)
				Combat_Util.Knockback(script, character, rootPart, cframe.LookVector * Config.FINISH_KNOCKBACK, 0.15)
				Combat_Util.RagDoll(script, character, p, Config.FINISH_RAGDOLL)
			end
		end,
		After = function(p, list)
			if p then
				ImpactSounds.Play(character, script.Parent.Name, list[1])
			end
		end
	})
end

function PalisadeBiteServer.Hold(player, _: Vector3?, state)
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	state.stage = "Hold"
	state.lock = nil
	EffectsEvent.ToAllInRange(humanoidRootPart, "Palisade Bite VFX", character, "Start")
	task.spawn(function()
		while state.stage == "Hold" and humanoidRootPart.Parent ~= nil do
			if state.lock ~= nil then
				local character2 = character
				local lock = state.lock
				local v3

				if lock == nil or not lock:IsDescendantOf(workspace) or lock:FindFirstChild("HumanoidRootPart") == nil then
					v3 = false
				else
					v3 = Checker.check_can_select(script, character2, lock) and true or false
				end

				if not v3 then
					state.lock = nil
				end
			end

			local lock2 = scan(character, humanoidRootPart)

			if lock2 ~= nil and lock2 ~= state.lock then
				state.lock = lock2
			end

			task.wait(Config.AIM_TICK)
		end
	end)
end

function PalisadeBiteServer.UnHold(player, _: Vector3?, state)
	local DISTANCE_EPSILON = 0.01
	state.stage = "Release"
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	local lock = state.lock
	state.lock = nil
	local v2

	if lock == nil or not lock:IsDescendantOf(workspace) or lock:FindFirstChild("HumanoidRootPart") == nil then
		v2 = false
	else
		v2 = Checker.check_can_select(script, character, lock) and true or false
	end

	if not v2 then
		lock = nil
	end

	local humanoidRootPart2 = lock and lock:FindFirstChild("HumanoidRootPart")
	local cleanIt = state.CleanIt or cleanit.new()
	state.CleanIt = cleanIt
	cleanIt:Clean()
	local v3 = PalisadeBiteServer.Id[player.UserId]
	local v4, v5 = ManuelCancel.new(player, Config.BARRAGE_END)
	v4:Connect(function()
		PalisadeBiteServer.Id[player.UserId] = -1
		PalisadeBiteServer.Cancel(player, nil, state)
	end)
	cleanIt:Add(v5)
	local getvaluesfolder = Utility.getvaluesfolder(character)
	cleanIt:Add(Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.BARRAGE_END))
	cleanIt:Add(Utility.AddValue(getvaluesfolder, "NR", Config.BARRAGE_END))
	cleanIt:Add(Utility.AddValue(getvaluesfolder, "skill_stand_still", Config.BARRAGE_END))
	local air_combo_bp = humanoidRootPart:FindFirstChild("air_combo_bp")

	if air_combo_bp then
		air_combo_bp:Destroy()
	end

	humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
	humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
	local cFrame = humanoidRootPart.CFrame
	local cframe, v6

	if humanoidRootPart2 == nil then
		local v7 = humanoidRootPart.CFrame.LookVector * createVector(1, 0, 1)
		local unit = (v7.Magnitude < DISTANCE_EPSILON and createVector(0, 0, 1) or v7).Unit
		cframe = CFrame.fromOrientation(0, math.atan2(-unit.X, -unit.Z), 0)
		local position = humanoidRootPart.Position
		local raycastResult = workspace:Raycast(position - unit * 5, unit * (Config.RADIUS + 5), RaycastHelper.Crater)
		local v8

		if raycastResult then
			v8 = math.max(raycastResult.Distance - 5 - Config.MISS_WALL_GAP, 0)
		else
			v8 = Config.RADIUS - Config.MISS_RANGE_TRIM
		end

		v6 = CFrame.new(position + unit * v8) * cframe
		character:PivotTo(v6)
	else
		local v7 = (humanoidRootPart.Position - humanoidRootPart2.Position) * createVector(1, 0, 1)
		local unit

		if v7.Magnitude > DISTANCE_EPSILON then
			unit = v7.Unit
		else
			unit = -(humanoidRootPart.CFrame.LookVector * createVector(1, 0, 1))
		end

		local unit2 = (unit.Magnitude < DISTANCE_EPSILON and createVector(0, 0, 1) or unit).Unit
		cframe = CFrame.fromOrientation(0, math.atan2(unit2.X, unit2.Z), 0)
		v6 = CFrame.new(humanoidRootPart2.Position + unit2 * Config.TELEPORT_OFFSET) * cframe
		character:PivotTo(v6)
	end

	cleanIt:Add(Combat_Util.Add_air_combo_bp(humanoidRootPart, nil, 0, nil, Config.BARRAGE_END))
	EffectsEvent.ToAllInRange(humanoidRootPart, "Palisade Bite VFX", character, "Teleport", cFrame, v6)
	local attachment = Instance.new("Attachment")
	attachment.Name = "palisade_bite_face_lock"
	local alignOrientation = Instance.new("AlignOrientation")
	alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
	alignOrientation.Attachment0 = attachment
	alignOrientation.CFrame = cframe
	alignOrientation.MaxTorque = 1000000
	alignOrientation.Responsiveness = 200
	alignOrientation.Parent = attachment
	attachment.Parent = humanoidRootPart
	cleanIt:Add(attachment)
	DebrisModule:AddItem(attachment, Config.BARRAGE_END)
	task.delay(Config.BARRAGE_VFX_AT, function()
		if PalisadeBiteServer.Id[player.UserId] ~= v3 or humanoidRootPart.Parent == nil then
			return
		end

		EffectsEvent.ToAllInRange(humanoidRootPart, "Palisade Bite VFX", character, "Barrage", v6)
	end)

	if Config.BARRAGE_FIRST_AT > 0 then
		task.wait(Config.BARRAGE_FIRST_AT)

		if PalisadeBiteServer.Id[player.UserId] ~= v3 or humanoidRootPart.Parent == nil then
			return
		end
	end

	local v7 = Config.BARRAGE_DURATION / Config.BARRAGE_HIT_COUNT

	for i = 1, Config.BARRAGE_HIT_COUNT do
		local v10

		if i == 1 then
			v10 = lock
		end

		barrageWave(character, humanoidRootPart, v6, v10)
		EffectsEvent.ToAllInRange(humanoidRootPart, "Palisade Bite VFX", character, "Wave", v6)

		if not (i < Config.BARRAGE_HIT_COUNT) then
			continue
		end

		task.wait(v7)

		if PalisadeBiteServer.Id[player.UserId] ~= v3 or humanoidRootPart.Parent == nil then
			return
		end
	end

	task.wait((math.max(0, Config.BARRAGE_FINISH_AT - Config.BARRAGE_FIRST_AT - v7 * (Config.BARRAGE_HIT_COUNT - 1))))

	if PalisadeBiteServer.Id[player.UserId] ~= v3 or humanoidRootPart.Parent == nil then
		return
	end

	EffectsEvent.ToAllInRange(humanoidRootPart, "Palisade Bite VFX", character, "Slash", v6)
	finisher(character, humanoidRootPart, v6, lock)
	task.wait((math.max(0, Config.BARRAGE_END - Config.BARRAGE_FINISH_AT)))

	if PalisadeBiteServer.Id[player.UserId] ~= v3 or humanoidRootPart.Parent == nil then
		return
	end

	cleanIt:Clean()
end

function PalisadeBiteServer.Cancel(player, _: Vector3?, p)
	p.stage = "Cancel"
	p.lock = nil
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and character then
		EffectsEvent.ToAllInRange(humanoidRootPart, "Palisade Bite VFX", character, "Cancel")
	end

	if p.CleanIt then
		p.CleanIt:Clean()
	end
end

return PalisadeBiteServer