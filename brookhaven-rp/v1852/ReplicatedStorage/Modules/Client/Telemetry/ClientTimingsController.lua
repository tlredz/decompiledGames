local ClientTimingsController = {}
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local Math = require(ReplicatedStorage.Modules.Shared.Math)
local ClientTimingsConstants = require(ReplicatedStorage.Modules.Shared.Telemetry.ClientTimingsConstants)
local v = {
	{ "NoResetGUIHandler", "AvatarEditorMenu" },
	{ "MainGUIHandler", "MainButtons" }
}
local v2 = {}
local v3 = {}

local function trySendData()
	local values = {}

	for k, v4 in v3 do
		local v5 = v2[k]

		if v5 ~= nil then
			values[k] = Math.round(v4 - v5, 4)
		end
	end

	if TableUtil.IsEmpty(values) then
		return
	end

	for k, _ in values do
		v2[k] = nil
		v3[k] = nil
	end

	Remotes.fireServer("ClientTimings:SendData", values)
end

local function sendDataLoop()
	while RunService:IsRunning() do
		task.wait(5)
		trySendData()
	end
end

local function checkAllTimingsCompleted()
	for k, _ in ClientTimingsConstants.AcceptableIdentifiers do
		if v2[k] == nil or v3[k] == nil then
			return
		end
	end

	task.spawn(trySendData)
end

function ClientTimingsController.FrameworkStart()
	local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
	PanelController.PanelRegistration:Connect(function(_, p: string)
		if ClientTimingsConstants.AcceptableIdentifiers[p] ~= nil then
			ClientTimingsController.Stop(p)
		end
	end)

	for _, list in v do
		local v4, v5 = table.unpack(list)
		ClientTimingsController.Start(v5)

		if PanelController.IsRegistered(v4, v5) then
			ClientTimingsController.Stop(v5)
		end
	end

	task.spawn(sendDataLoop)
end

function ClientTimingsController.Start(p: string)
	v2[p] = os.clock()
end

function ClientTimingsController.Stop(p: string)
	v3[p] = os.clock()
	checkAllTimingsCompleted()
end

function ClientTimingsController.StopWithStartTime(p: string, p2: number)
	v2[p] = p2
	ClientTimingsController.Stop(p)
end

function ClientTimingsController.Provide(p: string, p2: number, p3: number)
	v2[p] = p2
	v3[p] = p3
	checkAllTimingsCompleted()
end

return ClientTimingsController