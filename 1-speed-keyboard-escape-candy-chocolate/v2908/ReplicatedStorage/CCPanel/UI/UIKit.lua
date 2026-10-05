local UIKit = {
	C_BG = Color3.fromRGB(25, 25, 30),
	C_HEADER = Color3.fromRGB(18, 18, 22),
	C_SECTION = Color3.fromRGB(32, 32, 40),
	C_ENTRY = Color3.fromRGB(42, 42, 50),
	C_HOVER = Color3.fromRGB(58, 58, 70),
	C_SEL = Color3.fromRGB(40, 80, 140),
	C_ON = Color3.fromRGB(60, 180, 90),
	C_OFF = Color3.fromRGB(180, 60, 60),
	C_ACCENT = Color3.fromRGB(80, 130, 220),
	C_TEXT = Color3.fromRGB(220, 220, 230),
	C_SUB = Color3.fromRGB(150, 150, 165),
	FONT = Enum.Font.GothamMedium,
	FONT_BOLD = Enum.Font.GothamBold,
	corner = function(parent, value: number?)
		local uICorner = Instance.new("UICorner")
		uICorner.CornerRadius = UDim.new(0, value or 6)
		uICorner.Parent = parent
	end
}

function UIKit.label(parent, name, text, size, position, value, p, p2, p3)
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = name
	textLabel.Size = size
	textLabel.Position = position
	textLabel.BackgroundTransparency = 1
	textLabel.Text = text
	textLabel.TextSize = value or 13
	textLabel.TextColor3 = p or UIKit.C_TEXT
	textLabel.Font = p2 or UIKit.FONT
	textLabel.TextXAlignment = p3 or Enum.TextXAlignment.Left
	textLabel.Parent = parent
	return textLabel
end

function UIKit.btn(parent, name, text, size, position, p, p2)
	local textButton = Instance.new("TextButton")
	textButton.Name = name
	textButton.Size = size
	textButton.Position = position
	textButton.BackgroundColor3 = p or UIKit.C_ENTRY
	textButton.TextColor3 = p2 or UIKit.C_TEXT
	textButton.Text = text
	textButton.TextSize = 13
	textButton.Font = UIKit.FONT
	textButton.BorderSizePixel = 0
	textButton.AutoButtonColor = false
	UIKit.corner(textButton, 5)
	textButton.Parent = parent
	local backgroundColor = p or UIKit.C_ENTRY
	textButton.MouseEnter:Connect(function()
		if textButton:GetAttribute("locked") then
			return
		end

		textButton.BackgroundColor3 = UIKit.C_HOVER
	end)
	textButton.MouseLeave:Connect(function()
		if textButton:GetAttribute("locked") then
			return
		end

		textButton.BackgroundColor3 = backgroundColor
	end)
	return textButton
end

function UIKit.invoke(object, ...)
	local v, v2 = object:request(...):await()

	if v and type(v2) == "table" then
		return v2
	end

	return {
		success = false,
		error = "Erreur serveur"
	}
end

function UIKit.formatTimeRemaining(p: number, p2: number)
	if p == 0 then
		return ""
	end

	local v = p2 - (os.time() - p)

	if v <= 0 then
		return "Expired"
	end

	local v2 = math.floor(v / 86400)
	local v3 = math.floor(v % 86400 / 3600)
	local v4 = math.floor(v % 3600 / 60)

	if v2 > 0 then
		return "⏱ " .. v2 .. "d " .. v3 .. "h"
	end

	if v3 > 0 then
		return "⏱ " .. v3 .. "h " .. v4 .. "m"
	end

	return "⏱ " .. v4 .. "m"
end

return UIKit