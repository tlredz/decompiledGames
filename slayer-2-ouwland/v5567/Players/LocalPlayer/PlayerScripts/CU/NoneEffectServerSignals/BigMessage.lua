local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PopUpCreator = require(ReplicatedStorage.CAM.Global.Subsets.Classes.PopUpCreator)
return function(data)
	if data == nil or data.Text == nil then
		return
	end

	PopUpCreator.new({
		Type = "BigMessage",
		Content = data.Text,
		Timout = data.Timout,
		Color = data.Color,
		BackgroundTransparency = data.BackgroundTransparency,
		Sound = data.Sound
	})
end