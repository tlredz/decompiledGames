local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local ManuelCancel = require(CAM.Global.Subsets.Gameplay.ManuelCancel)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local Checker = require(CAM.Global.Checker)
local Utility = require(CAM.Global.Utility)
local Combat_Util = require(SAM.Services.Combat_Util)
local Combat_presets = require(CAM.Global.Combat_presets)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local Config = require(script.Parent.Config)
local ShellshockFrenzyServer = {
	Id = {}
}

function ShellshockFrenzyServer.Hold(player, _: Vector3?, p)
	local cleanIt = p.CleanIt or cleanit.new()
	p.CleanIt = cleanIt
	cleanIt:Clean()
	local v2 = ShellshockFrenzyServer.Id[player.UserId]
	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local getvaluesfolder = Utility.getvaluesfolder(character)
	cleanIt:Add(Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.MAX_FRENZY_DURATION))
	cleanIt:Add(Utility.AddValue(
		getvaluesfolder,
		"WalkSpeed",
		Config.MAX_FRENZY_DURATION,
		"NumberValue",
		Config.WALK_SPEED
	))
	EffectsEvent.ToAllInRange(humanoidRootPart, "Shellshock Frenzy VFX", character, "Start", humanoidRootPart.CFrame)
	local v3 = os.clock() + Config.MAX_FRENZY_DURATION
	local count = 0

	while ShellshockFrenzyServer.Id[player.UserId] == v2 and os.clock() < v3 do
		local v4 = Config.SHOT_FRAMES[count % #Config.SHOT_FRAMES + 1]
		local v5 = Config.SHOT_FRAMES[(count + 1) % #Config.SHOT_FRAMES + 1]
		count += 1
		local cFrame = humanoidRootPart.CFrame
		EffectsEvent.ToAllInRange(humanoidRootPart, "Shellshock Frenzy VFX", character, "Burst", cFrame, count)
		Utility.CreateHitbox({
			caster = character,
			hitboxCFrame = cFrame,
			hitboxSize = Config.BURST_HITBOX_SIZE,
			checker = Checker,
			hitPriorityHandler = {
				callback = v.Exists,
				data = "Choosing_1"
			},
			hitDetected = function(instance, p2, p3)
				local humanoid = instance:FindFirstChild("Humanoid")
				local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")

				if humanoid == nil or humanoidRootPart2 == nil then
					return
				end

				if p3 == "Perfect" then
					Combat_Util.Perfect(script, character, instance)
				elseif p3 == "Blocking" then
					Combat_Util.Block(script, character, instance, Config.BURST_BLOCK_BREAK)
				elseif p3 == true then
					Combat_Util.Damage(script, character, instance, {
						Base = Config.BURST_DAMAGE,
						Skill = script.Parent.Name
					})
					Combat_Util.AddStun(script, character, p2, Config.BURST_STUN)
					Combat_Util.Knockback(
						script,
						character,
						humanoidRootPart2,
						Vector3.new(0, Config.BURST_KNOCKUP, 0),
						Config.BURST_STUN
					)
					Combat_presets.PlayReactAnim(humanoid, nil, 0.6)
				end
			end
		})
		task.wait((v5 - v4) % Config.LOOP_FRAMES / 60)
	end
end

function ShellshockFrenzyServer.UnHold(player, _: Vector3?, p)
	local cleanIt = p.CleanIt or cleanit.new()
	p.CleanIt = cleanIt
	cleanIt:Clean()
	local v2 = ShellshockFrenzyServer.Id[player.UserId]
	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local getvaluesfolder = Utility.getvaluesfolder(character)
	local v3, v4 = ManuelCancel.new(player, 1.85)
	v3:Connect(function()
		ShellshockFrenzyServer.Id[player.UserId] = -1
		ShellshockFrenzyServer.Cancel(player, nil, p)
	end)
	cleanIt:Add(v4)
	humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
	humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
	cleanIt:Add(Utility.AddValue(getvaluesfolder, "pause_gameplay", 1.35))
	cleanIt:Add(Utility.AddValue(getvaluesfolder, "skill_stand_still", 1.35))
	EffectsEvent.ToAllInRange(humanoidRootPart, "Shellshock Frenzy VFX", character, "Jump", humanoidRootPart.CFrame)
	local position = humanoidRootPart.Position
	local raycastResult = workspace:Raycast(
		position + createVector(0, 5, 0),
		createVector(0, -80, 0),
		RaycastHelper.Crater
	)

	if raycastResult then
		position = raycastResult.Position or position
	end

	local cframe = CFrame.new(position)
	task.wait(0.75)

	if ShellshockFrenzyServer.Id[player.UserId] ~= v2 then
		return
	end

	EffectsEvent.ToAllInRange(
		humanoidRootPart,
		"Shellshock Frenzy VFX",
		character,
		"Shell",
		humanoidRootPart.CFrame,
		cframe
	)
	task.wait(0.15)

	if ShellshockFrenzyServer.Id[player.UserId] ~= v2 then
		return
	end

	EffectsEvent.ToAllInRange(
		humanoidRootPart,
		"Shellshock Frenzy VFX",
		character,
		"Explosion",
		humanoidRootPart.CFrame,
		cframe
	)
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = cframe * CFrame.new(0, Config.EXPLOSION_HITBOX_RAISE, 0),
		hitboxSize = Config.EXPLOSION_HITBOX_SIZE,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_2"
		},
		hitDetected = function(instance, p2, p3)
			local humanoid = instance:FindFirstChild("Humanoid")
			local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")

			if humanoid == nil or humanoidRootPart2 == nil then
				return
			end

			if p3 == "Perfect" then
				Combat_Util.Perfect(script, character, instance)
			elseif p3 == "Blocking" then
				Combat_Util.Block(script, character, instance, Config.EXPLOSION_BLOCK_BREAK)
			elseif p3 == true then
				local unit = ((humanoidRootPart2.Position - humanoidRootPart.Position) * createVector(1, 0, 1)).Unit
				Combat_Util.Damage(script, character, instance, {
					Base = Config.EXPLOSION_DAMAGE,
					Skill = script.Parent.Name
				})
				Combat_Util.AddStun(script, character, p2, Config.EXPLOSION_STUN)
				Combat_Util.RagDoll(script, character, p2, Config.EXPLOSION_STUN)
				Combat_Util.Knockback(
					script,
					character,
					humanoidRootPart2,
					unit * Config.EXPLOSION_KNOCKBACK + Vector3.new(0, Config.EXPLOSION_UPWARD, 0),
					0.25
				)
			end
		end
	})
	task.wait(0.45)

	if ShellshockFrenzyServer.Id[player.UserId] ~= v2 then
		return
	end

	cleanIt:Clean()
end

function ShellshockFrenzyServer.Cancel(player, _: Vector3?, p)
	local cleanIt = p.CleanIt or cleanit.new()
	p.CleanIt = cleanIt
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and character then
		humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
		humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
		EffectsEvent.ToAllInRange(humanoidRootPart, "Shellshock Frenzy VFX", character, "Cancel")
	end

	cleanIt:Clean()
end

return ShellshockFrenzyServer