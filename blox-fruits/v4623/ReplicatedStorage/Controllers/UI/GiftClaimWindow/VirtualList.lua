local Trove = require(game.ReplicatedStorage.Modules.Util.Trove)
local LastInput = require(game.ReplicatedStorage.Modules.LastInput)
local UIUtil = require(game.ReplicatedStorage.Modules.Util.UIUtil)
return function(object, selectedObject, instance)
	local v = assert(instance:FindFirstChildOfClass("UIListLayout"), "fakeScrollingFrame needs a UIListLayout")
	local v2 = assert(instance:FindFirstChildOfClass("UIPadding"), "fakeScrollingFrame needs a UIPadding even it's 0")
	local maid = Trove.new()
	local flag = false
	local v3 = {
		_Destroyed = false
	}
	maid:Add(function()
		maid = nil
		v3._Destroyed = true
		flag = false
		v3:UpdateScroll(true)

		if object.OnDestroy then
			object.OnDestroy(object)
		end

		table.clear(object.Data)
		table.clear(object.List)
	end)

	function v3:Destroy()
		if maid then
			maid:Destroy()
		end
	end

	local GuiService = game:GetService("GuiService")
	local Y = -1
	local fn = nil

	function v3:UpdateScroll(_: boolean?)
		if self._Destroyed then
			return
		end

		Y = selectedObject.CanvasPosition.Y
		local yPadding = object.YPadding or 0
		local scrollPaddingX = object.ScrollPaddingX or 0
		local Y2 = selectedObject.AbsoluteSize.Y
		local Y3 = object.List[1].GuiObject.AbsoluteSize.Y
		local v4 = Y2 * v.Padding.Scale + v.Padding.Offset
		local v5 = Y3 + v4 + yPadding
		local v6 = v5 / Y2
		local v7 = LastInput:Get() == "Gamepad" and Y3 or v4
		local uDim = UDim2.fromOffset(0, Y2 * (v6 * #object.Data) + v7)

		if uDim ~= selectedObject.CanvasSize then
			selectedObject.CanvasSize = uDim
			local v8 = Y2 < uDim.Y.Offset and selectedObject.ScrollBarThickness + scrollPaddingX or 0
			v2.PaddingRight = UDim.new(0, v8)
		end

		local v8 = math.max(
			selectedObject.AbsoluteWindowSize.Y - instance.AbsoluteSize.Y,
			selectedObject.CanvasPosition.Y
		)
		instance.Position = UDim2.fromOffset(0, -v8 % v5 - v5)
		local v9 = math.ceil(v8 / Y2 / v6)

		for i = 1, #object.List do
			if self._Destroyed then
				break
			end

			debug.profilebegin("GiftClaimWindow/Render")
			local v10 = v9 + i - 1
			local v11

			if flag then
				v11 = object.Data[v10]
			end

			object.List[i]:Render(v11, v10)
			debug.profileend()
		end

		if fn then
			local v10 = fn
			fn = nil
			v10()
		end
	end

	local thread = nil
	local v4 = true
	local zero = Vector2.zero

	function v3:UpdateRender(flag2: boolean?)
		if thread then
			task.cancel(thread)
			thread = nil
		end

		if self._Destroyed or not flag then
			return
		end

		if flag2 then
			if object:Update() then
				self:UpdateScroll(true)
			end
		else
			thread = task.delay(v4 and 0 or 0.2, function()
				thread = nil

				if self._Destroyed then
					return
				end

				if object:Update() then
					self:UpdateScroll(true)
				end
			end)
			v4 = false
			maid:Add(thread)
		end
	end

	local v5 = nil

	function v3.Disconnect(_)
		if not v5 then
			return
		end

		v4 = true
		v5:Destroy()
	end

	function v3:Connect()
		if v5 then
			return
		end

		local maid2 = maid:Extend()
		v5 = maid2
		maid2:Add(function()
			zero = selectedObject.CanvasPosition
			v5 = nil
			table.clear(object.Data)
			self:UpdateScroll(true)
			flag = false
		end)
		maid2:Add(selectedObject:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
			self:UpdateScroll(false)
		end))
		maid2:Add(selectedObject:GetPropertyChangedSignal("CanvasSize"):Connect(function()
			self:UpdateScroll(false)
		end))
		maid2:Add(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			self:UpdateRender(false)
		end))
		local screenGui = instance:FindFirstAncestorOfClass("ScreenGui")
		local v6 = nil

		local function capture(p: number?)
			if p == nil then
				GuiService.SelectedObject = selectedObject
				return
			end

			local selectedObject2 = GuiService.SelectedObject
			local v7 = 1

			for i = 1, #object.List do
				if v6 then
					if object.List[i]:Select() == v6:Select() then
						v7 = math.clamp(i + p, 1, #object.List)
						break
					end
				elseif object.List[i]:Select() == selectedObject2 then
					v7 = math.clamp(i + p, 1, #object.List)
					break
				end
			end

			local v8 = object.List[v7]

			if not v8 then
				return
			end

			v6 = v8
			local currentSelection = v8.GuiObject:GetAttribute("CurrentSelection")
			local snapLocation = UIUtil.getSnapLocation(v8.GuiObject, selectedObject, "Center")

			fn = function()
				for _, v9 in pairs(object.List) do
					if v9.GuiObject:GetAttribute("CurrentSelection") ~= currentSelection then
						continue
					end

					if v9.GuiObject.Parent == nil or v9.GuiObject.Name == "" then
						break
					end

					local GuiService2 = game:GetService("GuiService")
					GuiService2.SelectedObject = v9:Select()
					break
				end
			end

			local v9 = p == 1 and 0.52 or 0.2
			selectedObject.CanvasPosition = Vector2.new(0, snapLocation.Snap.Y + p * (v8.GuiObject.AbsoluteSize.Y * v9))
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function inputChanged()
			if LastInput:Get() == "Gamepad" then
				selectedObject.ScrollingEnabled = false
				GuiService.SelectedObject = selectedObject
			else
				GuiService.SelectedObject = nil
				selectedObject.ScrollingEnabled = true
			end
		end

		maid2:Add(LastInput.Changed:Connect(inputChanged))
		local UserInputService = game:GetService("UserInputService")
		maid2:Add(UserInputService.InputBegan:Connect(function(input, _)
			if not (LastInput:Get() == "Gamepad" and input.UserInputType == Enum.UserInputType.Gamepad1) then
				return
			end

			local selectedObject2 = GuiService.SelectedObject

			if selectedObject2 == nil or not selectedObject2:IsDescendantOf(screenGui) then
				capture()
			elseif (selectedObject2:IsDescendantOf(instance) or selectedObject2:IsDescendantOf(selectedObject)) and (input.KeyCode == Enum.KeyCode.DPadDown or input.KeyCode == Enum.KeyCode.DPadUp) then
				capture(input.KeyCode == Enum.KeyCode.DPadDown and 1 or -1)
			end
		end))
		flag = true

		fn = function()
			inputChanged() -- equivalent call inferred; original call site unknown
		end

		self:UpdateRender(true)
		selectedObject.CanvasPosition = zero

		if object.OnConnect then
			object.OnConnect(object, v5)
		end
	end

	return v3
end