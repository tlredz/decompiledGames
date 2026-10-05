local ColorPicker = require(script.Parent.Parent.ColorPicker)
script.Parent:GetPropertyChangedSignal("Text"):connect(function()
	script.Parent.Text = script.Parent.Text:sub(1, 7):upper()
end)
script.Parent.FocusLost:connect(function(_)
	local success, result = pcall(function()
		return Color3.fromHex(script.Parent.Text)
	end)

	if not success or #script.Parent.Text ~= 7 then
		script.Parent.Text = "#" .. ColorPicker:GetCurrentColor():ToHex()
		return
	end

	ColorPicker:SetPickerToColor(result)
	ColorPicker:UpdateColor()
end)