local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Bases = require(ReplicatedStorage.Data.Bases)
local QueueLock = require(ReplicatedStorage.Shared.Modules.QueueLock)
local Log = require(ReplicatedStorage.Packages.Log)
local Toast = require(ReplicatedStorage.Client.Notifications.Toast)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Save = require(ReplicatedStorage.Shared.Save)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Audio = require(ReplicatedStorage.Shared.Audio)
local t = require(ReplicatedStorage.Packages.t)
local TryCall = require(ReplicatedStorage.Shared.Utils.TryCall)
local color = Color3.fromRGB(255, 64, 64)
local v = {
	soundId = 119855061490364,
	pitchRange = { 0.9, 1.1 },
	volume = 1.5
}
local localPlayer = Players.LocalPlayer
local v2 = Log.new()
local v3 = QueueLock.new()
local completed = Signal.new()
local v5 = false
local transition = {
	Completed = completed,
	Begin = function()
		assert(not v5, "nested base upgrade transitions are not supported")
		v5 = true
	end,
	Complete = function()
		assert(v5, "no base upgrade transition is in flight to finish")
		v5 = false
		completed:Fire()
	end,
	IsPlaying = function()
		return v5
	end
}

function transition.Play(callback)
	assert(workspace.CurrentCamera ~= nil, "no render camera is bound on this client")
	transition.Begin()
	Audio.Play(v.soundId, script, {
		PlaybackSpeed = v.pitchRange,
		Volume = v.volume
	})
	task.spawn(callback)
	transition.Complete()
end

local BaseUpgrade = {
	Transition = transition
}

local function tierAbove(p)
	t.strict(t.intersection(t.integer, t.numberMin(0)))(p.BaseUpgradeLevel)
	local v7 = p.BaseUpgradeLevel + 1
	return v7, Bases.BASES[v7]
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isWithinBudget(p, p2)
	return p2 ~= nil and p.Money >= p2.Cost
end

local function blockingNotice(p, p2)
	if p2 == nil then
		return {
			Text = "Max base upgrade reached",
			Seconds = 2
		}
	end

	if p.Money < p2.Cost then
		return {
			Text = "Not enough money",
			Seconds = 2,
			Color = color
		}
	end

	return nil
end

local function playThenAsk()
	transition.Play(function()
		Remotes.Homestead.AskBaseTierRaise:FireServer()
	end)
end

function BaseUpgrade.PurchaseNextTier()
	local v7 = Save.Await(localPlayer)
	assert(v7 ~= nil, "local save data has not arrived yet")
	t.strict(t.intersection(t.integer, t.numberMin(0)))(v7.BaseUpgradeLevel)
	local v8 = v7.BaseUpgradeLevel + 1
	local v10 = blockingNotice(v7, Bases.BASES[v8])

	if v10 ~= nil then
		Toast.Show(v10)
	end

	local v11

	if v10 == nil then
		v11 = v3:TryTake()
	else
		v11 = nil
	end

	if v11 == nil then
		return false
	end

	task.spawn(function()
		local v12, v13 = TryCall(playThenAsk)
		v11:GiveBack()

		if not v12 then
			v2:AtError():Log((`upgrade transition aborted before firing: {v13}`))
		end
	end)
	return true
end

function BaseUpgrade.ResolveNextTier(p)
	return tierAbove(p)
end

function BaseUpgrade.IsNextTierAffordable(p)
	t.strict(t.intersection(t.integer, t.numberMin(0)))(p.BaseUpgradeLevel)
	local v7 = p.BaseUpgradeLevel + 1
	return isWithinBudget(p, Bases.BASES[v7])
end

return BaseUpgrade