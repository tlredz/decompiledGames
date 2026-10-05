local createVector = vector.create
local parent = script.Parent.Parent
local shared = parent.Parent.Shared
local hooks = parent.Hooks
local React = require(shared.React)
local useClock = require(hooks.useClock)
local useSpring = require(hooks.useSpring)
local useAttribute = require(hooks.useAttribute)
local useProductInfo = require(hooks.useProductInfo)

local function maybeString(value)
	return type(value) == "string" and value or nil
end

local function GameInfo(props)
	local adornee = props.Adornee
	local v = useAttribute(adornee, "PlaceId", tonumber) or props.PlaceId
	local gameName = useAttribute(adornee, "GameName", maybeString)
	local text = useAttribute(adornee, "Integration", maybeString)
	local v3 = useProductInfo(v)
	local v4, v5 = React.useBinding(false)
	local creator = v3 and v3.Creator
	local name = creator and creator.Name

	if creator and name and creator.HasVerifiedBadge then
		name ..= utf8.char(57344)
	end

	if gameName == nil and v3 then
		gameName = props.GameName or v3.Name
	end

	local groupTransparency = useSpring(v4:map(function(p)
		if p then
			return 0
		end

		return 1
	end))
	useClock(3, function()
		local adornee2 = props.Adornee

		if adornee2 then
			local pivot = nil

			if adornee2:IsA("PVInstance") then
				pivot = adornee2:GetPivot()
			elseif adornee2:IsA("Attachment") then
				pivot = adornee2.WorldCFrame
			end

			if pivot then
				local currentCamera = workspace.CurrentCamera
				v5((pivot.Position - currentCamera.Focus.Position).Magnitude < 40)
			end
		end
	end, { props.Adornee })
	return React.createElement(React.Fragment, nil, {
		Integration = text and React.createElement("BillboardGui", {
			Active = true,
			Brightness = 5,
			Size = UDim2.fromOffset(300, 150),
			StudsOffset = createVector(0, 10, 0),
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		}, {
			Text = React.createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				FontFace = Font.new(
					"rbxasset://fonts/families/JosefinSans.json",
					Enum.FontWeight.Bold,
					Enum.FontStyle.Normal
				),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromOffset(200, 50),
				Text = text,
				TextScaled = true,
				TextTransparency = 1
			}, {
				Stroke = React.createElement("UIStroke", {
					Color = Color3.fromRGB(255, 127, 255),
					Thickness = 2
				})
			})
		}),
		GameInfo = React.createElement("BillboardGui", {
			Active = true,
			AlwaysOnTop = true,
			MaxDistance = 64,
			Size = UDim2.fromScale(7.5, 4.875),
			SizeOffset = Vector2.new(0, 0.5),
			StudsOffset = createVector(0, 1, 0),
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
			Adornee = props.Adornee
		}, {
			Shadow = React.createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Image = "rbxassetid://222785823",
				ImageTransparency = groupTransparency:map(function(p: number)
					return p * 0.2 + 0.8
				end),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(1.5, 1.5),
				ZIndex = 0
			}),
			Fade = React.createElement("CanvasGroup", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.5),
				GroupTransparency = groupTransparency,
				Size = UDim2.fromScale(1, 1)
			}, {
				Scale = React.createElement("UIScale", {
					Scale = groupTransparency:map(function(p: number)
						return p * 0.2 + 1
					end)
				}),
				Info = React.createElement("TextLabel", {
					BackgroundTransparency = 1,
					FontFace = Font.new("rbxassetid://12187365364"),
					LayoutOrder = 3,
					Position = UDim2.fromScale(0, 1),
					RichText = true,
					Size = UDim2.fromScale(0.875, 0.25),
					Text = `<b>{gameName}</b>\n<font size="6">` .. (not name and "" or `by: <b>{name}</b>`) .. "</font>",
					TextColor3 = Color3.new(1, 1, 1),
					TextScaled = true,
					TextStrokeTransparency = 0.5
				}),
				Thumbnail = React.createElement("ImageLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Image = `https://www.roblox.com/asset-thumbnail/image?assetId={v}&width=768&height=432&format=png`,
					LayoutOrder = 2,
					Position = UDim2.fromScale(0.5, 0.5),
					ScaleType = Enum.ScaleType.Fit,
					Size = UDim2.fromScale(1, 0.8)
				}),
				Header = React.createElement("TextLabel", {
					BackgroundTransparency = 1,
					FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
					Size = UDim2.fromScale(0.875, 0.2),
					Text = "Featured RELICSxyz Partner:",
					TextColor3 = Color3.new(1, 1, 1),
					TextScaled = true,
					TextStrokeTransparency = 0.5
				}),
				List = React.createElement("UIListLayout", {
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					Padding = UDim.new(0.025, 0),
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Bottom,
					VerticalFlex = Enum.UIFlexAlignment.Fill
				})
			})
		})
	})
end

return GameInfo