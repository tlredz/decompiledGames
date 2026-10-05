local GamepassController = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GlobalReplicatedDataController = require(ReplicatedStorage.Modules.Client.Data.GlobalReplicatedDataController)
local RunService = game:GetService("RunService")
local GamepassNeededController = require(ReplicatedStorage.Modules.Client.UI.GamepassNeededController)
local GamepassUnlockController = require(ReplicatedStorage.Modules.Client.UI.GamepassUnlockController)
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local Purchasable = require(ReplicatedStorage.Modules.Shared.PlayerData.Purchasable)
local CountDownLatch = require(ReplicatedStorage.Modules.Shared.Async.CountDownLatch)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local Signal = require(ReplicatedStorage.Packages.Signal)
require(ReplicatedStorage.Modules.Shared.Advertisements.AdFeatures)
local v = nil
local v2 = nil

local function runPendingPurchaseIfMatching(p: number)
	if v2 == nil or v2.gamepassId ~= p then
		return
	end

	if v2.promptClosedAt ~= nil and os.clock() - v2.promptClosedAt > 10 then
		v2 = nil
		return
	end

	local callback = v2.callback
	v2 = nil
	task.spawn(callback)
end

GamepassController.OnGamepassUnlocked = Signal.new()

function GamepassController.FrameworkInit()
	GamepassController.Overrides = {}
end

function GamepassController.FrameworkStart()
	RunService.Heartbeat:Connect(function()
		if v == nil then
			return
		end

		local v3 = v[1]
		local v4 = v[2]
		local v5 = v[3]
		local v6 = v[4]
		local v7 = v[5]
		local v8 = v[6]
		local v9 = v[7]
		v = nil
		task.spawn(GamepassController.Show, v3, v4, v5, v6, v7, v8, nil, nil, v9)
	end)
	Remotes.connect("ShowGamepass", function(p, p2, p3, p4)
		GamepassController.Show(Gamepasses.GetById(p), p2, p3, nil, p4, nil, p3, p4 and p4.id)
	end)
	Remotes.connect("GamepassPromptPurchaseFinished", function(p: number, flag: boolean)
		if flag then
			Players.LocalPlayer.PlayerGui.PurchaseSFX:Play()

			if v2 ~= nil and v2.gamepassId == p then
				v2.promptClosedAt = os.clock()
			end
		elseif v2 ~= nil and v2.gamepassId == p then
			v2 = nil
		end
	end)
	GlobalReplicatedDataController.WaitForReplica():OnChange(function(p, list, items, _)
		local v3 = list[1] == tostring(Players.LocalPlayer.UserId)
		local v4 = list[2] == "profile"
		local v5 = list[3] == "gamepasses"

		if p == "SetValues" and v3 and v4 and v5 then
			for k, item in items do
				if not item then
					continue
				end

				local v6 = tonumber(k)
				GamepassController.OnGamepassUnlocked:Fire(v6)

				if not (v6 ~= nil and v2 ~= nil and v2.gamepassId == v6) then
					continue
				end

				if v2.promptClosedAt == nil or not (os.clock() - v2.promptClosedAt > 10) then
					local callback = v2.callback
					v2 = nil
					task.spawn(callback)
				else
					v2 = nil
				end
			end
		end
	end)
	GamepassController.Overrides = Remotes.invokeServer("GetProductOverrides")
end

function GamepassController.GetOverrideProductId(p)
	if GamepassController.Overrides == nil or GamepassController.Overrides.gamepasses == nil then
		return nil
	end

	return GamepassController.Overrides.gamepasses[tostring(Gamepasses.GetId(p))]
end

function GamepassController.WaitForGamepasses()
	local v3 = GlobalReplicatedDataController.WaitForReplica()
	local v4 = v3.Data[tostring(Players.LocalPlayer.UserId)]

	if v4 ~= nil and v4.loaded then
		return
	end

	local v5 = CountDownLatch.new(1)
	v3:OnSet({ tostring(Players.LocalPlayer.UserId), "loaded" }, function()
		v5:countDown()
	end)
	v5:await()
