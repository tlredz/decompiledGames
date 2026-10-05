local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local ReaperSlashServer = {
	Id = {}
}
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local Checker = require(ReplicatedStorage.CAM.Global.Checker)
local Combat_Util = require(ServerStorage.SAM.Services.Combat_Util)
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local ManuelCancel = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.ManuelCancel)
local hit_priority_handler = require(ServerStorage.SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local Config = require(script.Parent.Config)
local name = script.Parent.Name
local v2 = Config.MAX_RANGE + 20

function ReaperSlashServer.Hold(player, _)
	if not player then
		return
	end

	local character = player.Character

	if not character then
		return
	end

	EffectsEvent.ToAllInRange(player, "ReaperSlash_effs", character, "Hold")
end

function ReaperSlashServer.UnHold(player, _)
	if not player then
		return
	end

	local character = player.Character

	if not (character and character:FindFirstChild("HumanoidRootPart")) then
		return
	end

	EffectsEvent.ToAllInRange(player, "ReaperSlash_effs", character, "Start")
end

function ReaperSlashServer.UnHoldAfterClient(player, _, _, data, p)
	if not player then
		return
	end

	local character = player.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if typeof(data) ~= "CFrame" or not humanoidRootPart then
		ReaperSlashServer.Cancel(player)
		return
	end

	local v3 = data.Position - humanoidRootPart.Position
	local magnitude = v3.Magnitude

	if magnitude ~= magnitude or magnitude == 1e999 then
		ReaperSlashServer.Cancel(player)
		return
	end

	if v2 < magnitude then
		data = data.Rotation + (humanoidRootPart.Position + v3 / magnitude * v2)
	end

	p.Value_Table = {}
	local v4, v5 = ManuelCancel.new(player)
	v4:Connect(function()
		if player and player.Parent == game.Players then
			ReaperSlashServer.Id[player.UserId] = 0
			ReaperSlashServer.Cancel(player)
			v5()
		end
	end)
	local IMPACT_HITBOX_SIZE = Config.IMPACT_HITBOX_SIZE
	local v6 = data.LookVector * createVector(1, 0, 1)

	if v6.Magnitude < 0.01 then
		v6 = humanoidRootPart.CFrame.LookVector * createVector(1, 0, 1)
	end

	local unit = v6.Unit
	local v7 = CFrame.lookAt(data.Position, data.Position + unit) * Config.IMPACT_HITBOX_OFFSET
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local v8 = (not humanoid and 2 or humanoid.HipHeight) + humanoidRootPart.Size.Y / 2
	local raycastResult = workspace:Raycast(
		v7.Position + Vector3.new(0, Config.IMPACT_GROUND_PROBE_UP, 0),
		Vector3.new(0, -(Config.IMPACT_GROUND_PROBE_UP + Config.IMPACT_GROUND_PROBE_DOWN), 0),
		RaycastHelper.Ground
	)
	local position

	if raycastResult then
		position = raycastResult.Position
	else
		position = v7.Position - Vector3.new(0, v8, 0)
	end

	local cframe = CFrame.lookAt(position, position + unit)
	local hitboxCFrame = cframe + Vector3.new(0, IMPACT_HITBOX_SIZE.Y / 2, 0)
	local v10 = cframe + Vector3.new(0, v8, 0)
	EffectsEvent.ToAllInRange(player, "ReaperSlash_effs", character, "End", v10)

	local function fn(instance, p2, p3)
		if not instance then
			return
		end

		local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart2 then
			return
		end

		if p3 == "Blocking" then
			Combat_Util.Block(script, character, instance, Config.IMPACT_BLOCK_BREAK)
		elseif p3 == "Perfect" then
			Combat_Util.Perfect(script, character, instance)
		elseif p3 == true then
			Combat_Util.Damage(script, character, instance, {
				Base = Config.IMPACT_DAMAGE,
				Skill = name
			})
			Combat_Util.RagDoll(script, character, p2, Config.IMPACT_RAGDOLL)
			Combat_Util.AddStun(script, character, p2, Config.IMPACT_RAGDOLL)
			local v11 = humanoidRootPart.CFrame.LookVector * Config.IMPACT_KNOCKBACK
			Combat_Util.Knockback(
				script,
				character,
				humanoidRootPart2,
				Vector3.new(v11.X, Config.IMPACT_KNOCKUP, v11.Z),
				Config.IMPACT_KNOCK_DURATION
			)
		end
	end

	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = hitboxCFrame,
		hitboxSize = IMPACT_HITBOX_SIZE,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = fn
	})
	v5()
end

function ReaperSlashServer.Cancel(player)
	if not player then
		return
	end

	ReaperSlashServer.Id[player.UserId] = nil
	local character = player.Character

	if character then
		EffectsEvent.ToAllInRange(player, "ReaperSlash_effs", character, "Cancel")
	end
end

return ReaperSlashServer