local HeartbeatLoopFor = require(script.Parent.Parent.Parent.Parent.Loops.HeartbeatLoopFor)
local IsSequenceNotConstant = require(script.Parent.Parent.Parent.SchemesUtil.IsSequenceNotConstant)
local ColorSeqMap = require(script.Parent.Parent.Parent.Parent.SequenceMaps.ColorSeqMap)
local ColorScheme = {
	Attributes = {
		ColorSequence = ColorSequence.new(Color3.new())
	},
	_InsertResetState = function(p, _, p2)
		if not p[p2] then
			p[p2] = {}
		end

		p[p2].Color = p2.Color
	end,
	_LoopCondition = function(instance)
		return IsSequenceNotConstant(instance:GetAttribute("ColorSequence"))
	end
}

function ColorScheme.Setup(instance)
	for k, attribute in pairs(ColorScheme.Attributes) do
		instance:SetAttribute(k, attribute)
	end
end

function ColorScheme.Play(instance, p, p2)
	if not ColorScheme._LoopCondition(instance) then
		return
	end

	local v = p2 or instance
	local v2 = ColorSeqMap.new(instance:GetAttribute("ColorSequence"))
	HeartbeatLoopFor(p, function(_, _, p3)
		v.Color = v2:GetValue(p3)
	end, function()
		v.Color = v2:GetValue(1)
	end)
end

return ColorScheme