local FXModule = {}
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
game:GetService("RunService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer
ReplicatedStorage:WaitForChild("OtherEvent")
local visuals = workspace:WaitForChild("Visuals")
local damage = script:WaitForChild("Damage")
local heal = script:WaitForChild("Heal")
local dodge = script:WaitForChild("Dodge")

function FXModule.Damage(p, p2, p3, p4)
	local WAIT_INTERVAL = 0.1

	if p3 == "Heal" then
		local clone = heal:Clone()
		clone.Parent = visuals
		clone.CFrame = p.CFrame * CFrame.new(
			Random.new():NextNumber(-1, 1),
			Random.new():NextNumber(-1, 1),
			Random.new():NextNumber(-1, 1)
		)
		clone.UI.DMG.Text = `+{p2}`
		clone.UI.DMG.Stroke.Text = `+{p2}`
		Debris:AddItem(clone, 3)
		local UI = clone:FindFirstChild("UI")

		if UI then
			TweenService:Create(UI, TweenInfo.new(0.25, Enum.EasingStyle.Cubic), {
				Size = UDim2.new(10, 0, 1.75, 0)
			}):Play()
			TweenService:Create(UI.DMG.Stroke, TweenInfo.new(0.25, Enum.EasingStyle.Cubic), {
				TextTransparency = 0,
				TextStrokeTransparency = 0
			}):Play()
			local tween = TweenService:Create(UI.DMG, TweenInfo.new(0.25, Enum.EasingStyle.Cubic), {
				TextTransparency = 0,
				TextStrokeTransparency = 0
			})
			tween:Play()
			tween.Completed:Wait()

			if UI and UI.Parent then
				TweenService:Create(UI.DMG, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
					TextTransparency = 1,
					TextStrokeTransparency = 1
				}):Play()
				TweenService:Create(UI.DMG.Stroke, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
					TextTransparency = 1,
					TextStrokeTransparency = 1
				}):Play()
				TweenService:Create(UI.DMG.Stroke, TweenInfo.new(0.25, Enum.EasingStyle.Cubic), {
					TextColor3 = Color3.fromRGB(255, 255, 255)
				}):Play()
				task.wait(WAIT_INTERVAL)
				local tween2 = TweenService:Create(UI, TweenInfo.new(0.25, Enum.EasingStyle.Cubic), {
					Size = UDim2.new(1, 0, 1, 0)
				})
				tween2:Play()
				tween2.Completed:Wait()

				if clone and clone.Parent then
					clone:Destroy()
				end
			end
		end
	elseif p3 == "Dodge" then
		local clone = dodge:Clone()
		clone.Parent = visuals
		clone.CFrame = p.CFrame * CFrame.new(
			Random.new():NextNumber(-1, 1),
			Random.new():NextNumber(-1, 1),
			Random.new():NextNumber(-1, 1)
		)

		if localPlayer:GetAttribute("TH") then
			clone.UI.DMG.Text = `หลบหลีก! ({p2}/{p4})`
			clone.UI.DMG.Stroke.Text = `หลบหลีก! ({p2}/{p4})`
		else
			clone.UI.DMG.Text = `Dodged! ({p2}/{p4})`
			clone.UI.DMG.Stroke.Text = `Dodged! ({p2}/{p4})`
		end

		Debris:AddItem(clone, 3)
		local UI = clone:FindFirstChild("UI")

		if UI then
			TweenService:Create(UI, TweenInfo.new(0.25, Enum.EasingStyle.Cubic), {
				Size = UDim2.new(10, 0, 1.25, 0)
			}):Play()
			TweenService:Create(UI.DMG.Stroke, TweenInfo.new(0.25, Enum.EasingStyle.Cubic), {
				TextTransparency = 0,
				TextStrokeTransparency = 0
			}):Play()
			local tween = TweenService:Create(UI.DMG, TweenInfo.new(0.25, Enum.EasingStyle.Cubic), {
				TextTransparency = 0,
				TextStrokeTransparency = 0
			})
			tween:Play()
			tween.Completed:Wait()

			if UI and UI.Parent then
				TweenService:Create(UI.DMG, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
					TextTransparency = 1,
					TextStrokeTransparency = 1
				}):Play()
				TweenService:Create(UI.DMG.Stroke, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
					TextTransparency = 1,
					TextStrokeTransparency = 1
				}):Play()
				TweenService:Create(UI.DMG.Stroke, TweenInfo.new(0.25, Enum.EasingStyle.Cubic), {
					TextColor3 = Color3.fromRGB(255, 255, 255)
				}):Play()
				task.wait(WAIT_INTERVAL)
				local tween2 = TweenService:Create(UI, TweenInfo.new(0.25, Enum.EasingStyle.Cubic), {
					Size = UDim2.new(1, 0, 1, 0)
				})
				tween2:Play()
				tween2.Completed:Wait()

				if clone and clone.Parent then
					clone:Destroy()
				end
			end
		end
	else
		local clone = damage:Clone()
		clone.Parent = visuals
		clone.CFrame = p.CFrame * CFrame.new(
			Random.new():NextNumber(-1, 1),
			Random.new():NextNumber(-1, 1),
			Random.new():NextNumber(-1, 1)
		)
		clone.UI.DMG.Text = `{p2}`
		clone.UI.DMG.Stroke.Text = `{p2}`
		Debris:AddItem(clone, 3)
		local UI = clone:FindFirstChild("UI")

		if UI then
			TweenService:Create(UI, TweenInfo.new(0.25, Enum.EasingStyle.Cubic), {
				Size = UDim2.new(10, 0, 1.75, 0)
			}):Play()
			TweenService:Create(UI.DMG.Stroke, TweenInfo.new(0.25, Enum.EasingStyle.Cubic), {
				TextTransparency = 0,
				TextStrokeTransparency = 0
			}):Play()
			local tween = TweenService:Create(UI.DMG, TweenInfo.new(0.25, Enum.EasingStyle.Cubic), {
				TextTransparency = 0,
				TextStrokeTransparency = 0
			})
			tween:Play()
			tween.Completed:Wait()

			if UI and UI.Parent then
				TweenService:Create(UI.DMG, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
					TextTransparency = 1,
					TextStrokeTransparency = 1
				}):Play()
				TweenService:Create(UI.DMG.Stroke, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
					TextTransparency = 1,
					TextStrokeTransparency = 1
				}):Play()
				TweenService:Create(UI.DMG.Stroke, TweenInfo.new(0.25, Enum.EasingStyle.Cubic), {
					TextColor3 = Color3.fromRGB(255, 255, 255)
				}):Play()
				task.wait(WAIT_INTERVAL)
				local tween2 = TweenService:Create(UI, TweenInfo.new(0.25, Enum.EasingStyle.Cubic), {
					Size = UDim2.new(1, 0, 1, 0)
				})
				tween2:Play()
				tween2.Completed:Wait()

				if clone and clone.Parent then
					clone:Destroy()
				end
			end
		end
	end
end

return FXModule