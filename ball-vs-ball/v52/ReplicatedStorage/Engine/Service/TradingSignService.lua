local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Observers"))
local PlayerData = require(ReplicatedStorage.Engine.Service.PlayerData)
local server = PlayerData.server
local DevProductService = require(ReplicatedStorage.Engine.Market.DevProductService)
local TradingSignService = {
	server = {}
}
local folder = ReplicatedStorage["美术素材"]["杂项"]["手持展牌"]
local flag = false

local function preprocessTemplate()
	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = false
		part.Massless = true
	end

	folder.CanBeDropped = false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function hasTool(player)
	local backpack = player:FindFirstChildOfClass("Backpack")

	if backpack and backpack:FindFirstChild("手持展牌") then
		return true
	end

	local character = player.Character

	if character and character:FindFirstChild("手持展牌") then
		return true
	end

	return false
end

local function grantTool(instance)
	local backpack = instance:FindFirstChildOfClass("Backpack")

	if backpack then
		-- equivalent call inferred; original call site unknown
		if not hasTool(instance) then
			local clone = folder:Clone()
			clone.Parent = backpack
		end
	end
end

local function init()
	if flag then
		return
	end

	flag = true
	preprocessTemplate()
	DevProductService.server.bindProduct("Trading Sign", function(p)
		local plr = p.plr
		server[plr].hasUnlockedTradingSign(true)
		local backpack = plr:FindFirstChildOfClass("Backpack")

		if backpack then
			-- equivalent call inferred; original call site unknown
			if hasTool(plr) then
				return
			else
				local clone = folder:Clone()
				clone.Parent = backpack
			end
		end
	end)
	Observers.observeCharacter(function(instance, p)
		server.Service:waitForData(instance)

		if p.Parent == nil then
			return function() end
		end

		local backpack = server[instance].hasUnlockedTradingSign() and instance:FindFirstChildOfClass("Backpack")

		if backpack then
			-- equivalent call inferred; original call site unknown
			if not hasTool(instance) then
				local clone = folder:Clone()
				clone.Parent = backpack
			end
		end

		return function() end
	end)
end

TradingSignService.server.init = init
return TradingSignService