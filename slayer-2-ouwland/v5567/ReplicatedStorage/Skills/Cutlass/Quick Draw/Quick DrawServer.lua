local ReplicatedStorage = game:GetService("ReplicatedStorage")
local QuickDrawServer = {
	Id = {}
}
local Checker = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Checker"))
local Combat_Util = require(game.ServerStorage:WaitForChild("SAM"):WaitForChild("Services"):WaitForChild("Combat_Util"))
local Utility = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Utility"))
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local ManuelCancel = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.ManuelCancel)
local hit_priority_handler = require(game.ServerStorage:WaitForChild("SAM"):WaitForChild("Game_Play"):WaitForChild("hit_priority_handler"))
local v = hit_priority_handler.new(script)
local Combat_presets = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Combat_presets"))
local Config = require(script.Parent.Config)
local script2 = script

local function barrage(cframe: CFrame, instance, targets)
	local BARRAGE_BLOCK_BREAK = Config.BARRAGE_BLOCK_BREAK
	local lookVector = instance.PrimaryPart.CFrame.lookVector
	Utility.getvaluesfolder(instance)
	local BARRAGE_HIT_COUNT = Config.BARRAGE_HIT_COUNT
	local BARRAGE_INTERVAL = Config.BARRAGE_INTERVAL

	for i = 1, BARRAGE_HIT_COUNT do
		local v2 = i
		Utility.CreateHitbox({
			caster = instance,
			hitboxCFrame = cframe,
			hitboxSize = Config.BARRAGE_HITBOX_SIZE,
			targets = targets,
			checker = Checker,
			hitPriorityHandler = {
				callback = v.Exists,
				data = "Choosing_1"
			},
			hitDetected = function(instance2, p, p2)
				local humanoidRootPart = instance2:FindFirstChild("HumanoidRootPart")
				local humanoid = instance2:FindFirstChild("Humanoid")

				if not (humanoidRootPart and humanoid) then
					return false
				end

				if p2 == "Blocking" or p2 == "Perfect" then
					Combat_Util.Block(script2, instance, instance2, BARRAGE_BLOCK_BREAK)
				elseif p2 == true then
					if not table.find(targets, instance2) then
						table.insert(targets, instance2)
					end

					Combat_Util.Damage(script2, instance, instance2, {
						Base = Config.BARRAGE_TOTAL_DAMAGE / BARRAGE_HIT_COUNT,
						Skill = script.Parent.Name
					})

					if v2 == BARRAGE_HIT_COUNT then
						Combat_Util.Add_Strict_Stun(script2, instance, p, Config.FINAL_STUN)
						Combat_Util.RagDoll(script2, instance, p, Config.FINAL_RAGDOLL)
						local v3 = lookVector * Config.FINAL_KNOCKBACK
						Combat_Util.Knockback(
							script2,
							instance,
							humanoidRootPart,
							Vector3.new(v3.X, Config.FINAL_KNOCKUP, v3.Z),
							0.15
						)
					else
						Combat_Util.Add_Strict_Stun(script2, instance, p, Config.BARRAGE_STUN)
						Combat_presets.PlayReactAnim(humanoid)
						local v3 = lookVector * Config.BARRAGE_KNOCKBACK
						Combat_Util.Knockback(
							script2,
							instance,
							humanoidRootPart,
							Vector3.new(v3.X, Config.BARRAGE_KNOCKUP, v3.Z),
							0.15
						)
					end
				end

				return false
			end
		})
		task.wait(BARRAGE_INTERVAL)
	end
end

function QuickDrawServer.Hold(player)
	if player == nil then
		return
	end

	local _ = QuickDrawServer.Id[player.UserId]
	local character = player.Character

	if character == nil then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")

	if humanoidRootPart == nil or humanoid == nil then
		return
	end

	task.wait(Config.MIN_HOLD_DUR)
end

function QuickDrawServer.UnHold(player, p)
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
		return
	end

	local v2 = p and Utility.SafeLookAt(
		humanoidRootPart.Position,
		Vector3.new(p.X, humanoidRootPart.Position.Y, p.Z),
		humanoidRootPart.CFrame
	) or humanoidRootPart.CFrame
	local SLICE_HITBOX_SIZE = Config.SLICE_HITBOX_SIZE
	local hitboxCFrame = v2 * Config.SLICE_HITBOX_OFFSET
	local v4, v5 = ManuelCancel.new(player, Config.SLICE_HIT_AT, nil, script.Parent.Name)
	local flag = false
	v4:Connect(function()
		flag = true
	end)
	EffectsEvent.ToAllInRange(player, "QuickDraw_effs", character, "Slice")
	task.wait(Config.SLICE_HIT_AT)
	v5()

	if flag then
		return
	end

	local SLICE_BLOCK_BREAK = Config.SLICE_BLOCK_BREAK
	local getvaluesfolder = Utility.getvaluesfolder(character)
	local v6 = false
	local instances = {}
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = hitboxCFrame,
		hitboxSize = SLICE_HITBOX_SIZE,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Both,
			data = {
				pv = getvaluesfolder,
				name = "Choosing_1"
			}
		},
		hitDetected = function(instance, p2, p3)
			local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")
			local humanoid2 = instance:FindFirstChild("Humanoid")

			if not (humanoidRootPart2 and humanoid2) then
				return false
			end

			if p3 == "Blocking" then
				Combat_Util.Block(script2, character, instance, SLICE_BLOCK_BREAK)
			else
				if p3 == "Perfect" then
					Combat_Util.Perfect(script2, character, instance)
					return true
				end

				if p3 == true then
					table.insert(instances, instance)

					if not v6 then
						EffectsEvent.ToAllInRange(player, "QuickDraw_effs", instance, "Barrage")
						v6 = true
						task.spawn(barrage, humanoidRootPart2.CFrame, character, instances)
					end

					Combat_Util.Add_Strict_Stun(script2, character, p2, Config.SLICE_STUN)
					Combat_Util.Damage(script2, character, instance, {
						Base = Config.SLICE_DAMAGE,
						Skill = script.Parent.Name
					})
				end
			end

			return false
		end
	})
end

function QuickDrawServer.Cancel(player)
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

return QuickDrawServer