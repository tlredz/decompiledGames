local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Teleporter = require(ReplicatedStorage.CAM.Client.Modules.Teleporter)
return function(p: string, p2)
	if p == "Show" then
		local showCover = Teleporter.ShowCover

		if typeof(p2) ~= "table" then
			p2 = nil
		end

		showCover(p2)
	elseif p == "Hide" then
		Teleporter.HideCover()
	end
end