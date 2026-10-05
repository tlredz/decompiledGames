return function(instance, productId, value: string?, value2: string?)
	local v

	if typeof(instance) == "Instance" then
		v = instance.ClassName == "TextLabel" or instance.ClassName == "TextButton"
	else
		v = false
	end

	assert(v, "label must be a TextLabel or TextButton!")

	if typeof(productId) == "string" then
		productId = tonumber(productId)
	end

	assert(typeof(productId) == "number" or typeof(productId) == "string", "productId must be a number or string!")

	if value2 then
		instance:SetAttribute("PriceFormat", (value2:gsub(":robux:", "")))
	end

	if string.lower(value or "") == "gamepass" then
		instance:SetAttribute("ProductType", "GamePass")
	else
		instance:SetAttribute("ProductType", "DevProduct")
	end

	instance:SetAttribute("ProductId", productId)
	instance:AddTag("ProductPriceLabel")
end