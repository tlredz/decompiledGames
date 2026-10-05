local HeartbeatLoopFor = require(script.Parent.Parent.Parent.Parent.Loops.HeartbeatLoopFor)
local IsSequenceNotConstant = require(script.Parent.Parent.Parent.SchemesUtil.IsSequenceNotConstant)
local IntervalChangeDetector = require(script.Parent.Parent.Parent.SchemesUtil.IntervalChangeDetector)
local EmitUtilSoundSequence = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utilSoundWrapper = require(ReplicatedStorage:WaitForChild("Util")).UtilSoundWrapper
EmitUtilSoundSequence.Attributes = {
	EmitSoundSequence = NumberSequence.new(0)
}

function EmitUtilSoundSequence:_InsertResetState(_, p2)
	if not self[p2] then
		self[p2] = {}
	end
end

function EmitUtilSoundSequence._LoopCondition(instance)
	return IsSequenceNotConstant(instance:GetAttribute("EmitSoundSequence"))
end

function EmitUtilSoundSequence.Setup(instance)
	for k, attribute in pairs(EmitUtilSoundSequence.Attributes) do
		instance:SetAttribute(k, attribute)
	end
end

function EmitUtilSoundSequence.Play(instance, p, p2)
	if not EmitUtilSoundSequence._LoopCondition(instance) then
		return
	end

	local v = p2 or instance
	local v2 = IntervalChangeDetector.new(instance:GetAttribute("EmitSoundSequence"))
	HeartbeatLoopFor(p, function(_, _, p3)
		v2:TimeUpdate(p3)

		if v2:PrevTimeUpdateChangedInterval() then
			utilSoundWrapper.Play(v, v.Parent)
		end
	end)
end

return EmitUtilSoundSequence