local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Checker = require(ReplicatedStorage.CAM.Global.Checker)
local BarKeepup = require(ReplicatedStorage.CAM.Client.Components.NonePackagedMisc.Minigames.BarKeepup)
local FishingBar = require(ReplicatedStorage.CAM.Global.FishingBar)
local ServerClientPortal = require(ReplicatedStorage.CAM.Global.ServerClientPortal)
local faye = require(ReplicatedStorage.Packages.faye)
local localPlayer = Players.LocalPlayer
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.BruteForceAllSlow = true
raycastParams.FilterDescendantsInstances = {}

local function refreshWaterParams()
	local parents = {}

	for _, v in CollectionService:GetTagged("SwimParts") do
		table.insert(parents, v.Parent or v)
	end

	raycastParams.FilterDescendantsInstances = parents
	return #parents > 0
end

local RareFishingRod = {
	MouseParams = raycastParams
}
local flag = false

function RareFishingRod.check(_, _: string)
	if flag or Checker.check(localPlayer) then
		return true
	end

	return false
end

local v = nil
local v2 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function closeBite()
	local v3 = v2
	v2 = nil

	if v3 ~= nil then
		v3:Destroy()
	end

	localPlayer:SetAttribute("FishingBite", nil)
end

local function onBite(object, p)
	closeBite() -- equivalent call inferred; original call site unknown
	local thread = faye.new()
	v2 = thread
	localPlayer:SetAttribute("FishingBite", true)
	local flag2 = false

	local function report(flag3: boolean)
		if flag2 then
			return
		end

		flag2 = true

		if object.__Active then
			object:Server(p, flag3 == true)
		end

		task.defer(closeBite)
	end

	BarKeepup(localPlayer:WaitForChild("PlayerGui"):WaitForChild("Misc"), {
		Thread = thread,
		StartingPercent = FishingBar.Fill.StartingPercent,
		WinPercent = FishingBar.Fill.WinPercent,
		PercentStep = FishingBar.Fill.PercentStep,
		PercentGainTick = FishingBar.Fill.PercentGainTick,
		Stop = report
	})
end

local establishBiteLink

establishBiteLink = function()
	if v ~= nil and v.__Active then
		v:Destroy()
	end

	local link = ServerClientPortal.Link("FishingRod", -1)
	v = link
	link:OnDestroyed(function()
		if v == link then
			v = nil
		end

		closeBite() -- equivalent call inferred; original call site unknown

		if flag then
			establishBiteLink()
		end
	end)
	link:Connect(function(p, p2)
		if p == "Bite" then
			onBite(link, p2)
		elseif p == "BiteCancel" then
			closeBite() -- equivalent call inferred; original call site unknown
		end
	end)
end

function RareFishingRod.Equipped(_, _: string)
	flag = true
	refreshWaterParams()
	establishBiteLink()
end

function RareFishingRod.UnEquipped(_, _: string?)
	flag = false
	local v3 = v
	v = nil

	if v3 ~= nil and v3.__Active then
		v3:Destroy()
	end

	closeBite() -- equivalent call inferred; original call site unknown
end

return RareFishingRod