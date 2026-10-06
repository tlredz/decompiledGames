local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local module = require("./Signals")
local mouse = Players.LocalPlayer:GetMouse()
local Controller = {}
Controller.__index = Controller
local CheckParams

CheckParams = function(items, p)
	for k, item in items do
		local v = p[k]

		if v == nil then
			return (`Key '{k}' is missing!`)
		end

		local typeName = typeof(v)

		if typeof(item) == "table" then
			if typeName ~= "table" then
				return (`Expected '{k}' to be a 'table' but got '{typeName}'!`)
			end

			local checkParams = CheckParams(item, v)

			if checkParams ~= true then
				return checkParams
			end
		elseif typeof(item) == "string" and typeName ~= item then
			return (`Expected '{k}' to be a '{item}' but got '{typeName}'!`)
		end
	end

	return true
end

function Controller:Open(guiObject, p, flag: boolean)
	if self.Enabled == false or self.State == "Destroyed" then
		return
	end

	if not (guiObject and guiObject:IsA("GuiObject") and guiObject.Visible) or self.State == "Opened" and guiObject == self.Element then
		return
	end

	local params = typeof(p) ~= "table" and {} or p

	if self.OpenHandler then
		local checkParams = CheckParams(self.OpenHandler.Params, params)

		if checkParams ~= true then
			warn((`[NEOHOVER] Open Rejected - {checkParams}`))
			return
		end

		local callback = self.OpenHandler.Callback(guiObject, params, flag == true)

		if callback ~= true then
			if typeof(callback) == "string" then
				warn((`[NEOHOVER] Open Rejected - {callback}`))
			end

			return
		end
	end

	self.State = "Opened"
	self.Element = guiObject
	self.ListLimits = guiObject:FindFirstAncestorOfClass("ScrollingFrame")
	self.Params = params

	if self.RefreshHandler then
		self.RefreshHandler()
	end

	if not self.FirstOpen then
		self.FirstOpen = true
		self.PositionSpring:setPosition(UDim2.fromOffset(mouse.X, mouse.Y))
	end

	self.CurrentScale:set(self.OriginalScale)
	self.Instance.Visible = true
	self.UpdateConnection = RunService.RenderStepped:Connect(function()
		self:Update()
	end)
	self.VisibleConnection = guiObject:GetPropertyChangedSignal("Visible"):Connect(function()
		if not guiObject.Visible then
			self.Element = nil
			self:Close(nil, true)
		end
	end)
	self.DestroyConnection = guiObject.AncestryChanged:Connect(function(_, parent)
		if not parent then
			self.Element = nil
			self:Close(nil, true)
		end
	end)
	self:Update()
	module.HoverOpened:Fire(self.Identifier)
end

function Controller:Close(guiObject, flag: boolean?)
	if self.State == "Destroyed" or self.State == "Closed" or guiObject and guiObject:IsA("GuiObject") and self.Element ~= nil and self.Element ~= guiObject then
		return
	end

	if self.CloseHandler then
		local v = self.CloseHandler(guiObject, flag == true)

		if v ~= true then
			if typeof(v) == "string" then
				warn((`[NEOHOVER] Close Rejected - {v}`))
			end

			return
		end
	end

	self.State = "Closed"
	self.Element = nil
	self.ListLimits = nil
	self.Params = nil
	self.LastRefresh = nil

	if self.UpdateConnection then
		self.UpdateConnection:Disconnect()
		self.UpdateConnection = nil
	end

	if self.VisibleConnection then
		self.VisibleConnection:Disconnect()
		self.VisibleConnection = nil
	end

	if self.DestroyConnection then
		self.DestroyConnection:Disconnect()
		self.DestroyConnection = nil
	end

	self.CurrentScale:set(0)
	module.HoverClosed:Fire(self.Identifier)
end

function Controller.Click(data, guiObject, p)
	if data.Enabled == false or data.State == "Destroyed" or not (guiObject and guiObject:IsA("GuiObject")) then
		return
	end

	local v = typeof(p) ~= "table" and {} or p

	if data.ClickHandler then
		data.ClickHandler(guiObject, v)
	end
