local HeartbeatLoopFor = require(script.Parent.Parent.Parent.Parent.Loops.HeartbeatLoopFor)
local IsSequenceNotConstant = require(script.Parent.Parent.Parent.SchemesUtil.IsSequenceNotConstant)
local IntervalChangeDetector = require(script.Parent.Parent.Parent.SchemesUtil.IntervalChangeDetector)
local EmitScheme = {
	Attributes = {
		EmitMaxAmount = 0,
		EmitSequence = NumberSequence.new(0)
	},
	_InsertResetState = function(p, _, p2)
		if not p[p2] then
			p[p2] = {}
		end
	end,
	_LoopCondition = function(instance)
		return IsSequenceNotConstant(instance:GetAttribute("EmitSequence"))
	end
}

function EmitScheme.Setup(instance)
	for k, attribute in pairs(EmitScheme.Attributes) do
		instance:SetAttribute(k, attribute)
	end
end

function EmitScheme.Play(instance, p, p2)
	if not EmitScheme._LoopCondition(instance) then
		return
	end

	local v = p2 or instance
	local emitMaxAmount = instance:GetAttribute("EmitMaxAmount")
	local v2 = IntervalChangeDetector.new(instance:GetAttribute("EmitSequence"))
	HeartbeatLoopFor(p, function(_, _, p3)
		v2:TimeUpdate(p3)

		if v2:PrevTimeUpdateChangedInterval() then
			v:Emit((math.floor(0.5 + v2.lowerKeypoint.Value * emitMaxAmount)))
		end
	end)
end

return EmitScheme