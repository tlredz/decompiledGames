local _ = game.ReplicatedStorage
local replicatedStorage = game.ReplicatedStorage
game:GetService("TweenService")
return function(data, _)
	local tocf = data.tocf
	local lookcf = data.lookcf
	local startatt = data.startatt

	for _ = 1, 5 do
		task.spawn(function()
			local clone = replicatedStorage.Chest.FruitEffect.String.webhandler:Clone()
			clone.Parent = workspace.Effects
			clone.CFrame = lookcf
			local ModuleScript = require(clone.ModuleScript)
			ModuleScript({
				tocf = tocf,
				startatt = startatt
			})
			_G.PU:Dust(clone, 0.75)
		end)
	end
end