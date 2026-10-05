local function dothing()
	script.Parent.Parent.Parent.Parent.Neighbors.Enabled = false
	script.Parent.Parent.Parent.Parent.MainMenu.Enabled = false
	script.Parent.Parent.Parent.Enabled = true
	local UI = require(game.ReplicatedStorage.Modules.UI)
	UI:Bind(script.Parent)

	repeat
		task.wait(1)
	until game:IsLoaded() == true

	game.TweenService:Create(script.Parent.Frame, TweenInfo.new(5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		Size = UDim2.new(1, 0, 1, 0)
	}):Play()
	task.wait(5)
	script.Parent.Frame:Destroy()
	script.Parent.BackgroundColor3 = Color3.fromRGB(190, 255, 176)
	script.Parent.Text = "Let's Go!"
	script.Parent.MouseButton1Click:Connect(function()
		script.Parent.Parent.Parent.Parent.Neighbors.Enabled = true
		script.Parent.Parent.Parent.Parent.MainMenu.Enabled = true
		script.Parent.Parent.Parent:Destroy()
	end)
end

local Network = require(game.ReplicatedStorage.Modules.Network)
Network:listen("eggPopup", function()
	dothing()
end)