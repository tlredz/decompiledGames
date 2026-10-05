local RunService = game:GetService("RunService")
local isServer = RunService:IsServer()
local Config = require(script.Shared.Config)
local HttpService = game:GetService("HttpService")
local Stats = require(script.Shared.Stats)
local Player = require(script.Server.Player)
local Receiver = require(script.Server.Receiver)
local ServerClock = require(script.Server.ServerClock)
local Entity = require(script.Shared.Entity)
local Events = require(script.Shared.Events)
local Holder = require(script.Shared.Holder)
local ReplicationRules = require(script.Shared.ReplicationRules)
local Snapshots = require(script.Shared.Snapshots)
require(script.Shared.Types)
local EntityGrid = require(script.Server.EntityGrid)

-- equivalent calls inferred from this helper; original call sites unknown
local function CheckVersion()
	task.spawn(function()
		pcall(function()
			local success, result = pcall(function()
				return HttpService:GetAsync("https://api.github.com/repos/Parihsz/Chrono/releases/latest")
			end)

			if not success then
				return
			end

			local tag_name = HttpService:JSONDecode(result).tag_name
			local _GetConfig = Config._GetConfig("__VERSION")

			if tag_name ~= _GetConfig then
				warn(("Chrono: A new version is available! You are using version %s, but the latest version is %s."):format(
					_GetConfig,
					tag_name
				))
			end
		end)
	end)
end

local flag = false
return {
	Start = function(moduleScript)
		if flag then
			warn("Chrono: Already Started. Ignoring subsequent calls.")
			return
		end

		flag = true

		if moduleScript then
			require(moduleScript)
		end

		if isServer then
			require(script.Server.Replicate)
		else
			require(script.Client.Replicate)
		end

		Config._Lock()

		if isServer and Config._GetConfig("CHECK_NEW_VERSION") then
			CheckVersion() -- equivalent call inferred; original call site unknown
		end

		local _GetConfig = Config._GetConfig("__VERSION")
		print((`Chrono {_GetConfig} Started.`))
	end,
	Holder = Holder,
	Entity = Entity,
	Stats = Stats,
	Config = Config,
	ReplicationRules = ReplicationRules,
	Events = Events,
	Snapshots = Snapshots,
	ServerClock = ServerClock,
	Player = Player,
	ServerReceiver = Receiver,
	EntityGrid = EntityGrid
}