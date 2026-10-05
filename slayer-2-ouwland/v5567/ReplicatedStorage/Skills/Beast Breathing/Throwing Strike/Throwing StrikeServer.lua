local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local ManuelCancel = require(CAM.Global.Subsets.Gameplay.ManuelCancel)
local HitCooldown = require(CAM.Global.Subsets.Gameplay.HitCooldown)
local Checker = require(CAM.Global.Checker)
local Utility = require(CAM.Global.Utility)
local Combat_Util = require(SAM.Services.Combat_Util)
local ImpactSounds = require(SAM.Utility.ImpactSounds)
local Combat_presets = require(CAM.Global.Combat_presets)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local DebrisModule = require(CAM.DebrisModule)
local Config = require(script.Parent.Config)
local ThrowingStrikeServer = {
	Id = {}
}
local name = script.Parent.Name

-- equivalent calls inferred from this helper; original call sites unknown
local function showItem(p)
	if p.hideItem then
		p.hideItem:Destroy()
		p.hideItem = nil
	end
end

local function equippedNames(character)
	local tool_Accessories = character:FindFirstChild("Tool_Accessories")

	if tool_Accessories == nil then
		return nil
	end

	local names = {}

	for _, child in tool_Accessories:GetChildren() do
		if child:GetAttribute("_ClanAccessory") ~= true then
			table.insert(names, child.Name)
		end
	end

	if #names > 0 then
		return (table.concat(names, ","))
	end

	return nil
end

local function pullVictimTo(character, instance, parent, vector2: Vector3, duration: number)
	local child = Players:FindFirstChild(character.Name)

	if child and instance.Name ~= child.Name and instance:GetAttribute("IsMob") == nil and Players:FindFirstChild(instance.Name) == nil and parent:CanSetNetworkOwnership() then
		parent:SetNetworkOwner(child)
	end

	local getvaluesfolder = Utility.getvaluesfolder(instance)

	if getvaluesfolder then
		Combat_Util.Add_No_GP(script, character, getvaluesfolder, duration + Config.PULL_HOLD)
	end

	Utility.ClearMovers(parent)

	if child then
		local child2 = Players:FindFirstChild(instance.Name)
		EffectsEvent.ToClient(child2 or child, "Add_Velocity", parent, createVector(0, 0, 0), 0, "delete")
	end

	local attachment = Instance.new("Attachment")
	attachment.Name = "air_combo_bp"
	local alignPosition = Instance.new("AlignPosition")
	alignPosition.Name = "bpv"
	alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
	alignPosition.ForceLimitMode = Enum.ForceLimitMode.PerAxis
	alignPosition.MaxAxesForce = createVector(1000000, 1000000, 1000000)
	alignPosition.Attachment0 = attachment
	alignPosition.Responsiveness = 200
	alignPosition.Position = parent.Position
	alignPosition.Parent = attachment
	attachment.Parent = parent
	TweenService:Create(alignPosition, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
		Position = vector2
	}):Play()
	DebrisModule:AddItem(attachment, duration + Config.PULL_HOLD)
end

function ThrowingStrikeServer.Hold(player, _: Vector3?, p)
	local cleanIt = p.CleanIt or cleanit.new()
	p.CleanIt = cleanIt
	cleanIt:Clean()
	showItem(p) -- equivalent call inferred; original call site unknown
	local character = player.Character
	local v2 = character and Utility.getvaluesfolder(character)

	if v2 == nil then
		return
	end

	cleanIt:Add(Utility.AddValue(v2, "pause_gameplay", Config.MAX_HOLD))
	cleanIt:Add(Utility.AddValue(v2, "NR", Config.MAX_HOLD))
end

