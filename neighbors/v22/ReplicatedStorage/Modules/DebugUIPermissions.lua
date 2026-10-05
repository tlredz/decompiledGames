local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Server = require(ReplicatedStorage.Modules.Server)
return function(_)
	if Server:IsTestServer() then
		return true
	end
end