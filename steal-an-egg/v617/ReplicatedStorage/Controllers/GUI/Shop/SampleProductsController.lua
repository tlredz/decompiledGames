local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GUI = require(ReplicatedStorage.Client.GUI)
require(ReplicatedStorage.Client.Types.GUI)
return {
	Start = function()
		local shop = GUI.Shop()
		local samples = shop.Frame.ScrollingFrame.Samples
		local samples2 = shop.Frame.ButtonsHolder.Samples
		samples.Visible = false
		samples2.Visible = false
		samples2.Active = false
		samples2.Selectable = false
		samples2.Interactable = false

		for _, button in samples:GetDescendants() do
			if not button:IsA("GuiButton") then
				continue
			end

			button.Active = false
			button.Selectable = false
			button.Interactable = false
		end
	end
}