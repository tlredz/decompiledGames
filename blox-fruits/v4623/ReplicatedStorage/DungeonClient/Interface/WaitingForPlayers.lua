local React = require(game.ReplicatedStorage.Packages.React)
require(game.ReplicatedStorage.Packages.ReactRoblox)
require(game.ReplicatedStorage.Util.Maid)
local createElement = React.createElement

local function rootWaitingComponent(p)
	local dungeonWaitingFolder = p.dungeonWaitingFolder
	local ref = React.useRef("")
	local children = dungeonWaitingFolder:GetChildren()
	local children2 = { (createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0.025, 0)
		})) }

	for _, folder in children do
		if not folder:IsA("Folder") then
			continue
		end

		local useRef = React.useRef
		local v

		if folder:GetAttribute("IsReady") then
			v = Color3.fromRGB(0, 167, 0)
		else
			v = Color3.fromRGB(231, 231, 231)
		end

		local color = useRef(v)
		table.insert(children2, createElement("ImageLabel", {
			Size = UDim2.new(0, 100, 0, 100),
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			Image = `https://www.roblox.com/bust-thumbnail/image?userId={folder.Name}&width=420&height=420&format=png`,
			ScaleType = Enum.ScaleType.Fit,
			ImageColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundColor3 = Color3.fromRGB(231, 231, 231)
		}, { createElement("UICorner", {
				CornerRadius = UDim.new(1, 0)
			}), (createElement("UIStroke", {
				Color = color,
				Thickness = 4
			})) }))
		local v4 = folder
		folder:GetAttributeChangedSignal("IsReady"):Connect(function()
			local color2 = color
			local current

			if v4:GetAttribute("IsReady") then
				current = Color3.fromRGB(0, 167, 0)
			else
				current = Color3.fromRGB(231, 231, 231)
			end

			color2.current = current
		end)
	end

	return createElement("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.new(0.5, 0, 0.6, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0
	}, { createElement("TextLabel", {
			Size = UDim2.new(0.85, 0, 0.05, 0),
			Position = UDim2.new(0, 0, 0.2, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Text = ref,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextScaled = true,
			Font = Enum.Font.Roboto,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Center
		}, { (createElement("UIStroke", {
				Color = Color3.fromRGB(0, 0, 0),
				Thickness = 1
			})) }), createElement("Frame", {
			Size = UDim2.new(0.85, 0, 0.15, 0),
			Position = UDim2.new(0, 0, 0.1, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			BorderSizePixel = 0
		}, children2) })
end

return rootWaitingComponent