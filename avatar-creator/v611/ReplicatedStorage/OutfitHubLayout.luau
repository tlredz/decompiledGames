local function box(instance, p, p2, p3, p4, value)
	instance.AnchorPoint = Vector2.zero
	instance.Position = UDim2.fromOffset(p, p2)
	instance.Size = UDim2.fromOffset(math.max(1, p3), (math.max(1, p4)))

	if instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
		instance.TextScaled = false
		instance.TextSize = value or 14
	end
end

return {
	Apply = function(p)
		local panel = p.Root.Panel
		local absoluteSize = p.Root.AbsoluteSize

		if absoluteSize.X < 1 or absoluteSize.Y < 1 then
			return
		end

		local v = math.min(1100, absoluteSize.X - 20)
		local v2 = math.min(680, absoluteSize.Y - 20)

		for _, child in panel:GetChildren() do
			if child:IsA("UIScale") then
				child.Scale = 1
			elseif child:IsA("UISizeConstraint") then
				child.MinSize = Vector2.zero
				child.MaxSize = Vector2.new(2200, 2200)
			end
		end

		panel.AnchorPoint = Vector2.new(0.5, 0.5)
		panel.Position = UDim2.fromScale(0.5, 0.5)
		panel.Size = UDim2.fromOffset(v, v2)
		local v3

		if v >= 600 then
			v3 = v2 < 420
		else
			v3 = false
		end

		box(panel.Title, 12, 6, v3 and 100 or v - 92, 44, 24)
		box(panel.Close, v - 56, 6, 44, 44, 13)
		local v4 = v3 and v - 184 or v - 24
		box(panel.HubTabs, v3 and 116 or 12, v3 and 8 or 58, v4, 40)

		for k, v5 in { "Wearing", "Saved", "Loader" } do
			box(panel.HubTabs[v5], (k - 1) * (v4 + 8) / 3, 0, (v4 - 16) / 3, 40, 14)
		end

		local v5 = v3 and 60 or 108
		local v6 = v - 24
		local v7 = v2 - v5 - 12

		for _, v8 in { panel.Current, panel.Saved, panel.Loader } do
			box(v8, 12, v5, v6, v7)
		end

		local current = panel.Current
		box(current.Summary, 0, 0, v6, 28, 12)
		box(current.Results, 0, 34, v6, v7 - 118)
		box(current.Status, 0, v7 - 78, v6, 28, 11)
		local v8 = (v6 - 24) / 4

		for k, v9 in {
			"SaveOutfit",
			"ResetAvatar",
			"Refresh",
			"BuyAll"
		} do
			box(current[v9], (k - 1) * (v8 + 8), v7 - 44, v8, 44, 12)
		end

		current.SaveOutfit.Text = "Save"
		current.ResetAvatar.Text = "Reset"
		current.Refresh.Text = "Refresh"
		current.BuyAll.Text = current.BuyAll.Text:find("20", 1, true) and "Buy next 20" or "Buy all"
		box(current.Empty, 12, 40, v6 - 24, math.max(44, v7 - 136), 14)
		local saved = panel.Saved
		box(saved.OutfitName, 0, 0, v6 - 140, 44, 14)
		box(saved.SaveCurrent, v6 - 132, 0, 132, 44, 13)
		box(saved.Status, 0, 50, v6 - 92, 28, 12)
		box(saved.Refresh, v6 - 84, 50, 84, 28, 12)
		box(saved.Results, 0, 86, v6, v7 - 86)
		box(saved.Empty, 16, 90, v6 - 32, math.max(60, v7 - 110), 15)
		local v9 = math.max(1, (math.floor((v6 + 10) / (v3 and 160 or 180))))
		local v10 = math.floor((v6 - 8 - (v9 - 1) * 10) / v9)
		local v11 = v3 and 172 or 246
		saved.Results.Grid.CellSize = UDim2.fromOffset(v10, v11)

		for _, frame in saved.Results:GetChildren() do
			if not frame:IsA("Frame") then
				continue
			end

			box(frame.Avatar, 4, 4, v10 - 8, v11 - 88)
			box(frame.OutfitTitle, 8, v11 - 82, v10 - 16, 30, 13)
			box(frame.View, 6, v11 - 46, (v10 - 18) / 2, 40, 13)
			box(frame.Wear, (v10 + 6) / 2, v11 - 46, (v10 - 18) / 2, 40, 13)
		end

		local loader = panel.Loader
		box(loader.Username, 0, 0, v6 - 98, 44, 14)
		box(loader.Search, v6 - 90, 0, 90, 44, 14)
		box(loader.Status, 0, 50, v6 - 150, 30, 12)
		box(loader.More, v6 - 142, 50, 142, 30, 12)
		box(loader.Results, 0, 86, v6, v7 - 86)
		local v12 = math.max(1, (math.floor((v6 + 10) / (v3 and 160 or 200))))
		local v13 = math.floor((v6 - 12 - (v12 - 1) * 10) / v12)
		loader.Results.UIGridLayout.CellSize = UDim2.fromOffset(v13, v3 and 172 or 230)

		for _, frame in loader.Results:GetChildren() do
			if not frame:IsA("Frame") then
				continue
			end

			for _, button in frame:GetChildren() do
				if not button:IsA("GuiButton") then
					continue
				end

				button.Size = UDim2.new(0.5, -9, 0, 36)
				button.Position = UDim2.new(button.Position.X.Scale, button.Position.X.Offset, 1, -40)
				button.TextSize = 13
			end
		end

		local savedDetails = panel.SavedDetails
		box(savedDetails, 0, 0, v, v2)
		box(savedDetails.Title, 14, 8, v - 110, 40, 22)
		box(savedDetails.Back, v - 94, 8, 80, 40, 14)

		if v >= 600 then
			local v14 = math.floor(v * 0.6)
			local v15 = v - v14 - 38
			box(savedDetails.Avatar, 12, 56, v14 - 18, v2 - 144)
			box(savedDetails.DragHint, 12, v2 - 82, v14 - 18, 24, 12)
			box(savedDetails.PurchaseOutfit, 12, v2 - 52, (v14 - 30) / 2, 44, 13)
			box(savedDetails.SaveToRoblox, (v14 + 6) / 2, v2 - 52, (v14 - 30) / 2, 44, 13)
			box(savedDetails.Status, v14 + 8, 64, v15, math.max(48, v2 - 184), 14)
			box(savedDetails.Wear, v14 + 8, v2 - 108, v15, 44, 15)
			box(savedDetails.Delete, v14 + 8, v2 - 56, v15, 44, 14)
		else
			box(savedDetails.Avatar, 12, 56, v - 24, v2 - 266)
			box(savedDetails.DragHint, 12, v2 - 206, v - 24, 24, 11)
			box(savedDetails.PurchaseOutfit, 12, v2 - 176, (v - 32) / 2, 44, 12)
			box(savedDetails.SaveToRoblox, v / 2 + 4, v2 - 176, (v - 32) / 2, 44, 12)
			box(savedDetails.Status, 12, v2 - 128, v - 24, 64, 12)
			box(savedDetails.Wear, 12, v2 - 56, (v - 32) / 2, 44, 14)
			box(savedDetails.Delete, v / 2 + 4, v2 - 56, (v - 32) / 2, 44, 14)
		end
	end
}