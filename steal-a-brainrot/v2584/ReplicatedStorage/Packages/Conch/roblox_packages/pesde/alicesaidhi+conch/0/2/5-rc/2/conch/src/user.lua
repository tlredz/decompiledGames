local RunService = game:GetService("RunService")
local module = require("./constants")
local module2 = require("./net")
local module3 = require("./state")
require("./types")
local isServer = RunService:IsServer()
local User = {}

function User.obtain_user_key(p, p2: string?)
	if p then
		return (`player-{p.UserId}`)
	end

	return (`server-{p2}`)
end

function User.create_user(p)
	local player = p.player
	local name = p.name
	local id

	if player then
		id = `player-{player.UserId}`
	else
		id = `server-{name}`
	end

	local v = {
		id = id,
		name = p.name,
		player = p.player,
		disconnected = false,
		dirty = false,
		roles = {}
	}

	if isServer and v.player then
		module2.server.fire_create_user(v.player, v.id, v.name)
	end

	module3.users[v.id] = v
	return v
end

function User.disconnect_user(state)
	if state.disconnected == true then
		return
	end

	state.disconnected = true
	module3.users[state.id] = nil
end

function User.has_permissions(p, ...)
	local v = { ... }

	for _, role in p.roles do
		if module.ADMIN_ROLE == role then
			return true
		end

		if not module3.roles[role] then
			continue
		end

		for _, v2 in module3.roles[role] do
			local index = table.find(v, v2)

			if not index then
				continue
			end

			table.remove(v, index)

			if #v == 0 then
				return true
			end
		end
	end

	return false
end

function User.give_roles(state, ...)
	if state.disconnected then
		return
	end

	local roles = {}

	for i = 1, select("#", ...) do
		local v2 = select(i, ...)

		if not table.find(roles, v2) then
			table.insert(roles, v2)
		end
	end

	for _, role in state.roles do
		if not table.find(roles, role) then
			table.insert(roles, role)
		end
	end

	state.roles = roles

	if isServer and state.player then
		state.dirty = true
		module2.server.fire_update_user_roles(state.player, {
			id = state.id,
			roles = roles
		})
	end
end

function User.remove_roles(state, ...)
	if state.disconnected then
		return
	end

	local clone = table.clone(state.roles)
	local v = { ... }

	for i = #clone, 1, -1 do
		if not table.find(v, clone[i]) then
			continue
		end

		clone[i] = clone[#clone]
		clone[#clone] = nil
	end

	state.roles = clone

	if RunService:IsServer() and state.player then
		state.dirty = true
		module2.server.fire_update_user_roles(state.player, {
			id = state.id,
			roles = clone
		})
	end
end

return User