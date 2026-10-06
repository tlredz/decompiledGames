local module = require("@game/ReplicatedStorage/Omni")
local UIGradient = {
	SetupGradient = function(uIGradient)
		if not (uIGradient and uIGradient:IsA("UIGradient")) or uIGradient:IsDescendantOf(module.Services.StarterGui) then
			return
		end

		module.Gradient:CreateGradient(uIGradient)
	end,
	SetupTemplateGradient = function(frame)
		if not (frame and frame:IsA("Frame")) then
			return
		end

		local rarity = frame:GetAttribute("Rarity")

		if not rarity or rarity == "" then
			return
		end

		module.Utils.Instance:SetupTemplateForRarity(frame, rarity)
	end
}
module.Utils.Instance:ObserveTaggedObject("GradientWaves", UIGradient.SetupGradient)
module.Utils.Instance:ObserveTaggedObject("GradientWavesTemplate", UIGradient.SetupTemplateGradient)
return UIGradient