local module = require("./utility")
local Resize = {
	apply = function(instance, p: number)
		if instance:IsA("ParticleEmitter") then
			instance.Size = module.scaleNumberSequence(instance.Size, p)
			instance.Speed = NumberRange.new(instance.Speed.Min * p, instance.Speed.Max * p)
			instance.Acceleration *= p
		elseif instance:IsA("Beam") then
			module.scaleAttribute(instance, p, "Width0_Start")
			module.scaleAttribute(instance, p, "Width1_Start")
			module.scaleAttribute(instance, p, "Width0_End")
			module.scaleAttribute(instance, p, "Width1_End")
			module.scaleAttribute(instance, p, "CurveSize0_Start")
			module.scaleAttribute(instance, p, "CurveSize1_Start")
			module.scaleAttribute(instance, p, "CurveSize0_End")
			module.scaleAttribute(instance, p, "CurveSize1_End")
			module.scaleAttribute(instance, p, "Length_Scale_Start")
			module.scaleAttribute(instance, p, "Length_Scale_End")
			instance.Width0 *= p
			instance.Width1 *= p
			instance.CurveSize0 *= p
			instance.CurveSize1 *= p
			local attachment0 = instance.Attachment0
			local attachment1 = instance.Attachment1
			module.scaleAttachmentDistance(attachment0, attachment1, p)
		elseif instance:IsA("Trail") then
			local attachment0 = instance.Attachment0
			local attachment1 = instance.Attachment1
			module.scaleAttachmentDistance(attachment0, attachment1, p)
		elseif instance:IsA("Sound") then
			instance.RollOffMinDistance *= p
			instance.RollOffMaxDistance *= p
			module.scaleAttribute(instance, p, "RollOff_Start")
			module.scaleAttribute(instance, p, "RollOff_End")
		elseif instance:IsA("Model") then
			if module.isMeshVFX(instance) then
				local start = instance:FindFirstChild("Start")
				local firstChild = instance:FindFirstChild("End")

				if start and firstChild then
					start.Size *= p
					firstChild.Size *= p
					local specialMesh = start:FindFirstChildOfClass("SpecialMesh")
					local specialMesh2 = firstChild:FindFirstChildOfClass("SpecialMesh")

					if specialMesh and specialMesh2 then
						specialMesh.Scale *= p
						specialMesh2.Scale *= p
					end
				end
			else
				module.scaleAttribute(instance, p, "Scale_Start")
				module.scaleAttribute(instance, p, "Scale_End")
			end
		elseif instance:IsA("Attachment") and instance:HasTag(module.LIGHTNING_TAG) then
			module.scaleAttribute(instance, p, "OffsetScale")
			module.scaleAttribute(instance, p, "Width_Start")
			module.scaleAttribute(instance, p, "Width_End")
		elseif instance:IsA("BasePart") and instance.Parent and module.findFirstClassWithTag(
			instance.Parent,
			"Attachment",
			module.SHOCKWAVE_TAG
		) then
			module.scaleAttribute(instance, p, "Radius")
			module.scaleAttribute(instance, p, "Length")
			module.scaleAttribute(instance, p, "MinSize")
			module.scaleAttribute(instance, p, "MaxSize")

			if instance:GetAttribute("LinearMagnitude") then
				instance.Size *= p
				module.scaleAttribute(instance, p, "LinearMagnitude")
				module.scaleAttribute(instance, p, "AngularMagnitude")
			end
		elseif instance:IsA("RayValue") and instance:HasTag(module.SCREENSHAKE_TAG) then
			module.scaleAttribute(instance, p, "Falloff")
		end
	end
}

function Resize.batch(p: number, ...)
	for _, folder in { ... } do
		Resize.apply(folder, p)

		for _, descendant in folder:GetDescendants() do
			Resize.apply(descendant, p)
		end
	end
end

return Resize