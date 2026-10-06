local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local engine = ReplicatedStorage:WaitForChild("Engine")
local Net = require(ReplicatedStorage.Packages.Net)
local Permission = require(engine.Service.Permission)
local CommandSchema = require(script.CommandSchema)
local remoteEvent = Net:RemoteEvent("AdminPanelExecute")
local remoteEvent2 = Net:RemoteEvent("AdminPanelResult")
local flag = false
local v = false
local v2 = nil
local v3 = nil
local v4 = {}
local v5 = {}
local v6 = false

local function commands(p)
	local v7

	if p then
		v7 = v3
	else
		v7 = v2
	end

	return require(v7 or engine.Service.CMD)
end

local function listCommands(p)
	return CommandSchema.list(commands(p))
end

local function describeCommand(p, p2)
	local v7

	if p then
		v7 = v3
	else
		v7 = v2
	end

	local v8 = require(v7 or engine.Service.CMD)[p2]

	if not v8 then
		return nil, CommandSchema.result(false, "UNKNOWN_COMMAND", "Unknown command: " .. tostring(p2))
	end

	local success, result = pcall(CommandSchema.describe, p2, v8)

	if success then
		return result
	end

	return nil, CommandSchema.result(false, "INVALID_DEFINITION", (tostring(result)))
end

local function validate(p, p2)
	local success, result, v7 = pcall(CommandSchema.validate, p, p2)

	if success then
		return result, v7
	end

	return nil, CommandSchema.result(false, "INVALID_DEFINITION", (tostring(result)))
end

local function performServer(player, value, clone, p, value2)
	if not RunService:IsServer() then
		return CommandSchema.result(false, "WRONG_CONTEXT", "This command must run on the server.")
	end

	if typeof(player) ~= "Instance" or not player:IsA("Player") or player.Parent ~= Players then
		return CommandSchema.result(false, "INVALID_PLAYER", "You must be in this server to run commands.")
	end

	if not Permission.CanUseCMD(player) then
		return CommandSchema.result(false, "FORBIDDEN", "You do not have permission to use commands.")
	end

	if type(value) ~= "string" then
		return CommandSchema.result(false, "UNKNOWN_COMMAND", "Choose a valid command.")
	end

	local v7 = require(v2 or engine.Service.CMD)[value]

	if not v7 then
		return CommandSchema.result(false, "UNKNOWN_COMMAND", "Unknown command: " .. value)
	end

	local playerByUserId

	if value2 == nil then
		playerByUserId = player
	else
		if type(value2) ~= "number" or value2 % 1 ~= 0 then
			return CommandSchema.result(false, "INVALID_TARGET", "Choose a valid target.")
		end

		if v7.beneficiary then
			playerByUserId = Players:GetPlayerByUserId(value2)

			if not playerByUserId then
				return CommandSchema.result(false, "TARGET_LEFT", "The target left. Choose another player.")
			end
		else
			playerByUserId = player
		end
	end

	if v7.beneficiaryParam and value2 ~= nil then
		clone = table.clone(clone or {})
		clone[v7.beneficiaryParam] = playerByUserId.Name
	end

	local success, result, v8 = pcall(CommandSchema.validate, v7, clone)

	if not success then
		v8 = CommandSchema.result(false, "INVALID_DEFINITION", (tostring(result)))
		result = nil
	end

	if v8 then
		return v8
	end

	if not p and not v7.serverFn and v7.clientFn then
		return CommandSchema.result(false, "WRONG_CONTEXT", "Run this command from the command panel.")
	end

	local PlayerData = require(engine.Service.PlayerData)
	PlayerData.server.Service:waitForData(player).adminCommandUsage(function(options)
		local clone2 = table.clone(options or {})
		clone2[value] = (clone2[value] or 0) + 1
		return clone2
	end)

	if v7.beneficiary and playerByUserId.Parent ~= Players then
		return CommandSchema.result(false, "TARGET_LEFT", "The target left. Choose another player.")
	end

	if v7.beneficiary and not v7.beneficiaryParam then
		PlayerData.server.Service:waitForData(playerByUserId)

		if playerByUserId.Parent ~= Players then
			return CommandSchema.result(false, "TARGET_LEFT", "The target left the server.")
		end
	end

	local invoke = CommandSchema.invoke
	local serverFn = v7.serverFn

	if v7.beneficiary then
		if v7.beneficiaryParam then
			playerByUserId = player
		end
	else
		playerByUserId = player
	end

	return invoke(serverFn, playerByUserId, result)
end

local function serverExecute(p, p2, p3)
	local v7, v8 = xpcall(function()
		return performServer(p, p2, p3, false)
	end, debug.traceback)

	if v7 then
		return v8
	end

	return (CommandSchema.result(false, "EXECUTION_ERROR", "Could not complete the command."))
