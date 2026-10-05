local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage:WaitForChild("CAM")
local SAM = ServerStorage:WaitForChild("SAM")
local global = CAM:WaitForChild("Global")
local services = SAM:WaitForChild("Services")
local EffectsEvent = require(ReplicatedStorage2.Communication.ServerAndClient.Effects.EffectsEvent)
local Utility = require(global.Utility)
local Checker = require(global.Checker)
local Combat_Util = require(services.Combat_Util)
local ImpactSounds = require(SAM.Utility.ImpactSounds)
local Combat_presets = require(CAM.Global.Combat_presets)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local ManuelCancel = require(global.Subsets.Gameplay.ManuelCancel)
local Config = require(script.Parent.Config)
local RaycastHelper = require(ReplicatedStorage2.CAM.Global.RaycastHelper)
local script2 = script
local BurstingBloomServer = {
	Id = {},
	Hold = function(player, _, p)
		local character = player.Character

		if not (character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild(
			"Animator",
			true
		)) then
			return
		end

		EffectsEvent.ToAllInRange(player, "Bursting BloomVFX", character, "StartUp")
		p.Clock = os.clock()
	end
}

function BurstingBloomServer.UnHold(player, p, p2)
	local character = player.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not (humanoidRootPart and character:FindFirstChild("Animator", true)) then
		return
	end

	local air_combo_bp = humanoidRootPart:FindFirstChild("air_combo_bp")

	if air_combo_bp then
		air_combo_bp:Destroy()
	end

	local getvaluesfolder = Utility.getvaluesfolder(character)
	Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.BLINK_DELAY + Config.ENDLAG)
	local v2 = BurstingBloomServer.Id[player.UserId]
	local v3, v4 = ManuelCancel.new(player, 1)
	v3:Connect(function()
		v2 = -1
		BurstingBloomServer.Cancel(player, p, p2)
		v4()
	end)
	task.wait(Config.BLINK_DELAY)

	if BurstingBloomServer.Id[player.UserId] ~= v2 then
		return
	end

	for _, child in getvaluesfolder:GetChildren() do
		if Utility.Cancel_Values[child.Name] then
			return
		end
	end

	local cFrame = humanoidRootPart.CFrame
	local v5 = vector.normalize(p - cFrame.Position) * Config.MAX_DISTANCE
	local cframe = CFrame.new(cFrame.Position, cFrame.Position + v5)
	local raycastResult = workspace:Raycast(cFrame.Position, v5, RaycastHelper.Crater)
	local MAX_DISTANCE = Config.MAX_DISTANCE
	local v6

	if raycastResult then
		local v7 = raycastResult.Position - cFrame.Position
		MAX_DISTANCE = vector.magnitude(v7)
		v6 = cFrame.Position + vector.normalize(v7) * MAX_DISTANCE
	else
		v6 = cFrame.Position + v5
	end

	local v7 = CFrame.new(v6) * cframe.Rotation
	EffectsEvent.ToAllInRange(player, "Bursting BloomVFX", character, "Teleport", v7, cFrame)
	local instances = {}

	local function fn(instance, p3, p4, _)
		if instance and table.find(instances, instance) == nil then
			table.insert(instances, instance)
			local humanoid = instance:FindFirstChild("Humanoid")
			local rootPart = humanoid.RootPart

			if p4 == "Perfect" then
				Combat_Util.Perfect(script2, character, instance)
			elseif p4 == "Blocking" then
				Combat_Util.Block(script2, character, instance, Config.DASH_BLOCK_BREAK)
			elseif p4 == true then
				Combat_Util.AddStun(script2, character, p3, Config.DASH_STUN)
				Combat_Util.Damage(script, character, instance, {
					Base = Config.DASH_DAMAGE,
					Skill = script.Parent.Name
				})
				Combat_Util.Knockback(
					script2,
					character,
					rootPart,
					vector.create(0, Config.DASH_KNOCKUP, 0),
					Config.DASH_KNOCKBACK_DURATION
				)
				EffectsEvent.ToAllInRange(player, "Bursting BloomVFX", character, "Hit", rootPart)

				if humanoid then
					Combat_presets.PlayReactAnim(humanoid, nil, 0.35)
				end
			end
		end
	end

	local vector2 = Vector3.new(Config.DASH_HITBOX_WIDTH, Config.DASH_HITBOX_HEIGHT, MAX_DISTANCE + 8)
	local v8 = Utility.SafeLookAt(cFrame.Position, v7.Position, cFrame) * CFrame.new(0, 0, -(MAX_DISTANCE / 2 + 3))
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = v8,
		hitboxSize = vector2,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = fn,
		extraArgs = v8,
		After = function(p3, list)
			if p3 then
				ImpactSounds.Play(character, script.Parent.Name, list[1])
			end
		end
	})
end

function BurstingBloomServer.Cancel(player, _, _)
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

	humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
	humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
end

return BurstingBloomServer