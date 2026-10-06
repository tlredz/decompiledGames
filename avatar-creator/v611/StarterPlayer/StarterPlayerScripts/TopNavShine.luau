local TweenService = game:GetService("TweenService")
local localPlayer = game.Players.LocalPlayer
local screenGui = localPlayer:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")

for i, v in ipairs({ screenGui.Frame.CatalogButton, screenGui.Frame.CatelogButton }) do
	local shine = v:WaitForChild("TopPolish").Shine
	local v2 = false
	local v3 = nil
	local v4 = v

	local function sweep()
		if v2 or not v4.Visible or not screenGui.Enabled or localPlayer:GetAttribute("ReducedMotion") then
			return
		end

		v2 = true
		shine.Visible = true
		shine.Position = UDim2.fromScale(-1, 0)
		v3 = TweenService:Create(shine, TweenInfo.new(0.85, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Position = UDim2.fromScale(1, 0)
		})
		v3:Play()
		v3.Completed:Wait()
		shine.Visible = false
		v2 = false
	end

	local sweep2 = sweep
	v.MouseEnter:Connect(function()
		task.spawn(sweep2)
	end)
	local shine2 = shine
	localPlayer:GetAttributeChangedSignal("ReducedMotion"):Connect(function()
		if localPlayer:GetAttribute("ReducedMotion") then
			if v3 then
				v3:Cancel()
			end

			shine2.Visible = false
		end
	end)
	local v7 = i
	local v8 = v
	local sweep3 = sweep
	task.spawn(function()
		task.wait(v7 * 1.2)

		while v8.Parent do
			sweep3()
			task.wait(6)
		end
	end)
end