local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vide = require(ReplicatedStorage.Packages.Vide)
require(script.Parent.Types)
local RowTheme = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.RowTheme)
local VideUtil = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.VideUtil)
local create = Vide.create
local defaulted = VideUtil.defaulted
local read = VideUtil.read
local rbxassetfontsfamiliesGothamSSmjson = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Heavy)
local numberSequence = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 1),
	NumberSequenceKeypoint.new(0.35, 0.15),
	NumberSequenceKeypoint.new(1, 0.15)
})

local function fadeLine(name: string, point: Vector2, udim: UDim2, rotation: number, lineColor)
	return create("Frame")({
		Name = name,
		AnchorPoint = point,
		Position = udim,
		Size = UDim2.fromScale(0.3, 0.08),
		BackgroundColor3 = lineColor,
		create("UIGradient")({
			Rotation = rotation,
			Transparency = numberSequence
		}),
		create("UICorner")({
			CornerRadius = UDim.new(1, 0)
		})
	})
end

local function CategorySeparator(data)
	local function style()
		local variant = data.Variant
		local styleFor = RowTheme.styleFor
		local v

		if variant ~= nil then
			v = read(variant)
		end

		return styleFor(v)
	end

	local function lineColor()
		local variant = data.Variant
		local styleFor = RowTheme.styleFor
		local v

		if variant ~= nil then
			v = read(variant)
		end

		return styleFor(v).SeparatorColor
	end

	return create("Frame")({
		Name = data.Name or "CategorySeparator",
		LayoutOrder = data.LayoutOrder or 0,
		Size = defaulted(data.Size, UDim2.fromScale(1, 0.14)),
		BackgroundTransparency = 1,
		fadeLine("LeftLine", Vector2.new(0, 0.5), UDim2.fromScale(0.02, 0.5), 0, lineColor),
		fadeLine("RightLine", Vector2.new(1, 0.5), UDim2.fromScale(0.98, 0.5), 180, lineColor),
		create("TextLabel")({
			Name = "Label",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.34, 0.72),
			BackgroundTransparency = 1,
			FontFace = rbxassetfontsfamiliesGothamSSmjson,
			Text = data.Label,
			TextColor3 = function()
				local variant = data.Variant
				local styleFor = RowTheme.styleFor
				local v

				if variant ~= nil then
					v = read(variant)
				end

				return styleFor(v).TitleColor
			end,
			TextScaled = true,
			create("UIStroke")({
				Color = function()
					local variant = data.Variant
					local styleFor = RowTheme.styleFor
					local v

					if variant ~= nil then
						v = read(variant)
					end

					return styleFor(v).TitleStrokeColor
				end,
				Thickness = 0.1,
				StrokeSizingMode = 1
			})
		})
	})
end

return CategorySeparator