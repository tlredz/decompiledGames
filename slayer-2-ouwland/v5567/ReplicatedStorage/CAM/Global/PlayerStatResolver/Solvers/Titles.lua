local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Titles = require(ReplicatedStorage.CAM.Global.Titles)
return function(p, p2: string)
	return Titles.GetStatBonus(p, p2)
end