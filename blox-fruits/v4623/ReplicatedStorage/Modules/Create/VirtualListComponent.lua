local Trove = require(game.ReplicatedStorage.Modules.Util.Trove)
local LastInput = require(game.ReplicatedStorage.Modules.LastInput)
local GuiService = game:GetService("GuiService")
local UIUtil = require(game.ReplicatedStorage.Modules.Util.UIUtil)
return function(object, selectedObject)
	assert(object.TryUpdate ~= nil)
	local v = Trove.new()
	local maid = nil
	local thread = nil
	local zero = Vector2.zero
	local fn = nil
	local _VirtualContainer = assert(selectedObject.Parent):FindFirstChild("_VirtualContainer") or Instance.new("Frame")
	_VirtualContainer.Selectable = false
	_VirtualContainer.ClipsDescendants = true
	_VirtualContainer.Name = "_VirtualContainer"
	_VirtualContainer.BackgroundTransparency = 1
	_VirtualContainer.Size = selectedObject.Size
	_VirtualContainer.Position = selectedObject.Position
	_VirtualContainer.AnchorPoint = selectedObject.AnchorPoint
	_VirtualContainer.Parent = selectedObject.Parent
	local _VirtualList = _VirtualContainer:FindFirstChild("_VirtualList") or Instance.new("Frame")
	_VirtualList.Selectable = false
	_VirtualList.BackgroundTransparency = 1
	_VirtualList.Name = "_VirtualList"
	_VirtualList.Size = UDim2.fromScale(1, 1)
	_VirtualList.Parent = _VirtualContainer
	local v2 = _VirtualList:FindFirstChildOfClass("UIListLayout") or selectedObject:FindFirstChildOfClass("UIListLayout")
	local v3 = _VirtualList:FindFirstChildOfClass("UIPadding") or selectedObject:FindFirstChildOfClass("UIPadding")

	if v3 == nil then
		v3 = Instance.new("UIPadding")
	end

	if v2 == nil then
		v2 = Instance.new("UIListLayout")
	end

	for i = 1, #object.Entries do
		object.Entries[i].Rbx.Parent = _VirtualList
		v3.Parent = _VirtualList
		v2.Parent = _VirtualList
	end

	local v4 = {
		_Destroyed = false
	}
	assert(v):Add(function()
		v = nil
		v4._Destroyed = true

		if object.OnDestroy then
			object.OnDestroy(object)
		end
	end)

	function v4:UpdateScroll()
		if self._Destroyed or not maid then
			return
		end

		local Y = selectedObject.AbsoluteSize.Y
		local Y2 = object.Entries[1].Rbx.AbsoluteSize.Y
		local v5 = Y * v2.Padding.Scale + v2.Padding.Offset
		local v6 = Y2 + v5 + 0
		local v7 = v6 / Y
		local v8 = LastInput:Get() == "Gamepad" and Y2 or v5
		local uDim = UDim2.fromOffset(0, Y * (v7 * #(object.Data or {})) + v8)

		if uDim ~= selectedObject.CanvasSize then
			selectedObject.CanvasSize = uDim
			local v9 = Y < uDim.Y.Offset and selectedObject.ScrollBarThickness + 0 or 0
			v3.PaddingRight = UDim.new(0, v9)
		end

		local v9 = math.max(
			selectedObject.AbsoluteWindowSize.Y - _VirtualList.AbsoluteSize.Y,
			selectedObject.CanvasPosition.Y
		)
		_VirtualList.Position = UDim2.fromOffset(0, -v9 % v6 - v6)
		local v10 = math.ceil(v9 / Y / v7)

		for i = 1, #object.Entries do
			if self._Destroyed or not maid then
				break
			end

			debug.profilebegin("VirtualList.Render")
			local renderIndex = v10 + i - 1
			object.Entries[i]._RenderIndex = renderIndex

			if renderIndex == 0 then
				object.Entries[i].Rbx.Visible = true
				object.Entries[i]._RenderData = nil
				debug.profileend()
			else
				local renderData = (object.Data or {})[renderIndex]

				if renderData and not renderData._UID then
					renderData._UID = Random.new():NextNumber()
				end

				object.Entries[i]._RenderData = renderData
				object.Entries[i]:Render(renderData)
				debug.profileend()
			end
		end

		if fn then
			local v11 = fn
			fn = nil
			v11()
		end
	end

	function v4:UpdateRender(duration: number?)
		if thread then
			task.cancel(thread)
			thread = nil
		end

		if self._Destroyed or not maid then
			return
		end

		if duration == nil or duration == 0 then
			if object:TryUpdate() then
				self:UpdateScroll()
			end
		else
			thread = task.delay(duration, function()
				thread = nil

				if self._Destroyed then
					return
				end

				if object:TryUpdate() then
					self:UpdateScroll()
				end
			end)

			if thread then
				v:Add(thread)
			end
		end
	end

	function v4:Destroy()
		if v then
			v:Destroy()
		end
	end

	function v4.Disconnect(_)
		if maid then
			maid:Destroy()
		end
	end

	function v4:Connect()
		if maid then
			return
		end

		maid = v:Extend()
		assert(maid):Add(function()
			zero = selectedObject.CanvasPosition
			maid = nil
			object.Data = nil
		end)

		for i = 1, #object.Entries do
			assert(object.Entries[i].Select, "Virtual list entry needs Select for controller")
			local button = object.Entries[i]:Select()
			assert(
				typeof(button) == "Instance" and button:IsA("TextButton") or button:IsA("ImageButton"),
				(`Select of wrong type: {typeof(button)}`)
			)
			object.Entries[i].Rbx:SetAttribute("_Index", i - 1)
			object.Entries[i].Rbx.LayoutOrder = i - 1
		end

		maid:Add(selectedObject:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
			self:UpdateScroll()
		end))
		maid:Add(selectedObject:GetPropertyChangedSignal("CanvasSize"):Connect(function()
			self:UpdateScroll()
		end))
		maid:Add(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			self:UpdateRender(0.2)
		end))
		local screenGui = selectedObject:FindFirstAncestorOfClass("ScreenGui")
		local flag = false

		local function capture(p: number?)
			if flag then
				return
			end

			if p == nil then
				GuiService.SelectedObject = selectedObject
				return
			end

			flag = true
			local v5 = tonumber(GuiService.SelectedObject:GetAttribute("_Index")) + p
			local entry = object.Entries[math.clamp(v5, 2, #object.Entries)]

			if not (entry and entry._RenderData) then
				flag = false
				return
			end

			local _UID = entry._RenderData._UID
			local v6 = assert(UIUtil.getSnapLocation(entry.Rbx, selectedObject, "Center"))

			fn = function()
				for _, entry2 in pairs(object.Entries) do
					if not (entry2._RenderData and entry2._RenderData._UID == _UID) then
						continue
					end

					GuiService.SelectedObject = entry2:Select()
					break
				end

				task.defer(function()
					flag = false
				end)
			end

			local v7 = p == 1 and 0.52 or 0.2
			selectedObject.CanvasPosition = Vector2.new(0, v6.Snap.Y + p * (entry.Rbx.AbsoluteSize.Y * v7))
			self:UpdateScroll()
		end

		local maid2 = maid
		local UserInputService = game:GetService("UserInputService")
		maid2:Add(UserInputService.InputBegan:Connect(function(input, _)
			if not (LastInput:Get() == "Gamepad" and input.UserInputType == Enum.UserInputType.Gamepad1) then
				return
			end

			local selectedObject2 = GuiService.SelectedObject

			if selectedObject2 == nil or not selectedObject2:IsDescendantOf(screenGui) then
				capture()
			elseif (selectedObject2:IsDescendantOf(_VirtualContainer) or selectedObject2:IsDescendantOf(selectedObject)) and (input.KeyCode == Enum.KeyCode.DPadDown or input.KeyCode == Enum.KeyCode.DPadUp) then
				capture(input.KeyCode == Enum.KeyCode.DPadDown and 1 or -1)
			end
		end))

		-- equivalent calls inferred from this helper; original call sites unknown
		local function inputChanged()
			if LastInput:Get() == "Gamepad" then
				GuiService.SelectedObject = selectedObject
				selectedObject.ScrollingEnabled = false
			else
				GuiService.SelectedObject = nil
				selectedObject.ScrollingEnabled = true
			end

			self:UpdateScroll()
		end

		maid:Add(LastInput.Changed:Connect(inputChanged))

		fn = function()
			inputChanged() -- equivalent call inferred; original call site unknown
		end

		self:UpdateRender()
		selectedObject.CanvasPosition = zero

		if object.OnConnect then
			object.OnConnect(object, maid)
		end
	end

	return v4
end