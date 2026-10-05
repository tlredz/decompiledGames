local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("StarterGui")
game:GetService("TweenService")
local Debris = game:GetService("Debris")
local v = require3(ReplicatedStorage2.Shared.FastUtils)
local v2 = require3(script.Parent["RewardPopup.story"])
local rewardBoom = script.RewardBoom
local random = Random.new()

local function rewardBoom2(child, p, value: number?, flag: boolean?)
	local v3 = value or 1
	local clone = rewardBoom:Clone()
	Debris:AddItem(clone, v3 * 0.5 + 0.1)

	for _, guiObject in clone:GetChildren() do
		if guiObject:IsA("GuiObject") then
			task.delay(
				v3 * 0.5,
				v.fastTween,
				guiObject,
				TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
				{
					ImageTransparency = 1
				}
			)
		end
	end

	clone.Size = UDim2.new()
	v.fastTween(clone, TweenInfo.new(v3 * 0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Size = UDim2.fromScale(3, 3)
	})
	v.fastTween(clone, TweenInfo.new(v3 * 7.5, Enum.EasingStyle.Linear), {
		Rotation = 1080
	})

	if not flag then
		p.WhiteFlash.Visible = true
		p.WhiteFlash.BackgroundTransparency = 0.25
		v.fastTween(p.WhiteFlash, TweenInfo.new(v3 * 0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			BackgroundTransparency = 1
		})
	end

	clone.Parent = child
	v.fastAudio("rbxassetid://9113216700", p, 0.25)
end

local v3 = {}
local v4 = false
local flag = false
local animate

animate = function(p, p2: string, p3: number, p4: string, _: string)
	flag = true
	local v5 = v4
	local items = p.Background.Spin.Items

	if p2 == "Small" then
		if not v5 then
			local v6

			if v5 then
				v6 = random:NextInteger(1, 3)
			else
				v6 = random:NextInteger(3, 5)
			end

			for i = 1, v6 do
				local v7 = i ~= v6 and 5 or p2 ~= "Small" and 3 or p3

				for i2 = 1, v7 do
					v.fastAudio("rbxassetid://16670859474", p, 0.5)
					local highlight = items:FindFirstChild((`SmallItem{i2}`)):FindFirstChild("Highlight")

					if highlight then
						highlight.ImageTransparency = 0.25
						v.fastTween(
							highlight,
							TweenInfo.new(
								0.25,
								Enum.EasingStyle.Sine,
								Enum.EasingDirection.In,
								0,
								false,
								i == v6 and i2 == v7 and 1 or 0
							),
							{
								ImageTransparency = 1
							}
						)
					end

					task.wait(v5 and 0.05 or 0.1)
				end
			end
		end

		rewardBoom2(items:FindFirstChild((`SmallItem{"Small" ~= "Small" and 3 or p3}`)), p, v5 and 4 or 1, v5)
		v.fastAudio("rbxassetid://16670863996", p, 0.5)
		flag = false
	else
		local integer = random:NextInteger(3, 5)

		for i = 1, integer do
			local v6 = i ~= integer and 4 or p3

			for i2 = 1, v6 do
				v.fastAudio("rbxassetid://9114464537", p, 0.5, 1.5, 0.085)
				local highlight = items:FindFirstChild((`BigItem{i2}`)):FindFirstChild("Highlight")

				if highlight then
					highlight.ImageTransparency = 0.15
					v.fastTween(
						highlight,
						TweenInfo.new(
							0.25,
							Enum.EasingStyle.Sine,
							Enum.EasingDirection.In,
							0,
							false,
							i == integer and i2 == v6 and 1 or 0
						),
						{
							ImageTransparency = 1
						}
					)
				end

				task.wait(v5 and 0.1 or 0.2)
			end
		end

		local child = items:FindFirstChild((`BigItem{p3}`))
		rewardBoom2(child, p, v5 and 2 or 1)
		v.fastAudio("rbxassetid://16670862056", p, 0.5)
		v2(p4, child.Item.Image)
		task.wait(1)
		flag = false
		local v6 = table.remove(v3, 1)

		if v6 then
			animate(p, v6.Tier, v6.Index, v6.RewardName, v6.RewardIcon)
		end
	end
end

return function(p, tier: string, p3: number, rewardName: string, rewardIcon: string, flag2: boolean?)
	v4 = flag2 and true or false

	if flag then
		table.insert(v3, {
			Tier = tier,
			Index = p3,
			RewardName = rewardName,
			RewardIcon = rewardIcon
		})
	else
		animate(p, tier, p3, rewardName, rewardIcon)
	end
end