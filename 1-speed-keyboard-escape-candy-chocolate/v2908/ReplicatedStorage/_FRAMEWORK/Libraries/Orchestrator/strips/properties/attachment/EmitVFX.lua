local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(script.Parent.Parent.Parent.Parent.types.Property)
require(script.Parent.Parent.Parent.Parent.types.Strip)
local VFXUtils = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.VFXUtils)
local dataTemplate = {
	emitCount = 0,
	includeSounds = true
}
local EmitVFX = {}
EmitVFX.stripType = "property"
EmitVFX.playbackMode = "action"
EmitVFX.propertyName = "Emit VFX"
EmitVFX.context = "client"
EmitVFX.catchUpPolicies = { "skip" }
EmitVFX.dataTemplate = dataTemplate
EmitVFX.supportsGlobal = false

function EmitVFX.buildEditor(p, state, _)
	p.Components:AddNumberField(function(object)
		object:SetText("Emit Count (0 = emitter attribute)"):SetValue(state.emitCount):SetNumberFilter(0):SetOnChangedUnfocus(function(p2: number)
			state.emitCount = math.round((math.max(p2, 0)))
		end)
	end)
	p.Components:AddCheckbox(function(object)
		object:SetText("Include Sounds"):SetValue(state.includeSounds):SetOnChanged(function(includeSounds: boolean)
			state.includeSounds = includeSounds
		end)
	end)
end

function EmitVFX.supports(attachment)
	return attachment:IsA("Attachment")
end

function EmitVFX.capture(_, _)
	return table.clone(dataTemplate)
end

function EmitVFX.trigger(p, p2, _)
	local v2

	if p2.emitCount > 0 then
		v2 = p2.emitCount
	end

	VFXUtils.emitAttachment(p, v2, p2.includeSounds)
end

return EmitVFX