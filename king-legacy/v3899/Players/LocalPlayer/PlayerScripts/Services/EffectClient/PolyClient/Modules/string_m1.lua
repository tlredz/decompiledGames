local _ = game.ReplicatedStorage
local _ = game.ReplicatedStorage
return function(data, _)
	local _ = game.Players.LocalPlayer
	local _ = data.tocf
	local _ = data.fromcf
	local mode = data.mode

	if mode == "normal" then
		local normal = require(script.normal)
		normal(data)
	elseif mode == "haki" then
		local haki = require(script.haki)
		haki(data)
	elseif mode == "hakiv2" then
		local hakiv2 = require(script.hakiv2)
		hakiv2(data)
	else
		if mode ~= "arc" then
			return
		end

		local arc = require(script.arc)
		arc(data)
	end
end