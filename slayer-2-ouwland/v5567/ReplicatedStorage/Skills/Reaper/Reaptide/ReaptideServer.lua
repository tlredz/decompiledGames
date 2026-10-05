local createVector = vector.create
local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage2 = game:GetService("ServerStorage")
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage:WaitForChild("SAM")
local global = CAM:WaitForChild("Global")
local services = SAM:WaitForChild("Services")
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local Utility = require(global.Utility)
local Combat_Util = require(services.Combat_Util)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local Checker = require(ReplicatedStorage.CAM.Global.Checker)
local Server_Mouse_Pos = require(ServerStorage2.SAM.Services.Server_Mouse_Pos)
local Config = require(script.Parent.Config)
local ServerStorage3 = game:GetService("ServerStorage")
local Server_Mouse_Pos2 = require(ServerStorage3.SAM.Services.Server_Mouse_Pos)
local ReaptideServer = {}
ReaptideServer.Id = {}

function ReaptideServer.Hold(player, _, p)
	if not player then
		return
	end

	local character = player.Character

	if not character then
		return
	end

	Server_Mouse_Pos.Create_Pos_Part(character, script.Parent.Name)
	p.Start = character.HumanoidRootPart.Position
	EffectsEvent.ToAllInRange(player, "Reap Of DespairVFX", player.Character, "Start")
end

