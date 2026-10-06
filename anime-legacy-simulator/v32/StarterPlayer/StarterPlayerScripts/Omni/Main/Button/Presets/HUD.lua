local HUD = {}
HUD.__index = HUD

function HUD.Setup(data)
	local value = data.Scope:Value(1)
	local value2 = data.Scope:Value(nil)
	local visible = data.Scope:Value(nil)
	local enabled = data.Scope:Value(nil)
	data.Scope:Observer(data.State):onBind(function()
		local state = data.Scope.peek(data.State)

		if state == "Pressed" then
			visible:set(true)
			enabled:set(false)
			value2:set(30)
			value:set(0.9)
		elseif state == "Hover" then
			visible:set(true)
			enabled:set(false)
			value2:set(-15)
			value:set(1.1)
		else
			visible:set(false)
			enabled:set(true)
			value2:set(0)
			value:set(1)
		end
	end)
	local hover = data.Instance:FindFirstChild("Hover")

	if hover then
		data.Scope:Hydrate(hover)({
			Visible = visible
		})
	end

	local icon = data.Instance:FindFirstChild("Icon")

	if icon then
		data.Scope:Hydrate(icon)({
			Rotation = data.Scope:Spring(value2, 40, 1)
		})
		local uIGradient = icon:FindFirstChild("UIGradient")

		if uIGradient then
			data.Scope:Hydrate(uIGradient)({
				Enabled = enabled
			})
		end
	end

	data.Scope:Hydrate(data.UIScale)({
		Scale = data.Scope:Spring(value, 40, 1)
	})
end

function HUD.BindFunction(p, p2, p3)
	if p.Functions[p2] then
		return
	end

	p.Functions[p2] = p3
end

function HUD.UnbindFunction(p, p2)
	if not p.Functions[p2] then
		return
	end

	p.Functions[p2] = nil
end

function HUD.BindOnEnter(p, p2, p3)
	if p.OnEnterConnections[p2] then
		return
	end

	p.OnEnterConnections[p2] = p3
end

function HUD.UnbindOnEnter(p, p2)
	if not p.OnEnterConnections[p2] then
		return
	end

	p.OnEnterConnections[p2] = nil
end

function HUD.BindOnMove(p, p2, p3)
	if p.OnMoveConnections[p2] then
		return
	end

	p.OnMoveConnections[p2] = p3
end

function HUD.UnbindOnMove(p, p2)
	if not p.OnMoveConnections[p2] then
		return
	end

	p.OnMoveConnections[p2] = nil
end

function HUD.BindOnLeave(p, p2, p3)
	if p.OnLeaveConnections[p2] then
		return
	end

	p.OnLeaveConnections[p2] = p3
end

function HUD.UnbindOnLeave(p, p2)
	if not p.OnLeaveConnections[p2] then
		return
	end

	p.OnLeaveConnections[p2] = nil
end

function HUD.BindOnPress(p, p2, p3)
	if p.OnPressConnections[p2] then
		return
	end

	p.OnPressConnections[p2] = p3
end

function HUD.UnbindOnPress(p, p2)
	if not p.OnPressConnections[p2] then
		return
	end

	p.OnPressConnections[p2] = nil
end

function HUD.BindOnRelease(p, p2, p3)
	if p.OnReleaseConnections[p2] then
		return
	end

	p.OnReleaseConnections[p2] = p3
end

function HUD.UnbindOnRelease(p, p2)
	if not p.OnReleaseConnections[p2] then
		return
	end

	p.OnReleaseConnections[p2] = nil
end

function HUD.Destroy(p)
	for k, connection in p.Connections do
		connection:Disconnect()
		p.Connections[k] = nil
	end

	p.Scope:doCleanup()
end

return HUD