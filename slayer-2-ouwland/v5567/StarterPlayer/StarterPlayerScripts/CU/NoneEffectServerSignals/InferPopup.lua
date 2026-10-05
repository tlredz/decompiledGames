local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PopUpCreator = require(ReplicatedStorage.CAM.Global.Subsets.Classes.PopUpCreator)
return function(p)
	return (PopUpCreator.new(p):WaitResult(true))
end