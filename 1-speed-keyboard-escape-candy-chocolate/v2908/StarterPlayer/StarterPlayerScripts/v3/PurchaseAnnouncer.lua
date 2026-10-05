local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local MarketplaceInfoCache = require(ReplicatedStorage.Utilities.MarketplaceInfoCache)

-- equivalent calls inferred from this helper; original call sites unknown
local function getGeneralChannel()
	local textChannels = TextChatService:FindFirstChild("TextChannels")

	if textChannels then
		return textChannels:FindFirstChild("RBXGeneral")
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function display(p)
	local generalChannel = getGeneralChannel() -- equivalent call inferred; original call site unknown

	if generalChannel then
		generalChannel:DisplaySystemMessage("<font size=\"17\"><b>" .. p .. "</b></font>")
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function formatPurchase(p, p2, value)
	return "❤️ " .. p .. " purchased " .. p2 .. (type(value) ~= "number" and "" or " for " .. tostring(value) .. "⬢ ") .. "!"
end

ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("PurchaseAnnounce").OnClientEvent:Connect(function(p, p2, value, p3)
	local v = Enum.InfoType[p3]

	if type(value) == "number" and value ~= 0 and v then
		MarketplaceInfoCache.Request(value, v, function(p4)
			local v2

			if type(p4) == "table" then
				v2 = p4.PriceInRobux
			end

			local v3 = formatPurchase(p, p2, v2) -- equivalent call inferred; original call site unknown
			display(v3) -- equivalent call inferred; original call site unknown
		end)
		return
	end

	display("❤️ " .. p .. " purchased " .. p2 .. "!") -- equivalent call inferred; original call site unknown
end)