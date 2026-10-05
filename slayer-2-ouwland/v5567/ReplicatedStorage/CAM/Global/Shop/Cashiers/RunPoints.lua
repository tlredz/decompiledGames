local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)

local function owner(p)
	local parent = p.Parent
	local parent2

	if parent ~= nil then
		parent2 = parent.Parent
	end

	if parent2 == nil then
		return nil
	end

	return (Players:FindFirstChild(parent2.Name))
end

local function towerScore()
	local minigamesPlace = ReplicatedStorage:FindFirstChild("Minigames Place")
	local minigames = minigamesPlace ~= nil and minigamesPlace:FindFirstChild("Minigames") or nil
	local ouwigahara = minigames ~= nil and minigames:FindFirstChild("Ouwigahara") or nil

	if ouwigahara == nil then
		return nil
	end

	local Score = require(ouwigahara.Score)
	return Score
end

local RunPoints = {}

function RunPoints.FormulateTextPlusText(p: number)
	return (`{Utility.addCommasToNumber(p)} [#]<img={BunchaIcons.OuwigaharaPointsRaw}>`)
end

function RunPoints.FormulateRichText(p: number)
	return (`<font color="rgb(255,217,77)">{Utility.addCommasToNumber(p)} points</font>`)
end

function RunPoints.GetContent(price: number)
	return {
		Icon = BunchaIcons.OuwigaharaPoints,
		Price = price
	}
end

function RunPoints.CanBuy(p, p2: number)
	local parent = p.Parent
	local parent2

	if parent ~= nil then
		parent2 = parent.Parent
	end

	local child

	if parent2 ~= nil then
		child = Players:FindFirstChild(parent2.Name)
	end

	if child == nil or child:GetAttribute("SaveDisabled") == true or child:GetAttribute("SaveDisabledSlot") == true then
		return false
	end

	return p2 <= (tonumber(child:GetAttribute("RunPoints")) or 0)
end

function RunPoints.Buy(p, p2: number, child, _: string?)
	if not child then
		local parent = p.Parent
		local parent2

		if parent ~= nil then
			parent2 = parent.Parent
		end

		if parent2 == nil then
			child = nil
		else
			child = Players:FindFirstChild(parent2.Name)
		end
	end

	if child == nil then
		return
	end

	local ServerStorage = game:GetService("ServerStorage")
	require(ServerStorage.SAM.Services.Reporting.Analytics).Track(child, "ItemSpent", {
		Item = "RunPoints",
		Sink = "ShopPurchase"
	}, p2)
	local v = towerScore()

	if v == nil then
		child:SetAttribute("RunPoints", (tonumber(child:GetAttribute("RunPoints")) or 0) - p2)
	else
		v.Spend(child, p2)
	end
end

return RunPoints