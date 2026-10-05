local VehicleStateUtil = {}
local RunService = game:GetService("RunService")
local isServer = RunService:IsServer()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local v = nil
require(ReplicatedStorage.Modules.Shared.Game.Vehicles.VehicleState)

function VehicleStateUtil.ApplyStateToVehicle(p: string, p2)
	if not isServer then
		warn("ApplyStateToVehicle can only be called from the server")
		return false
	end

	if not p then
		warn("No vehicle uuid provided")
		return false
	end

	if not p2 then
		warn("No state provided")
		return false
	end

	local vehicleRoot = v.GetVehicleRoot(p)

	if vehicleRoot then
		vehicleRoot:SetState(p2)
		return true
	end

	warn("No vehicle found")
	return false
end

function VehicleStateUtil.GetVehicleState(p: string)
	if not isServer then
		return Remotes.invokeServer("GetVehicleState", p)
	end

	local vehicleRoot = v.GetVehicleRoot(p)

	if vehicleRoot then
		return vehicleRoot:GetState()
	end

	warn("No vehicle found")
end

function VehicleStateUtil.FrameworkInit() end

function VehicleStateUtil.FrameworkStart()
	if isServer then
		Remotes.createRemoteFunction("GetVehicleState")
		Remotes.onInvoke("GetVehicleState", function(_, p: string)
			return VehicleStateUtil.GetVehicleState(p)
		end)
		local ServerScriptService = game:GetService("ServerScriptService")
		local VehicleSpawnService = require(ServerScriptService.Modules.Vehicles.Services.VehicleSpawnService)
		v = VehicleSpawnService
	end
end

return VehicleStateUtil