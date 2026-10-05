local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)
local TrainingUiScale = {
	Factor = function()
		if Platform_Handler.Platform.Value == "Mobile" then
			return 1.2
		end

		return 1
	end
}

function TrainingUiScale.Size(udim: UDim2)
	local factor = TrainingUiScale.Factor()

	if factor == 1 then
		return udim
	end

	return UDim2.new(udim.X.Scale * factor, udim.X.Offset * factor, udim.Y.Scale * factor, udim.Y.Offset * factor)
end

function TrainingUiScale.Of(p: number)
	return p * TrainingUiScale.Factor()
end

return TrainingUiScale