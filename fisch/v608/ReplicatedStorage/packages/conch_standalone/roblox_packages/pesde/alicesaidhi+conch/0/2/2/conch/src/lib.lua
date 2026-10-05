local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local module = require("./arguments")
local module2 = require("../roblox_packages/ast")
local module3 = require("./bootstrap")
local module4 = require("./client")
local module5 = require("./console")
local module6 = require("./context")
local module7 = require("./net")
local module8 = require("./state")
require("./types")
local module9 = require("./user")
local isServer = RunService:IsServer()
local isClient = RunService:IsClient()
local create_user = module9.create_user
local disconnect_user = module9.disconnect_user
local has_permissions = module9.has_permissions
local create_command_context = module6.create_command_context
local get_command_context = module6.get_command_context

local function FOREACH(items, callback)
	for k, item in items do
		callback(item, k)
	end
end

local function set_role(p, ...)
	module8.roles[p] = { ... }

	if isServer then
		module7.server.fire_update_role_perms(p, { ... })
	end
end

local function initiate_user_replication(p)
	for _, command in module5.console.commands do
		if has_permissions(p, unpack(command.permissions)) then
			module7.server.fire_register_command(p.player, {
				name = command.name,
				permissions = command.permissions
			})
		end
	end
end

local function get_user(player)
	if typeof(player) == "string" then
		local obtain_user_key = module9.obtain_user_key(false, player)
		local user = module8.users[obtain_user_key]

		if user then
			return user
		end

		return (create_user({
			name = obtain_user_key,
			player = false
		}))
	else
		local obtain_user_key = module9.obtain_user_key(player, player.DisplayName)
		local user = module8.users[obtain_user_key]

		if user then
			return user
		end

		local v = create_user({
			name = player.DisplayName,
			player = player
		})
		initiate_user_replication(v)
		return v
	end
end

local function disconnect_user_for_player(p)
	local obtain_user_key = module9.obtain_user_key(p, p.DisplayName)
	local user = module8.users[obtain_user_key]

	if not user then
		return
	end

	disconnect_user(user)
end

local function invoke_server_command(player, data)
	local v = get_user(player)
	local command = module5.console.commands[data.name]

	local function fail()
		module7.server.fire_failed_invoke_reply(player, data.invoke_id)
	end

	if not (command and v and has_permissions(v, unpack(command.permissions))) then
		return fail()
	end

	local v2 = create_command_context(v, data.invoke_id)

	local function handle(flag: boolean, ...)
		v2()

		if flag then
			return module7.server.fire_successful_invoke_reply(player, data.invoke_id, { ... })
		end

		warn(...)
		return fail()
	end

	return handle(pcall(command.callback, unpack(data.args)))
end

local function resend_new_commands(state)
	if not (state.dirty and state.net_ready) then
		return
	end

	for _, command in module5.console.commands do
		module5.replicate_to_player(state.player, command)
	end

	state.dirty = false
end

local function mark_net_ready(player)
	local v = get_user(player)

	if v and not (v.disconnected or v.net_ready) then
		v.net_ready = true
		v.dirty = true
	end
end

local v = {}
local Lib = {}
Lib.args = module
Lib.parse = module2

function Lib.execute(p: string)
	local local_user = module8.local_user
	assert(isClient, "cannot run commands outside of the client")
	assert(local_user, "unable to run commands without a local user")
	local v2 = create_command_context(local_user, false)
	local success, result = pcall(module5.execute, p)

	if not success then
		module5.console.output({
			kind = "error",
			text = result
		})
	end

	v2()
end

Lib.register_quick = module5.register_quick
Lib.register = module5.register_command

function Lib.initiate_default_lifecycle()
	if isClient then
		module7.client.init()
		module7.client.on_command_registered(module4.register_command)
		module7.client.on_invoke_reply(module4.receive_server_results)
		module7.client.on_log_received(module4.log)
		module7.client.on_user_info_received(module4.create_local_user)
		module7.client.on_role_info_received(module4.update_role_permissions)
		module7.client.on_user_roles_update(module4.update_user_roles)
		module7.client.fire_ready()
	elseif isServer then
		module7.server.init()
		Players.PlayerAdded:Connect(get_user)
		Players.PlayerRemoving:Connect(disconnect_user_for_player)
		local players = Players:GetPlayers()
		local get_user2 = get_user

		for k, player in players do
			get_user2(player, k)
		end

		local players2 = Players:GetPlayers()

		for _, player in players2 do
			resend_new_commands(get_user(player))
		end

		module7.server.on_command_invoke(invoke_server_command)
		module7.server.on_ready(mark_net_ready)
		RunService.Heartbeat:Connect(function()
			for _, user in module8.users do
				resend_new_commands(user)
			end
		end)
	end
end

Lib.has_permissions = module9.has_permissions
Lib.set_role_permissions = set_role
Lib.give_roles = module9.give_roles
Lib.remove_roles = module9.remove_roles
Lib.get_user = get_user
Lib.set_var = module5.write_global
Lib.get_command_context = get_command_context
Lib.register_type = module5.register_type

function Lib.log(kind: string, text: string)
	if not isServer then
		module5.console.output({
			kind = kind,
			text = text
		})
		return
	end

	local v2 = v[coroutine.running()]

	if v2 then
		table.insert(v2, {
			kind = kind,
			text = text
		})
	end

	local v3 = module8.command_context[coroutine.running()]

	if not v3 then
		return
	end

	local player = v3.executor.player

	if not player then
		return
	end

	module7.server.fire_log(player, {
		kind = kind,
		text = text
	})
end

function Lib.listenLogs()
	if v[coroutine.running()] then
		warn(debug.traceback("A custom log listener already exists for the current thread!"))
	end

	v[coroutine.running()] = {}
end

function Lib.getLogs()
	assert(isServer, "server only twin")
	local v2 = v[coroutine.running()]

	if not v2 then
		return {}
	end

	v[coroutine.running()] = nil
	return v2
end

function Lib.sendLogs(p, items)
	assert(isServer, "server only twin")

	for _, item in items do
		module7.server.fire_log(p, item)
	end
end

Lib.register_default_commands = module3
Lib.console = module5.console
Lib.analyze = module5.analyze
Lib.on_command_invoke = module7.server.on_command_invoke
Lib._ = {
	create_user = module9.create_user,
	disconnect_user = module9.disconnect_user,
	create_local_user = function()
		local obtain_user_key = module9.obtain_user_key(false, "local")
		local local_user = module8.users[obtain_user_key] or create_user({
			name = obtain_user_key,
			player = false
		})
		module8.local_user = local_user
		return local_user
	end
}
return Lib