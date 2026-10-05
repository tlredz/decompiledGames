local Serialise = {}

function Serialise.serializeHumanoidDescription(object)
	return {
		Properties = {
			Shirt = object.Shirt,
			Pants = object.Pants,
			Face = object.Face,
			Torso = object.Torso,
			RightLeg = object.RightLeg,
			LeftLeg = object.LeftLeg,
			LeftArm = object.LeftArm,
			RightArm = object.RightArm,
			Head = object.Head,
			GraphicTShirt = object.GraphicTShirt,
			BodyTypeScale = object.BodyTypeScale,
			DepthScale = object.DepthScale,
			HeadScale = object.HeadScale,
			HeightScale = object.HeightScale,
			ProportionScale = object.ProportionScale,
			WidthScale = object.WidthScale,
			BackAccessory = object.BackAccessory,
			FaceAccessory = object.FaceAccessory,
			FrontAccessory = object.FrontAccessory,
			HairAccessory = object.HairAccessory,
			HatAccessory = object.HatAccessory,
			NeckAccessory = object.NeckAccessory,
			ShouldersAccessory = object.ShouldersAccessory,
			WaistAccessory = object.WaistAccessory,
			ClimbAnimation = object.ClimbAnimation,
			FallAnimation = object.FallAnimation,
			IdleAnimation = object.IdleAnimation,
			JumpAnimation = object.JumpAnimation,
			MoodAnimation = object.MoodAnimation,
			RunAnimation = object.RunAnimation,
			SwimAnimation = object.SwimAnimation,
			WalkAnimation = object.WalkAnimation
		},
		Colors = {
			HeadColor = object.HeadColor,
			LeftArmColor = object.LeftArmColor,
			RightArmColor = object.RightArmColor,
			LeftLegColor = object.LeftLegColor,
			RightLegColor = object.RightLegColor,
			TorsoColor = object.TorsoColor
		},
		LayeredClothing = object:GetAccessories(false)
	}
end

function Serialise.deSerializeHumanoidDescription(data)
	local humanoidDescription = Instance.new("HumanoidDescription")

	for k, property in data.Properties do
		if property ~= 0 then
			humanoidDescription[k] = property
		end
	end

	for k, color in data.Colors do
		humanoidDescription[k] = color
	end

	humanoidDescription:SetAccessories(data.LayeredClothing, false)
	return humanoidDescription
end

return Serialise