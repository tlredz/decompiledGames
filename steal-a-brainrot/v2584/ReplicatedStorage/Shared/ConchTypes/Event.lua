local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Conch = require(ReplicatedStorage.Packages.Conch)
local Net = require(ReplicatedStorage.Packages.Net)
local v = {}

if RunService:IsServer() then
	local ServerScriptService = game:GetService("ServerScriptService")
	local EventService = require(ServerScriptService.Services.EventService)

	for k in EventService.Events do
		table.insert(v, k)
	end
else
	v = Net:Invoke("EventService/ListEvents")
end

return Conch.register_type("Event", Conch.args.enum_new(v))