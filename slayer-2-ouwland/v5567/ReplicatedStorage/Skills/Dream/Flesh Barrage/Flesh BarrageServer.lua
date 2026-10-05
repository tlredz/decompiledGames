local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local Server_Mouse_Pos = require(SAM.Services.Server_Mouse_Pos)
local Checker = require(CAM.Global.Checker)
local Utility = require(CAM.Global.Utility)
local Combat_Util = require(SAM.Services.Combat_Util)
local Combat_presets = require(CAM.Global.Combat_presets)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local Config = require(script.Parent.Config)
local FleshBarrageServer = {
	Id = {},
	Hold = function(player, _: Vector3?, p)
		local cleanIt = p.CleanIt or cleanit.new()
		p.CleanIt = cleanIt
		cleanIt:Clean()
		local character = player.Character
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		Server_Mouse_Pos.Create_Pos_Part(character, script.Parent.Name, 4)
		cleanIt:Add(function()
			Server_Mouse_Pos.Delete_Pos_Part(character, script.Parent.Name)
		end)
		EffectsEvent.ToAllInRange(humanoidRootPart, "FleshBarrage VFX", character, "Startup")
	end
}

function FleshBarrageServer.UnHold(player, vector: Vector3, p)
	local cleanIt = p.CleanIt or cleanit.new()
	p.CleanIt = cleanIt
	local v2 = FleshBarrageServer.Id[player.UserId]
	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local _, v3 = Server_Mouse_Pos.Aim(character, script.Parent.Name, Config.MOUSE_RANGE, vector)
	local v4 = v3 or humanoidRootPart.CFrame * CFrame.new(0, 0, -Config.MOUSE_RANGE)
	local position = v4.Position
	local v5 = {}

	local function spawnTentacle(cframe: CFrame)
		EffectsEvent.ToAllInRange(humanoidRootPart, "FleshBarrage VFX", character, "Tentacle", cframe)
		task.delay(Config.RELEASE_TO_HITBOX, function()
			if v2 ~= FleshBarrageServer.Id[player.UserId] or humanoidRootPart.Parent == nil then
				return
			end

			local position2 = cframe.Position
			local lookVector = cframe.lookVector
			local v6 = position2 + lookVector * (Config.TENTACLE_HEIGHT / 2)
			local cframe2 = CFrame.lookAt(v6, v6 + lookVector)
			local vector2 = Vector3.new(
				Config.TENTACLE_HITBOX_WIDTH,
				Config.TENTACLE_HITBOX_WIDTH,
				Config.TENTACLE_HEIGHT
			)
			Utility.CreateHitbox({
				caster = character,
				hitboxCFrame = cframe2,
				hitboxSize = vector2,
				checker = Checker,
				hitPriorityHandler = {
					callback = v.Exists,
					data = "Choosing_1"
				},
				hitDetected = function(instance, p2, p3)
					if not instance then
						return
					end

					local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")

					if not humanoidRootPart2 then
						return
					end

					local v7 = v5[instance] or 0

					if Config.TENTACLE_HIT_CAP <= v7 then
						return
					end

					v5[instance] = v7 + 1

					if p3 == "Blocking" or p3 == "Perfect" then
						Combat_Util.Block(script, character, instance, Config.BARRAGE_BLOCK_BREAK)
					elseif p3 == true then
						Combat_Util.Damage(script, character, instance, {
							Base = Config.BARRAGE_DAMAGE,
							Skill = script.Parent.Name
						})
						Combat_Util.AddStun(script, character, p2, Config.BARRAGE_STUN)
						Combat_presets.PlayReactAnim(instance:FindFirstChild("Humanoid"), nil, nil)
						EffectsEvent.ToAllInRange(humanoidRootPart, "Normal_Punch_Effect", humanoidRootPart2, -1)
					end
				end
			})
		end)
	end

	for _ = 1, Config.TENTACLE_COUNT do
		if v2 ~= FleshBarrageServer.Id[player.UserId] or humanoidRootPart.Parent == nil then
			return
		end

		local v6 = math.random(-Config.TENTACLE_RADIUS, Config.TENTACLE_RADIUS)
		local v7 = math.random(-Config.TENTACLE_RADIUS, Config.TENTACLE_RADIUS)
		local v8 = v4.RightVector * v6 + v4.UpVector * v7
		local cframe = CFrame.Angles(
			math.rad((math.random(-Config.TENTACLE_ANGLE, Config.TENTACLE_ANGLE))),
			0,
			(math.rad((math.random(-Config.TENTACLE_ANGLE, Config.TENTACLE_ANGLE))))
		)
		local v9 = CFrame.new(position + v8, position + v8 + v4.LookVector) * cframe
		EffectsEvent.ToAllInRange(humanoidRootPart, "FleshBarrage VFX", character, "Tentacle", v9)
		task.delay(Config.RELEASE_TO_HITBOX, function()
			if v2 ~= FleshBarrageServer.Id[player.UserId] or humanoidRootPart.Parent == nil then
				return
			end

			local position2 = v9.Position
			local lookVector = v9.lookVector
			local v11 = position2 + lookVector * (Config.TENTACLE_HEIGHT / 2)
			local cframe2 = CFrame.lookAt(v11, v11 + lookVector)
			local vector2 = Vector3.new(
				Config.TENTACLE_HITBOX_WIDTH,
				Config.TENTACLE_HITBOX_WIDTH,
				Config.TENTACLE_HEIGHT
			)
			Utility.CreateHitbox({
				caster = character,
				hitboxCFrame = cframe2,
				hitboxSize = vector2,
				checker = Checker,
				hitPriorityHandler = {
					callback = v.Exists,
					data = "Choosing_1"
				},
				hitDetected = function(instance, p2, p3)
					if not instance then
						return
					end

					local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")

					if not humanoidRootPart2 then
						return
					end

					local v12 = v5[instance] or 0

					if Config.TENTACLE_HIT_CAP <= v12 then
						return
					end

					v5[instance] = v12 + 1

					if p3 == "Blocking" or p3 == "Perfect" then
						Combat_Util.Block(script, character, instance, Config.BARRAGE_BLOCK_BREAK)
					elseif p3 == true then
						Combat_Util.Damage(script, character, instance, {
							Base = Config.BARRAGE_DAMAGE,
							Skill = script.Parent.Name
						})
						Combat_Util.AddStun(script, character, p2, Config.BARRAGE_STUN)
						Combat_presets.PlayReactAnim(instance:FindFirstChild("Humanoid"), nil, nil)
						EffectsEvent.ToAllInRange(humanoidRootPart, "Normal_Punch_Effect", humanoidRootPart2, -1)
					end
				end
			})
		end)
		task.wait(Config.TENTACLE_INTERVAL)
	end

	if v2 ~= FleshBarrageServer.Id[player.UserId] or humanoidRootPart.Parent == nil then
		return
	end

	cleanIt:Clean()
end

function FleshBarrageServer.Cancel(player, _: Vector3?, p)
	local cleanIt = p.CleanIt or cleanit.new()
	p.CleanIt = cleanIt
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and character then
		EffectsEvent.ToAllInRange(humanoidRootPart, "FleshBarrage VFX", character, "Cancel")
	end

	cleanIt:Clean()
end

return FleshBarrageServer