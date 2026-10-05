game:GetService("RunService")
local module = require("./PassiveHandler")
local vector = Vector2.new(0.5, 0.5)
local BreezeGuster = {
	MorphHarpoon = function(p, _, data)
		local driftPerSecond = p.config.DriftPerSecond or 0.4
		p.reelTrove:Add(data.OnLogicStep:Connect(function(p2)
			if not data.active then
				return
			end

			local v = 1 - (1 - driftPerSecond) ^ p2

			for _, activeButton in data.activeButtons do
				if not (activeButton.removing or activeButton.destroyed or activeButton.paused) then
					activeButton:MoveTo(activeButton.moveTarget:Lerp(vector, v))
				end
			end
		end))
	end
}
setmetatable(BreezeGuster, module)
return BreezeGuster