end

function GamepassController.IsOwnedLegacy(p)
	return GamepassController.IsPlayerOwnedLegacy(Players.LocalPlayer.UserId, p)
end

function GamepassController.IsOwned(p)
	return GamepassController.IsPlayerOwned(Players.LocalPlayer.UserId, p)
end

function GamepassController.IsPermanentlyOwned(p)
	local replicatedData = GlobalReplicatedDataController.GetReplicatedData(Players.LocalPlayer.UserId)

	if replicatedData == nil or replicatedData.profile == nil or replicatedData.profile.gamepasses == nil then
		return false
	end

	local v3 = tostring(Gamepasses.GetId(p))
	return replicatedData.profile.gamepasses[v3] and true or false
end

function GamepassController.IsOwnedBefore(p, p2: number)
	local replicatedData = GlobalReplicatedDataController.GetReplicatedData(Players.LocalPlayer.UserId)

	if replicatedData == nil or replicatedData.profile == nil or replicatedData.profile.gamepasses == nil then
		return false
	end

	local v3 = tostring(Gamepasses.GetId(p))
	local gamepass = replicatedData.profile.gamepasses[v3]
	return gamepass ~= nil and gamepass < p2
end

function GamepassController.IsPlayerOwnedLegacy(p: number, p2)
	local replicatedData = GlobalReplicatedDataController.GetReplicatedData(p)

	if replicatedData == nil or replicatedData.profile == nil or replicatedData.profile.gamepasses == nil or replicatedData.profile.gamepassLegacyOwnership == nil then
		return false
	end

	local v3 = tostring(Gamepasses.GetId(p2))
	return replicatedData.profile.gamepassLegacyOwnership[v3] or false
end

function GamepassController.IsPlayerOwned(p: number, p2)
	local replicatedData = GlobalReplicatedDataController.GetReplicatedData(p)

	if replicatedData == nil or replicatedData.profile == nil or replicatedData.profile.gamepasses == nil then
		return false
	end

	local v3 = tostring(Gamepasses.GetId(p2))

	if replicatedData.profile.gamepasses[v3] then
		return true
	end

	if replicatedData.session == nil or replicatedData.session.gamepasses == nil then
		return false
	end

	return replicatedData.session.gamepasses[v3] or false
end

function GamepassController.NotifyPurchasePromptStarted(gamepassId: number, callback)
	v2 = {
		gamepassId = gamepassId,
		callback = callback
	}
end

function GamepassController.Show(p, p2: string?, p3: string?, callback, p4, p5: string?, p6: string?, p7: string?, callback2)
	assert(p, "no gamepass!")

	if callback2 ~= nil and GamepassController.IsOwned(p) then
		task.spawn(callback2)
		return
	end

	if callback2 == nil then
		v2 = nil
	end

	local overrideProductId = GamepassController.GetOverrideProductId(p)
	local v3 = Purchasable.ofGamepass(p)
	task.spawn(GamepassNeededController.Show, v3, p5)
	task.spawn(GamepassUnlockController.ShowPurchasable, v3, p2, p3, callback, p4, p6, p7, overrideProductId, callback2)
end

function GamepassController.ShowPurchasable(object, p: string?, p2: string?, callback, p3, p4: string?, p5: string?, p6: string?, callback2)
	local gamepass = object:ToGamepass()

	if gamepass ~= nil then
		GamepassController.Show(gamepass, p, p2, callback, p3, p4, p5, p6, callback2)
		return
	end

	v2 = nil
	task.spawn(GamepassNeededController.Show, object, p4)
	task.spawn(GamepassUnlockController.ShowPurchasable, object, p, p2, callback, p3, p5, p6, nil, callback2)
end

function GamepassController.ShowDetourLocalScript(p, p2: string?, p3: string?, callback, p4, p5: string?, callback2)
	v = {
		p,
		p2,
		p3,
		callback,
		p4,
		p5,
		callback2
	}
end

return GamepassController