local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Packages.Signal)
local _ = {
	minItemsToRender = 4
}

local function createDropdown(data)
	local default = data.default or data.options[1]
	local minItemsToRender = data.minItemsToRender or 4
	local parent

	if data.scroll then
		parent = data.scroll
	else
		parent = Instance.new("ScrollingFrame")
		parent.AnchorPoint = Vector2.new(0.5, 0)
		parent.BackgroundTransparency = 0.55
		parent.BorderSizePixel = 0
		parent.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		parent.ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
		parent.ScrollBarThickness = 0
		parent.CanvasSize = UDim2.fromOffset(0, 0)
		parent.ScrollingDirection = Enum.ScrollingDirection.Y
		parent.Position = UDim2.new(0.5, 0, 0, -4)
		local uIListLayout = Instance.new("UIListLayout")
		uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		uIListLayout.Padding = UDim.new(0.05, 0)
		uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		uIListLayout.Parent = parent
		local uIPadding = Instance.new("UIPadding")
		uIPadding.Name = "UIPadding"
		uIPadding.PaddingTop = UDim.new(0, 32)
		uIPadding.Parent = parent
		parent.ZIndex = data.root.ZIndex - 1
		parent.Parent = data.root
	end

	local uIPadding = parent:FindFirstChildWhichIsA("UIPadding")
	local textLabel = data.root:FindFirstChildWhichIsA("TextLabel")
	local clones = {}
	local selectedOption = nil
	local optionChanged = v.new()

	local function updateButtonsSize()
		local absoluteSize = data.root.AbsoluteSize
		local v5 = absoluteSize.Y * minItemsToRender

		if uIPadding then
			uIPadding.PaddingTop = UDim.new(0, absoluteSize.Y * 1.4)
			v5 += absoluteSize.Y + 4
		end

		parent.Size = UDim2.fromOffset(absoluteSize.X + 8, v5)

		for _, v6 in clones do
			v6.Size = UDim2.fromOffset(absoluteSize.X, absoluteSize.Y)
		end
	end

	local function switch(visible: boolean?)
		local v5 = parent

		if type(visible) ~= "boolean" then
			visible = not parent.Visible
		end

		v5.Visible = visible
	end

	local function setSelected(text: string)
		parent.Visible = false

		if selectedOption == text or not table.find(data.options, text) then
			return
		end

		if textLabel then
			textLabel.Text = text
		end

		selectedOption = text
		optionChanged:Fire(text)
	end

	for k, option in data.options do
		local clone = data.root:Clone()
		local textLabel2 = clone:FindFirstChildWhichIsA("TextLabel")

		if textLabel2 then
			textLabel2.Text = option
		end

		local text = option
		clone.Activated:Connect(function()
			local text2 = text
			parent.Visible = false

			if selectedOption ~= text2 then
				if not table.find(data.options, text2) then
					return
				end

				if textLabel then
					textLabel.Text = text2
				end

				selectedOption = text2
				optionChanged:Fire(text2)
			end
		end)
		clone.LayoutOrder = k
		clone.Parent = parent
		clones[k] = clone
	end

	parent.Visible = false

	if selectedOption ~= default and table.find(data.options, default) then
		if textLabel then
			textLabel.Text = default
		end

		selectedOption = default
		optionChanged:Fire(default)
	end

	local absoluteSizeChangedConnection = data.root:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateButtonsSize)
	task.defer(updateButtonsSize)
	local activatedConnection = data.root.Activated:Connect(switch)

	local function destroy()
		absoluteSizeChangedConnection:Disconnect()
		activatedConnection:Disconnect()
		absoluteSizeChangedConnection = nil
		activatedConnection = nil

		for _, v5 in clones do
			v5:Destroy()
		end

		if data.scroll == nil then
			parent:Destroy()
		end

		clones = {}
		optionChanged:Destroy()
	end

	return {
		switch = switch,
		destroy = destroy,
		setSelected = setSelected,
		selectedOption = selectedOption,
		optionChanged = optionChanged
	}
end

return createDropdown