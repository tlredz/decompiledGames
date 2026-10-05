local SaleService = require(game.ReplicatedStorage.SaleService)
return function(p)
	if not (SaleService:GetIfInitialized() and p) then
		return nil
	end

	if SaleService:GetIfValidKey(p) then
		return SaleService:GetSaleByKey(p)
	end

	return nil
end