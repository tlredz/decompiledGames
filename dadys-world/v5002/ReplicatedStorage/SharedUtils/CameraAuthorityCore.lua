local CameraAuthorityCore = {
	DEFAULT_PRIORITY = 10,
	new = function()
		return {
			claims = {},
			gates = {},
			nextId = 1,
			seq = 0
		}
	end
}

function CameraAuthorityCore:claim(owner: string, p2: number?)
	local nextId = self.nextId
	self.nextId += 1
	self.seq += 1
	table.insert(self.claims, {
		id = nextId,
		owner = owner,
		priority = p2 or CameraAuthorityCore.DEFAULT_PRIORITY,
		seq = self.seq
	})
	return nextId
end

function CameraAuthorityCore.release(p, p2: number)
	for i, claim in ipairs(p.claims) do
		if claim.id ~= p2 then
			continue
		end

		table.remove(p.claims, i)
		return true
	end

	return false
end

function CameraAuthorityCore.releaseOwner(p, p2: string)
	local count = 0

	for i = #p.claims, 1, -1 do
		if p.claims[i].owner ~= p2 then
			continue
		end

		table.remove(p.claims, i)
		count += 1
	end

	return count
end

function CameraAuthorityCore:clearAll()
	local v = #self.claims
	self.claims = {}
	self.gates = {}
	return v
end

function CameraAuthorityCore.active(p)
	local v = nil

	for _, claim in ipairs(p.claims) do
		if not (v == nil or claim.priority > v.priority or claim.priority == v.priority and claim.seq > v.seq) then
			continue
		end

		v = claim
	end

	return v
end

function CameraAuthorityCore.isActive(p, p2: number)
	local active = CameraAuthorityCore.active(p)
	return active ~= nil and active.id == p2
end

function CameraAuthorityCore.desiredType(p)
	if #p.claims > 0 then
		return "Scriptable"
	end

	return "Custom"
end

function CameraAuthorityCore.gateRotation(p, p2: string, flag: boolean)
	if flag then
		p.gates[p2] = nil
	else
		p.gates[p2] = true
	end
end

function CameraAuthorityCore.rotationEnabled(p)
	return next(p.gates) == nil
end

function CameraAuthorityCore.reconcile(p, p2: string)
	if #p.claims > 0 then
		if p2 == "Scriptable" then
			return "ok"
		end

		return "overridden"
	elseif p2 == "Custom" then
		return "ok"
	else
		return "stuck"
	end
end

function CameraAuthorityCore.dump(p)
	local active = CameraAuthorityCore.active(p)
	local v = {}

	for k in pairs(p.gates) do
		table.insert(v, k)
	end

	table.sort(v)
	return string.format(
		"claims=%d active=%s gates=[%s] desired=%s",
		#p.claims,
		active and string.format("%s(p%d#%d)", active.owner, active.priority, active.id) or "none",
		table.concat(v, ","),
		CameraAuthorityCore.desiredType(p)
	)
end

return CameraAuthorityCore