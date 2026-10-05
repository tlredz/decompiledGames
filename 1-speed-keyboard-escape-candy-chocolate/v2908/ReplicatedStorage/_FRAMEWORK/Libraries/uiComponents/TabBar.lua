local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vide = require(ReplicatedStorage.Packages.Vide)
local VideUtil = require(script.Parent.Parent.Basics.VideUtil)
local create = Vide.create
local defaulted = VideUtil.defaulted
local read = VideUtil.read
local rbxassetfontsfamiliesGothamSSmjson = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Heavy)
local color = Color3.fromRGB(22, 28, 44)
local color2 = Color3.fromRGB(22, 28, 44)

local function tabButton(data, tab, i: number, p: number)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function selected()
		return read(data.SelectedId) == tab.Id
	end

	return create("TextButton")({
		Name = tab.Id,
		LayoutOrder = i,
		Size = UDim2.fromScale(p, 1),
		BackgroundColor3 = function()
			local v

			if selected() then
				v = defaulted(data.SelectedColor, Color3.fromRGB(255, 200, 60))
			else
				v = defaulted(data.Color, Color3.fromRGB(58, 66, 86))
			end

			return read(v)
		end,
		AutoButtonColor = false,
		Text = "",
		ZIndex = data.ZIndex or 1,
		MouseButton1Click = function()
			data.OnSelect(tab.Id)
		end,
		create("UICorner")({
			CornerRadius = defaulted(data.CornerRadius, UDim.new(0.35, 0))
		}),
		create("UIStroke")({
			Color = defaulted(data.StrokeColor, color),
			Thickness = function()
				if selected() then
					return 0.12
				end

				return 0.08
			end,
			StrokeSizingMode = 1
		}),
		create("TextLabel")({
			Name = "Label",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.86, 0.62),
			BackgroundTransparency = 1,
			FontFace = rbxassetfontsfamiliesGothamSSmjson,
			Text = tab.Label,
			TextColor3 = function()
				local v

				if selected() then
					v = defaulted(data.SelectedTextColor, Color3.fromRGB(255, 197, 105))
				else
					v = defaulted(data.TextColor, Color3.fromRGB(226, 234, 250))
				end

				return read(v)
			end,
			TextScaled = true,
			ZIndex = (data.ZIndex or 1) + 1,
			create("UIStroke")({
				Color = defaulted(data.TextStrokeColor, color2),
				Thickness = 0.1,
				StrokeSizingMode = 1
			})
		})
	})
end

local function TabBar(data)
	local count = #data.Tabs
	local padding = data.Padding or 0.02
	local v = not (count > 0) and 1 or (1 - padding * (count - 1)) / count
	local v2 = {}

	for i, tab in ipairs(data.Tabs) do
		v2[i] = tabButton(data, tab, i, v)
	end

	return create("Frame")({
		Name = data.Name or "TabBar",
		AnchorPoint = data.AnchorPoint,
		Position = data.Position,
		Size = defaulted(data.Size, UDim2.fromScale(1, 1)),
		BackgroundTransparency = 1,
		ZIndex = data.ZIndex or 1,
		create("UIListLayout")({
			Padding = UDim.new(padding, 0),
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder
		}),
		v2
	})
end

return TabBar