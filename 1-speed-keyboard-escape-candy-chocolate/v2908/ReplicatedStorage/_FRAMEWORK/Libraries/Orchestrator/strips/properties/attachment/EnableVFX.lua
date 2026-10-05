require(script.Parent.Parent.Parent.Parent.types.Property)

local function getEmitters(folder)
	local emitters = {}

	for _, emitter in folder:GetDescendants() do
		if emitter:IsA("ParticleEmitter") then
			table.insert(emitters, emitter)
		end
	end

	return emitters
end

local function areEmittersEnabled(p, flag: boolean)
	for _, v in getEmitters(p) do
		if v.Enabled ~= flag then
			return false
		end
	end

	return true
end

local EnableVFX = {}
EnableVFX.stripType = "property"
EnableVFX.playbackMode = "continuous"
EnableVFX.propertyName = "EnableVFX"
EnableVFX.context = "client"
EnableVFX.catchUpPolicies = { "latest" }
EnableVFX.dataTemplate = {
	enabled = true
}
EnableVFX.supportsGlobal = false

function EnableVFX.buildEditor(p, p2, _)
	p.Components:AddCheckbox(function(object)
		object:SetText("Enabled"):SetValue(p2.enabled):SetOnChanged(function(enabled: boolean)
			p2.enabled = enabled
		end)
	end)
end

function EnableVFX.supports(attachment)
	return attachment:IsA("Attachment") and #getEmitters(attachment) > 0
end

function EnableVFX.capture(p, _)
	local v = getEmitters(p)[1]
	return {
		enabled = v ~= nil and v.Enabled
	}
end

function EnableVFX.interpolate(p, _, _: number)
	return table.clone(p)
end

function EnableVFX.apply(p, p2)
	for _, v in getEmitters(p) do
		v.Enabled = p2.enabled
	end
end

function EnableVFX.isApplied(p, p2, _)
	local enabled = p2.enabled

	for _, v in getEmitters(p) do
		if v.Enabled ~= enabled then
			return false
		end
	end

	return true
end

return EnableVFX