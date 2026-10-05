local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vide = require(ReplicatedStorage.Packages.Vide)
local create = Vide.create
local v = { "All", "Sent", "Received" }
local rbxassetfontsfamiliesRobotoMonojson = Font.new("rbxasset://fonts/families/RobotoMono.json")

local function MessagingLogConsole(data)
	local baseZIndex = data.baseZIndex
	local source = Vide.source(false)
	local v2 = { create("UIListLayout")({
			SortOrder = Enum.SortOrder.LayoutOrder
		}) }
	local v3 = nil
	local v4 = nil

	for k, text in v do
		local v6 = text
		table.insert(v2, create("TextButton")({
			AutoButtonColor = true,
			BackgroundColor3 = Color3.fromRGB(52, 52, 52),
			BorderColor3 = Color3.fromRGB(8, 8, 8),
			FontFace = rbxassetfontsfamiliesRobotoMonojson,
			LayoutOrder = k,
			Size = UDim2.new(1, 0, 0, 22),
			Text = text,
			TextColor3 = Color3.fromRGB(220, 220, 220),
			TextSize = 12,
			ZIndex = baseZIndex + 12,
			MouseButton1Click = function()
				source(false)

				if v3 then
					v3.Text = `{v6}  v`
				end

				data.onDirectionChanged(v6)
			end
		}))
	end

	return (create("Frame")({
		Name = "MessagingLogConsole",
		BackgroundColor3 = Color3.fromRGB(18, 18, 18),
		BorderColor3 = Color3.fromRGB(8, 8, 8),
		Size = UDim2.fromScale(1, 1),
		ZIndex = baseZIndex + 1,
		create("TextBox")({
			Name = "Search",
			BackgroundColor3 = Color3.fromRGB(31, 31, 31),
			BorderColor3 = Color3.fromRGB(8, 8, 8),
			ClearTextOnFocus = false,
			FontFace = rbxassetfontsfamiliesRobotoMonojson,
			PlaceholderText = "search topic or payload...",
			Position = UDim2.fromOffset(4, 4),
			Size = UDim2.new(1, -96, 0, 24),
			Text = "",
			TextColor3 = Color3.fromRGB(230, 230, 230),
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = baseZIndex + 3,
			create("UIPadding")({
				PaddingLeft = UDim.new(0, 7),
				PaddingRight = UDim.new(0, 7)
			}),
			Vide.action(function(instance)
				local textChangedConnection = instance:GetPropertyChangedSignal("Text"):Connect(function()
					data.onSearchChanged(string.lower(instance.Text))
				end)
				Vide.cleanup(textChangedConnection)
			end)
		}),
		create("TextButton")({
			Name = "DirectionFilter",
			AutoButtonColor = true,
			BackgroundColor3 = Color3.fromRGB(52, 52, 52),
			BorderColor3 = Color3.fromRGB(8, 8, 8),
			FontFace = rbxassetfontsfamiliesRobotoMonojson,
			Position = UDim2.new(1, -88, 0, 4),
			Size = UDim2.fromOffset(84, 24),
			Text = "All  v",
			TextColor3 = Color3.fromRGB(220, 220, 220),
			TextSize = 12,
			ZIndex = baseZIndex + 3,
			MouseButton1Click = function()
				source(not source())
			end,
			Vide.action(function(p)
				v3 = p
			end)
		}),
		create("Frame")({
			Name = "DirectionDropdown",
			BackgroundColor3 = Color3.fromRGB(38, 38, 38),
			BorderColor3 = Color3.fromRGB(8, 8, 8),
			Position = UDim2.new(1, -88, 0, 29),
			Size = UDim2.fromOffset(84, #v * 22),
			Visible = source,
			ZIndex = baseZIndex + 11,
			v2
		}),
		create("ScrollingFrame")({
			Name = "Rows",
			Active = true,
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = Color3.fromRGB(20, 20, 20),
			BorderColor3 = Color3.fromRGB(8, 8, 8),
			CanvasSize = UDim2.new(),
			Position = UDim2.fromOffset(4, 32),
			ScrollBarImageColor3 = Color3.fromRGB(95, 95, 95),
			ScrollBarThickness = 7,
			Size = UDim2.new(1, -8, 1, -64),
			ZIndex = baseZIndex + 2,
			Vide.action(function(p)
				data.onRowsMounted(p)
			end)
		}),
		create("TextButton")({
			Name = "Clear",
			AutoButtonColor = true,
			BackgroundColor3 = Color3.fromRGB(52, 52, 52),
			BorderColor3 = Color3.fromRGB(8, 8, 8),
			FontFace = rbxassetfontsfamiliesRobotoMonojson,
			Position = UDim2.new(0, 4, 1, -28),
			Size = UDim2.new(0.5, -6, 0, 24),
			Text = "Clear local",
			TextColor3 = Color3.fromRGB(220, 220, 220),
			TextSize = 12,
			ZIndex = baseZIndex + 3,
			MouseButton1Click = data.onClear
		}),
		create("TextButton")({
			Name = "Follow",
			AutoButtonColor = true,
			BackgroundColor3 = Color3.fromRGB(52, 52, 52),
			BorderColor3 = Color3.fromRGB(8, 8, 8),
			FontFace = rbxassetfontsfamiliesRobotoMonojson,
			Position = UDim2.new(0.5, 2, 1, -28),
			Size = UDim2.new(0.5, -6, 0, 24),
			Text = "Follow: ON",
			TextColor3 = Color3.fromRGB(140, 230, 140),
			TextSize = 12,
			ZIndex = baseZIndex + 3,
			MouseButton1Click = function()
				if v4 then
					data.onToggleFollow(v4)
				end
			end,
			Vide.action(function(p)
				v4 = p
			end)
		})
	}))
end

return MessagingLogConsole