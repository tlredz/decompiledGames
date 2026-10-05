return {
	Register = function(_, button)
		if not button then
			return nil
		end

		local imageColor3 = nil
		local v = nil

		if button:IsA("ImageButton") then
			imageColor3 = button.ImageColor3
			v = button
		else
			local imageLabel = button:FindFirstChildWhichIsA("ImageLabel")

			if imageLabel then
				imageColor3 = imageLabel.ImageColor3
				v = imageLabel
			end
		end

		local textLabel = button:FindFirstChildWhichIsA("TextLabel")

		local function apply()
			local disabled = button:GetAttribute("Disabled") == true
			button.Active = not disabled
			button.Interactable = not disabled

			if imageColor3 and v then
				if textLabel then
					textLabel.TextTransparency = disabled and 0.7 or 0
				end

				if disabled then
					v.ImageColor3 = Color3.new(imageColor3.R * 0.5, imageColor3.G * 0.5, imageColor3.B * 0.5)
				else
					v.ImageColor3 = imageColor3
				end
			end
		end

		local disabledChangedConnection = button:GetAttributeChangedSignal("Disabled"):Connect(apply)
		button:SetAttribute("Disabled", button:GetAttribute("Disabled") == true)
		apply()
		return disabledChangedConnection
	end
}