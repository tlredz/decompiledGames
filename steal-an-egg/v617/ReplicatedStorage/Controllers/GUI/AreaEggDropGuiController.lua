local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AreaEggs = require(ReplicatedStorage.Shared.Types.AreaEggs)
local ButtonFX = require(ReplicatedStorage.Client.UI.VFX.ButtonFX)
local EggState = require(ReplicatedStorage.Client.EggState)
local GUI = require(ReplicatedStorage.Client.GUI)
local Log = require(ReplicatedStorage.Packages.Log)
local Timer = require(ReplicatedStorage.Packages.Timer)
local ToolGameplayGuard = require(ReplicatedStorage.Client.ToolGameplayGuard)
local Trove = require(ReplicatedStorage.Packages.Trove)
local playerRequest = AreaEggs.DropReasons.PlayerRequest
local v = Log.new()
local localPlayer = Players.LocalPlayer
return {
	Start = function()
		local v2 = GUI.DropHeldEgg()
		local maid = Trove.new()
		local isCarrying = false

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateVisibility()
			v2.Enabled = isCarrying and ToolGameplayGuard.IsLocalInsideArena()
		end

		local function setCarrying(p)
			isCarrying = p.IsCarrying
			updateVisibility() -- equivalent call inferred; original call site unknown
		end

		v2.Enabled = false
		ButtonFX(v2.Button, nil, function()
			if not ToolGameplayGuard.IsLocalInsideArena() then
				updateVisibility() -- equivalent call inferred; original call site unknown
				return
			end

			local v3, v4 = EggState.DropFieldEgg(playerRequest)

			if not v3 and v4 ~= nil then
				v:AtDebug():Log((`Drop held area egg denied for {localPlayer.UserId}: {v4}`))
			end
		end)
		maid:Add(Timer.Simple(0.1, updateVisibility, true))
		maid:Add(EggState.CarryChanged:Connect(setCarrying))
		maid:AttachToInstance(script)
	end
}