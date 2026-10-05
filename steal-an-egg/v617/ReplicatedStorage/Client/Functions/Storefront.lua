local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PurchaseSession = require(ReplicatedStorage.Client.Functions.PurchaseSession)
return {
	Prompt = function(p: number, flag: boolean?)
		PurchaseSession.Request(p, flag)
	end
}