local React = require(game.ReplicatedStorage.Packages.React)
local PreviewModel = require(game.ReplicatedStorage.Controllers.UI.Spinner.Components.PreviewModel)
return function(p)
	local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
	local ref = React.useRef(nil)
	local ref2 = React.useRef(nil)
	local v = React.useMemo(function()
		if not p.Selected then
			return nil
		end

		local itemId = p.Selected:GetAttribute("ItemId")

		if not (itemId and typeof(itemId) == "number") then
			return nil
		end

		local match = ItemConfig.match(itemId)

		if not match:isErr() then
			return match:unwrap()
		end

		match:inspectErr(warn)
		return nil
	end, { p.Selected })
	local element = React.createElement("Frame", {
		Size = UDim2.fromScale(1, 0.45),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1
	}, {
		Host = React.createElement("Frame", {
			ref = ref,
			Size = UDim2.fromScale(0.9, 0.9),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1
		}, {
			Aspect = React.createElement("UIAspectRatioConstraint")
		})
	})
	local element2 = React.createElement("TextButton", {
		Text = "Close",
		Size = UDim2.fromScale(0.2, 0.1),
		Position = UDim2.fromScale(1, 1),
		AnchorPoint = Vector2.new(1, 1),
		[React.Event.Activated] = p.OnClose
	})
	React.useEffect(function()
		if p.Selected and v and ref.current then
			if ref2.current ~= v.Index.ItemId then
				ref2.current = v.Index.ItemId
				return (PreviewModel.new({
					Instance = p.Selected,
					Host = ref.current,
					Rarity = v.Quality.Rarity or "Common",
					ItemId = v.Index.ItemId,
					DisplayName = v.Display.Title or v.Display.Name or v.Index.StorageKey
				}))
			end
		else
			ref2.current = nil
		end

		return nil
	end, { p.Selected, v, ref.current })
	return React.createElement("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1)
	}, {
		Spinner = element,
		Close = element2
	})
end