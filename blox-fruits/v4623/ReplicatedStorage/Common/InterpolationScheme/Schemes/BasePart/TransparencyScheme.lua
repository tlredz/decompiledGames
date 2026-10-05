local HeartbeatLoopFor = require(script.Parent.Parent.Parent.Parent.Loops.HeartbeatLoopFor)
local IsSequenceNotConstant = require(script.Parent.Parent.Parent.SchemesUtil.IsSequenceNotConstant)
local NumSeqMap = require(script.Parent.Parent.Parent.Parent.SequenceMaps.NumSeqMap)
local TransparencyScheme = {
	Attributes = {
		TransparencyGoal = 1,
		TransparencySequence = NumberSequence.new(0)
	},
	_InsertResetState = function(p, _, p2)
		if not p[p2] then
			p[p2] = {}
		end

		p[p2].Transparency = p2.Transparency
	end,
	_LoopCondition = function(instance)
		return IsSequenceNotConstant(instance:GetAttribute("TransparencySequence"))
	end
}

function TransparencyScheme.Setup(instance)
	for k, attribute in pairs(TransparencyScheme.Attributes) do
		instance:SetAttribute(k, attribute)
	end
end

function TransparencyScheme.Play(instance, p, p2)
	if not TransparencyScheme._LoopCondition(instance) then
		return
	end

	local v = p2 or instance
	local transparency = v.Transparency
	local v2 = instance:GetAttribute("TransparencyGoal") - transparency
	local v3 = NumSeqMap.new(instance:GetAttribute("TransparencySequence"), instance:GetAttribute("Keypoints"))
	HeartbeatLoopFor(p, function(_, _, p3)
		v.Transparency = transparency + v2 * v3:GetValue(p3)
	end, function()
		v.Transparency = transparency + v2 * v3:GetValue(1)
	end)
end

return TransparencyScheme