end

local function serverMain(p)
	if flag then
		return
	end

	flag = true
	v2 = p
	remoteEvent.OnServerEvent:Connect(function(player, value, p2, p3, p4)
		if type(value) ~= "string" or #value > 64 then
			return
		end

		task.spawn(function()
			local v7 = v5[player]

			if not v7 then
				v7 = {}
				v5[player] = v7
			end

			local now = os.clock()

			for k, v8 in v7 do
				if v8.result and now - v8.at > 300 then
					v7[k] = nil
				end
			end

			if v7[value] then
				local v8 = v7[value]

				if v8.result then
					remoteEvent2:FireClient(player, value, v8.result)
				end
			else
				local v8 = {
					at = now
				}
				v7[value] = v8
				local v9, v10 = xpcall(function()
					return performServer(player, p2, p3, true, p4)
				end, debug.traceback)

				if not v9 then
					v10 = CommandSchema.result(false, "EXECUTION_ERROR", "Could not complete the command.")
				end

				v8.result = v10
				v8.at = os.clock()

				if player.Parent == Players then
					remoteEvent2:FireClient(player, value, v10)
				end
			end
		end)
	end)
	Players.PlayerRemoving:Connect(function(player)
		v5[player] = nil
	end)
end

local function clientExecute(value, p, p2)
	if not RunService:IsClient() then
		return CommandSchema.result(false, "WRONG_CONTEXT", "Run this command from the command panel.")
	end

	if not Permission.CanLocalPlayerUseCMD() then
		return CommandSchema.result(false, "FORBIDDEN", "You do not have permission to use commands.")
	end

	if type(value) ~= "string" then
		return CommandSchema.result(false, "UNKNOWN_COMMAND", "Choose a valid command.")
	end

	local v7 = require(v3 or engine.Service.CMD)[value]

	if not v7 then
		return CommandSchema.result(false, "UNKNOWN_COMMAND", "Unknown command: " .. value)
	end

	local success, result, selected = pcall(CommandSchema.validate, v7, p)

	if not success then
		selected = CommandSchema.result(false, "INVALID_DEFINITION", (tostring(result)))
		result = nil
	end

	if selected then
		return selected
	end

	if not v6 then
		v6 = true
		remoteEvent2.OnClientEvent:Connect(function(p3, serverResult)
			local v9 = v4[p3]

			if v9 then
				v9.serverResult = serverResult
			end
		end)
	end

	local GUID = HttpService:GenerateGUID(false)
	local v9 = {
		stage = "client",
		done = false
	}
	v4[GUID] = v9
	task.spawn(function()
		v9.clientResult = CommandSchema.invoke(v7.clientFn, Players.LocalPlayer, result)

		if not v9.clientResult.ok then
			v9.done = true
			return
		end

		v9.stage = "server"
		remoteEvent:FireServer(GUID, value, result, p2)
	end)
	local v10 = os.clock() + 15

	while not v9.done and not v9.serverResult and os.clock() < v10 do
		task.wait()
	end

	v4[GUID] = nil
	local clientResult

	if v9.done then
		clientResult = v9.clientResult
	elseif v9.serverResult then
		clientResult = v9.serverResult

		if clientResult.ok and v7.clientFn then
			clientResult = CommandSchema.result(true, v9.clientResult.code, v9.clientResult.message, {
				client = v9.clientResult.data,
				server = clientResult.data
			})
		end
	else
		clientResult = CommandSchema.result(
			false,
			"TIMEOUT",
			"No result yet. The command may still be running. Check before trying again.",
			{
				stage = v9.stage,
				outcome = "unknown"
			}
		)
	end

	clientResult.requestId = GUID
	return clientResult
end

local function getUsageData()
	local PlayerData = require(engine.Service.PlayerData)
	return PlayerData.client.adminCommandUsage()
end

local function clientMain(p)
	v3 = p

	if v or not Permission.CanLocalPlayerUseCMD() then
		return
	end

	v = true
	local AdminPanelController = require(engine.Gui.AdminPanelController)
	AdminPanelController.init(script.AdminPanelUI, require(v3 or engine.Service.CMD), clientExecute, getUsageData)
end

return {
	server = {
		main = serverMain,
		execute = serverExecute,
		listCommands = function()
			return listCommands(false)
		end,
		describeCommand = function(p)
			return describeCommand(false, p)
		end
	},
	client = {
		main = clientMain,
		execute = clientExecute,
		getUsageData = getUsageData,
		listCommands = function()
			return listCommands(true)
		end,
		describeCommand = function(p)
			return describeCommand(true, p)
		end
	}
}