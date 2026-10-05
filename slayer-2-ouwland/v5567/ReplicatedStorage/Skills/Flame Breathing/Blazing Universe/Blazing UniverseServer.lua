local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
game:GetService("RunService")
game:GetService("TweenService")
game:GetService("CollectionService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage:WaitForChild("CAM")
local SAM = ServerStorage:WaitForChild("SAM")
local global = CAM:WaitForChild("Global")
local services = SAM:WaitForChild("Services")
local EffectsEvent = require(ReplicatedStorage2.Communication.ServerAndClient.Effects.EffectsEvent)
local Utility = require(global.Utility)
require(global.Checker)
local RaycastHelper = require(global.RaycastHelper)
local Combat_Util = require(services.Combat_Util)
local ImpactSounds = require(SAM.Utility.ImpactSounds)
require(CAM.Global.Combat_presets)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
require(global.Subsets.Gameplay.ManuelCancel)
require(CAM.Client.Modules.Effects.vfxUtility)
require(CAM:FindFirstChild("DebrisModule"))
require(SAM:FindFirstChild("Game_Play"):FindFirstChild("Cutscene_camera_handler"))
require(global.Subsets.Gameplay.CharGrabPosCorrector)
local Checker = require(ReplicatedStorage2.CAM.Global.Checker)
local Config = require(script.Parent.Config)
local ServerStorage2 = game:GetService("ServerStorage")
local Server_Mouse_Pos = require(ServerStorage2.SAM.Services.Server_Mouse_Pos)
local _ = Vector3.new
local _ = tick
local BlazingUniverseServer = {}
BlazingUniverseServer.Id = {}

function BlazingUniverseServer.Hold(player, _, _)
	if not player then
		return
	end

	local character = player.Character

	if not character then
		return
	end

	EffectsEvent.ToAllInRange(player, "Blazing UniverseVFX", character, "Start")
end

function BlazingUniverseServer.UnHoldAfterClient(player, _, _, p, _)
	if not player then
		return
	end

	local character = player.Character

	if not (character and typeof(p) == "CFrame") then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local clamped = Server_Mouse_Pos.Clamp(character, p.Position, Config.AIM_RANGE + 15)

	if clamped == nil then
		return
	end

	local v2 = p.Rotation + clamped
	character:WaitForChild("Humanoid")
	EffectsEvent.ToAllInRange(player, "Blazing UniverseVFX", character, "Slam", v2)
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = v2 * Config.SLAM_HITBOX_OFFSET,
		hitboxSize = Config.SLAM_HITBOX_SIZE,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		TreeDestruction = true,
		hitDetected = function(instance, p2, p3)
			if instance then
				local rootPart = instance:FindFirstChild("Humanoid").RootPart

				if p3 == "Blocking" then
					Combat_Util.Block(script, character, instance, Config.SLAM_BLOCK_BREAK)
				elseif p3 == "Perfect" then
					Combat_Util.Perfect(script, character, instance)
				elseif p3 == true then
					local v3 = humanoidRootPart.CFrame.LookVector * Config.SLAM_KNOCKBACK + vector.create(
						0,
						Config.SLAM_KNOCKUP,
						0
					)
					Combat_Util.AddStun(script, character, p2, Config.SLAM_STUN)
					Combat_Util.Damage(script, character, instance, {
						Base = Config.SLAM_DAMAGE,
						Skill = script.Parent.Name
					})
					Combat_Util.Knockback(script, character, rootPart, v3, 0.2)
					Combat_Util.RagDoll(script, character, p2, Config.SLAM_RAGDOLL)
				end
			end
		end,
		After = function(p2, list)
			if p2 then
				ImpactSounds.Play(character, script.Parent.Name, list[1])
			end
		end
	})
end

function BlazingUniverseServer.UnHold(player, _, _)
	if not player then
		return
	end

	local character = player.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not (humanoidRootPart and character:FindFirstChild("Animator", true)) then
		return
	end

	local cFrame = humanoidRootPart.CFrame
	local raycastResult = workspace:Raycast(humanoidRootPart.Position, createVector(0, -15, 0), RaycastHelper.Crater)

	if raycastResult ~= nil then
		cFrame = CFrame.lookAlong(raycastResult.Position + createVector(0, 3, 0), humanoidRootPart.CFrame.LookVector)
	end

	EffectsEvent.ToAllInRange(player, "Blazing UniverseVFX", character, "Jump", cFrame)
end

function BlazingUniverseServer.Cancel(player, _, _)
	if not player then
		return
	end

	local character = player.Character

	if not character then
		return
	end

	if character:FindFirstChild("HumanoidRootPart") then
	end
end

return BlazingUniverseServer