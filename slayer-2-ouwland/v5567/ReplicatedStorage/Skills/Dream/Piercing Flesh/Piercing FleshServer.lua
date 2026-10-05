local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local Checker = require(CAM.Global.Checker)
local Utility = require(CAM.Global.Utility)
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local Combat_Util = require(SAM.Services.Combat_Util)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local CharGrabPosCorrector = require(CAM.Global.Subsets.Gameplay.CharGrabPosCorrector)
local Server_Mouse_Pos = require(SAM.Services.Server_Mouse_Pos)
local Config = require(script.Parent.Config)
local PiercingFleshServer = {
	Id = {},
	Hold = function(player, p, p2)
		local cleanIt = p2.CleanIt or cleanit.new()
		p2.CleanIt = cleanIt
		cleanIt:Clean()
		local character = player.Character
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		Server_Mouse_Pos.Create_Pos_Part(character, script.Parent.Name, 5, p)
		cleanIt:Add(function()
			Server_Mouse_Pos.Delete_Pos_Part(character, script.Parent.Name)
		end)
		EffectsEvent.ToAllInRange(humanoidRootPart, "PiercingFlesh VFX", character, "Startup")
	end
}

function PiercingFleshServer.UnHold(player, vector2: Vector3, p)
	local cleanIt = p.CleanIt or cleanit.new()
	p.CleanIt = cleanIt
	local v2 = PiercingFleshServer.Id[player.UserId]
	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	task.wait(0.3)

	if v2 ~= PiercingFleshServer.Id[player.UserId] or humanoidRootPart.Parent == nil then
		return
	end

	local lookVector = humanoidRootPart.CFrame.LookVector
	local vector3 = Vector3.new(lookVector.X, 0, lookVector.Z)
	local v3 = not (vector3.Magnitude > 0.01) and createVector(1, 0, 0) or vector3.Unit
	local _, v4 = Server_Mouse_Pos.Aim(character, script.Parent.Name, Config.MOUSE_RANGE, vector2)
	local v5 = (v4 or humanoidRootPart.CFrame * CFrame.new(0, 0, -Config.MOUSE_RANGE)).Position - createVector(
		0,
		0.25,
		0
	)
	local cframe = CFrame.lookAt(v5, v5 + v3)
	local flag = false
	local v6 = false
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = cframe,
		hitboxSize = Config.SPIKE_HITBOX_SIZE,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = function(instance, p2, p3)
			if not instance then
				return
			end

			flag = true
			v6 = true

			if p3 == "Perfect" then
				flag = false
				Combat_Util.Perfect(script, character, instance)
				PiercingFleshServer.Cancel(player, vector2, p)
			elseif p3 == "Blocking" then
				flag = false
				v6 = false
				Combat_Util.Block(script, character, instance, 1)
			else
				local humanoid = instance:FindFirstChild("Humanoid")

				if not humanoid then
					return
				end

				local rootPart = humanoid.RootPart

				if not rootPart then
					return
				end

				if p3 == true then
					cleanIt:Add(Utility.AddValue(p2, "iframe", Config.GRAB_DURATION, "StringValue", character.Name))
					cleanIt:Add(Utility.AddValue(p2, "pause_gameplay", Config.GRAB_DURATION))
					local cFrame = cframe * CFrame.new(0.35, 3.06, 0.5) * CFrame.Angles(0, 3.141592653589793, 0)
					rootPart.CFrame = cFrame
					cleanIt:Add(Utility.lock(rootPart, cFrame, Config.GRAB_DURATION))
					task.delay(0.25, function()
						if v2 ~= PiercingFleshServer.Id[player.UserId] or humanoidRootPart.Parent == nil or Checker.check_victim(
							script,
							character,
							instance
						) == nil then
							return
						end

						local track = humanoid:FindFirstChild("Animator"):LoadAnimation(script.PiercingFleshVictim)
						track:Play()
						cleanIt:Add(track)
						CharGrabPosCorrector.Do(instance, track, 2.1333333333333333, character)
						task.wait(1.2)

						if v2 ~= PiercingFleshServer.Id[player.UserId] or humanoidRootPart.Parent == nil or Checker.check_victim(
							script,
							character,
							instance
						) == nil then
							return
						end

						Combat_Util.Damage(script, character, instance, {
							Base = Config.HIT_DAMAGE,
							Skill = script.Parent.Name
						})
						task.wait(0.9666666666666667)

						if v2 ~= PiercingFleshServer.Id[player.UserId] or humanoidRootPart.Parent == nil or Checker.check_victim(
							script,
							character,
							instance
						) == nil then
							return
						end

						Combat_Util.Damage(script, character, instance, {
							Base = Config.HIT_DAMAGE,
							Skill = script.Parent.Name
						})
						Combat_Util.AddStun(script, character, p2, Config.HIT_STUN)
						Combat_Util.RagDoll(script, character, p2, Config.HIT_STUN)
						Combat_Util.Knockback(script, character, rootPart, lookVector * Config.HIT_KNOCKBACK, 0.2)
					end)
				end
			end
		end
	})

	if flag then
		EffectsEvent.ToAllInRange(humanoidRootPart, "PiercingFlesh VFX", character, "Hit", cframe)
	elseif not v6 then
		EffectsEvent.ToAllInRange(humanoidRootPart, "PiercingFlesh VFX", character, "Miss", cframe)
		task.wait(Config.MISS_RECOVERY)
		cleanIt:Clean()
	end
end

function PiercingFleshServer.Cancel(player, _: Vector3?, p)
	local cleanIt = p.CleanIt or cleanit.new()
	p.CleanIt = cleanIt
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and character then
		EffectsEvent.ToAllInRange(humanoidRootPart, "PiercingFlesh VFX", character, "Cancel")
	end

	cleanIt:Clean()
end

return PiercingFleshServer