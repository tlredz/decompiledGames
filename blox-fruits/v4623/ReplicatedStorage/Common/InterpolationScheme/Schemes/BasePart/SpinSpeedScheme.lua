local HeartbeatLoopFor = require(script.Parent.Parent.Parent.Parent.Loops.HeartbeatLoopFor)
local NumSeqMap = require(script.Parent.Parent.Parent.Parent.SequenceMaps.NumSeqMap)
local SpinSpeedScheme = {
	Attributes = {
		SpinAxis = vector.create(0, 1, 0),
		SpinSpeedInitial = 0,
		SpinSpeedGoal = 0,
		SpinSpeedSequence = NumberSequence.new(0)
	},
	_InsertResetState = function(p, _, p2)
		if not p[p2] then
			p[p2] = {}
		end

		p[p2].CFrame = p2.CFrame
	end,
	_LoopCondition = function(instance)
		return instance:GetAttribute("SpinSpeedInitial") ~= 0 or instance:GetAttribute("SpinSpeedGoal") ~= 0
	end
}

function SpinSpeedScheme.Setup(instance)
	for k, attribute in pairs(SpinSpeedScheme.Attributes) do
		instance:SetAttribute(k, attribute)
	end
end

function SpinSpeedScheme.Play(instance, p, p2)
	if not SpinSpeedScheme._LoopCondition(instance) then
		return
	end

	local v = p2 or instance
	local spinSpeedInitial = instance:GetAttribute("SpinSpeedInitial")
	local v2 = instance:GetAttribute("SpinSpeedGoal") - spinSpeedInitial
	local v3 = NumSeqMap.new(instance:GetAttribute("SpinSpeedSequence"), instance:GetAttribute("Keypoints"))
	local unit = instance:GetAttribute("SpinAxis").Unit
	HeartbeatLoopFor(p, function(_, p3, p4)
		v.CFrame *= CFrame.fromAxisAngle(unit, p3 * (spinSpeedInitial + v2 * v3:GetValue(p4)))
	end, function()
		v.CFrame *= CFrame.fromAxisAngle(unit, 0.016666666666666666 * (spinSpeedInitial + v2 * v3:GetValue(1)))
	end)
end

return SpinSpeedScheme