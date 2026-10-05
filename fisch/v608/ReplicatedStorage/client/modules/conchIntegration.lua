local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local conch_standalone = require(ReplicatedStorage.packages.conch_standalone)
local Net = require(ReplicatedStorage.packages.Net)
return {
	init = function()
		require(ReplicatedStorage.shared.conchTypes)
		conch_standalone.initiate_default_lifecycle()
		conch_standalone.ui.bind_to(Enum.KeyCode.F2)
		Net:RemoteEvent("Conch/SetCore", -1).OnClientEvent:Connect(function(...)
			StarterGui:SetCore(...)
		end)
	end
}