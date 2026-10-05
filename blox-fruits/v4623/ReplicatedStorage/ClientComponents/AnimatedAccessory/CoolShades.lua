local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
return {
	Start = function(p)
		local lens = p.Instance:FindFirstChild("Lens", true)
		local texture = lens and lens:FindFirstChildWhichIsA("Texture", true)

		if texture and lens then
			local function renderStepUpdate(_: number)
				local sunDirection

				if Lighting.ClockTime >= 6 and Lighting.ClockTime < 18 then
					sunDirection = Lighting:GetSunDirection()
				else
					sunDirection = Lighting:GetMoonDirection()
				end

				local dot = lens.CFrame.LookVector:Dot(sunDirection)

				if not (dot > 0) then
					texture.Transparency = 1
					return
				end

				texture.OffsetStudsU = lens.CFrame.RightVector:Dot(sunDirection) * 2
				texture.Transparency = 1 - dot
			end

			p._trove:Add(RunService.RenderStepped:Connect(renderStepUpdate))
		end
	end
}