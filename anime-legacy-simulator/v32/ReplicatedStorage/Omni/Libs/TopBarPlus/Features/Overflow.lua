local Overflow = {}
local childrenByName = {}
local v = {}
local iconsDictionary = nil
local currentCamera = workspace.CurrentCamera
local v2 = {}
local v3 = {}
local Utility = require(script.Parent.Parent.Utility)
local flag = false
local v4 = false
local v5 = nil

function Overflow.start(p)
	v5 = p
	iconsDictionary = v5.iconsDictionary
	local v6 = nil

	for _, v7 in pairs(v5.container) do
		if v6 == nil and v7.ScreenInsets == Enum.ScreenInsets.TopbarSafeInsets then
			v6 = v7
		end

		for _, child in pairs(v7.Holders:GetChildren()) do
			if child:GetAttribute("IsAHolder") then
				childrenByName[child.Name] = child
			end
		end
	end

	local v7 = false
	local stagger = Utility.createStagger(0.1, function(p2)
		if not v7 then
			return
		end

		if not p2 then
			Overflow.updateAvailableIcons("Center")
		end

		Overflow.updateBoundary("Left")
		Overflow.updateBoundary("Right")
	end)
	task.delay(0.5, function()
		v7 = true
		stagger()
	end)
	task.delay(2, function()
		flag = true
		stagger()
	end)
	v5.iconAdded:Connect(stagger)
	v5.iconRemoved:Connect(stagger)
	v5.iconChanged:Connect(stagger)
	currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		stagger(true)
	end)
	v6:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
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
	local result = {}
	local count = 0

	for _, v6 in pairs(iconsDictionary) do
		local parentIconUID = v6.parentIconUID
		local v7 = not parentIconUID or v3[parentIconUID]
		local v8 = v3[v6.UID]

		if not v7 or v6.alignment ~= p or v8 or not v6.isEnabled then
			continue
		end

		table.insert(result, v6)
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

			return nil
		end
	end)
	v[p] = result
	return result
end

function Overflow.getRealXPositions(p, list)
	local v6 = p == "Left"
	local v7 = childrenByName[p]
	local X = v7.AbsolutePosition.X
	local X2 = v7.AbsoluteSize.X
	local offset = v7.UIListLayout.Padding.Offset
	local v8 = v6 and X or X + X2
	local result = {}

	if v6 then
		Utility.reverseTable(list)
	end

	for i = #list, 1, -1 do
		local v9 = list[i]
		local width = Overflow.getWidth(v9)

		if not v6 then
			v8 -= width
		end

		result[v9.UID] = v8

		if v6 then
			v8 += width
		end

		v8 += v6 and offset or -offset
	end

	return result
end

