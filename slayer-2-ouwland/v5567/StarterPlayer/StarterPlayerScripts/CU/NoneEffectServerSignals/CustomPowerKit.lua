local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CustomPower = require(ReplicatedStorage.CAM.Global.CustomPower)
local Skills_Provider = require(ReplicatedStorage.CAM.Client.Controllers.Skills_Provider)
return function(p)
	if p == nil or p.Name == nil or p.Picks == nil then
		return
	end

	CustomPower.Install(p.Name, p.Picks)
	Skills_Provider.Keys_Changed:Fire(Skills_Provider.get_current_keys())
end