local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DoubleCutServer = {
	Id = {}
}
require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Utility"))
local Checker = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Checker"))
local Combat_Util = require(game.ServerStorage:WaitForChild("SAM"):WaitForChild("Services"):WaitForChild("Combat_Util"))
local Utility = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Utility"))
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local _ = table.find
local _ = table.insert
local hit_priority_handler = require(game.ServerStorage:WaitForChild("SAM"):WaitForChild("Game_Play"):WaitForChild("hit_priority_handler"))
local v = hit_priority_handler.new(script)
local ManuelCancel = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.ManuelCancel)
local Config = require(script.Parent.Config)

function DoubleCutServer.Hold(_, _) end

function DoubleCutServer.UnHold(player, p)
	if player == nil then
		return
	end

	local v2 = DoubleCutServer.Id[player.UserId]
	local character = player.Character

	if character == nil then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")

	if humanoidRootPart == nil or humanoid == nil then
		return
	end

	local BASE_DAMAGE = Config.BASE_DAMAGE
	EffectsEvent.ToAllInRange(player, "DoubleCut_effs", character, p, "First")
	local v3 = {}
	task.delay(0.05, function()
		if v2 ~= DoubleCutServer.Id[player.UserId] then
			return
		end

		local safeLookAt = Utility.SafeLookAt(
			humanoidRootPart.Position,
			Vector3.new(p.X, humanoidRootPart.Position.Y, p.Z),
			humanoidRootPart.CFrame
		)
		local FIRST_HITBOX_SIZE = Config.FIRST_HITBOX_SIZE
		local modelInRegion = Utility.GetModelInRegion(safeLookAt, FIRST_HITBOX_SIZE, nil, nil)
		local FIRST_BLOCK_BREAK = Config.FIRST_BLOCK_BREAK
		local getvaluesfolder = Utility.getvaluesfolder(character)
		local v4 = false

		for _, v5 in modelInRegion do
			if v4 == true then
				break
			end

			if not (v5 ~= character and v5:FindFirstChild("Humanoid") ~= nil) then
				continue
			end

			local humanoidRootPart2 = v5:FindFirstChild("HumanoidRootPart")
			local humanoid2 = v5:FindFirstChild("Humanoid")
			local check_victim, _ = Checker.check_victim(script, character, v5)
			local getvaluesfolder2 = Utility.getvaluesfolder(v5)

			if v.Both(getvaluesfolder2, {
				pv = getvaluesfolder,
				name = "Choosing_1"
			}) == true then
				continue
			end

			local humanoidRootPart3 = character:FindFirstChild("HumanoidRootPart")

			if not (humanoidRootPart2 ~= nil and humanoid2 ~= nil and humanoidRootPart3 ~= nil) then
				continue
			end

			if check_victim == "Blocking" then
				Combat_Util.Block(script, character, v5, FIRST_BLOCK_BREAK)
			elseif check_victim == "Perfect" then
				Combat_Util.Perfect(script, character, v5)
				v4 = true
			elseif check_victim == true then
				table.insert(v3, v5)
				local v6 = humanoidRootPart.CFrame.rightVector * -Config.FIRST_KNOCKBACK
				EffectsEvent.ToAllInRange(player, "Normal_Sword_Slash_Effect", humanoidRootPart2)
				Combat_Util.AddStun(script, character, getvaluesfolder2, Config.FIRST_STUN)
				Combat_Util.Damage(script, character, v5, {
					Base = BASE_DAMAGE / 2,
					Skill = script.Parent.Name
				})
				Combat_Util.Knockback(
					script,
					character,
					humanoidRootPart2,
					Vector3.new(v6.X, Config.FIRST_KNOCKUP, v6.Z),
					Config.FIRST_KNOCK_DURATION
				)
			end
		end
	end)
	local v4, v5 = ManuelCancel.new(player, Config.CANCEL_WINDOW)
	v4:Connect(function()
		DoubleCutServer.Id[player.UserId] = nil
	end)
	task.wait(Config.SECOND_DELAY)

	if v2 ~= DoubleCutServer.Id[player.UserId] then
		return
	end

	v5()
	EffectsEvent.ToAllInRange(player, "DoubleCut_effs", character, p, "Second")
	local SECOND_DURATION = Config.SECOND_DURATION
	local SECOND_STEP_COUNT = Config.SECOND_STEP_COUNT
	local SECOND_DISTANCE = Config.SECOND_DISTANCE
	local cFrame = humanoidRootPart.CFrame
	local v6 = SECOND_DISTANCE / SECOND_STEP_COUNT
	local flag = false
	local v7 = {}

	for i = 1, SECOND_STEP_COUNT do
		if flag then
			break
		end

		local v8 = cFrame * CFrame.new(0, 0, -(v6 * i))
		local vector = Vector3.new(Config.SECOND_HITBOX_WIDTH, Config.SECOND_HITBOX_WIDTH, v6)
		local modelInRegion = Utility.GetModelInRegion(v8, vector, nil, nil)
		local SECOND_BLOCK_BREAK = Config.SECOND_BLOCK_BREAK
		local getvaluesfolder = Utility.getvaluesfolder(character)

		for _, v9 in v3 do
			if table.find(modelInRegion, v9) == nil then
				table.insert(modelInRegion, v9)
			end
		end

		for _, v9 in modelInRegion do
			if flag == true then
				break
			end

			if table.find(v7, v9) then
				continue
			end

			table.insert(v7, v9)

			if not (v9 ~= character and v9:FindFirstChild("Humanoid") ~= nil) then
				continue
			end

			local humanoidRootPart2 = v9:FindFirstChild("HumanoidRootPart")
			local humanoid2 = v9:FindFirstChild("Humanoid")
			local check_victim, _ = Checker.check_victim(script, character, v9)
			local getvaluesfolder2 = Utility.getvaluesfolder(v9)

			if v.Both(getvaluesfolder2, {
				pv = getvaluesfolder,
				name = "Choosing_1"
			}) == true then
				continue
			end

			local humanoidRootPart3 = character:FindFirstChild("HumanoidRootPart")

			if not (humanoidRootPart2 ~= nil and humanoid2 ~= nil and humanoidRootPart3 ~= nil) then
				continue
			end

			if check_victim == "Blocking" then
				Combat_Util.Block(script, character, v9, SECOND_BLOCK_BREAK)
			elseif check_victim == "Perfect" then
				Combat_Util.Perfect(script, character, v9)
				flag = true
			elseif check_victim == true then
				local v10 = v8.lookVector * Config.SECOND_KNOCKBACK
				EffectsEvent.ToAllInRange(player, "Normal_Sword_Slash_Effect", humanoidRootPart2)
				Combat_Util.AddStun(script, character, getvaluesfolder2, Config.SECOND_STUN)
				Combat_Util.Damage(script, character, v9, {
					Base = BASE_DAMAGE,
					Skill = script.Parent.Name
				})
				Combat_Util.RagDoll(script, character, getvaluesfolder2, Config.SECOND_RAGDOLL)
				Combat_Util.Knockback(
					script,
					character,
					humanoidRootPart2,
					Vector3.new(v10.X, Config.SECOND_KNOCKUP, v10.Z),
					0.15
				)
			end
		end

		task.wait(SECOND_DURATION / SECOND_STEP_COUNT)
	end
end

function DoubleCutServer.Cancel(player)
	if player == nil then
		return
	end

	local character = player.Character

	if character == nil then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")

	if humanoidRootPart == nil or humanoid == nil then
	end
end

return DoubleCutServer