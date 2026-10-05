local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local TweenService = game:GetService("TweenService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require3(ReplicatedStorage2.Shared.LootboxData)
local v = require3(ReplicatedStorage2.Common.Utils.Utilities.Icons)
local v2 = {
	ClanSwordCrate = "rbxassetid://15602339790",
	ClanMagicalCrate = "rbxassetid://17212489971"
}
local v3 = {
	ClanSwordCrate = "rbxassetid://15602331592",
	ClanMagicalCrate = ""
}
return {
	DoAnimation = function(_, instance, data, p: string)
		instance.Crate.Image = v2[p]
		local clone = instance:Clone()
		clone.Parent = instance.Parent
		clone.Title.Text = data.DisplayName or data.RewardKey
		clone.Icon.Image = data.ImageId or v:GetIcon("DEFAULT_MISSING")

		local function shakeImageLabel(p2)
			local v4 = 10
			local v5 = 0.15

			local function stopShakingAndExplode()
				p2.Rotation = 0
				p2.Image = v3[p]
				TweenService:Create(p2, TweenInfo.new(0.3), {
					Size = UDim2.fromScale(0.3, 0.3)
				}):Play()
				task.delay(0.3, function()
					clone.Crate.Visible = false
				end)
			end

			local doShake

			doShake = function()
				local tween = TweenService:Create(
					p2,
					TweenInfo.new(v5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Rotation = 15
					}
				)
				tween:Play()
				tween.Completed:Connect(function()
					p2.Rotation *= -1
					v5 *= 0.85
					v4 -= 1

					if v4 > 0 then
						doShake()
					else
						stopShakingAndExplode()
					end
				end)
			end

			doShake()
		end

		local function fallingStars()
			for _, child in clone.stars:GetChildren() do
				child.Size = UDim2.new(0, 0, 0, 0)
				child.ImageTransparency = 1
				child.Rotation = 0
				local uDim = UDim2.new(0, 100, 0, 100)
				local uDim2 = UDim2.new(0, 50, 0, 50)
				local position = child.Position
				local uDim3 = UDim2.new(position.X.Scale, position.X.Offset, 1, 0)
				local tween = TweenService:Create(
					child,
					TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
					{
						Size = uDim,
						ImageTransparency = 0
					}
				)
				tween:Play()
				local v4 = child
				tween.Completed:Connect(function()
					local tween2 = TweenService:Create(
						v4,
						TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
						{
							Position = uDim3,
							Size = uDim2,
							Rotation = 360
						}
					)
					local tween3 = TweenService:Create(
						v4,
						TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
						{
							ImageTransparency = 1
						}
					)
					tween2:Play()
					tween3:Play()
				end)
			end
		end

		local function rewardIcon()
			TweenService:Create(clone.Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = UDim2.fromScale(0.5, 0.167),
				TextTransparency = 0
			}):Play()
			TweenService:Create(
				clone.Title.UIStroke,
				TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Transparency = 0
				}
			):Play()
			local uDim = UDim2.fromScale(0.35, 0.35)
			TweenService:Create(clone.ItemGlow, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = uDim
			}):Play()
			local startRotation

			startRotation = function()
				local tween = TweenService:Create(
					clone.ItemGlow,
					TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
					{
						Rotation = clone.ItemGlow.Rotation + 360
					}
				)
				tween.Completed:Connect(function()
					if clone and clone:FindFirstChild("ItemGlow") then
						clone.ItemGlow.Rotation = clone.ItemGlow.Rotation % 360
						startRotation()
					end
				end)
				tween:Play()
			end

			startRotation()
			clone.Icon.Visible = true
			clone.ItemGlow.Visible = true
			local tween = TweenService:Create(
				clone.Icon,
				TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				{
					Size = UDim2.fromScale(0.4, 0.4)
				}
			)
			tween.Completed:Connect(function()
				TweenService:Create(
					clone.Icon,
					TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
					{
						Size = UDim2.fromScale(0.35, 0.35)
					}
				):Play()
			end)
			tween:Play()
		end

		clone.Visible = true
		local crate = clone.Crate
		local v4 = 10
		local v5 = 0.15

		local function stopShakingAndExplode()
			crate.Rotation = 0
			crate.Image = v3[p]
			TweenService:Create(crate, TweenInfo.new(0.3), {
				Size = UDim2.fromScale(0.3, 0.3)
			}):Play()
			task.delay(0.3, function()
				clone.Crate.Visible = false
			end)
		end

		local doShake

		doShake = function()
			local tween = TweenService:Create(
				crate,
				TweenInfo.new(v5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Rotation = 15
				}
			)
			tween:Play()
			tween.Completed:Connect(function()
				crate.Rotation *= -1
				v5 *= 0.85
				v4 -= 1

				if v4 > 0 then
					doShake()
				else
					stopShakingAndExplode()
				end
			end)
		end

		doShake()
		task.wait(0.95)
		fallingStars()
		rewardIcon()
		task.delay(2, function()
			clone:Destroy()
		end)
	end
}