local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.CAM.Global.Subsets.Classes.PopUpCreator)
require(ReplicatedStorage.Packages.faye)
local Guide = require(script.Parent.Guide)
return function(p, p2, p3, p4: number)
	Guide(p, p2, p3, p4, true)
end