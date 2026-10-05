local ReplicatedStorage = game:GetService("ReplicatedStorage")
local global = ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global")
local Utility = require(global:WaitForChild("Utility"))
local StatTypes = require(global.Types.StatTypes)
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local Config = require(script.Parent.Config)

local function drawHeart(instance)
	local humanoid = instance:FindFirstChild("Humanoid")

	if humanoid == nil then
		return
	end

	humanoid.Health = math.min(humanoid.Health + Config.HEART_HEAL, humanoid.MaxHealth)
end

local function drawMuscle(p, p2)
	Utility.AddDodges(p, Config.MUSCLE_DODGES, Config.MUSCLE_DURATION, false, script.Parent.Name)
	local v = Utility.AddValue(p2, Config.MUSCLE_BUFF_VALUE, Config.MUSCLE_DURATION)
	v:AddTag(StatTypes.ValueStatTag)
	v:SetAttribute(
		StatTypes.StatToAttribute("Additional Damage Factor"),
		(`{Config.MUSCLE_BUFF_MASTERY},{Config.MUSCLE_BUFF_AMOUNT}`)
	)
end

local function drawLungs(_, instance)
	local stamina = instance:FindFirstChild("Stamina")
	local v = stamina == nil and 0 or stamina.Value
	Utility.AddTimedValue(instance, "Max Stamina", Config.LUNGS_DURATION, "NumberValue", Config.LUNGS_MAX_STAMINA):SetAttribute(
		"Skill",
		script.Parent.Name
	)

	if stamina == nil then
		return
	end

	task.defer(function()
		stamina.Value = v + Config.LUNGS_MAX_STAMINA
	end)
end

local v = {
	Heart = drawHeart,
	Muscle = drawMuscle,
	Lungs = drawLungs
}
return {
	Id = {},
	Hold = function(player, _, _)
		local character = player.Character

		if character == nil then
			return false
		end

		local getvaluesfolder = Utility.getvaluesfolder(character)

		if getvaluesfolder == nil then
			return false
		end

		local v2 = Config.DRAWS[math.random(1, #Config.DRAWS)]
		v[v2](character, getvaluesfolder)
		EffectsEvent.ToAllInRange(player, "VitalDrawVFX", character, v2)
		return true
	end
}