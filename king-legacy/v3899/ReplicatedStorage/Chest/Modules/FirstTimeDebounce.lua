return function(_)
	local RunService = game:GetService("RunService")

	if RunService:IsClient() then
		local _ = game.Players.LocalPlayer
	end
end