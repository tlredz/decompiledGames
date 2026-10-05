local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = require(ReplicatedStorage.Packages.faye)
local Transition = {
	Info = faye.Info(0.2)
}

function Transition.FadeOutOnClean(udim: UDim2?)
	return function(animator, folder)
		for _, descendant in folder:GetDescendants() do
			if descendant:IsA("GuiObject") then
				animator:LoadAnimation(descendant, {
					BackgroundTransparency = 1
				}, Transition.Info):Play()
			end

			if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox") then
				animator:LoadAnimation(descendant, {
					TextTransparency = 1,
					TextStrokeTransparency = 1
				}, Transition.Info):Play()
			end

			if descendant:IsA("ImageLabel") or descendant:IsA("ImageButton") then
				animator:LoadAnimation(descendant, {
					ImageTransparency = 1
				}, Transition.Info):Play()
			end

			if descendant:IsA("UIStroke") or descendant:IsA("UIShadow") then
				animator:LoadAnimation(descendant, {
					Transparency = 1
				}, Transition.Info):Play()
			end
		end

		if udim == nil then
			return {
				BackgroundTransparency = animator:Animation(1, Transition.Info)
			}
		end

		return {
			BackgroundTransparency = animator:Animation(1, Transition.Info),
			Position = animator:Animation(udim, Transition.Info)
		}
	end
end

return Transition