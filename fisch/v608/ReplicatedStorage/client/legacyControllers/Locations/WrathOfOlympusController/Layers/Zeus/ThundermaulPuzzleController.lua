local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
return {
	Start = function(_)
		RunService.Heartbeat:Connect(function(dt)
			for _, v in CollectionService:GetTagged("ZeusGear") do
				if not v:GetAttribute("Active") then
					continue
				end

				local cframe = CFrame.Angles(0, math.rad(60 * dt), 0)
				v:PivotTo(v:GetPivot() * cframe)
			end
		end)
	end
}