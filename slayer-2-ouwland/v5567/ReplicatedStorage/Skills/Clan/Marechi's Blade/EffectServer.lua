local Config = require(script.Parent.Config)
local name = script.Parent.Name
local EffectServer = {}

function EffectServer.Activate(p, instance, instance2)
	if instance == nil or instance2 == nil then
		return
	end

	local humanoid = instance:FindFirstChildOfClass("Humanoid")

	if humanoid == nil or humanoid.Health <= 0 then
		return
	end

	if p ~= nil then
		humanoid.Health = math.max(1, humanoid.Health - humanoid.MaxHealth * Config.SELF_DAMAGE_RATIO)
	end

	local child = instance2:FindFirstChild(name)

	if child == nil then
		return
	end

	child:SetAttribute("OnHitTick", Config.TICK_VALUE)
	child:SetAttribute("Damage", Config.TICK_DAMAGE)
	child:SetAttribute("TickDuration", Config.TICK_DURATION)
	child:SetAttribute("Skill", name)
	child:SetAttribute("HubText", (`M1s Inflict <font color="rgb(255,0,0)">{Config.TICK_DAMAGE}</font> Poison Damage`))
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