local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Server = require(ReplicatedStorage.Modules.Server)
local MatchRequestInvite = {
	{
		Amount = 1,
		Cost = 100
	},
	{
		Amount = 5,
		ProductIds = {
			Regular = 3539599258,
			Test = 3539495416,
			Adult = 3539600053
		}
	},
	{
		Amount = 15,
		ProductIds = {
			Regular = 3539599529,
			Test = 3539495650,
			Adult = 3539600161
		}
	}
}
local v = Server:IsAdultServer() and "Adult" or Server:IsTestServer() and "Test" or "Regular"

for _, v2 in next, MatchRequestInvite, nil do
	if v2.ProductIds then
		v2.ProductId = v2.ProductIds[v]
	end
end

return MatchRequestInvite