local BeamLightningCache = {}
local beam = Instance.new("Beam")
beam.LightInfluence = 0
beam.TextureMode = Enum.TextureMode.Stretch
local attachment = Instance.new("Attachment")

function BeamLightningCache.GetBeam(parent)
	local clone = beam:Clone()
	clone.Parent = parent
	return clone
end

function BeamLightningCache.ReturnBeam(instance)
	if instance then
		instance:Destroy()
	end
end

function BeamLightningCache.GetAttachment(parent)
	local clone = attachment:Clone()
	clone.Parent = parent
	return clone
end

function BeamLightningCache.ReturnAttachment(instance)
	if instance then
		instance:Destroy()
	end
end

function BeamLightningCache.Clear() end

return BeamLightningCache