local SatchelDragScroll = {}
local v = nil

local function hold(state)
	if v ~= state or state.Writing or not state.Frame.Parent then
		return
	end

	local frame = state.Frame
	local v2 = math.max(0, frame.AbsoluteCanvasSize.Y - frame.AbsoluteWindowSize.Y)
	local v3 = math.max(0, frame.AbsoluteCanvasSize.X - frame.AbsoluteWindowSize.X)
	local vector = Vector2.new(math.clamp(state.Position.X, 0, v3), (math.clamp(state.Position.Y, 0, v2)))

	if frame.CanvasPosition ~= vector then
		state.Writing = true
		frame.CanvasPosition = vector
		state.Writing = false
	end
end

function SatchelDragScroll.IsLocked()
	return v ~= nil
end

function SatchelDragScroll.Reset()
	local v2 = v

	if not v2 then
		return
	end

	v = nil

	for _, connection in v2.Connections do
		connection:Disconnect()
	end

	for _, owner in v2.Owners do
		owner:Disconnect()
	end

	if v2.Frame.Parent then
		v2.Frame.ScrollingEnabled = v2.Enabled
	end
end

function SatchelDragScroll:Begin(instance2)
	if v and v.Frame ~= self then
		SatchelDragScroll.Reset()
	end

	if not v then
		local v2 = {
			Frame = self,
			Position = self.CanvasPosition,
			Enabled = self.ScrollingEnabled,
			Owners = {},
			Connections = {},
			Writing = false
		}
		v = v2
		self.ScrollingEnabled = false

		for _, propertyName in { "CanvasPosition", "AbsoluteCanvasSize", "AbsoluteWindowSize" } do
			table.insert(v2.Connections, self:GetPropertyChangedSignal(propertyName):Connect(function()
				hold(v2)
			end))
		end

		table.insert(v2.Connections, self.Destroying:Connect(SatchelDragScroll.Reset))
	end

	local v2 = v

	if not v2.Owners[instance2] then
		v2.Owners[instance2] = instance2.Destroying:Connect(function()
			SatchelDragScroll.End(instance2)
		end)
	end

	hold(v2)
end

function SatchelDragScroll.End(p)
	local v2 = v

	if not (v2 and v2.Owners[p]) then
		return
	end

	v2.Owners[p]:Disconnect()
	v2.Owners[p] = nil
	task.defer(function()
		if v ~= v2 or next(v2.Owners) then
			return
		end

		hold(v2)
		SatchelDragScroll.Reset()
	end)
end

return SatchelDragScroll