function Overflow.updateBoundary(p)
	local v6 = childrenByName[p]
	local uIListLayout = v6.UIListLayout
	local X = v6.AbsolutePosition.X
	local X2 = v6.AbsoluteSize.X
	local offset = uIListLayout.Padding.Offset
	local offset2 = uIListLayout.Padding.Offset
	local v7 = Overflow.updateAvailableIcons(p)
	local total = 0
	local count = 0

	for _, v8 in pairs(v7) do
		total += Overflow.getWidth(v8) + offset2
		count += 1
	end

	if count <= 0 then
		return
	end

	local v8 = p == "Center"
	local v9 = p == "Left"
	local v10 = not v9
	local v11 = v2[p]

	if not v11 and not v8 and #v7 > 0 then
		v11 = v5.new()
		v11:setImage(6069276526, "Deselected")
		v11:setName("Overflow" .. p)
		v11:setOrder(v9 and -9999999 or 9999999)
		v11:setAlignment(p)
		v11:autoDeselect(false)
		v11.isAnOverflow = true
		v11:select("OverflowStart", v11)
		v11:setEnabled(false)
		v2[p] = v11
		v3[v11.UID] = true

		if not v5.closeableOverflowMenus then
			local instance_2 = v11:getInstance("IconSpot")
			instance_2.Visible = false
		end
	end

	local v12 = p == "Left" and "Right" or "Left"
	local v13 = Overflow.updateAvailableIcons(v12)
	local v14 = v9 and v13[1] or v10 and v13[#v13]
	local v15 = v2[v12]
	local v16

	if v9 then
		v16 = X + X2 or X
	else
		v16 = X
	end

	if v14 then
		local v17 = Overflow.getRealXPositions(v12, v13)[v14.UID]
		local width = Overflow.getWidth(v14)
		v16 = v9 and v17 - offset or v17 + width + offset
	end

	local count2 = 0
	local checkToShiftCentralIcon

	checkToShiftCentralIcon = function()
		local availableIcons = Overflow.getAvailableIcons("Center")
		local availableIcon = availableIcons[v9 and 1 or #availableIcons]

		-- equivalent calls inferred from this helper; original call sites unknown
		local function secondaryCheck()
			if not v4 then
				v4 = true
				task.delay(3, Overflow.updateBoundary, p)
			end
		end

		if availableIcon and not availableIcon.hasRelocatedInOverflow then
			local v17 = v9 and v7[#v7] or v10 and v7[1]
			local X3 = availableIcon.widget.AbsolutePosition.X
			local X4 = v17.widget.AbsolutePosition.X
			local width = Overflow.getWidth(v17)
			local v18 = v9 and X3 - offset or X3 + Overflow.getWidth(availableIcon) + offset

			if v9 then
				X4 = X4 + width or X4
			end

			local flag2 = false

			if v9 then
				if v18 < X4 then
					if flag then
						availableIcon:align("Left")
						availableIcon.hasRelocatedInOverflow = true
						flag2 = true
					else
						secondaryCheck() -- equivalent call inferred; original call site unknown
						return
					end
				end
			elseif v10 and X4 < v18 then
				if flag and not (X4 < 0) then
					availableIcon:align("Right")
					availableIcon.hasRelocatedInOverflow = true
					flag2 = true
				else
					secondaryCheck() -- equivalent call inferred; original call site unknown
					return
				end
			end

			if flag2 then
				count2 += 1

				if count2 <= 4 then
					Overflow.updateAvailableIcons("Center")
					checkToShiftCentralIcon()
				end
			end
		end
	end

	checkToShiftCentralIcon()

	if v11 then
		local instance = v11:getInstance("Menu")
		local v17 = X + X2

		if instance and v15 then
			local X3 = v15.widget.AbsolutePosition.X
			local width = Overflow.getWidth(v15)
			local v18 = v9 and X3 - offset or X3 + width + offset
			local instance2 = v15:getInstance("Menu")
			local v19 = instance.AbsoluteCanvasSize.X >= instance2.AbsoluteCanvasSize.X
			local v20 = X + X2 / 2
			local v21 = v9 and v20 - offset / 2 or v20 + offset / 2

			if v19 then
				v21 = v18
			end

			X2 = v9 and v21 - X or v17 - v21
		end

		local maxWidth = instance and instance:GetAttribute("MaxWidth")
		local rounded = Utility.round(X2)

		if instance and maxWidth ~= rounded then
			instance:SetAttribute("MaxWidth", rounded)
		end
	end

	local realXPositions = Overflow.getRealXPositions(p, v7)
	local v17 = false

	for i = #v7, 1, -1 do
		local v18 = v7[i]
		local width = Overflow.getWidth(v18)
		local realXPosition = realXPositions[v18.UID]

		if v9 and v16 <= realXPosition + width or v10 and realXPosition <= v16 then
			v17 = true
		end
	end

	for i = #v7, 1, -1 do
		local v18 = v7[i]

		if v3[v18.UID] then
			continue
		end

		if v17 and not v18.parentIconUID then
			v18:joinMenu(v11)
		elseif not v17 and v18.parentIconUID then
			v18:leave()
		end
	end

	if v11.isEnabled ~= v17 then
		v11:setEnabled(v17)
	end

	if v11.isEnabled and not v11.overflowAlreadyOpened then
		v11.overflowAlreadyOpened = true
		v11:select()
	end
end

return Overflow