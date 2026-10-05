local Overflow = {}
local childrenByName = {}
local v = {}
local iconsDictionary = nil
local currentCamera = workspace.CurrentCamera
local v2 = {}
local v3 = {}
local Utility = require(script.Parent.Parent.Utility)
local v4 = nil

function Overflow.start(p)
	v4 = p
	iconsDictionary = v4.iconsDictionary
	local v5 = nil

	for _, v6 in pairs(v4.container) do
		if v5 == nil and v6.ScreenInsets == Enum.ScreenInsets.TopbarSafeInsets then
			v5 = v6
		end

		for _, child in pairs(v6.Holders:GetChildren()) do
			if child:GetAttribute("IsAHolder") then
				childrenByName[child.Name] = child
			end
		end
	end

	local v6 = false
	local stagger = Utility.createStagger(0.1, function(p2)
		if not v6 then
			return
		end

		if not p2 then
			Overflow.updateAvailableIcons("Center")
		end

		Overflow.updateBoundary("Left")
		Overflow.updateBoundary("Right")
	end)
	task.delay(1, function()
		v6 = true
		stagger()
	end)
	v4.iconAdded:Connect(stagger)
	v4.iconRemoved:Connect(stagger)
	v4.iconChanged:Connect(stagger)
	currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		stagger(true)
	end)
	v5:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		stagger(true)
	end)
end

function Overflow.getWidth(p, _)
	local widget = p.widget
	return widget:GetAttribute("TargetWidth") or widget.AbsoluteSize.X
end

function Overflow.getAvailableIcons(p)
	return v[p] or Overflow.updateAvailableIcons(p)
end

function Overflow.updateAvailableIcons(p)
	local _ = childrenByName[p].UIListLayout
	local result = {}
	local count = 0

	for _, v5 in pairs(iconsDictionary) do
		local parentIconUID = v5.parentIconUID
		local v6 = not parentIconUID or v3[parentIconUID]
		local v7 = v3[v5.UID]

		if not v6 or v5.alignment ~= p or v7 then
			continue
		end

		table.insert(result, v5)
		count += 1
	end

	if count <= 0 then
		return {}
	end

	table.sort(result, function(a, b)
		local layoutOrder = a.widget.LayoutOrder
		local layoutOrder2 = b.widget.LayoutOrder
		local parentIconUID = a.parentIconUID
		local parentIconUID2 = b.parentIconUID

		if parentIconUID == parentIconUID2 then
			if layoutOrder < layoutOrder2 then
				return true
			end

			return not (layoutOrder2 < layoutOrder) and a.widget.AbsolutePosition.X < b.widget.AbsolutePosition.X
		else
			if parentIconUID2 then
				return false
			end

			if parentIconUID then
				return true
			end
		end
	end)
	v[p] = result
	return result
end

function Overflow.getRealXPositions(p, list)
	local v5 = p == "Left"
	local v6 = childrenByName[p]
	local X = v6.AbsolutePosition.X
	local X2 = v6.AbsoluteSize.X
	local offset = v6.UIListLayout.Padding.Offset
	local v7 = v5 and X or X + X2
	local result = {}

	if v5 then
		Utility.reverseTable(list)
	end

	for i = #list, 1, -1 do
		local v8 = list[i]
		local width = Overflow.getWidth(v8)

		if not v5 then
			v7 -= width
		end

		result[v8.UID] = v7

		if v5 then
			v7 += width
		end

		v7 += v5 and offset or -offset
	end

	return result
end

