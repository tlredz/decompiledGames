local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Packages.Net)
return table.freeze({
	Remotes = {
		AutofillToggle = v:RemoteEvent("SquadRoyale/Autofill"),
		CreateParty = v:RemoteFunction("SquadRoyale/CreateParty"),
		LeaveParty = v:RemoteFunction("SquadRoyale/LeaveParty"),
		CreateInvite = v:RemoteFunction("SquadRoyale/CreateInvite"),
		AcceptInvite = v:RemoteEvent("SquadRoyale/AcceptInvite")
	}
})