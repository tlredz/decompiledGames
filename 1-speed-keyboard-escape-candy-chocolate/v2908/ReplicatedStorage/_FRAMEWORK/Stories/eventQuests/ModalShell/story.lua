local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.Packages
local UILabs = require(packages["UI-Labs"])
local Vide = require(packages.Vide)
local ModalShell = require(ReplicatedStorage._FRAMEWORK.Libraries.uiComponents.ModalShell)
local controls2 = {
	Title = "~Quests~",
	BackgroundImage = "rbxassetid://16280131699",
	ImageTransparency = UILabs.Slider(0.7, 0, 1),
	GradientTop = Color3.fromRGB(255, 214, 120),
	GradientBottom = Color3.fromRGB(255, 138, 61),
	GradientRotation = UILabs.Slider(90, 0, 360),
	StrokeColor = Color3.fromRGB(74, 46, 0),
	StrokeThickness = UILabs.Slider(0.02, 0, 0.1),
	CornerRadius = UILabs.Slider(0.05, 0, 0.25),
	AspectRatio = UILabs.Slider(1.5, 0.5, 3),
	TitleColor = Color3.fromRGB(255, 255, 255),
	TitleStrokeColor = Color3.fromRGB(74, 46, 0),
	ShowClose = true
}
return UILabs.CreateVideStory({
	name = "Event Quests — Modal Shell",
	vide = Vide,
	controls = controls2
}, function(p)
	local controls = p.controls

	local function gradientColor()
		return ColorSequence.new(controls.GradientTop(), controls.GradientBottom())
	end

	local function cornerRadius()
		return UDim.new(controls.CornerRadius(), 0)
	end

	return ModalShell({
		Name = "EventQuestsModal",
		Title = controls.Title,
		BackgroundImage = controls.BackgroundImage,
		BackgroundImageTransparency = controls.ImageTransparency,
		GradientColor = gradientColor,
		GradientRotation = controls.GradientRotation,
		StrokeColor = controls.StrokeColor,
		StrokeThickness = controls.StrokeThickness,
		CornerRadius = cornerRadius,
		AspectRatio = controls.AspectRatio,
		TitleColor = controls.TitleColor,
		TitleStrokeColor = controls.TitleStrokeColor,
		ShowClose = controls.ShowClose,
		OnClose = function()
			print("[ModalShell.story] close")
		end
	})
end)