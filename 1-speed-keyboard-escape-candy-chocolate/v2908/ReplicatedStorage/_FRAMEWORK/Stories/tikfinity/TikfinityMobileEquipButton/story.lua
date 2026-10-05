local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.Packages
local UILabs = require(packages["UI-Labs"])
local Vide = require(packages.Vide)
local TikfinityMobileEquipButton = require(ReplicatedStorage._FRAMEWORK.Libraries.uiComponents.TikfinityMobileEquipButton)
return UILabs.CreateVideStory({
	name = "Tikfinity - Mobile Equip Button",
	vide = Vide,
	controls = {
		label = UILabs.Choose({
			"EQUIP",
			"SLOT 1",
			"SLOT 2",
			"SLOT 3"
		})
	}
}, function(p)
	return TikfinityMobileEquipButton({
		position = UDim2.fromScale(0.35, 0.425),
		size = UDim2.fromScale(0.3, 0.15),
		text = p.controls.label,
		onActivated = function()
			print("[TikfinityMobileEquipButton.story] activated")
		end
	})
end)