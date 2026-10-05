local Digit = require(script.Digit)
local NumberSpinner = {}
local v = {
	Frame = true,
	Digits = true,
	CommaLabels = true,
	Text = true
}
local v2 = {
	Value = "number",
	Duration = "number",
	Decimals = "number",
	Prefix = "string",
	Suffix = "string",
	Commas = "boolean",
	TextScaled = "boolean",
	UIStroke = "Instance"
}
local v3 = {
	[Enum.TextXAlignment.Center] = Enum.HorizontalAlignment.Center,
	[Enum.TextXAlignment.Left] = Enum.HorizontalAlignment.Left,
	[Enum.TextXAlignment.Right] = Enum.HorizontalAlignment.Right
}
local frame = Instance.new("Frame")
local textLabel = Instance.new("TextLabel")
textLabel.TextSize = 25
textLabel.TextColor3 = Color3.fromRGB(250, 250, 255)
textLabel.FontFace = Font.new("SourceSans")

local function newSpinner()
	local v4 = {
		Value = 0,
		Duration = 0.3,
		Decimals = 2,
		Prefix = "$",
		Suffix = "",
		Commas = false,
		Digits = {
			Whole = table.create(3),
			Decimal = table.create(2)
		},
		CommaLabels = table.create(2),
		Frame = nil,
		UIStroke = nil,
		Layout = nil,
		PrefixLabel = nil,
		SuffixLabel = nil,
		DecimalLabel = nil,
		NegativeLabel = nil
	}
	local object = setmetatable({}, {
		__index = function(_, p)
			local v5 = v4[p]

			if v5 then
				return v5
			end

			if pcall(function()
				local _ = frame[p]
			end) then
				return v4.Frame[p]
			end

			local success, result = pcall(function()
				return textLabel[p]
			end)

			if not success then
				return nil
			end

			local v6 = v4.Digits.Whole[1]

			if v6 then
				return v6[p]
			end

			return result
		end,
		__newindex = function(_, p, p2)
			if v[p] then
				warn("Attempted to set read-only value Spinner." .. p)
			elseif pcall(function()
				local _ = frame[p]
			end) then
				local typeName = typeof(frame[p])

				if typeName == "nil" or typeName == typeof(p2) then
					v4.Frame[p] = p2
				else
					warn("Attempted to set Spinner." .. p .. " to invalid value (" .. tostring(p2) .. ")")
				end
			elseif p == "TextXAlignment" then
				v4.Layout.HorizontalAlignment = v3[p2]
			elseif pcall(function()
				local _ = textLabel[p]
			end) then
				local typeName = typeof(textLabel[p])

				if typeName ~= "nil" and typeName ~= typeof(p2) then
					warn("Attempted to set Spinner." .. p .. " to invalid value (" .. tostring(p2) .. ")")
					return
				end

				for _, v5 in pairs(v4.Digits.Whole) do
					v5[p] = p2
				end

				for _, v5 in pairs(v4.Digits.Decimal) do
					v5[p] = p2
				end

				for _, commaLabel in pairs(v4.CommaLabels) do
					commaLabel[p] = p2
				end

				v4.PrefixLabel[p] = p2
				v4.SuffixLabel[p] = p2
				v4.DecimalLabel[p] = p2
				v4.NegativeLabel[p] = p2
			else
				if not v2[p] then
					return
				end

				if typeof(p2) ~= v2[p] then
					warn("Attempted to set Spinner." .. p .. " to invalid value (" .. tostring(p2) .. ")")
					return
				end

				v4[p] = p2
				v4:Update(p, p2)
			end
		end
	})

	function v4:Destroy()
		self.Frame:Destroy()
		table.clear(self)
	end

	function v4:Update(p)
		if p == "Prefix" then
			v4.PrefixLabel.Text = v4.Prefix
			return
		elseif p == "Suffix" then
			v4.SuffixLabel.Text = v4.Suffix
			return
		end

		local value = math.abs(v4.Value)
		local visible = v4.Value < 0

		if v4.NegativeLabel then
			v4.NegativeLabel.Visible = visible
		end

		local v6 = v4.Decimals > 0 and string.format("%." .. v4.Decimals .. "f", value) or string.format("%d", value)
		local v7 = string.split(v6, ".")
		local v8 = v7[1]
		local v9 = v7[2]

		if not v8 then
			return
		end

		local count = #v8

		for i = 1, count do
			local v10 = v4.Digits.Whole[i]

			if v10 then
				v10.Duration = v4.Duration
				v10.Value = tonumber((string.sub(v8, i, i)))
			else
				local v11 = Digit.new(object, i * 2 - 900, (tonumber((string.sub(v8, i, i)))))
				v4.Digits.Whole[i] = v11
			end
		end

		for i = count + 1, #v4.Digits.Whole do
			local v10 = v4.Digits.Whole[i]

			if not v10 then
				continue
			end

			v10:Destroy()
			v4.Digits.Whole[i] = nil
		end

		if v4.Commas then
			local v10 = count * 2 - 900
			local count2 = 0

			for i = 0, #string.format("%d", (math.floor((math.abs(v4.Value))))) - 1, 3 do
				if i == 0 then
					continue
				end

				count2 += 1
				local parent = v4.CommaLabels[count2]

				if not parent then
					parent = Instance.new("TextLabel")
					parent.Name = "Comma"
					parent.BackgroundTransparency = 1
					parent.Size = UDim2.new(0, 0, 1, 0)
					parent.FontFace = object.FontFace
					parent.TextSize = object.TextSize
					parent.TextColor3 = object.TextColor3
					parent.Text = ","
					parent.AutomaticSize = Enum.AutomaticSize.X

					if v4.UIStroke then
						local clone = v4.UIStroke:Clone()
						clone.Parent = parent
					end

					parent.Parent = v4.Frame
					v4.CommaLabels[count2] = parent
				end

				parent.LayoutOrder = v10 - (i - 1) * 2 - 1
			end

			for i = count2 + 1, #v4.CommaLabels do
				v4.CommaLabels[i]:Destroy()
				v4.CommaLabels[i] = nil
			end
		end

		if v9 then
			if v4.DecimalLabel then
				v4.DecimalLabel.Visible = true
			end

			for i = 1, #v9 do
				local v10 = v4.Digits.Decimal[i]

				if v10 then
					v10.Duration = v4.Duration
					v10.Value = tonumber((string.sub(v9, i, i)))
				else
					local v11 = Digit.new(object, i, (tonumber((string.sub(v9, i, i)))))
					v4.Digits.Decimal[i] = v11
				end
			end

			for i = #v9 + 1, #v4.Digits.Decimal do
				local v10 = v4.Digits.Decimal[i]

				if not v10 then
					continue
				end

				v10:Destroy()
				v4.Digits.Decimal[i] = nil
			end
		else
			if v4.DecimalLabel then
				v4.DecimalLabel.Visible = false
			end

			for _, v10 in ipairs(v4.Digits.Decimal) do
				v10:Destroy()
			end

			table.clear(v4.Digits.Decimal)
		end
	end

	return object, v4
