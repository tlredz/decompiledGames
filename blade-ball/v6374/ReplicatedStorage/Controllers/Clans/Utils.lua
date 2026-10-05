local _ = {
	Selected = "rbxassetid://138019256440659",
	SelectedHover = "rbxassetid://91982978538238",
	Unselected = "rbxassetid://99902288883618",
	UnselectedHover = "rbxassetid://84290715964709"
}
local v = {
	Selected = Color3.fromRGB(68, 34, 0),
	Unselected = Color3.fromRGB(0, 54, 81)
}
return {
	setButtonImages = function(instance, flag: boolean)
		instance.Image = flag and "rbxassetid://138019256440659" or "rbxassetid://99902288883618"
		instance.HoverImage = flag and "rbxassetid://91982978538238" or "rbxassetid://84290715964709"
		local textLabel = instance:FindFirstChildWhichIsA("TextLabel")
		local uIStroke

		if textLabel then
			uIStroke = textLabel:FindFirstChildWhichIsA("UIStroke")
		end

		if uIStroke then
			local color

			if flag then
				color = v.Selected
			else
				color = v.Unselected
			end

			uIStroke.Color = color
		end
	end
}