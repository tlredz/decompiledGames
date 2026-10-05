local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local module = require("@self/ScriptUtil")
local playerGui = Players.LocalPlayer.PlayerGui
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Circular, Enum.EasingDirection.Out)
return {
	new = function(state)
		local promptConfirmation = playerGui.PromptConfirmation

		if not promptConfirmation then
			return nil, nil
		end

		local frame = promptConfirmation.Frame
		local overlay = promptConfirmation.Overlay
		local header = frame.Header
		local options = frame.Options
		header.Visible = state.header
		header.Text = state.header or ""
		frame.Body.Text = state.text
		local create_continue = module.create_continue()

		for _, v in options:QueryDescendants(">GuiButton") do
			v:Destroy()
		end

		if not (state.options and next(state.options)) then
			state.options = {
				{
					text = "Okay"
				}
			}
		end

		local v = false

		for k, option in state.options do
			local color = option.color or Color3.fromRGB(161, 255, 192)
			local clone = script.Button:Clone()
			local label = clone.Label
			clone.LayoutOrder = k
			clone.Modal = true
			label.Text = `[{option.text}]`
			clone.UIStroke.Color = color
			label.TextColor3 = color
			clone.Parent = options
			local countdown = option.countdown or 0
			local v2 = countdown > 0
			local v3 = k
			clone.Activated:Connect(function()
				if v2 or v then
					return
				end

				create_continue.continue(v3)
			end)

			if not v2 then
				continue
			end

			clone.UIStroke.Color = Color3.fromRGB(135, 135, 135)
			label.TextColor3 = Color3.fromRGB(135, 135, 135)
			local v4 = countdown
			local v5 = clone
			local label2 = label
			local v7 = option
			local v8 = color
			task.spawn(function()
				for i = v4, 1, -1 do
					if v or not v5.Parent then
						return
					end

					label2.Text = `[{v7.text}] ({i})`
					task.wait(1)
				end

				if v or not v5.Parent then
					return
				end

				v2 = false
				label2.Text = `[{v7.text}]`
				v5.UIStroke.Color = v8
				label2.TextColor3 = v8
			end)
		end

		local overlayGradient = state.overlayGradient
		overlay:ClearAllChildren()
		overlay.BackgroundColor3 = overlayGradient and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(0, 0, 0)

		if overlayGradient then
			local uIGradient = Instance.new("UIGradient")
			uIGradient.Rotation = 90
			uIGradient.Color = overlayGradient
			uIGradient.Parent = overlay
		end

		frame.Position = UDim2.fromScale(0.5, 0.515)
		frame.Visible = true
		TweenService:Create(frame, TweenInfo.new(0.35, Enum.EasingStyle.Circular, Enum.EasingDirection.Out), {
			Position = UDim2.fromScale(0.5, 0.5)
		}):Play()
		TweenService:Create(overlay, tweenInfo, {
			BackgroundTransparency = 0.5
		}):Play()
		local v2, v3 = create_continue.yield()
		v = true
		frame.Visible = false
		TweenService:Create(overlay, tweenInfo, {
			BackgroundTransparency = 1
		}):Play()

		for _, v4 in options:QueryDescendants(">GuiButton") do
			v4:Destroy()
		end

		return v2, v3
	end
}