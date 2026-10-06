local Default = {}
Default.__index = Default

function Default.Setup(data)
	local value = data.Scope:Value(1)
	data.Scope:Observer(data.State):onBind(function()
		local state = data.Scope.peek(data.State)

		if state == "Pressed" then
			value:set(0.9)
		elseif state == "Hover" then
			value:set(1.1)
		else
			value:set(1)
		end
	end)
	data.Scope:Hydrate(data.UIScale)({
		Scale = data.Scope:Spring(value, 40, 1)
	})
end

function Default.BindFunction(p, p2, p3)
	if p.Functions[p2] then
		return
	end

	p.Functions[p2] = p3
end

function Default.UnbindFunction(p, p2)
	if not p.Functions[p2] then
		return
	end

	p.Functions[p2] = nil
end

function Default.BindOnEnter(p, p2, p3)
	if p.OnEnterConnections[p2] then
		return
	end

	p.OnEnterConnections[p2] = p3
end

function Default.UnbindOnEnter(p, p2)
	if not p.OnEnterConnections[p2] then
		return
	end

	p.OnEnterConnections[p2] = nil
end

function Default.BindOnMove(p, p2, p3)
	if p.OnMoveConnections[p2] then
		return
	end

	p.OnMoveConnections[p2] = p3
end

function Default.UnbindOnMove(p, p2)
	if not p.OnMoveConnections[p2] then
		return
	end

	p.OnMoveConnections[p2] = nil
end

function Default.BindOnLeave(p, p2, p3)
	if p.OnLeaveConnections[p2] then
		return
	end

	p.OnLeaveConnections[p2] = p3
end

function Default.UnbindOnLeave(p, p2)
	if not p.OnLeaveConnections[p2] then
		return
	end

	p.OnLeaveConnections[p2] = nil
end

function Default.BindOnPress(p, p2, p3)
	if p.OnPressConnections[p2] then
		return
	end

	p.OnPressConnections[p2] = p3
end

function Default.UnbindOnPress(p, p2)
	if not p.OnPressConnections[p2] then
		return
	end

	p.OnPressConnections[p2] = nil
end

function Default.BindOnRelease(p, p2, p3)
	if p.OnReleaseConnections[p2] then
		return
	end

	p.OnReleaseConnections[p2] = p3
end

function Default.UnbindOnRelease(p, p2)
	if not p.OnReleaseConnections[p2] then
		return
	end

	p.OnReleaseConnections[p2] = nil
end

function Default.Destroy(p)
	for k, connection in p.Connections do
		connection:Disconnect()
		p.Connections[k] = nil
	end

	p.Scope:doCleanup()
end

return Default