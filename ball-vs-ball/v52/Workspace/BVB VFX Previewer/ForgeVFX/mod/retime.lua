local module = require("./utility")
local Retime = {
	apply = function(instance, p: number, p2: number)
		if instance:IsA("ParticleEmitter") then
			module.scaleAttribute(instance, p2, "EmitDelay")
			module.scaleAttribute(instance, p2, "EmitDuration")
			module.scaleAttribute(instance, p2, "TimeScale_Duration")
			instance.Speed = NumberRange.new(instance.Speed.Min * p, instance.Speed.Max * p)
			instance.RotSpeed = NumberRange.new(instance.RotSpeed.Min * p, instance.RotSpeed.Max * p)
			instance.Lifetime = NumberRange.new(instance.Lifetime.Min / p, instance.Lifetime.Max / p)
			instance.Acceleration *= p ^ 2
			instance.Drag *= p
			instance.Rate *= p
		elseif instance:IsA("Beam") then
			module.scaleAttribute(instance, p2, "EmitDelay")
			module.scaleAttribute(instance, p2, "EmitDuration")
			module.scaleAttribute(instance, p2, "EffectDuration")
			module.scaleAttribute(instance, p2, "Speed_Duration")
			module.scaleAttribute(instance, p2, "Duration")
			instance.TextureSpeed *= p
		elseif instance:IsA("Trail") then
			instance.Lifetime *= p2
		elseif instance:IsA("Sound") then
			module.scaleAttribute(instance, p2, "EmitDelay")
			module.scaleAttribute(instance, p2, "EmitDuration")
			module.scaleAttribute(instance, p2, "EmitInterval")
			module.scaleAttribute(instance, p2, "RepeatInterval")
			module.scaleAttribute(instance, p2, "FadeOutTime")
			module.scaleAttribute(instance, p2, "Volume_Duration")
			module.scaleAttribute(instance, p2, "Speed_Duration")
			module.scaleAttribute(instance, p2, "RollOff_Duration")
		elseif instance:IsA("Model") then
			if module.isMeshVFX(instance) then
				module.scaleAttribute(instance, p2, "EmitDelay")
				module.scaleAttribute(instance, p2, "DestroyDelay")
				module.scaleAttribute(instance, p2, "EmitDuration")
				module.scaleAttribute(instance, p2, "EffectDuration")
				module.scaleAttribute(instance, p2, "Speed_Duration")
				module.scaleAttribute(instance, p2, "Duration")
				module.scaleAttribute(instance, p, "Rate")
				module.scaleAttribute(instance, p, "Part_RotSpeed_Start")
				module.scaleAttribute(instance, p, "Part_RotSpeed_End")
			else
				module.scaleAttribute(instance, p, "SpinRotation")
				module.scaleAttribute(instance, p2, "EmitDelay")
				module.scaleAttribute(instance, p2, "ResetDelay")
				module.scaleAttribute(instance, p2, "SpinDuration")
				module.scaleAttribute(instance, p2, "Scale_Duration")
				module.scaleAttribute(instance, p2, "SpinSpeed_Duration")
			end
		elseif instance:IsA("Attachment") and instance:HasTag(module.BEZIER_TAG) then
			module.scaleAttribute(instance, p2, "EmitDelay")
			module.scaleAttribute(instance, p2, "DestroyDelay")
			module.scaleAttribute(instance, p2, "EmitDuration")
			module.scaleAttribute(instance, p2, "Duration")
			module.scaleAttribute(instance, p2, "Speed_Duration")
			module.scaleAttribute(instance, p, "ProjectileSpeed")
			module.scaleAttribute(instance, p2, "ProjectileLifetime")
			module.scaleAttribute(instance, p, "Rate")
			module.scaleAttribute(instance, p, "Part_RotSpeed_Start")
			module.scaleAttribute(instance, p, "Part_RotSpeed_End")
		elseif instance:IsA("Attachment") and instance:HasTag(module.LIGHTNING_TAG) then
			module.scaleAttribute(instance, p2, "EmitDelay")
			module.scaleAttribute(instance, p2, "DestroyDelay")
			module.scaleAttribute(instance, p2, "EmitDuration")
			module.scaleAttribute(instance, p2, "Duration")
			module.scaleAttribute(instance, p2, "Speed_Duration")
			module.scaleAttribute(instance, p2, "Color_Duration")
			module.scaleAttribute(instance, p2, "Fill_Color_Duration")
			module.scaleAttribute(instance, p2, "Fade_In_Duration")
			module.scaleAttribute(instance, p2, "Fade_Out_Duration")
			module.scaleAttribute(instance, p2, "Dissipate_Duration")
			module.scaleAttribute(instance, p, "ProjectileSpeed")
			module.scaleAttribute(instance, p2, "ProjectileLifetime")
			module.scaleAttribute(instance, p, "Rate")
			module.scaleAttribute(instance, p, "RefreshRate")
		elseif instance:IsA("BasePart") and instance.Parent and module.findFirstClassWithTag(
			instance.Parent,
			"Attachment",
			module.SHOCKWAVE_TAG
		) then
			module.scaleAttribute(instance, p2, "EmitDelay")
			module.scaleAttribute(instance, p2, "Size_Duration")
			module.scaleAttribute(instance, p2, "Transparency_Duration")
			module.scaleAttribute(instance, p2, "Lifetime")
			module.scaleAttribute(instance, p2, "Duration")
			module.scaleAttribute(instance, p, "Rate_Start")
			module.scaleAttribute(instance, p, "Rate_End")
		elseif instance:IsA("RayValue") and instance:HasTag(module.SCREENSHAKE_TAG) then
			module.scaleAttribute(instance, p2, "EmitDelay")
			module.scaleAttribute(instance, p2, "EmitDuration")
			module.scaleAttribute(instance, p2, "Scale_Duration")
		elseif instance:IsA("RayValue") then
			module.scaleAttribute(instance, p2, "Duration")
			module.scaleAttribute(instance, p2, "Speed_Duration")
			module.scaleAttribute(instance, p2, "EmitDelay")
		end
	end
}

function Retime.batch(p: number, ...)
	local v = 1 / p

	for _, folder in { ... } do
		Retime.apply(folder, p, v)

		for _, descendant in folder:GetDescendants() do
			Retime.apply(descendant, p, v)
		end
	end
end

return Retime