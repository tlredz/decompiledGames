local Config = require(script.Parent.Config)
local name = script.Parent.Name
local EffectServer = {}

function EffectServer.Activate(_, _, instance)
	if instance == nil then
		return
	end

	local child = instance:FindFirstChild(name)

	if child == nil then
		return
	end

	child:SetAttribute("OnHitTick", Config.TICK_VALUE)
	child:SetAttribute("Ratio", Config.MAX_HEALTH_RATIO)
	child:SetAttribute("MinDamage", Config.MIN_DAMAGE)
	child:SetAttribute("TickDuration", Config.POISON_DURATION)
	child:SetAttribute("Stacks", true)
	child:SetAttribute("Skill", name)
	child:SetAttribute(
		"HubText",
		(`M1s Inflict <font color="rgb(255,0,0)">{math.round(Config.MAX_HEALTH_RATIO * 100)}%</font> Max Health Poison`)
	)
end

function EffectServer.Cancel(_, _, instance)
	if instance == nil then
		return
	end

	local child = instance:FindFirstChild(name)

	if child ~= nil then
		child:Destroy()
	end
end

return EffectServer