local MarketplaceService = game:GetService("MarketplaceService")
local v = {
	[true] = 600,
	[false] = 300
}
local v2 = {}
local v3 = {}

local function slotFor(value: number, p)
	assert(type(value) == "number", (`marketplace id must be a number, got {typeof(value)}`))
	local formatted = `{p.Value}:{value}`
	local v4 = v2[formatted]

	if v4 == nil then
		v4 = {
			Value = nil,
			Answered = false,
			HoldUntil = 0
		}
		v2[formatted] = v4
	end

	return v4
end

local function ask(p, p2: number, p3)
	local success, productInfo = pcall(MarketplaceService.GetProductInfo, MarketplaceService, p2, p3)
	p.Answered = success
	p.HoldUntil = os.clock() + v[success]

	if success then
		p.Value = productInfo
	else
		warn((`marketplace info unavailable for {p3.Name} {p2}: {productInfo}`))
	end
end

local function trusted(p, p2: number, p3)
	if os.clock() >= p.HoldUntil then
		ask(p, p2, p3)
	end

	return p.Answered
end

function v3.Info(p: number, p2)
	local v4 = p2 or Enum.InfoType.Product
	local v5 = slotFor(p, v4)

	if os.clock() >= v5.HoldUntil then
		ask(v5, p, v4)
	end

	local _ = v5.Answered
	return v5.Value
end

function v3.Current(p: number, p2)
	local v4 = p2 or Enum.InfoType.Product
	local v5 = slotFor(p, v4)

	if os.clock() >= v5.HoldUntil then
		ask(v5, p, v4)
	end

	if v5.Answered then
		return v5.Value
	end

	return nil
end

function v3.Price(p: number, p2)
	local info = v3.Info(p, p2)

	if type(info) ~= "table" or info.IsForSale ~= true then
		return nil
	end

	local priceInRobux = info.PriceInRobux

	if type(priceInRobux) == "number" then
		return priceInRobux
	end

	return nil
end

return table.freeze(v3)