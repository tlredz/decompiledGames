local import = _G.import("romodel")
local basic = _G.import("viewImports"):get("basic")
local Players = game:GetService("Players")
local wrapped = import.wrap(basic.EmptyElement, basic.ConstrainedElement, basic.Corner)

function wrapped.init(options)
	local v = options or {}
	return {
		Name = v.Name or "Avatar",
		Size = v.Size or UDim2.new(1, 0, 1, 0),
		LayoutOrder = v.LayoutOrder,
		AspectRatio = 1,
		BackgroundColor3 = v.BackgroundColor3 or Color3.fromRGB(12, 12, 16),
		BackgroundTransparency = v.BackgroundTransparency or 0.5,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		CornerRadius = v.CornerRadius or UDim.new(1, 0),
		StrokeTransparency = v.StrokeTransparency or 0,
		UserId = v.UserId,
		Image = v.Image,
		ThumbnailType = v.ThumbnailType or Enum.ThumbnailType.HeadShot
	}, {
		Icon = import.make(basic.ImageLabel, {
			Name = "Icon",
			Location = "Center",
			Size = UDim2.new(1, 0, 1, 0),
			NoAspectRatio = true,
			Image = v.Image or "",
			ScaleType = Enum.ScaleType.Crop,
			BackgroundTransparency = 1
		}, {
			UICorner = import.make("UICorner", {
				CornerRadius = v.CornerRadius or UDim.new(1, 0)
			})
		})
	}
end

function wrapped.spawn(data)
	if data.Icon.Image ~= "" then
		return
	end

	local userId = data.UserId

	if not userId then
		local players = Players:GetPlayers()
		userId = players[1] and players[1].UserId
	end

	if not userId then
		return
	end

	task.spawn(function()
		local success, result = pcall(function()
			return Players:GetUserThumbnailAsync(userId, data.ThumbnailType, Enum.ThumbnailSize.Size420x420)
		end)

		if data.Icon and data.Icon.Instance then
			data.Icon.Image = success and result or ""
		end
	end)
end

return {
	Avatar = wrapped
}