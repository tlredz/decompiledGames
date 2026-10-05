local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
game:GetService("RunService")
game:GetService("CollectionService")
game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage:WaitForChild("CAM")
local SAM = ServerStorage:WaitForChild("SAM")
local global = CAM:WaitForChild("Global")
local services = SAM:WaitForChild("Services")
local Utility = require(global.Utility)
local Checker = require(global.Checker)
local Combat_Util = require(services.Combat_Util)
local ImpactSounds = require(SAM.Utility.ImpactSounds)
require(CAM.Global.Combat_presets)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local ManuelCancel = require(global.Subsets.Gameplay.ManuelCancel)
local ServerClientPortal = require(global:WaitForChild("ServerClientPortal"))
local Server_Mouse_Pos = require(services.Server_Mouse_Pos)
local DebrisModule = require(CAM:FindFirstChild("DebrisModule"))
local Config = require(script.Parent.Config)
local EffectsEvent = require(ReplicatedStorage2.Communication.ServerAndClient.Effects.EffectsEvent)
local LightningFoldServer = {
	Id = {},
	Hold = function(_, _, _) end
}

function LightningFoldServer.UnHold(player, _, p)
	local character = player.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local air_combo_bp = humanoidRootPart and humanoidRootPart:FindFirstChild("air_combo_bp")

	if air_combo_bp then
		air_combo_bp:Destroy()
	end

	local getvaluesfolder = Utility.getvaluesfolder(character)
	local v2 = LightningFoldServer.Id[player.UserId]
	local v3 = ServerClientPortal.Create(player, script.Parent.Name, Config.STARTUP_DUR + 0.8)
	local v4, _ = ManuelCancel.new(player, 1)
	local stringValue = nil
	local v5 = nil
	v4:Connect(function()
		if v3 and v3.__Active then
			v3:Destroy()
		end

		if p.Invis ~= nil then
			p.Invis:Destroy()
			p.Invis = nil
		end

		if stringValue ~= nil then
			stringValue:Destroy()
			stringValue = nil
		end

		if v5 ~= nil then
			v5:Destroy()
			v5 = nil
		end

		LightningFoldServer.Id[player.UserId] = nil
	end)
	local position

	if humanoidRootPart == nil then
		position = character:GetPivot().Position
	else
		position = humanoidRootPart.Position
	end

	local count = 0
	v3:Connect(function(list)
		if typeof(list) ~= "table" or #list ~= 4 or count >= 6 then
			return
		end

		local v6 = list[1]
		local v7 = list[2]
		local v8 = list[3]
		local v9 = list[4]

		if typeof(v6) ~= "CFrame" or typeof(v7) ~= "CFrame" or typeof(v8) ~= "number" or typeof(v9) ~= "number" then
			return
		end

		local clamped = Server_Mouse_Pos.Clamp(character, v7.Position, Config.RADIUS + 15, position)
		local clamped2 = Server_Mouse_Pos.Clamp(character, v6.Position, Config.RADIUS + 45, position)

		if clamped == nil or clamped2 == nil then
			return
		end

		local v10 = v7.Rotation + clamped
		local v11 = v6.Rotation + clamped2
		count += 1
		local v12 = {
			v11,
			v10,
			math.clamp(v8, -50, 50),
			v9
		}
		EffectsEvent.ToOthersInRange(player, "Thunder_Bell_VFX", character, "Dash" .. count, v12)

		if count == 4 then
			character:PivotTo(v10)
			DebrisModule:AddItem(p.Invis, 0.5)
		end
	end)
	task.wait(Config.STARTUP_DUR)

	if LightningFoldServer.Id[player.UserId] == v2 then
		p.Invis = Instance.new("StringValue")
		p.Invis.Name = "Transparent"
		p.Invis.Value = script.Parent.Name
		p.Invis.Parent = getvaluesfolder
		DebrisModule:AddItem(p.Invis, 2)
		stringValue = Instance.new("StringValue")
		stringValue.Name = "pause_gameplay"
		stringValue.Value = script.Parent.Name
		stringValue.Parent = getvaluesfolder
		DebrisModule:AddItem(stringValue, Config.CAST_DUR)
		v5 = Utility.AddValue(getvaluesfolder, "iframe", Config.CAST_DUR + 1)
	elseif v3 and v3.__Active then
		v3:Destroy()
	end
