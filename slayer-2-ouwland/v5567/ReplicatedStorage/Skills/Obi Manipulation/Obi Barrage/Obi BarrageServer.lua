local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ObiBarrageServer = {
	Id = {}
}
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local Combat_Util = require(game.ServerStorage:WaitForChild("SAM"):WaitForChild("Services"):WaitForChild("Combat_Util"))
local Server_Mouse_Pos = require(game.ServerStorage:WaitForChild("SAM"):WaitForChild("Services"):WaitForChild("Server_Mouse_Pos"))
require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local ManuelCancel = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Subsets"):WaitForChild("Gameplay"):WaitForChild("ManuelCancel"))
local Utility = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Utility"))
local hit_priority_handler = require(game.ServerStorage:WaitForChild("SAM"):WaitForChild("Game_Play"):WaitForChild("hit_priority_handler"))
local v = hit_priority_handler.new(script)
local Checker = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Checker"))
local Combat_presets = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Combat_presets"))
local Character_info_provider = require(ReplicatedStorage.CAM.Global.Character_info_provider)
local Config = require(script.Parent.Config)

function ObiBarrageServer.Hold(player, _, p)
	local v2 = ObiBarrageServer.Id[player.UserId]

	if player ~= nil and player.Character then
		local character = player.Character
		local create_Pos_Part = Server_Mouse_Pos.Create_Pos_Part(character, script.Name, 10)
		local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
		character:WaitForChild("Humanoid")

		if p.bp then
			p.bp:Destroy()
			p.bp = nil
		end

		task.delay(Config.FLOAT_START_AT, function()
			if v2 == ObiBarrageServer.Id[player.UserId] and humanoidRootPart then
				EffectsEvent.ToAllInRange(character, "ObiBarrage_effs", character, "Start")
				p.bp = Combat_Util.Add_air_combo_bp(
					humanoidRootPart,
					nil,
					Config.FLOAT_HEIGHT,
					nil,
					Config.FLOAT_DURATION
				)
			end
		end)
		task.delay(Config.BARRAGE_START_AT, function()
			if v2 ~= ObiBarrageServer.Id[player.UserId] then
				return
			end

			EffectsEvent.ToAllInRange(character, "ObiBarrage_effs", character, "Barrage")

			local function fn(instance, p2, p3)
				local humanoid = instance:FindFirstChild("Humanoid")
				local rootPart = humanoid.RootPart
				local animator = humanoid:FindFirstChild("Animator")

				if p3 == "Perfect" then
					Combat_Util.Perfect(script, character, instance)
				elseif p3 == "Blocking" then
					Combat_Util.Block(script, character, instance, Config.BARRAGE_BLOCK_BREAK)
				elseif p3 == true then
					Combat_Util.AddStun(script, character, p2, Config.BARRAGE_STUN)
					Combat_Util.Damage(script, character, instance, {
						Base = Config.BARRAGE_DAMAGE,
						Skill = script.Parent.Name
					})
					Combat_presets.stop_extra_anims(humanoid)
					local v3 = math.random(1, 5)
					local v4 = v3 == 5 and 6 or v3
					local track = animator:LoadAnimation(Character_info_provider.get_core_anim(
						character,
						"React_" .. v4
					))
					track:AdjustSpeed(2.25)
					track:Play()
					local vector = Vector3.new(0, Config.BARRAGE_KNOCKUP, 0)
					Combat_Util.Knockback(script, character, rootPart, vector, Config.BARRAGE_KNOCKUP_DUR)
				end
			end

			Utility.getvaluesfolder(character)
			local position = humanoidRootPart.Position

			while v2 == ObiBarrageServer.Id[player.UserId] and create_Pos_Part and humanoidRootPart.Parent ~= nil do
				Utility.CreateHitbox({
					caster = character,
					hitboxSize = Config.BARRAGE_HITBOX_SIZE,
					hitboxCFrame = CFrame.new(position.X, humanoidRootPart.Position.Y, position.Z) * Utility.SafeLookAt(
						humanoidRootPart.Position,
						create_Pos_Part.Position,
						humanoidRootPart.CFrame
					).Rotation * Config.BARRAGE_HITBOX_OFFSET,
					hitPriorityHandler = {
						callback = v.Exists,
						data = "Choosing_1"
					},
					checker = Checker,
					hitDetected = fn
				})
				task.wait(Config.BARRAGE_TICK_INTERVAL)
			end
		end)
	end
end

function ObiBarrageServer.UnHold(player, p, p2)
	local v2 = ObiBarrageServer.Id[player.UserId]

	if player ~= nil and player.Character then
		local character = player.Character
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		Server_Mouse_Pos.Delete_Pos_Part(character, script.Name)
		local v3, v4 = ManuelCancel.new(player, Config.FINAL_CANCEL_WINDOW)
		v3:Connect(function()
			if player and player.Parent == game.Players then
				ObiBarrageServer.Id[player.UserId] = 0
			end

			if p2.bp then
				p2.bp:Destroy()
				p2.bp = nil
			end

			EffectsEvent.ToAllInRange(character, "ObiBarrage_effs", character, "Cancel")
			v4()
		end)
		task.wait(Config.FINAL_VFX_AT)

		if v2 ~= ObiBarrageServer.Id[player.UserId] then
			return
		end

		EffectsEvent.ToAllInRange(character, "ObiBarrage_effs", character, "Final")
		task.wait(Config.FINAL_HIT_DELAY)

		local function fn(instance, p3, p4)
			local humanoid = instance:FindFirstChild("Humanoid")
			local rootPart = humanoid.RootPart
			humanoid:FindFirstChild("Animator")

			if p4 == "Perfect" then
				Combat_Util.Perfect(script, character, instance)
			elseif p4 == "Blocking" then
				Combat_Util.Block(script, character, instance, Config.FINAL_BLOCK_BREAK)
			elseif p4 == true then
				Combat_Util.AddStun(script, character, p3, Config.FINAL_STUN)
				Combat_Util.Damage(script, character, instance, {
					Base = Config.FINAL_DAMAGE,
					Skill = script.Parent.Name
				})
				local v5 = (humanoidRootPart.CFrame.lookVector + Vector3.new(0, Config.FINAL_KNOCKUP, 0)) * Config.FINAL_KNOCKBACK
				Combat_Util.Knockback(script, character, rootPart, v5, 0.2)
				Combat_Util.RagDoll(script, character, p3, Config.FINAL_RAGDOLL)
			end
		end

		local getvaluesfolder = Utility.getvaluesfolder(character)
		Utility.CreateHitbox({
			caster = character,
			hitboxSize = Config.FINAL_HITBOX_SIZE,
			hitboxCFrame = CFrame.lookAt(humanoidRootPart.Position, p) * Config.FINAL_HITBOX_OFFSET,
			hitPriorityHandler = {
				callback = v.Both,
				data = {
					pv = getvaluesfolder,
					name = "Choosing_1"
				}
			},
			checker = Checker,
			hitDetected = fn
		})
		task.wait(Config.FINAL_FLOAT_LINGER)

		if p2.bp then
			p2.bp:Destroy()
			p2.bp = nil
		end
	end
end

function ObiBarrageServer.Cancel(player, _, p)
	if player ~= nil and player.Character then
		local character = player.Character
		EffectsEvent.ToAllInRange(character, "ObiBarrage_effs", character, "Cancel")
		Server_Mouse_Pos.Delete_Pos_Part(character, script.Name)

		if p.bp then
			p.bp:Destroy()
			p.bp = nil
		end
	end
end

return ObiBarrageServer