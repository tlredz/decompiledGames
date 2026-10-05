local createVector = vector.create
local HeartbeatLoopFor = require(script.Parent.Parent.Parent.Parent.Loops.HeartbeatLoopFor)
local NumSeqMap = require(script.Parent.Parent.Parent.Parent.SequenceMaps.NumSeqMap)
local AccelerationScheme = {
	Attributes = {
		AccelerationDirection = createVector(0, -1, 0),
		AccelerationInitial = 0,
		AccelerationGoal = 0,
		AccelerationSequence = NumberSequence.new(0),
		InitialObjectVelocity = createVector(0, 0, 0)
	},
	_InsertResetState = function(p, _, p2)
		if not p[p2] then
			p[p2] = {}
		end

		p[p2].CFrame = p2.CFrame
	end,
	_LoopCondition = function(instance)
		return instance:GetAttribute("AccelerationInitial") ~= 0 or instance:GetAttribute("AccelerationGoal") ~= 0 or instance:GetAttribute("InitialObjectVelocity") ~= createVector(
			0,
			0,
			0
		)
	end
}

function AccelerationScheme.Setup(instance)
	for k, attribute in pairs(AccelerationScheme.Attributes) do
		instance:SetAttribute(k, attribute)
	end
end

function AccelerationScheme.Play(instance, p, p2)
	if not AccelerationScheme._LoopCondition(instance) then
		return
	end

	local v = p2 or instance
	local accelerationInitial = instance:GetAttribute("AccelerationInitial")
	local v2 = instance:GetAttribute("AccelerationGoal") - accelerationInitial
	local v3 = NumSeqMap.new(instance:GetAttribute("AccelerationSequence"), instance:GetAttribute("Keypoints"))
	local unit = instance:GetAttribute("AccelerationDirection").Unit
	local vectorToWorldSpace = v.CFrame:VectorToWorldSpace(instance:GetAttribute("InitialObjectVelocity"))
	HeartbeatLoopFor(p, function(_, p3, p4)
		vectorToWorldSpace += unit * p3 * (accelerationInitial + v2 * v3:GetValue(p4))
		v.Position += vectorToWorldSpace * p3
	end, function()
		vectorToWorldSpace += unit * 0.016666666666666666 * (accelerationInitial + v2 * v3:GetValue(1))
		v.Position += vectorToWorldSpace * 0.016666666666666666
	end)
end

return AccelerationScheme