end

function Controller:Update()
	local now = os.clock()

	if now - (self.LastRefresh or 0) >= 1 and self.RefreshHandler then
		self.LastRefresh = now
		self.RefreshHandler()
	end

	local vector, safePosition

	if self.UpdateMode == "Element" and self.Element then
		local absoluteSize = self.Element.AbsoluteSize
		local absolutePosition = self.Element.AbsolutePosition
		local v = absolutePosition.X + absoluteSize.X / 2
		local v2 = absolutePosition.Y + absoluteSize.Y / 2
		vector = Vector2.new(v, v2)
		safePosition = self:GetSafePosition(v, v2)
	else
		local X = mouse.X
		local Y = mouse.Y
		vector = Vector2.new(X, Y)
		safePosition = self:GetSafePosition(X, Y)
	end

	if not (vector and safePosition) then
		return
	end

	if self.ListLimits then
		local absolutePosition = self.ListLimits.AbsolutePosition
		local absoluteSize = self.ListLimits.AbsoluteSize
		local X = absolutePosition.X
		local Y = absolutePosition.Y
		local v = absolutePosition.X + absoluteSize.X
		local v2 = absolutePosition.Y + absoluteSize.Y

		if vector.X < X or v < vector.X or vector.Y < Y or v2 < vector.Y then
			self:Close()
			return
		end
	end

	self.CurrentPosition:set(safePosition)
end

function Controller:GetSafePosition(value: number, value2: number)
	local safeBound = self.SafeBound or 0
	local absoluteSize = self.Interface.AbsoluteSize
	local absoluteSize2 = self.Instance.AbsoluteSize
	local v = math.min(absoluteSize2.X * safeBound, absoluteSize2.Y * safeBound)
	local v2 = absoluteSize2.X * self.Instance.AnchorPoint.X
	local v3 = absoluteSize2.Y * self.Instance.AnchorPoint.Y
	local v4 = absoluteSize2.X * (1 - self.Instance.AnchorPoint.X)
	local v5 = absoluteSize2.Y * (1 - self.Instance.AnchorPoint.Y)
	local v6 = v2 + v
	local v7 = v3 + v
	local v8 = absoluteSize.X - v4 - v
	local v9 = absoluteSize.Y - v5 - v
	local v10

	if v6 <= v8 then
		v10 = math.clamp(value, v6, v8)
	else
		v10 = (v6 + v8) / 2
	end

	local v11

	if v7 <= v9 then
		v11 = math.clamp(value2, v7, v9)
	else
		v11 = (v7 + v9) / 2
	end

	return UDim2.fromOffset(v10, v11)
end

function Controller:SetEnabled(flag: boolean?)
	self.Enabled = flag == true
end

function Controller:SetUpdateMode(updateMode: string)
	self.UpdateMode = updateMode
end

function Controller:SetSafeBound(safeBound: number)
	if safeBound < 0 or safeBound > 1 then
		return
	end

	self.SafeBound = safeBound
end

function Controller:SetRestrictedToOne(flag: boolean?)
	self.RestrictedToOne = flag == true
end

function Controller:SetOpenHandler(callback, params)
	self.OpenHandler = {
		Callback = callback,
		Params = params
	}
end

function Controller:SetCloseHandler(closeHandler)
	self.CloseHandler = closeHandler
end

function Controller:SetClickHandler(clickHandler)
	self.ClickHandler = clickHandler
end

function Controller:SetRefreshHandler(refreshHandler)
	self.RefreshHandler = refreshHandler
end

function Controller:Destroy()
	self.State = "Destroyed"

	if self.UpdateConnection then
		self.UpdateConnection:Disconnect()
		self.UpdateConnection = nil
	end

	for k, connection in self.Connections do
		connection:Disconnect()
		self.Connections[k] = nil
	end

	self.Scope:doCleanup()
end

return Controller