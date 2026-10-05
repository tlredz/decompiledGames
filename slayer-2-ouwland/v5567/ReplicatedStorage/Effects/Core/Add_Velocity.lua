local Utility = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Utility"))
return function(p, p2, p3, p4)
	if p ~= nil and p2 ~= nil and p3 ~= nil then
		Utility.bv(p, p2, p3, p4)
	end
end