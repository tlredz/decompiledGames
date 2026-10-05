local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local v = RunService:IsServer() and "server" or "client"

local function assert_run_context(p: string)
	assert(v == p, (`expected run context {p} but got {v}`))
end

local v2 = nil
local Net = {
	client = {
		initialized = false
	},
	server = {
		initialized = false
	}
}

local function init()
	assert(v == "server", (`expected run context server but got {v}`))
	local folder = Instance.new("Folder")
	folder.Name = "conch_networking"
	folder.Parent = ReplicatedStorage

	-- equivalent calls inferred from this helper; original call sites unknown
	local function remote(name: string)
		local remoteEvent = Instance.new("RemoteEvent")
		remoteEvent.Name = name
		remoteEvent.Parent = folder
		return remoteEvent
	end

	v2 = {
		invoke_server_command = remote("invoke_server_command"),
		create_user = remote("create_user"),
		update_user_roles = remote("update_user_roles"),
		update_role_permissions = remote("update_role_permissions"),
		register_command = remote("register_command"),
		client_ready = remote("client_ready"),
		log = remote("log")
	}
	Net.server.initialized = true
end

Net.server.init = init

local function init2()
	assert(v == "client", (`expected run context client but got {v}`))
	local conch_networking = ReplicatedStorage:WaitForChild("conch_networking")

	local function remote(childName: string)
		return (conch_networking:WaitForChild(childName))
	end

	v2 = {
		invoke_server_command = conch_networking:WaitForChild("invoke_server_command"),
		create_user = conch_networking:WaitForChild("create_user"),
		update_user_roles = conch_networking:WaitForChild("update_user_roles"),
		update_role_permissions = conch_networking:WaitForChild("update_role_permissions"),
		register_command = conch_networking:WaitForChild("register_command"),
		client_ready = conch_networking:WaitForChild("client_ready"),
		log = conch_networking:WaitForChild("log")
	}
	Net.client.initialized = true
end

Net.client.init = init2

local function on_user_roles_update(onOnClientEvent)
	assert(Net.client.initialized, "client not initialized")
	assert(v == "client", (`expected run context client but got {v}`))
	v2.update_user_roles.OnClientEvent:Connect(onOnClientEvent)
end

Net.client.on_user_roles_update = on_user_roles_update

local function on_command_registered(onOnClientEvent)
	assert(Net.client.initialized, "client not initialized")
	assert(v == "client", (`expected run context client but got {v}`))
	v2.register_command.OnClientEvent:Connect(onOnClientEvent)
end

Net.client.on_command_registered = on_command_registered

local function on_role_info_received(onOnClientEvent)
	assert(Net.client.initialized, "client not initialized")
	assert(v == "client", (`expected run context client but got {v}`))
	v2.update_role_permissions.OnClientEvent:Connect(onOnClientEvent)
end

Net.client.on_role_info_received = on_role_info_received

local function on_user_info_received(onOnClientEvent)
	assert(Net.client.initialized, "client not initialized")
	assert(v == "client", (`expected run context client but got {v}`))
	v2.create_user.OnClientEvent:Connect(onOnClientEvent)
end

Net.client.on_user_info_received = on_user_info_received

local function on_log_received(onOnClientEvent)
	assert(Net.client.initialized, "client not initialized")
	assert(v == "client", (`expected run context client but got {v}`))
	v2.log.OnClientEvent:Connect(onOnClientEvent)
end

Net.client.on_log_received = on_log_received

local function invoke_command(invoke_id: number, name: string, args)
	assert(Net.client.initialized, "client not initialized")
	assert(v == "client", (`expected run context client but got {v}`))
	v2.invoke_server_command:FireServer({
		invoke_id = invoke_id,
		name = name,
		args = args
	})
end

Net.client.invoke_command = invoke_command

local function on_invoke_reply(onOnClientEvent)
	assert(Net.client.initialized, "client not initialized")
	assert(v == "client", (`expected run context client but got {v}`))
	v2.invoke_server_command.OnClientEvent:Connect(onOnClientEvent)
end

Net.client.on_invoke_reply = on_invoke_reply

local function fire_ready()
	assert(Net.client.initialized, "client not initialized")
	assert(v == "client", (`expected run context client but got {v}`))
	v2.client_ready:FireServer()
end

Net.client.fire_ready = fire_ready

local function on_ready(onOnServerEvent)
	assert(Net.server.initialized, "server not initialized")
	assert(v == "server", (`expected run context server but got {v}`))
	v2.client_ready.OnServerEvent:Connect(onOnServerEvent)
end

Net.server.on_ready = on_ready

local function fire_log(player, p)
	assert(Net.server.initialized, "server not initialized")
	assert(v == "server", (`expected run context server but got {v}`))
	v2.log:FireClient(player, p)
end

Net.server.fire_log = fire_log

local function fire_register_command(player, p)
	assert(Net.server.initialized, "server not initialized")
	assert(v == "server", (`expected run context server but got {v}`))
	v2.register_command:FireClient(player, p)
end

Net.server.fire_register_command = fire_register_command

local function on_command_invoke(onOnServerEvent)
	assert(Net.server.initialized, "server not initialized")
	assert(v == "server", (`expected run context server but got {v}`))
	v2.invoke_server_command.OnServerEvent:Connect(onOnServerEvent)
end

Net.server.on_command_invoke = on_command_invoke

local function fire_successful_invoke_reply(player, invoke_id: number, results)
	assert(Net.server.initialized, "server not initialized")
	assert(v == "server", (`expected run context server but got {v}`))
	v2.invoke_server_command:FireClient(player, {
		status = "ok",
		invoke_id = invoke_id,
		results = results
	})
end

Net.server.fire_successful_invoke_reply = fire_successful_invoke_reply

local function fire_failed_invoke_reply(player, invoke_id: number)
	assert(Net.server.initialized, "server not initialized")
	assert(v == "server", (`expected run context server but got {v}`))
	v2.invoke_server_command:FireClient(player, {
		status = "err",
		invoke_id = invoke_id
	})
end

Net.server.fire_failed_invoke_reply = fire_failed_invoke_reply

local function fire_create_user(player, id: string, name: string)
	assert(Net.server.initialized, "server not initialized")
	assert(v == "server", (`expected run context server but got {v}`))
	v2.create_user:FireClient(player, {
		name = name,
		id = id
	})
end

Net.server.fire_create_user = fire_create_user

local function fire_update_user_roles(player, p)
	assert(Net.server.initialized, "server not initialized")
	assert(v == "server", (`expected run context server but got {v}`))
	v2.update_user_roles:FireClient(player, p)
end

Net.server.fire_update_user_roles = fire_update_user_roles

local function fire_update_role_perms(name: string, permissions)
	assert(Net.server.initialized, "server not initialized")
	assert(v == "server", (`expected run context server but got {v}`))
	v2.update_role_permissions:FireAllClients({
		name = name,
		permissions = permissions
	})
end

Net.server.fire_update_role_perms = fire_update_role_perms
return Net