function ReaptideServer.UnHoldAfterClient(player, _, _, p, p2)
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

	local clamped = Server_Mouse_Pos2.Clamp(character, p.Position, Config.TARGET_RANGE + 15)

	if clamped == nil then
		return
	end

	local v2 = p.Rotation + clamped
	local humanoid = character:WaitForChild("Humanoid")
	local getvaluesfolder = Utility.getvaluesfolder(player)
	p2.targets = {}
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = v2 * Config.GRAB_HITBOX_OFFSET,
		hitboxSize = Config.GRAB_HITBOX_SIZE,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = function(instance, p3, p4)
			if instance then
				local humanoid2 = instance:FindFirstChild("Humanoid")
				local rootPart = humanoid2.RootPart

				if p4 == "Blocking" then
					Combat_Util.Block(script, character, instance, Config.GRAB_BLOCK_BREAK)
					return
				elseif p4 == "Perfect" then
					Combat_Util.Perfect(script, character, instance)
					return true
				end

				if p4 == true then
					Combat_Util.Damage(script, character, instance, {
						Base = Config.GRAB_DAMAGE,
						Skill = script.Parent.Name
					})
					local v3 = Utility.AddValue(p3, "pause_gameplay", Config.VICTIM_LOCK_DURATION)
					Combat_Util.Cancel(script, p3)
					local ouwWeld = Utility.CreateOuwWeld(humanoidRootPart, rootPart)
					local track = humanoid2.Animator:LoadAnimation(script.Victim)
					track:Play()
					table.insert(p2.targets, {
						ouwWeld,
						track,
						instance,
						v3
					})
				end
			end
		end,
		After = function()
			local v3 = Server_Mouse_Pos.Find(character, script.Parent.Name)

			if #p2.targets > 0 then
				local v4 = Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.CASTER_LOCK_DURATION)
				EffectsEvent.ToAllInRange(player, "ReaptideVFX", character, "Hit", v2)
				humanoid.Animator:LoadAnimation(script.User):Play()
				local attachment = Instance.new("Attachment", humanoidRootPart)
				attachment.Name = "skill_stand_still"
				local alignOrientation = Instance.new("AlignOrientation")
				alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
				alignOrientation.MaxTorque = 20000
				alignOrientation.Responsiveness = 30
				alignOrientation.Attachment0 = attachment
				alignOrientation.Parent = attachment
				local linearVelocity = Instance.new("LinearVelocity")
				linearVelocity.Attachment0 = attachment
				linearVelocity.MaxForce = 10000
				linearVelocity.ForceLimitMode = Enum.ForceLimitMode.PerAxis
				linearVelocity.MaxAxesForce = createVector(10000, 0, 10000)
				linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
				linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
				linearVelocity.VectorVelocity = createVector(0, 0, 0)
				linearVelocity.Parent = attachment
				TweenService:Create(linearVelocity, TweenInfo.new(Config.DRAG_ACCEL_TIME), {
					VectorVelocity = vector.create(0, 0, -Config.DRAG_SPEED)
				}):Play()
				task.spawn(function()
					while v3 ~= nil and v3.Parent ~= nil do
						alignOrientation.CFrame = Utility.SafeLookAt(
							humanoidRootPart.Position,
							v3.Position,
							humanoidRootPart.CFrame
						)
						task.wait()
					end
				end)
				task.wait(Config.DRAG_DURATION)
				EffectsEvent.ToAllInRange(player, "ReaptideVFX", character, "Unhold")
				TweenService:Create(linearVelocity, TweenInfo.new(Config.DRAG_DECEL_TIME), {
					VectorVelocity = createVector(0, 0, 0)
				}):Play()
				task.wait(Config.FINAL_HIT_DELAY)

				if v4 ~= nil then
					DebrisModule:AddItem(v4, 0.2)
				end

				EffectsEvent.ToAllInRange(player, "ReaptideVFX", character, "Final")
				local targets = {}

				if p2.targets ~= nil then
					for _, target in ipairs(p2.targets) do
						target[1]:Destroy()
						target[2]:Stop()
						target[4]:Destroy()
						table.insert(targets, target[3])
					end

					p2.targets = nil
				end

				local cFrame = humanoidRootPart.CFrame
				task.wait()
				Utility.CreateHitbox({
					caster = character,
					hitboxCFrame = cFrame,
					hitboxSize = Config.FINAL_HITBOX_SIZE,
					checker = Checker,
					hitPriorityHandler = {
						callback = v.Exists,
						data = "Choosing_1"
					},
					targets = targets,
					hitDetected = function(instance, p3, p4)
						if instance then
							local rootPart = instance:FindFirstChild("Humanoid").RootPart

							if p4 == "Blocking" or p4 == "Perfect" then
								Combat_Util.Block(script, character, instance, Config.FINAL_BLOCK_BREAK)
							elseif p4 == true then
								local v6 = cFrame.LookVector * Config.FINAL_KNOCKBACK + vector.create(
									0,
									Config.FINAL_KNOCKUP,
									0
								)
								Combat_Util.AddStun(script, character, p3, Config.FINAL_STUN)
								Combat_Util.Damage(script, character, instance, {
									Base = Config.FINAL_DAMAGE,
									Skill = script.Parent.Name
								})
								Combat_Util.Knockback(script, character, rootPart, v6, Config.FINAL_KNOCKBACK_TIME)
								Combat_Util.RagDoll(script, character, p3, Config.FINAL_RAGDOLL)
							end
						end
					end
				})
				task.wait(0.2)
				attachment:Destroy()
			else
				EffectsEvent.ToAllInRange(player, "ReaptideVFX", character, "MissHit", v2)
			end

			Server_Mouse_Pos.Delete_Pos_Part(character, script.Parent.Name)
		end
	})
end

function ReaptideServer.UnHold(player, _, p)
	if not player then
		return
	end

	local character = player.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	EffectsEvent.ToAllInRange(
		player,
		"ReaptideVFX",
		character,
		"Jump",
		CFrame.new(p.Start) * humanoidRootPart.CFrame.Rotation
	)
end

function ReaptideServer.Cancel(player, _, p)
	if not player then
		return
	end

	local character = player.Character

	if character == nil then
		return
	end

	Server_Mouse_Pos.Delete_Pos_Part(character, script.Parent.Name)

	if p.targets ~= nil then
		for _, target in ipairs(p.targets) do
			target:Destroy()
		end

		p.targets = nil
	end
end

return ReaptideServer