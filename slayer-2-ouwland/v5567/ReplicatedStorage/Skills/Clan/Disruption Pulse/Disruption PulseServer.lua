local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local global = ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global")
local hit_priority_handler = require(ServerStorage.SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local Combat_Util = require(ServerStorage.SAM.Services.Combat_Util)
local Checker = require(ReplicatedStorage.CAM.Global.Checker)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local ManuelCancel = require(global.Subsets.Gameplay.ManuelCancel)
local StatTypes = require(ReplicatedStorage.CAM.Global.Types.StatTypes)
local PartBox = require(ReplicatedStorage.CAM.Global.PartBox)
local Config = require(script.Parent.Config)
local DisruptionPulseServer = {
	Id = {}
}

-- equivalent calls inferred from this helper; original call sites unknown
local function awayFrom(instance, humanoidRootPart)
	local v2 = humanoidRootPart.Position - instance.Position
	local vector2 = Vector3.new(v2.X, 0, v2.Z)

	if vector2.Magnitude <= 0 then
		return instance.CFrame.LookVector
	end

	return vector2.Unit
end

function DisruptionPulseServer.Hold(player, _, p)
	local character = player.Character

	if character == nil then
		return false
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return false
	end

	local getvaluesfolder = Utility.getvaluesfolder(character)
	Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.WINDUP)
	local v2 = DisruptionPulseServer.Id[player.UserId]
	local v3, v4 = ManuelCancel.new(player, 1)
	v3:Connect(function()
		v2 = -1
		v4()
	end)
	task.wait(Config.WINDUP)

	if v2 ~= DisruptionPulseServer.Id[player.UserId] or humanoidRootPart.Parent == nil then
		v4()
		return false
	end

	EffectsEvent.ToAllInRange(player, "DisruptionPulseVFX", character)

	if p ~= nil and p.field ~= nil then
		p.field:Destroy()
		p.field = nil
	end

	local field = PartBox.new({
		Shape = "Ball",
		Center = humanoidRootPart.CFrame,
		Size = createVector(1, 1, 1) * (Config.RADIUS * 2),
		MaxDuration = Config.FIELD_DURATION,
		caster = character,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = function(instance, p2, p3)
			local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")

			if p3 == "Perfect" then
				Combat_Util.Perfect(script, character, instance)
			elseif p3 == "Blocking" then
				Combat_Util.Block(script, character, instance, Config.BLOCK_BREAK)
			elseif p3 == true then
				Combat_Util.Aggro(script, character, instance)
				local v7 = awayFrom(humanoidRootPart, humanoidRootPart2) -- equivalent call inferred; original call site unknown
				Combat_Util.Knockback(
					script,
					character,
					humanoidRootPart2,
					v7 * Config.KNOCKBACK,
					Config.KNOCKBACK_DURATION
				)
				local v8 = Utility.AddValue(p2, Config.DEBUFF_VALUE, Config.DEBUFF_DURATION)
				v8:AddTag(StatTypes.ValueStatTag)
				v8:SetAttribute(StatTypes.StatToAttribute("Additional Damage Factor"), Config.DEBUFF_DAMAGE_FACTOR)
				v8:SetAttribute(StatTypes.StatToAttribute("Movement Speed Factor"), Config.DEBUFF_SPEED_FACTOR)
			end
		end
	})

	if p ~= nil then
		p.field = field
	end

	v4()
	return true
end

function DisruptionPulseServer.Cancel(player, _, p)
	if player == nil then
		return
	end

	if p ~= nil and p.field ~= nil then
		p.field:Destroy()
		p.field = nil
	end

	local character = player.Character

	if character == nil then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
	humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
end

return DisruptionPulseServer