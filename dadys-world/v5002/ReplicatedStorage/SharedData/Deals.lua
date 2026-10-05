local Deals = {
	StarterBundle = require(script.StarterBundle)
}

function Deals.byProductKey(p)
	for _, v in pairs(Deals) do
		if type(v) == "table" and v.productKey == p then
			return v
		end
	end

	return nil
end

return Deals