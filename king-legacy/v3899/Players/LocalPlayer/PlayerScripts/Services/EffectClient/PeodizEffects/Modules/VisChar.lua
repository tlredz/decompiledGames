local TweenService = game:GetService("TweenService")
game:GetService("ReplicatedStorage")
local v = {}
local v2 = {}
return function(data)
	local startCF = data.StartCF
	local success, result = pcall(function()
		return (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - startCF.p).Magnitude > 1000
	end)

	if success and result then
		return
	end

	if data.Vis == true then
		if v2[data.Target] then
			return
		end

		v2[data.Target] = true

		if not v[data.Target] then
			v[data.Target] = {}
		end

		for _, part in pairs(data.Target:GetDescendants()) do
			if not part:IsA("BasePart") then
				continue
			end

			v[data.Target][part] = part.Transparency
			TweenService:Create(part, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {
				Transparency = 1
			}):Play()
		end
	else
		if not v[data.Target] then
			return
		end

		for part, v3 in pairs(v[data.Target]) do
			if part:IsA("BasePart") and v[data.Target][part] then
				TweenService:Create(part, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {
					Transparency = v3 or 0
				}):Play()
			end
		end

		v[data.Target] = {}
		spawn(function()
			wait(0.5)
			v2[data.Target] = nil
		end)
	end
end