end

function NumberSpinner.new(uIStroke)
	local v4, v5 = newSpinner()
	local frame2 = Instance.new("Frame")
	frame2.BackgroundTransparency = 1
	frame2.ClipsDescendants = true
	frame2.Size = UDim2.new(0, 200, 0, 50)
	frame2.Position = UDim2.new(0, 0, 0, 0)
	local uIListLayout = Instance.new("UIListLayout")
	uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout.FillDirection = Enum.FillDirection.Horizontal
	uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uIListLayout.Padding = UDim.new(0, 0)
	uIListLayout.Parent = frame2
	local textLabel2 = Instance.new("TextLabel")
	textLabel2.Name = "Prefix"
	textLabel2.LayoutOrder = -1000
	textLabel2.BackgroundTransparency = 1
	textLabel2.Size = UDim2.new(0, 0, 1, 0)
	textLabel2.FontFace = v4.FontFace
	textLabel2.TextSize = v4.TextSize
	textLabel2.TextColor3 = v4.TextColor3
	textLabel2.Text = v4.Prefix
	textLabel2.AutomaticSize = Enum.AutomaticSize.X

	if uIStroke then
		local clone = uIStroke:Clone()
		clone.Parent = textLabel2
	end

	textLabel2.Parent = frame2
	local textLabel3 = Instance.new("TextLabel")
	textLabel3.Name = "Suffix"
	textLabel3.LayoutOrder = 1000
	textLabel3.BackgroundTransparency = 1
	textLabel3.Size = UDim2.new(0, 0, 1, 0)
	textLabel3.FontFace = v4.FontFace
	textLabel3.TextSize = v4.TextSize
	textLabel3.TextColor3 = v4.TextColor3
	textLabel3.Text = v4.Suffix
	textLabel3.AutomaticSize = Enum.AutomaticSize.X

	if uIStroke then
		local clone_2 = uIStroke:Clone()
		clone_2.Parent = textLabel3
	end

	textLabel3.Parent = frame2
	local textLabel4 = Instance.new("TextLabel")
	textLabel4.Name = "Decimal"
	textLabel4.LayoutOrder = 0
	textLabel4.BackgroundTransparency = 1
	textLabel4.Size = UDim2.new(0, 0, 1, 0)
	textLabel4.FontFace = v4.FontFace
	textLabel4.TextSize = v4.TextSize
	textLabel4.TextColor3 = v4.TextColor3
	textLabel4.Text = "."
	textLabel4.AutomaticSize = Enum.AutomaticSize.X

	if uIStroke then
		local clone_3 = uIStroke:Clone()
		clone_3.Parent = textLabel4
	end

	textLabel4.Parent = frame2
	local textLabel5 = Instance.new("TextLabel")
	textLabel5.Name = "Negative"
	textLabel5.LayoutOrder = -999
	textLabel5.BackgroundTransparency = 1
	textLabel5.Size = UDim2.new(0, 0, 1, 0)
	textLabel5.FontFace = v4.FontFace
	textLabel5.TextSize = v4.TextSize
	textLabel5.TextColor3 = v4.TextColor3
	textLabel5.Text = "-"
	textLabel5.AutomaticSize = Enum.AutomaticSize.X

	if uIStroke then
		local clone_4 = uIStroke:Clone()
		clone_4.Parent = textLabel5
	end

	textLabel5.Parent = frame2
	v5.Frame = frame2
	v5.UIStroke = uIStroke
	v5.Layout = uIListLayout
	v5.PrefixLabel = textLabel2
	v5.SuffixLabel = textLabel3
	v5.DecimalLabel = textLabel4
	v5.NegativeLabel = textLabel5
	v4:Update()
	return v4
