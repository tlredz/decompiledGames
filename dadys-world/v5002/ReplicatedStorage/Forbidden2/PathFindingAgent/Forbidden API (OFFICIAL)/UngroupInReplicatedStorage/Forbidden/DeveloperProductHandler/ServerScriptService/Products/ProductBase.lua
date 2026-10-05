local Config = require(script:WaitForChild("Config"))
local ProductBase = {}

function ProductBase.Trigger(_)
	return Enum.ProductPurchaseDecision.NotProcessedYet
end

function ProductBase.GetProductId()
	return Config.ProductId
end

function ProductBase.GetProductName()
	return script.Name
end

return ProductBase