end

function LightningFoldServer.UnHoldAfterClient(player, p, _, p2)
	if not player then
		return
	end

	local character = player.Character

	if not character or (typeof(p2) ~= "CFrame" or typeof(p) ~= "Vector3") then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local v2 = Utility.SafeDirection(
		Vector3.new(humanoidRootPart.Position.X, 0, humanoidRootPart.Position.Z),
		(Vector3.new(p.X, 0, p.Z))
	) or Vector3.new(humanoidRootPart.CFrame.LookVector.X, 0, humanoidRootPart.CFrame.LookVector.Z).Unit
	local _ = humanoidRootPart.Position + v2 * Config.RADIUS
	local getvaluesfolder = Utility.getvaluesfolder(character)
	local character2 = player.Character
	local _ = LightningFoldServer.Id[player.UserId]
	local clamped = Server_Mouse_Pos.Clamp(character, p2.Position, Config.RADIUS)

	if clamped == nil then
		return
	end

	local v3 = p2.Rotation + clamped
	local position = v3.Position
	EffectsEvent.ToOthersInRange(player, "Thunder_Bell_VFX", character, "Downslam", v3)
	local modelInRegion = Utility.GetModelInRegion(CFrame.new(position), Config.SLAM_HITBOX_SIZE, nil, nil)
	Utility.TreeDestruction({
		CFrame = CFrame.new(position),
		Size = Config.SLAM_HITBOX_SIZE
	})
	local v4 = nil

	for _, v5 in pairs(modelInRegion) do
		if not (v5 ~= character2 and v5:FindFirstChild("Humanoid") ~= nil) then
			continue
		end

		local humanoidRootPart2 = v5:FindFirstChild("HumanoidRootPart")
		local humanoid = v5:FindFirstChild("Humanoid")
		local check_victim, _ = Checker.check_victim(script, character2, v5)
		local getvaluesfolder2 = Utility.getvaluesfolder(v5)

		if v.Both(getvaluesfolder2, {
			pv = getvaluesfolder,
			name = "Choosing_1"
		}) == true then
			continue
		end

		local humanoidRootPart3 = character2:FindFirstChild("HumanoidRootPart")

		if not (humanoidRootPart2 ~= nil and humanoid ~= nil and humanoidRootPart3 ~= nil) then
			continue
		end

		if check_victim == "Perfect" then
			Combat_Util.Perfect(script, character2, v5)
		elseif check_victim == "Blocking" then
			Combat_Util.Block(script, character2, v5, Config.SLAM_BLOCK_BREAK)
		elseif check_victim == true then
			Combat_Util.AddStun(script, character2, getvaluesfolder2, Config.SLAM_STUN)
			Combat_Util.Damage(script, character2, v5, {
				Base = Config.SLAM_DAMAGE,
				Skill = script.Parent.Name
			})
			Combat_Util.RagDoll(script, character2, getvaluesfolder2, Config.SLAM_RAGDOLL)
			local v6 = vector.normalize(humanoidRootPart2.Position - humanoidRootPart.Position) * Config.SLAM_KNOCKBACK
			local vector2 = Vector3.new(v6.X, Config.SLAM_KNOCKUP, v6.Z)
			Combat_Util.Knockback(script, character2, humanoidRootPart2, vector2, Config.SLAM_KNOCKBACK_DUR)
			v4 = v4 or v5
		end
	end

	if v4 ~= nil then
		ImpactSounds.Play(character2, script.Parent.Name, v4)
	end
end

function LightningFoldServer.Cancel(player, _, p)
	if not (player and player.Character) then
		return
	end

	if p ~= nil and p.Invis ~= nil then
		p.Invis:Destroy()
		p.Invis = nil
	end
end

return LightningFoldServer