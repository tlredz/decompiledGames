local UIGridPosition = {
	fromIndex = function(p: number, p2: number)
		return {
			row = math.ceil(p / p2),
			column = (p - 1) % p2 + 1
		}
	end,
	getColumns = function(data, scrollingFrame)
		local X = data.AbsoluteCellCount.X

		if X > 0 then
			return X
		end

		if data.FillDirectionMaxCells > 0 then
			return data.FillDirectionMaxCells
		end

		local X2 = data.AbsoluteCellSize.X

		if X2 > 0 then
			local offset = data.CellPadding.X.Offset
			local v

			if scrollingFrame:IsA("ScrollingFrame") then
				v = scrollingFrame.AbsoluteWindowSize.X
			else
				v = scrollingFrame.AbsoluteSize.X
			end

			return (math.max(1, (math.floor((v + offset) / (X2 + offset)))))
		else
			local scale = data.CellSize.X.Scale

			if scale <= 0 then
				return nil
			end

			return (math.max(1, (math.floor(1 / scale + 0.01))))
		end
	end
}

function UIGridPosition.fromButton(p)
	local parent = p.Parent

	if parent == nil or not parent:IsA("GuiObject") then
		return nil
	end

	local uIGridLayout = parent:FindFirstChildOfClass("UIGridLayout")

	if uIGridLayout == nil then
		return nil
	end

	local guiObjects = {}

	for _, guiObject in parent:GetChildren() do
		if guiObject:IsA("GuiObject") and guiObject.Visible and guiObject.Name ~= "Template" then
			table.insert(guiObjects, guiObject)
		end
	end

	table.sort(guiObjects, function(a, b)
		if a.LayoutOrder == b.LayoutOrder then
			return a.Name < b.Name
		end

		return a.LayoutOrder < b.LayoutOrder
	end)
	local index = table.find(guiObjects, p)

	if index == nil then
		return nil
	end

	local columns = UIGridPosition.getColumns(uIGridLayout, parent)

	if columns == nil then
		return nil
	end

	return UIGridPosition.fromIndex(index, columns)
end

return UIGridPosition