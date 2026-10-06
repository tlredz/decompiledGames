local Close = {}
Close.__index = Close

function Close.Setup(data)
	local value = data.Scope:Value(1)
	local value2 = data.Scope:Value(nil)
	local visible = data.Scope:Value(nil)
	data.Scope:Observer(data.State):onBind(function()
		local state = data.Scope.peek(data.State)

		if state == "Pressed" then
			value:set(0.9)
			value2:set(30)
			visible:set(true)
		elseif state == "Hover" then
			value:set(1.1)
			value2:set(-15)
			visible:set(true)
		else
			value:set(1)
			value2:set(0)
			visible:set(false)
		end
	end)
	local hover = data.Instance:FindFirstChild("Hover")

	if hover then
		data.Scope:Hydrate(hover)({
			Visible = visible
		})
	end

	data.Scope:Hydrate(data.Instance)({
		Rotation = data.Scope:Spring(value2, 40, 1)
	})
	data.Scope:Hydrate(data.UIScale)({
		Scale = data.Scope:Spring(value, 40, 1)
	})
end

function Close.BindFunction(p, p2, p3)
	if p.Functions[p2] then
		return
	end

	p.Functions[p2] = p3
end

function Close.UnbindFunction(p, p2)
	if not p.Functions[p2] then
		return
	end

	p.Functions[p2] = nil
end

function Close.BindOnEnter(p, p2, p3)
	if p.OnEnterConnections[p2] then
		return
	end

	p.OnEnterConnections[p2] = p3
end

function Close.UnbindOnEnter(p, p2)
	if not p.OnEnterConnections[p2] then
		return
	end

	p.OnEnterConnections[p2] = nil
end

function Close.BindOnMove(p, p2, p3)
	if p.OnMoveConnections[p2] then
		return
	end

	p.OnMoveConnections[p2] = p3
end

function Close.UnbindOnMove(p, p2)
	if not p.OnMoveConnections[p2] then
		return
	end

	p.OnMoveConnections[p2] = nil
end

function Close.BindOnLeave(p, p2, p3)
	if p.OnLeaveConnections[p2] then
		return
	end

	p.OnLeaveConnections[p2] = p3
end

function Close.UnbindOnLeave(p, p2)
	if not p.OnLeaveConnections[p2] then
		return
	end

	p.OnLeaveConnections[p2] = nil
end

function Close.BindOnPress(p, p2, p3)
	if p.OnPressConnections[p2] then
		return
	end

	p.OnPressConnections[p2] = p3
end

function Close.UnbindOnPress(p, p2)
	if not p.OnPressConnections[p2] then
		return
	end

	p.OnPressConnections[p2] = nil
end

function Close.BindOnRelease(p, p2, p3)
	if p.OnReleaseConnections[p2] then
		return
	end

	p.OnReleaseConnections[p2] = p3
end

function Close.UnbindOnRelease(p, p2)
	if not p.OnReleaseConnections[p2] then
		return
	end

	p.OnReleaseConnections[p2] = nil
end

function Close.Destroy(p)
	for k, connection in p.Connections do
		connection:Disconnect()
		p.Connections[k] = nil
	end

	p.Scope:doCleanup()
end

return Close