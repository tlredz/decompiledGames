local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local assets = game.ReplicatedStorage:WaitForChild("Assets")
game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Reusable").IndicateDamage.OnClientEvent:Connect(function(data)
	local damageIndicatorUI = data.DamageIndicatorUI
	local damageDealt = data.DamageDealt
	local damageType = data.DamageType or "Physical"
	local isCrit = data.IsCrit or false
	local damageTexts = assets.DamageIndicator.DamageTexts
	local child

	if isCrit then
		child = damageTexts:FindFirstChild(damageType .. "Crit")
	else
		child = damageTexts:FindFirstChild(damageType)
	end

	if not child then
		warn("Damage text not found for type: " .. damageType)
		return
	end

	local text = math.floor(damageDealt)
	local clone = child:Clone()
	local v2 = isCrit == true and 0.75 or 0.25
	local v3 = math.clamp(text / 500, 0, 0.75) + v2
	clone.Size = UDim2.new(v3 + 0.25, 0, v3 + 0.25, 0)
	TweenService:Create(clone, TweenInfo.new(0.2), {
		Size = UDim2.new(v3, 0, v3, 0)
	}):Play()
	local v4 = math.random(-10, 10)
	local v5 = math.random(-5, 5)
	clone.Position = UDim2.new(0.5, v4, 0.7, v5)
	clone.Parent = damageIndicatorUI

	if isCrit == true then
		clone.DamageIndicator.Text = text
	else
		clone.Text = text
		TweenService:Create(clone, TweenInfo.new(0.2), {
			Position = UDim2.new(0.7, v4, 0.4, v5)
		}):Play()
		task.wait(0.2)
	end

	local v6, v7

	if isCrit == true then
		local damageIndicator = clone.DamageIndicator
		local critImage = clone.CritImage
		local tween = TweenService:Create(clone, TweenInfo.new(0.5), {
			BackgroundTransparency = 1
		})
		local tween2 = TweenService:Create(critImage, TweenInfo.new(0.5), {
			ImageTransparency = 1
		})
		v6 = TweenService:Create(damageIndicator, TweenInfo.new(0.5), {
			TextTransparency = 1
		})
		v7 = TweenService:Create(damageIndicator.UIStroke, TweenInfo.new(0.5), {
			Transparency = 1
		})
		tween:Play()
		tween2:Play()
		TweenService:Create(clone, TweenInfo.new(0.5), {
			Position = UDim2.new(0.8, v4, 0.2, v5)
		}):Play()
	else
		v6 = TweenService:Create(clone, TweenInfo.new(0.5), {
			TextTransparency = 1
		})
		v7 = TweenService:Create(clone.UIStroke, TweenInfo.new(0.5), {
			Transparency = 1
		})
		TweenService:Create(clone, TweenInfo.new(0.5), {
			Position = UDim2.new(0.9, v4, 1, v5)
		}):Play()
	end

	v6:Play()
	v7:Play()
	Debris:AddItem(clone, 2)
end)