end

function NumberSpinner:fromGuiObject()
	if not (typeof(self) == "Instance" and self:IsA("GuiObject")) then
		return
	end

	local v4 = NumberSpinner.new(self:FindFirstChildWhichIsA("UIStroke"))
	v4.Name = "Spinner_" .. self.Name
	v4.SizeConstraint = self.SizeConstraint
	v4.Size = self.Size
	v4.Position = self.Position
	v4.AnchorPoint = self.AnchorPoint
	v4.Rotation = self.Rotation
	v4.LayoutOrder = self.LayoutOrder
	v4.ZIndex = self.ZIndex
	v4.Visible = self.Visible
	v4.BackgroundColor3 = self.BackgroundColor3
	v4.BorderColor3 = self.BorderColor3
	v4.BorderSizePixel = self.BorderSizePixel
	v4.BackgroundTransparency = self.BackgroundTransparency

	if self:IsA("TextLabel") or self:IsA("TextButton") or self:IsA("TextBox") then
		v4.FontFace = self.FontFace
		v4.TextSize = self.TextSize
		v4.TextColor3 = self.TextColor3
		v4.TextTransparency = self.TextTransparency
		v4.TextStrokeColor3 = self.TextStrokeColor3
		v4.TextStrokeTransparency = self.TextStrokeTransparency
		v4.Layout.HorizontalAlignment = v3[self.TextXAlignment]
	end

	v4.Parent = self.Parent
	self.Visible = false
	return v4
end

return NumberSpinner