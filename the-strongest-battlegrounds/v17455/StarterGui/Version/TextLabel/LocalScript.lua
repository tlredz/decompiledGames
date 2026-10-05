local AssetService = game:GetService("AssetService")
local placeId = nil

for _, v2 in AssetService:GetGamePlacesAsync(game.GameId):GetCurrentPage() do
	placeId = v2.PlaceId
	break
end

local MarketplaceService = game:GetService("MarketplaceService")
local productInfo = MarketplaceService:GetProductInfo(placeId)
local updated = productInfo.Updated
local v2 = 5381

for i = 1, #updated do
	local v3 = string.byte(updated, i)
	v2 = bit32.band(bit32.lshift(v2, 5) + v2 + v3, 4294967295)
end

local v3 = string.format("%08x", v2)
local v4 = string.rep(v3, 4):sub(1, 32)
local name = productInfo.Name
local v5 = (name:match("^[^%-]+") or name):lower():gsub("%a+", function(value)
	return value:sub(1, 1)
end):gsub("[^a-z]", "")

if workspace:GetAttribute("VIPServer") then
	v4 = "ps" .. v4:sub(0, #v4 - 2)
end

local formatted = ("Yielding Arts %s • %s"):format(v5:upper(), v4)
script.Parent.Text = formatted