local Stuck = {}
Stuck.__index = Stuck

function Stuck.BindFunction(p, p2, p3)
	if p.Functions[p2] then
		return
	end

	p.Functions[p2] = p3
end

function Stuck.UnbindFunction(p, p2)
	if not p.Functions[p2] then
		return
	end

	p.Functions[p2] = nil
end

function Stuck.BindOnEnter(p, p2, p3)
	if p.OnEnterConnections[p2] then
		return
	end

	p.OnEnterConnections[p2] = p3
end

function Stuck.UnbindOnEnter(p, p2)
	if not p.OnEnterConnections[p2] then
		return
	end

	p.OnEnterConnections[p2] = nil
end

function Stuck.BindOnMove(p, p2, p3)
	if p.OnMoveConnections[p2] then
		return
	end

	p.OnMoveConnections[p2] = p3
end

function Stuck.UnbindOnMove(p, p2)
	if not p.OnMoveConnections[p2] then
		return
	end

	p.OnMoveConnections[p2] = nil
end

function Stuck.BindOnLeave(p, p2, p3)
	if p.OnLeaveConnections[p2] then
		return
	end

	p.OnLeaveConnections[p2] = p3
end

function Stuck.UnbindOnLeave(p, p2)
	if not p.OnLeaveConnections[p2] then
		return
	end

	p.OnLeaveConnections[p2] = nil
end

function Stuck.BindOnPress(p, p2, p3)
	if p.OnPressConnections[p2] then
		return
	end

	p.OnPressConnections[p2] = p3
end

function Stuck.UnbindOnPress(p, p2)
	if not p.OnPressConnections[p2] then
		return
	end

	p.OnPressConnections[p2] = nil
end

function Stuck.BindOnRelease(p, p2, p3)
	if p.OnReleaseConnections[p2] then
		return
	end

	p.OnReleaseConnections[p2] = p3
end

function Stuck.UnbindOnRelease(p, p2)
	if not p.OnReleaseConnections[p2] then
		return
	end

	p.OnReleaseConnections[p2] = nil
end

function Stuck.Destroy(p)
	for k, connection in p.Connections do
		connection:Disconnect()
		p.Connections[k] = nil
	end

	p.Scope:doCleanup()
end

return Stuck