local service = game:service("TweenService")
wait(10)

for _, child in pairs(script.Parent:GetChildren()) do
	if child.Name == "TextLabel" then
		service:Create(child, TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			TextTransparency = 1,
			TextStrokeTransparency = 1
		}):Play()
	elseif child.Name == "Fade" then
		service:Create(child, TweenInfo.new(5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			ImageTransparency = 1
		}):Play()
	end
end

local Debris = game:GetService("Debris")
Debris:AddItem(script.Parent, 6)