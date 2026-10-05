local HeartbeatLoopFor = require(script.Parent.Parent.Parent.Parent.Loops.HeartbeatLoopFor)
local NumSeqMap = require(script.Parent.Parent.Parent.Parent.SequenceMaps.NumSeqMap)
local SpeedScheme = {
	Attributes = {
		SpeedDirection = vector.create(0, 1, 0),
		SpeedInitial = 0,
		SpeedGoal = 0,
		SpeedSequence = NumberSequence.new(0)
	},
	_InsertResetState = function(p, _, p2)
		if not p[p2] then
			p[p2] = {}
		end

		p[p2].CFrame = p2.CFrame
	end,
	_LoopCondition = function(instance)
		return instance:GetAttribute("SpeedInitial") ~= 0 or instance:GetAttribute("SpeedGoal") ~= 0
	end
}

function SpeedScheme.Setup(instance)
	for k, attribute in pairs(SpeedScheme.Attributes) do
		instance:SetAttribute(k, attribute)
	end
end

function SpeedScheme.Play(instance, p, p2)
	if not SpeedScheme._LoopCondition(instance) then
		return
	end

	local v = p2 or instance
	local speedInitial = instance:GetAttribute("SpeedInitial")
	local v2 = instance:GetAttribute("SpeedGoal") - speedInitial
	local v3 = NumSeqMap.new(instance:GetAttribute("SpeedSequence"), instance:GetAttribute("Keypoints"))
	local unit = instance:GetAttribute("SpeedDirection").Unit
	HeartbeatLoopFor(p, function(_, p3, p4)
		v.CFrame *= CFrame.new(unit * p3 * (speedInitial + v2 * v3:GetValue(p4)))
	end, function()
		v.CFrame *= CFrame.new(unit * 0.016666666666666666 * (speedInitial + v2 * v3:GetValue(1)))
	end)
end

return SpeedScheme