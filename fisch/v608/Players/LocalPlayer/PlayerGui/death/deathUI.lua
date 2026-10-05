local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local parent = script.Parent
local clone = parent:Clone()
local fade = parent:WaitForChild("fade")
local iris = parent:WaitForChild("iris")
fade.Visible = false
iris.Visible = false
local v = {
	"How did that happen?",
	"It's a fishing game",
	"Respawning",
	"Was this on purpose?",
	"How'd you manage to die?",
	"This game is meant to be relaxing",
	"How do you die in a fishing game?",
	"Does this count as rare?",
	"Floaties not included",
	"I hope no one heard that",
	"Do you think they saw?",
	"Fisch is a relaxing fishing game with 100% freedom of exploration and progression",
	"How does this happen?",
	"Best wishes in your next fishing trip",
	"What kind of fish did you try to catch?",
	"Hurry up and get back into the action!"
}
local humanoid = character:WaitForChild("Humanoid")
humanoid.Died:Once(function()
	local hud = parent.Parent:WaitForChild("hud")
	hud.Enabled = false
	fade.BackgroundTransparency = 0.8
	fade.titlebg.ImageTransparency = 0.4
	fade.fish.ImageTransparency = 1
	fade.fish.Position = UDim2.new(0.5, 0, 0.5, 0)
	fade.count.TextTransparency = 1
	fade.count.Text = "[" .. (humanoid:GetAttribute("OverrideDeathScreen") or v[math.random(1, #v)]) .. "]"

	if character:GetAttribute("deathMsg") then
		fade.count.Text = character:GetAttribute("deathMsg")
	end

	fade.Visible = true
	TweenService:Create(fade.fish, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true, 0), {
		Rotation = 30
	}):Play()
	parent:WaitForChild("thud"):Play()
	parent:WaitForChild("flatline"):Play()
	workspace.CurrentCamera.FieldOfView = 70
	TweenService:Create(workspace.CurrentCamera, TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		FieldOfView = 80
	}):Play()
	TweenService:Create(
		Lighting:WaitForChild("uiblur"),
		TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
		{
			Size = 0
		}
	):Play()
	TweenService:Create(
		Lighting:WaitForChild("uicc"),
		TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
		{
			Brightness = 0,
			TintColor = Color3.fromRGB(255, 255, 255),
			Saturation = 0
		}
	):Play()
	TweenService:Create(fade.titlebg, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		ImageTransparency = 1
	}):Play()
	TweenService:Create(fade.titlebg, TweenInfo.new(1.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Size = UDim2.new(0.5, 0, 0.5, 0)
	}):Play()
	TweenService:Create(fade.count, TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		TextTransparency = 0.4
	}):Play()
	TweenService:Create(fade, TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
		BackgroundTransparency = 0
	}):Play()
	TweenService:Create(fade.fish, TweenInfo.new(3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		ImageTransparency = 0,
		Position = UDim2.new(0.5, 0, 0.41, 0)
	}):Play()
	local thread = task.delay(20, function()
		if parent.Parent then
			local hud = parent.Parent:WaitForChild("hud")
			hud.Enabled = true
			clone.Parent = parent.Parent
			parent:Destroy()
		end
	end)
	character = localPlayer.CharacterAdded:Wait()
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if humanoidRootPart.Anchored then
		humanoidRootPart:GetPropertyChangedSignal("Anchored"):Wait()
	end

	if not character:GetAttribute("SpawnFinished") then
		character:GetAttributeChangedSignal("SpawnFinished"):Wait()
	end

	workspace.CurrentCamera.FieldOfView = 100
	task.wait(0.5)
	iris.Visible = true
	iris.Size = UDim2.new(0, 0, 0, 0)
	TweenService:Create(iris, TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, 0.3), {
		Size = UDim2.new(3, 0, 3, 0)
	}):Play()
	TweenService:Create(
		workspace.CurrentCamera,
		TweenInfo.new(3.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0.3),
		{
			FieldOfView = 70
		}
	):Play()
	TweenService:Create(fade.fish, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		ImageTransparency = 1
	}):Play()
	TweenService:Create(fade.title, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		ImageTransparency = 1
	}):Play()
	TweenService:Create(fade.count, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		TextTransparency = 1
	}):Play()
	TweenService:Create(fade, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 1
	}):Play()
	task.wait(2.5)
	task.cancel(thread)
	local hud_2 = parent.Parent:WaitForChild("hud")
	hud_2.Enabled = true
	clone.Parent = parent.Parent
	parent:Destroy()
end)