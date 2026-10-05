local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local module = require("@self/arguments")
local module2 = require("@self/bootstrap")
local module3 = require("@self/client")
local module4 = require("@self/console")
local module5 = require("@self/context")
require("./roblox_packages/language")
local module6 = require("@self/net")
local module7 = require("@self/state")
require("@self/types")
local module8 = require("@self/user")
local isServer = RunService:IsServer()
local isClient = RunService:IsClient()
local create_user = module8.create_user
local disconnect_user = module8.disconnect_user
local has_permissions = module8.has_permissions
local create_command_context = module5.create_command_context
local get_command_context = module5.get_command_context

local function FOREACH(items, callback)
	for k, item in items do
		callback(item, k)
	end
end

local function set_role(p, ...)
	module7.roles[p] = { ... }

	if isServer then
		module6.server.fire_update_role_perms(p, { ... })
	end
end

local function initiate_user_replication(p)
	if not p.player then
		return
	end

	for _, command in module4.console.commands do
		if has_permissions(p, unpack(command.permissions)) then
			module6.server.fire_register_command(p.player, {
				name = command.name,
				description = command.description,
				permissions = command.permissions,
				type = command.type
			})
		end
	end
end

local function get_user(player)
	if typeof(player) == "string" then
		local obtain_user_key = module8.obtain_user_key(false, player)
		local user = module7.users[obtain_user_key]

		if user then
			return user
		end

		return (create_user({
			name = obtain_user_key,
			player = false
		}))
	else
		local obtain_user_key = module8.obtain_user_key(player, player.DisplayName)
		local user = module7.users[obtain_user_key]

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
	local obtain_user_key = module8.obtain_user_key(p, p.DisplayName)
	local user = module7.users[obtain_user_key]

	if not user then
		return
	end

	disconnect_user(user)
end

local function invoke_server_command(player, data)
	local v = get_user(player)
	local command = module4.console.commands[data.name]

	local function fail()
		module6.server.fire_failed_invoke_reply(player, data.invoke_id)
	end

	if not (command and v and has_permissions(v, unpack(command.permissions))) then
		return fail()
	end

	local v2 = create_command_context(v, data.invoke_id)

	local function handle(flag: boolean, ...)
		v2()

		if flag then
			return module6.server.fire_successful_invoke_reply(player, data.invoke_id, { ... })
		end

		warn(...)
		return fail()
	end

	return handle(pcall(command.callback, unpack(data.args)))
end

local function resend_new_commands(state)
	if not (state.dirty and state.player) then
		return
	end

	for _, command in module4.console.commands do
		module4.replicate_to_player(state.player, command)
	end

	state.dirty = false
end

local v = {}

local function on_ready(player)
	if v[player] then
		return
	end

	v[player] = true
	local v2 = get_user(player)
	v2.dirty = true
	module6.server.fire_create_user(player, v2.id, v2.name)

	for k, role in module7.roles do
		module6.server.fire_update_role_perms_to(player, k, role)
	end

	module6.server.fire_update_user_roles(player, {
		id = v2.id,
		roles = v2.roles
	})
	resend_new_commands(get_user(player))
end

local Src = {}
Src.version = "0.4.0-rc.9"
Src.args = module.args
Src.get_strange_type = module.get_strange_type
Src.register_strange_type = module.register_strange_type
Src.pluralize_type = module.pluralize
Src.wrap_type = module.wrap_type

function Src.execute(p: string)
	local local_user = module7.local_user
	assert(isClient, "cannot run commands outside of the client")
	assert(local_user, "unable to run commands without a local user")

	if isClient then
		module6.client.fire_log_command(p)
	end

	local v2 = create_command_context(local_user, false)
	local success, result = pcall(module4.execute, p)

	if not success then
		module4.console.output({
			kind = "error",
			text = result
		})
	end

	v2()
end

Src.cancel = module4.cancel
Src.register_quick = module4.register_quick
Src.register = module4.register_command

function Src.on_execution(callback)
	local connection = module6.server.on_log_command(function(object, value)
		if typeof(value) ~= "string" then
			object:Kick()
		end

		callback(object, value)
	end)
	return function()
		connection:Disconnect()
	end
end

function Src.on_command_run(callback)
	local connection = module4.after_command_run:connect(callback)
	return function()
		connection:disconnect()
	end
end

function Src.initiate_default_lifecycle()
	if isClient then
		module6.client.init()
		module6.client.on_command_registered(module3.register_command)
		module6.client.on_invoke_reply(module3.receive_server_results)
		module6.client.on_log_received(module3.log)
		module6.client.on_user_info_received(module3.create_local_user)
		module6.client.on_role_info_received(module3.update_role_permissions)
		module6.client.on_user_roles_update(module3.update_user_roles)
		module6.client.fire_ready()
	elseif isServer then
		module6.server.init()
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

		module6.server.on_ready(on_ready)
		module6.server.on_command_invoke(invoke_server_command)
		RunService.PostSimulation:Connect(function()
			for _, user in module7.users do
				resend_new_commands(user)
			end
		end)
	end
end

Src.has_permissions = module8.has_permissions
Src.set_role_permissions = set_role
Src.give_roles = module8.give_roles
Src.remove_roles = module8.remove_roles
Src.get_user = get_user
Src.set_var = module4.write_global
Src.get_command_context = get_command_context

function Src.log(kind: string, text: string)
	if not isServer then
		module4.console.output({
			kind = kind,
			text = text
		})
		return
	end

	local v2 = module7.command_context[coroutine.running()]

	if not v2 then
		return
	end

	local player = v2.executor.player

	if not player then
		return
	end

	module6.server.fire_log(player, {
		kind = kind,
		text = text
	})
end

function Src.log_to(p, kind: string, text: string)
	if isServer then
		module6.server.fire_log(p, {
			kind = kind,
			text = text
		})
	elseif Players.LocalPlayer == p then
		module4.console.output({
			kind = kind,
			text = text
		})
	end
end

Src.register_default_commands = module2
Src.console = module4.console
Src.analyze = module4.analyze
Src._ = {
	type = module.type,
	create_user = module8.create_user,
	disconnect_user = module8.disconnect_user,
	create_local_user = function()
		local obtain_user_key = module8.obtain_user_key(false, "local")
		local local_user = module7.users[obtain_user_key] or create_user({
			name = obtain_user_key,
			player = false
		})
		module7.local_user = local_user
		return local_user
	end
}
return Src