function ThrowingStrikeServer.UnHold(player, vector2: Vector3?, p)
	local cleanIt = p.CleanIt or cleanit.new()
	p.CleanIt = cleanIt
	cleanIt:Clean()
	local v2 = ThrowingStrikeServer.Id[player.UserId]
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	local getvaluesfolder = Utility.getvaluesfolder(character)
	cleanIt:Add(Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.LOCK))
	cleanIt:Add(Utility.AddValue(getvaluesfolder, "NR", Config.LOCK))
	local v3, v4 = ManuelCancel.new(player, Config.DURATION)
	v3:Connect(function()
		ThrowingStrikeServer.Id[player.UserId] = -1
		ThrowingStrikeServer.Cancel(player, nil, p)
	end)
	cleanIt:Add(v4)
	EffectsEvent.ToAllInRange(humanoidRootPart, "Throwing Strike VFX", character, "Release")
	task.wait(Config.WINDUP)

	if ThrowingStrikeServer.Id[player.UserId] ~= v2 or humanoidRootPart.Parent == nil then
		return
	end

	local position = humanoidRootPart.Position
	local v5 = vector2 or position + humanoidRootPart.CFrame.LookVector
	local safeLookAt = Utility.SafeLookAt(position, v5, humanoidRootPart.CFrame)
	showItem(p) -- equivalent call inferred; original call site unknown
	local v6 = equippedNames(character)

	if v6 then
		p.hideItem = Utility.AddValue(getvaluesfolder, "InvisibleItem", Config.DURATION, "StringValue", v6)
	end

	EffectsEvent.ToAllInRange(humanoidRootPart, "Throwing Strike VFX", character, "Throw", safeLookAt)
	local instances = {}
	local v7 = HitCooldown.new(Config.DURATION)
	local now = os.clock()
	local v8 = os.clock() + Config.THROW_TIME + Config.RETURN_DELAY + Config.RETURN_TIME
	task.spawn(function()
		while os.clock() < v8 do
			task.wait(Config.SAW_INTERVAL)

			if ThrowingStrikeServer.Id[player.UserId] ~= v2 or humanoidRootPart.Parent == nil then
				break
			end

			local v9 = nil

			for _, v10 in instances do
				local humanoidRootPart2 = v10:FindFirstChild("HumanoidRootPart")

				if not (v10.Parent ~= nil and humanoidRootPart2 ~= nil and Checker.check_victim(script, character, v10) == true) then
					continue
				end

				Combat_Util.Damage(script, character, v10, {
					Base = Config.SAW_DAMAGE,
					Skill = name
				})
				Combat_presets.PlayReactAnim((v10:FindFirstChild("Humanoid")))
				EffectsEvent.ToAllInRange(humanoidRootPart, "Normal_Sword_Slash_Effect", humanoidRootPart2, -1)
				v9 = v9 or v10
			end

			if v9 ~= nil then
				ImpactSounds.Play(character, script.Parent.Name, v9)
			end
		end
	end)

	local function castBox(p2: number, p3: number, fn)
		local v9 = CFrame.new(humanoidRootPart.Position) * humanoidRootPart.CFrame.Rotation
		local v10 = (p2 + Config.HITBOX_BACK) * Config.HITBOX_LENGTH_SCALE
		local v11 = v9.LookVector * createVector(1, 0, 1)
		local v12 = not (v11.Magnitude > 0.001) and createVector(0, 0, 0) or v11.Unit
		local v13 = nil
		Utility.CreateHitbox({
			caster = character,
			hitboxCFrame = v9 * CFrame.new(0, 0, Config.HITBOX_BACK - v10 / 2),
			hitboxSize = Vector3.new(Config.HITBOX_WIDTH, Config.HITBOX_HEIGHT, v10),
			checker = Checker,
			hitPriorityHandler = {
				callback = v.Exists,
				data = "Choosing_1"
			},
			hitDetected = function(instance, p4, p5)
				if not v7:Take(instance) then
					return
				end

				local humanoid = instance:FindFirstChild("Humanoid")
				local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")

				if humanoid == nil or humanoidRootPart2 == nil then
					return
				end

				if p5 == "Perfect" then
					Combat_Util.Perfect(script, character, instance)
				elseif p5 == "Blocking" then
					Combat_Util.Block(script, character, instance, Config.BLOCK_BREAK)
				elseif p5 == true then
					Combat_Util.Damage(script, character, instance, {
						Base = Config.DAMAGE,
						Skill = name
					})
					v13 = v13 or instance
					Combat_Util.AddStun(script, character, p4, p3)
					Combat_presets.PlayReactAnim(humanoid)
					table.insert(instances, instance)
					fn(instance, humanoidRootPart2, v12)
				end

				EffectsEvent.ToAllInRange(humanoidRootPart, "Normal_Sword_Slash_Effect", humanoidRootPart2, -1)
			end,
			After = function()
				if v13 ~= nil then
					ImpactSounds.Play(character, script.Parent.Name, v13)
				end
			end
		})
	end

	for i = 1, Config.SWEEP_COUNT do
		castBox(
			Config.TRAVEL_DISTANCE * math.min(i * Config.SWEEP_INTERVAL / Config.THROW_TIME, 1),
			Config.STUN,
			function(_, p2, vector3: Vector3)
				Combat_Util.Knockback(script, character, p2, vector3 * Config.KNOCKBACK, Config.STUN, "remove_airbp")
			end
		)
		local v9 = now + i * Config.SWEEP_INTERVAL - os.clock()

		if v9 > 0 then
			task.wait(v9)
		end

		if ThrowingStrikeServer.Id[player.UserId] ~= v2 or humanoidRootPart.Parent == nil then
			return
		end
	end

	task.wait(Config.RETURN_DELAY)

	if ThrowingStrikeServer.Id[player.UserId] ~= v2 or humanoidRootPart.Parent == nil then
		return
	end

	local v9 = humanoidRootPart.CFrame.LookVector * createVector(1, 0, 1)
	local v10 = not (v9.Magnitude > 0.001) and createVector(0, 0, 1) or v9.Unit
	local position2 = humanoidRootPart.Position + v10 * Config.PULL_FRONT_DIST

	for _, v12 in instances do
		if v12.Parent == nil then
			continue
		end

		local humanoidRootPart2 = v12:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart2 ~= nil and Checker.check_victim(script, character, v12) == true then
			pullVictimTo(character, v12, humanoidRootPart2, position2, Config.RETURN_TIME)
		end
	end

	local lastTime = os.clock()

	for i = 1, math.ceil(Config.RETURN_TIME / Config.SWEEP_INTERVAL) do
		local v12 = os.clock() - lastTime
		local v13 = math.max(Config.RETURN_TIME - v12, 0)
		castBox(Config.TRAVEL_DISTANCE * (v13 / Config.RETURN_TIME), v13 + Config.STUN_MARGIN, function(p2, parent)
			if v13 > 0 then
				pullVictimTo(character, p2, parent, position2, v13)
			end
		end)
		local v15 = lastTime + i * Config.SWEEP_INTERVAL - os.clock()

		if v15 > 0 then
			task.wait(v15)
		end

		if ThrowingStrikeServer.Id[player.UserId] ~= v2 or humanoidRootPart.Parent == nil then
			return
		end
	end

	local v12 = lastTime + Config.RETURN_TIME - os.clock()

	if v12 > 0 then
		task.wait(v12)
	end

	if ThrowingStrikeServer.Id[player.UserId] ~= v2 or humanoidRootPart.Parent == nil then
		return
	end

	showItem(p) -- equivalent call inferred; original call site unknown
	EffectsEvent.ToAllInRange(humanoidRootPart, "Throwing Strike VFX", character, "Grab")
	task.wait(Config.END_LAG)

	if ThrowingStrikeServer.Id[player.UserId] ~= v2 then
		return
	end

	cleanIt:Clean()
end

function ThrowingStrikeServer.Cancel(player, _: Vector3?, p)
	local cleanIt = p.CleanIt or cleanit.new()
	p.CleanIt = cleanIt
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and character then
		EffectsEvent.ToAllInRange(humanoidRootPart, "Throwing Strike VFX", character, "Cancel")
	end

	showItem(p) -- equivalent call inferred; original call site unknown
	cleanIt:Clean()
end

return ThrowingStrikeServer