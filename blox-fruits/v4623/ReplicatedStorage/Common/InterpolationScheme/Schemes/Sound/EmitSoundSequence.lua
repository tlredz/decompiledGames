local Sound = require(game.ReplicatedStorage.Util.Sound)
local HeartbeatLoopFor = require(script.Parent.Parent.Parent.Parent.Loops.HeartbeatLoopFor)
local IsSequenceNotConstant = require(script.Parent.Parent.Parent.SchemesUtil.IsSequenceNotConstant)
local IntervalChangeDetector = require(script.Parent.Parent.Parent.SchemesUtil.IntervalChangeDetector)
local EmitSoundSequence = {
	Attributes = {
		EmitSoundSequence = NumberSequence.new(0)
	},
	_InsertResetState = function(p, _, p2)
		if not p[p2] then
			p[p2] = {}
		end
	end,
	_LoopCondition = function(instance)
		return IsSequenceNotConstant(instance:GetAttribute("EmitSoundSequence"))
	end
}

function EmitSoundSequence.Setup(instance)
	for k, attribute in pairs(EmitSoundSequence.Attributes) do
		instance:SetAttribute(k, attribute)
	end
end

function EmitSoundSequence:Play(p, p2)
	if not EmitSoundSequence._LoopCondition(self) then
		return
	end

	local v = p2 or self
	local v2 = IntervalChangeDetector.new(self:GetAttribute("EmitSoundSequence"))
	HeartbeatLoopFor(p, function(_, _, p3)
		v2:TimeUpdate(p3)

		if v2:PrevTimeUpdateChangedInterval() then
			local worldPosition = v.Parent.ClassName == "Attachment" and v.Parent.WorldPosition or v.Parent.Position
			Sound:Play(v:GetAttribute("SoundLocation"), worldPosition)
		end
	end)
end

return EmitSoundSequence