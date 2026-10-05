local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = game.Players.LocalPlayer
localPlayer:WaitForChild("PlayerSettings"):WaitForChild("ThaiLanguage")
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript")
local Translate = require(moduleScript:WaitForChild("Translate"))
local parent = script.Parent
local menu = parent:WaitForChild("Menu")
local select_Button = parent:WaitForChild("Select_Button")
local parent2 = parent.Parent.Parent.Parent.Parent.Parent

local function trigger()
	if menu:GetAttribute("IsOpen") == false and menu:GetAttribute("CanOpen") == true then
		menu:SetAttribute("CanOpen", false)
		local tween = TweenService:Create(menu, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(1.35, 0, 5.3, 0)
		})
		TweenService:Create(select_Button.Icon, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Rotation = 0
		}):Play()
		tween:Play()

		for _, button in ipairs(menu:GetChildren()) do
			if button:IsA("GuiButton") then
				button.Visible = true
			end
		end

		tween.Completed:Wait()
		menu:SetAttribute("IsOpen", true)
		menu:SetAttribute("CanOpen", true)
	elseif menu:GetAttribute("IsOpen") == true and menu:GetAttribute("CanOpen") == true then
		menu:SetAttribute("CanOpen", false)
		TweenService:Create(menu, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(1.35, 0, 0, 0)
		}):Play()
		TweenService:Create(select_Button.Icon, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Rotation = 180
		}):Play()
		task.wait(0.05)

		for _, button in ipairs(menu:GetChildren()) do
			if button:IsA("GuiButton") then
				button.Visible = false
			end
		end

		menu:SetAttribute("IsOpen", false)
		menu:SetAttribute("CanOpen", true)
	end
end

select_Button.Activated:Connect(trigger)

for _, button in ipairs(menu:GetChildren()) do
	if not button:IsA("GuiButton") then
		continue
	end

	local v = button
	button.Activated:Connect(function()
		if localPlayer:GetAttribute("TH") then
			select_Button.SelectedText.Text = Translate[v.Name]
		else
			select_Button.SelectedText.Text = v.Name
		end

		trigger()
	end)
end

local function Menu_Changed()
	if parent2.Visible == false and menu:GetAttribute("IsOpen") == true then
		trigger()
	end
end

parent2:GetPropertyChangedSignal("Visible"):Connect(Menu_Changed)