function Overflow.updateBoundary(p)
	local v5 = childrenByName[p]
	local uIListLayout = v5.UIListLayout
	local X = v5.AbsolutePosition.X
	local X2 = v5.AbsoluteSize.X
	local offset = uIListLayout.Padding.Offset
	local offset2 = uIListLayout.Padding.Offset
	local v6 = Overflow.updateAvailableIcons(p)
	local total = 0
	local count = 0

	for _, v7 in pairs(v6) do
		total += Overflow.getWidth(v7) + offset2
		count += 1
	end

	if count <= 0 then
		return
	end

	local v7 = p == "Central"
	local v8 = p == "Left"
	local v9 = not v8
	local v10 = v2[p]

	if not v10 and not v7 and #v6 > 0 then
		v10 = v4.new()
		v10:setImage(6069276526, "Deselected")
		v10:setName("Overflow" .. p)
		v10:setOrder(v8 and -9999999 or 9999999)
		v10:setAlignment(p)
		v10:autoDeselect(false)
		v10.isAnOverflow = true
		v10:select("OverflowStart", v10)
		v10:setEnabled(false)
		v2[p] = v10
		v3[v10.UID] = true
	end

	local v11 = p == "Left" and "Right" or "Left"
	local v12 = Overflow.updateAvailableIcons(v11)
	local v13 = v8 and v12[1] or v9 and v12[#v12]
	local v14 = v2[v11]
	local v15

	if v8 then
		v15 = X + X2 or X
	else
		v15 = X
	end

	if v13 then
		local _ = v13.widget
		local v16 = Overflow.getRealXPositions(v11, v12)[v13.UID]
		local width = Overflow.getWidth(v13)
		v15 = v8 and v16 - offset or v16 + width + offset
	end

	local availableIcons = Overflow.getAvailableIcons("Center")
	local availableIcon = availableIcons[v8 and 1 or #availableIcons]

	if availableIcon and not availableIcon.hasRelocatedInOverflow then
		local v16 = v8 and v6[#v6] or v9 and v6[1]
		local X3 = availableIcon.widget.AbsolutePosition.X
		local X4 = v16.widget.AbsolutePosition.X
		local width = Overflow.getWidth(v16)
		local v17 = v8 and X3 - offset or X3 + Overflow.getWidth(availableIcon) + offset

		if v8 then
			X4 = X4 + width or X4
		end

		if v8 then
			if v17 < X4 then
				availableIcon:align("Left")
				availableIcon.hasRelocatedInOverflow = true
			end
		elseif v9 and X4 < v17 then
			availableIcon:align("Right")
			availableIcon.hasRelocatedInOverflow = true
		end
	end

	if v10 then
		local instance = v10:getInstance("Menu")
		local v16 = X + X2

		if instance and v14 then
			local X3 = v14.widget.AbsolutePosition.X
			local width = Overflow.getWidth(v14)
			local v17 = v8 and X3 - offset or X3 + width + offset
			local instance2 = v14:getInstance("Menu")
			local v18 = instance.AbsoluteCanvasSize.X >= instance2.AbsoluteCanvasSize.X
			local v19 = X + X2 / 2
			local v20 = v8 and v19 - offset / 2 or v19 + offset / 2

			if v18 then
				v20 = v17
			end

			X2 = v8 and v20 - X or v16 - v20
		end

		local maxWidth = instance and instance:GetAttribute("MaxWidth")
		local rounded = Utility.round(X2)

		if instance and maxWidth ~= rounded then
			instance:SetAttribute("MaxWidth", rounded)
		end
	end

	local realXPositions = Overflow.getRealXPositions(p, v6)
	local v16 = false

	for i = #v6, 1, -1 do
		local v17 = v6[i]
		local width = Overflow.getWidth(v17)
		local realXPosition = realXPositions[v17.UID]

		if v8 and v15 <= realXPosition + width or v9 and realXPosition <= v15 then
			v16 = true
		end
	end

	for i = #v6, 1, -1 do
		local v17 = v6[i]

		if v3[v17.UID] then
			continue
		end

		if v16 and not v17.parentIconUID then
			v17:joinMenu(v10)
		elseif not v16 and v17.parentIconUID then
			v17:leave()
		end
	end

	if v10.isEnabled ~= v16 then
		v10:setEnabled(v16)
	end

	if v10.isEnabled and not v10.overflowAlreadyOpened then
		v10.overflowAlreadyOpened = true
		v10:select()
	end
end

return Overflow