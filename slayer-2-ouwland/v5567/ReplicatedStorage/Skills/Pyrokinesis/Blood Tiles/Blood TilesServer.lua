local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("CollectionService")
local EffectsEvent = require(ReplicatedStorage2.Communication.ServerAndClient.Effects.EffectsEvent)
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local Checker = require(CAM.Global.Checker)
local Utility = require(CAM.Global.Utility)
require(CAM.Global.Combat_presets)
local DebrisModule = require(CAM.DebrisModule)
local ManuelCancel = require(CAM.Global.Subsets.Gameplay.ManuelCancel)
local RaycastHelper = require(CAM.Global.RaycastHelper)
require(SAM.Utility.SkillStorage)
local Combat_Util = require(SAM.Services.Combat_Util)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local Config = require(script.Parent.Config)
local script2 = script
local BloodTilesServer = {
	Id = {},
	Hold = function(player, _: Vector3, p)
		p.stage = "Hold"
		local character = player.Character
		local rootPart = character:FindFirstChild("Humanoid").RootPart
		EffectsEvent.ToAllInRange(rootPart, "Blood Tiles VFX", character, "Start")
	end
}

function BloodTilesServer.UnHold(player, vector2: Vector3, p)
	p.stage = "Release"
	local character = player.Character
	local getvaluesfolder = Utility.getvaluesfolder(character)
	local rootPart = character:FindFirstChild("Humanoid").RootPart
	local v2, v3 = ManuelCancel.new(player, Config.RELEASE_CANCEL_WINDOW)
	v2:Connect(function()
		BloodTilesServer.Cancel(player, vector2, p)
	end)
	local boolValue = Instance.new("BoolValue")
	boolValue.Name = "pause_gameplay"
	boolValue.Parent = getvaluesfolder
	DebrisModule:AddItem(boolValue, Config.RELEASE_PAUSE_DUR)
	task.wait(Config.TILE1_AT)

	if p.stage == "Cancel" then
		return
	end

	local v4 = 0
	local instances = {}

	local function fn(instance, p2, p3)
		if p3 == "Perfect" then
			Combat_Util.Perfect(script2, character, instance)
			return
		elseif p3 == "Blocking" then
			Combat_Util.Block(script2, character, instance, Config.TILE_BLOCK_BREAK)
			return
		end

		table.insert(instances, instance)
		local rootPart2 = instance:FindFirstChild("Humanoid").RootPart
		Combat_Util.Damage(script2, character, instance, {
			Base = Config.TILE_DAMAGES[v4],
			Skill = script.Parent.Name
		})
		Combat_Util.Add_Strict_Stun(script2, character, p2, Config.TILE_STUN)
		Combat_Util.Knockback(
			script2,
			character,
			rootPart2,
			rootPart.CFrame.LookVector * Config.TILE_KNOCKBACKS[v4][1] + Config.TILE_KNOCKBACKS[v4][2],
			0.15
		)
		Combat_Util.RagDoll(script2, character, p2, Config.TILE_RAGDOLL)
	end

	local v5 = nil

	local function createHitbox(p2: number)
		v4 = p2
		local raycastResult = workspace:Raycast(
			(rootPart.CFrame * Config.TILE_HITBOX_OFFSETS[p2]).Position + createVector(0, 25, 0),
			createVector(0, -36, 0),
			RaycastHelper.Crater
		)
		local cFrame = rootPart.CFrame
		v5 = v5 or cFrame
		local v6 = cFrame * CFrame.new(0, -2.75, 0) * Config.TILE_HITBOX_OFFSETS[p2]
		local hitboxCFrame = Utility.SafeLookAt(v5.Position, v6.Position, v5).Rotation + v6.Position
		v5 = hitboxCFrame
		EffectsEvent.ToAllInRange(
			rootPart,
			"Blood Tiles VFX",
			character,
			"Release",
			p2,
			raycastResult ~= nil and raycastResult.Instance ~= nil and ({
				Instance = raycastResult.Instance,
				Position = raycastResult.Position,
				Normal = raycastResult.Normal
			} or nil) or nil,
			hitboxCFrame
		)
		Utility.CreateHitbox({
			caster = character,
			hitboxSize = Config.TILE_HITBOX_SIZES[p2],
			hitboxCFrame = hitboxCFrame,
			targets = instances,
			checker = Checker,
			hitPriorityHandler = {
				callback = v.Exists,
				data = "Choosing_1"
			},
			hitDetected = fn
		})

		if p2 == 3 then
			v3()
		end
	end

	createHitbox(1)
	task.wait(Config.TILE_INTERVAL)

	if p.stage == "Cancel" then
		return
	end

	createHitbox(2)
	task.wait(Config.TILE_INTERVAL)

	if p.stage == "Cancel" then
		return
	end

	createHitbox(3)
end

function BloodTilesServer.Cancel(player, _: Vector3, p)
	p.stage = "Cancel"
	EffectsEvent.ToAllInRange(player, "Blood Tiles VFX", player.Character, "Cancel")
end

return BloodTilesServer