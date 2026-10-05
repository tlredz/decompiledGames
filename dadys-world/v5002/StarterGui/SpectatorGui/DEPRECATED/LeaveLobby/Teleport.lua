local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiAnimations = require(ReplicatedStorage.Modules.UI.GuiAnimations)
local teleport = ReplicatedStorage.Events:WaitForChild("Teleport")
local parent = script.Parent
GuiAnimations.SetupButtonAnimationsSimple(parent)
local v = false
parent.Activated:Connect(function()
	if not v then
		v = true
		teleport:FireServer()
		task.spawn(function()
			task.wait(0.5)
			parent.Visible = false
			task.wait(8)
			parent.Visible = true
			v = false
		end)
	end
end)