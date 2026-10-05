local React = require(game.ReplicatedStorage.Packages.React)
local IdMap = require(game.ReplicatedStorage.IdMap)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local Textures = require(game.ReplicatedStorage.Textures)
local FormatUtil = require(game.ReplicatedStorage.React.FormatUtil)
local Card = require(game.ReplicatedStorage.React.Components.Shop.Card)
local useSale = require(game.ReplicatedStorage.React.Hooks.useSale)
local useRobuxPrice = require(game.ReplicatedStorage.React.Hooks.Item.useRobuxPrice)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local gamepassBundle = IdMap.Redeemable.GamepassBundle
local unwrapped = ItemConfig.match(gamepassBundle):unwrap()
local colorSequence = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 0.7, 1)),
	ColorSequenceKeypoint.new(0.25, Color3.fromHSV(0.15, 1, 1)),
	ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.4, 0.8, 1)),
	ColorSequenceKeypoint.new(0.7, Color3.fromHSV(0.6, 0.8, 1)),
	ColorSequenceKeypoint.new(0.85, Color3.fromHSV(0.7, 0.7, 1)),
	ColorSequenceKeypoint.new(1, Color3.fromHSV(0, 0.7, 1))
})
local createElement = React.createElement

function evalColorSequence(sequence, p: number)
	if p == 0 then
		return sequence.Keypoints[1].Value
	elseif p == 1 then
		return sequence.Keypoints[#sequence.Keypoints].Value
	end

	for i = 1, #sequence.Keypoints - 1 do
		local keypoint = sequence.Keypoints[i]
		local keypoint2 = sequence.Keypoints[i + 1]

		if not (keypoint.Time <= p and p < keypoint2.Time) then
			continue
		end

		local v = (p - keypoint.Time) / (keypoint2.Time - keypoint.Time)
		return Color3.new(
			(keypoint2.Value.R - keypoint.Value.R) * v + keypoint.Value.R,
			(keypoint2.Value.G - keypoint.Value.G) * v + keypoint.Value.G,
			(keypoint2.Value.B - keypoint.Value.B) * v + keypoint.Value.B
		)
	end

	return sequence.Keypoints[#sequence.Keypoints].Value
end

function animate(p: string, p2: number, p3: number, p4: number)
	return FormatUtil.font(p, {
		color = evalColorSequence(colorSequence, (p2 + p3) % 1):Lerp(CONSTANTS.COLOR.PALETTE.WHITE, p4 * 0.2)
	})
end

function splitAnimate(value: string, p: number)
	local v = p % 3 / 3
	local v2 = math.clamp(math.sin(p * 2) * 0.5 + 0.5, 0, 1)
	local count = 0

	for i = 1, value:len() do
		if value:sub(i, i) ~= " " then
			count += 1
		end
	end

	local v3 = {}
	local count2 = 0

	for i = 1, value:len() do
		local v4 = value:sub(i, i)

		if v4 == " " then
			table.insert(v3, " ")
		else
			table.insert(v3, animate(v4, v, count2 / count, v2))
			count2 += 1
		end
	end

	return table.concat(v3, "")
end

return function(props)
	local v = useSale("Easter2026")
	local price = useRobuxPrice(gamepassBundle)
	return createElement(Card, {
		ZIndex = props.ZIndex,
		Position = props.Position,
		Size = props.Size,
		AnchorPoint = props.AnchorPoint,
		LayoutOrder = props.LayoutOrder,
		SizeConstraint = props.SizeConstraint,
		AutomaticSize = props.AutomaticSize,
		Title = unwrapped.Display.Name or unwrapped.Index.StorageKey,
		TitleColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("#f4e400")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("#f4ab00"))
		}),
		ProductImage = Textures.banner.shop["GamepassBundle.png"],
		Description = function(p: number)
			return FormatUtil.stroke(
				"Get " .. FormatUtil.clean("<") .. splitAnimate("Fruit Notifier", p) .. FormatUtil.clean(">") .. " & " .. FormatUtil.innerArrowBracket(
					"2x Mastery",
					"Premium"
				) .. " & " .. FormatUtil.innerArrowBracket("2x Boss Drop", Color3.fromHex("#00bfff")) .. " & " .. FormatUtil.innerArrowBracket(
					"2x Money",
					"Green"
				) .. " & " .. FormatUtil.innerArrowBracket("Fast Boats", "Mythical") .. " + " .. FormatUtil.font(
					"$" .. FormatUtil.commaInteger(1800000),
					{
						color = Color3.fromRGB(102, 255, 102)
					}
				) .. (" + " .. FormatUtil.font("ƒ" .. FormatUtil.commaInteger(10000), {
					color = Color3.fromRGB(255, 0, 255)
				})) .. " in storage!",
				{
					thickness = 1.5
				}
			)
		end,
		Price = price,
		OriginalPrice = 6298,
		SaleFinishAt = v and v.Date.Finish:unwrap(),
		OnPreviewClick = props.OnPreviewClick,
		OnClick = props.OnClick and function()
			props.OnClick(gamepassBundle)
		end,
		FlexWidthRatio = props.FlexWidthRatio or 4
	})
end