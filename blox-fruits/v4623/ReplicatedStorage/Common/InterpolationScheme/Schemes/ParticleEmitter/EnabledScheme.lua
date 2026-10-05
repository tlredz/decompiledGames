local HeartbeatLoopFor = require(script.Parent.Parent.Parent.Parent.Loops.HeartbeatLoopFor)
local IsSequenceNotConstant = require(script.Parent.Parent.Parent.SchemesUtil.IsSequenceNotConstant)
local IntervalChangeDetector = require(script.Parent.Parent.Parent.SchemesUtil.IntervalChangeDetector)
local EnabledScheme = {
	Attributes = {
		EnabledSequence = NumberSequence.new(0.5)
	},
	_InsertResetState = function(p, _, p2)
		if not p[p2] then
			p[p2] = {}
		end

		p[p2].Enabled = p2.Enabled
	end,
	_LoopCondition = function(instance)
		return IsSequenceNotConstant(instance:GetAttribute("EnabledSequence"))
	end
}

function EnabledScheme.Setup(instance)
	for k, attribute in pairs(EnabledScheme.Attributes) do
		instance:SetAttribute(k, attribute)
	end
end

function EnabledScheme.Play(instance, p, p2)
	if not EnabledScheme._LoopCondition(instance) then
		return
	end

	local v = p2 or instance
	local v2 = IntervalChangeDetector.new(instance:GetAttribute("EnabledSequence"))
	HeartbeatLoopFor(p, function(_, _, p3)
		v2:TimeUpdate(p3)

		if v2:PrevTimeUpdateChangedInterval() then
			v.Enabled = v2.lowerKeypoint.Value > 0.5
		end
	end)
end

return EnabledScheme