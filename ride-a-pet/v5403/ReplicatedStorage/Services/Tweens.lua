local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Tweens = {}

function Tweens.FadeOut(_, folder, options)
	local v = options or {}
	local delay = v.Delay or 0
	local fadeOutTime = v.FadeOutTime or 0.5
	local descendants = { folder }

	for _, descendant in folder:GetDescendants() do
		table.insert(descendants, descendant)
	end

	for _, instance in descendants do
		if instance:FindFirstAncestorOfClass("LocalScript") then
			continue
		end

		local textTransparency, v2, v3

		if instance:IsA("TextLabel") then
			textTransparency = instance.TextTransparency
			v2 = fadeOutTime
			v3 = {
				TextTransparency = 1
			}
		elseif instance:IsA("UIStroke") then
			textTransparency = instance.Transparency
			v2 = fadeOutTime
			v3 = {
				Transparency = 1
			}
		elseif instance:IsA("Frame") then
			textTransparency = instance.BackgroundTransparency
			v2 = fadeOutTime + 0.2
			v3 = {
				BackgroundTransparency = 1
			}
		else
			if not instance:IsA("ImageLabel") then
				continue
			end

			textTransparency = instance.ImageTransparency
			v2 = fadeOutTime
			v3 = {
				ImageTransparency = 1
			}
		end

		instance:SetAttribute("OriginalTransparency", textTransparency)
		local tween = TweenService:Create(
			instance,
			TweenInfo.new(v2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, delay),
			v3
		)
		tween:Play()
		Debris:AddItem(tween, v2 + 1)
	end
end

function Tweens.FadeIn(_, folder, options)
	local v = options or {}
	local delay = v.delay or 0
	local fadeInTime = v.FadeInTime or 0.5
	local descendants = { folder }

	for _, descendant in folder:GetDescendants() do
		table.insert(descendants, descendant)
	end

	for _, instance in descendants do
		if instance:FindFirstAncestorOfClass("LocalScript") then
			continue
		end

		local v2

		if instance:IsA("TextLabel") then
			v2 = {
				TextTransparency = 0
			}
		elseif instance:IsA("UIStroke") then
			v2 = {
				Transparency = 0
			}
		elseif instance:IsA("Frame") then
			v2 = {
				BackgroundTransparency = 0
			}
		elseif instance:IsA("ImageLabel") then
			v2 = {
				ImageTransparency = 0
			}
		else
			continue
		end

		local tween = TweenService:Create(
			instance,
			TweenInfo.new(fadeInTime, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, delay),
			v2
		)
		tween:Play()
		Debris:AddItem(tween, fadeInTime)
	end
end

return Tweens