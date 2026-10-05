local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local FlowerAndCoinsClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local UtilityAlec = require(ReplicatedStorage.Modules.UtilityAlec)
local flowerAmount = nil
local coinAmount = nil
Random.new()
FlowerAndCoinsClient.FlowerAmount = 0
FlowerAndCoinsClient.CoinAmount = 0
local animation = nil
local v = nil
local animation2 = nil
local v2 = nil
local count = 0
local count2 = 0

function UpdateFlowers(text, p)
	if p then
		flowerAmount.FlowerLabel.Size = UDim2.new(0.524, 0, 1.358, 0)
		TweenService:Create(
			flowerAmount.FlowerLabel,
			TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
			{
				Size = UDim2.new(0.385, 0, 1, 0)
			}
		):Play()
	end

	count += 1
	local v3 = count
	local textLabel = flowerAmount:WaitForChild("TextLabel")
	textLabel.Text = text
	flowerAmount.Visible = true
	Client.Interface.Flower.FlowerAmount.Text = text

	if text <= 0 then
		flowerAmount.Visible = false
	end

	task.spawn(function()
		wait(10)

		if count == v3 then
			flowerAmount.Visible = false
			flowerAmount.TextLabel.Text = localPlayer:GetAttribute("Coins") or 0
		end
	end)
end

function UpdateCoins(value, p)
	if p then
		coinAmount.CoinLabel.Size = UDim2.new(0.524, 0, 1.358, 0)
		TweenService:Create(
			coinAmount.CoinLabel,
			TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
			{
				Size = UDim2.new(0.385, 0, 1, 0)
			}
		):Play()
	end

	count2 += 1
	local v3 = count2
	local text = value or 0
	coinAmount.TextLabel.Text = text
	coinAmount.Visible = true

	if text <= 0 then
		coinAmount.Visible = false
	end

	Client.FurnitureClient.UpdateCoinAmount()
	task.spawn(function()
		wait(10)

		if count2 == v3 then
			coinAmount.Visible = false
		end
	end)
end

function FlowerAndCoinsClient.PullFlower(instance)
	task.spawn(function()
		if not instance then
			return
		end

		local clone = instance:Clone()
		clone:RemoveTag("Interaction")
		clone.Parent = instance.Parent

		if clone and clone.Parent and clone:FindFirstChild("AnimationController") then
			clone.AnimationController.Animator:LoadAnimation(animation):Play(0.1, 1, 2)
			wait(v)
			Client.Sound.Play("FlowerPick", {
				Duplicate = true
			})

			if clone then
				clone:Destroy()
			end
		end
	end)
end

function FlowerAndCoinsClient.PickupCoins(instance)
	task.spawn(function()
		if not instance then
			return
		end

		local coinAmount2 = instance:GetAttribute("CoinAmount")
		local clone = instance:Clone()
		clone:RemoveTag("Interaction")
		clone.PrimaryPart = clone.HumanoidRootPart
		clone:RemoveTag("Coins")
		clone.PrimaryPart.Anchored = true
		clone.Parent = instance.Parent

		if instance then
			instance:Destroy()
		end

		if clone and clone.Parent and clone:FindFirstChild("AnimationController") then
			clone.AnimationController.Animator:LoadAnimation(animation2):Play(0.1, 1, 2)
			task.spawn(function()
				local mossyCoin3 = clone["Mossy Coin3"]
				wait()

				for _, part in pairs(mossyCoin3:GetChildren()) do
					if part:IsA("BasePart") then
						TweenService:Create(part, TweenInfo.new(0.13, Enum.EasingStyle.Linear), {
							Transparency = 1
						}):Play()
					end
				end
			end)
			task.spawn(function()
				local mossyCoin4 = clone["Mossy Coin4"]
				wait(0.05)

				for _, part in pairs(mossyCoin4:GetChildren()) do
					if part:IsA("BasePart") then
						TweenService:Create(part, TweenInfo.new(0.16, Enum.EasingStyle.Linear), {
							Transparency = 1
						}):Play()
					end
				end
			end)
			task.spawn(function()
				local mossyCoin5 = clone["Mossy Coin5"]
				wait(0.1)

				for _, part in pairs(mossyCoin5:GetChildren()) do
					if part:IsA("BasePart") then
						TweenService:Create(part, TweenInfo.new(0.21, Enum.EasingStyle.Linear), {
							Transparency = 1
						}):Play()
					end
				end
			end)
			task.spawn(function()
				local mossyCoin2 = clone["Mossy Coin2"]
				wait(0.2)

				for _, part in pairs(mossyCoin2:GetChildren()) do
					if part:IsA("BasePart") then
						TweenService:Create(part, TweenInfo.new(0.17, Enum.EasingStyle.Linear), {
							Transparency = 1
						}):Play()
					end
				end
			end)
			task.spawn(function()
				local mossyCoin = clone["Mossy Coin"]
				wait(0.3)

				for _, part in pairs(mossyCoin:GetChildren()) do
					if part:IsA("BasePart") then
						TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
							Transparency = 1
						}):Play()
					end
				end
			end)
			Client.Sound.Play("CoinPickup", {
				Duplicate = true
			})
			wait(0.5)

			if clone then
				FlowerAndCoinsClient.CoinAmount += coinAmount2
				UpdateCoins(FlowerAndCoinsClient.CoinAmount, true)
				clone:Destroy()
				local v4 = Client.Events.RequestCollectCoints:InvokeServer(instance)

				if not (v4 and v4.Success) then
					FlowerAndCoinsClient.CoinAmount -= coinAmount2
				end
			end
		end
	end)
end

Client.Events.ServerUpdateCoinAmount:Connect(function(value)
	Client.Sound.Play("CoinPickup", {
		Duplicate = true
	})
	FlowerAndCoinsClient.CoinAmount = value or 0
	UpdateCoins(FlowerAndCoinsClient.CoinAmount)
end)
Client.Events.FlowerDestroy:Connect(function(instance)
	if instance and instance.Parent and instance.PrimaryPart then
		instance:Destroy()
	end
end)
Client.Events.UpdateCoinAmount:Connect(function(value)
	FlowerAndCoinsClient.CoinAmount = value or 0
	UpdateCoins(FlowerAndCoinsClient.CoinAmount)
end)

function FlowerAndCoinsClient.Init()
	task.spawn(function()
		flowerAmount = Client.Interface.FlowerAmount
		coinAmount = Client.Interface.CoinAmount
		animation = Instance.new("Animation")
		animation.AnimationId = "rbxassetid://105026852273857"
		v = UtilityAlec.GetAnimationLength(animation) / 2
		animation2 = Instance.new("Animation")
		animation2.AnimationId = "rbxassetid://83991600543889"
		v2 = UtilityAlec.GetAnimationLength(animation2)
		UtilityAlec.preload({ animation, animation2 })
		UtilityAlec.preload({
			"rbxassetid://84459296274799",
			"rbxassetid://125472822187494",
			"rbxassetid://112868713412917",
			"rbxassetid://130006746231093",
			"rbxassetid://127897066286794",
			"rbxassetid://98791318764973",
			"rbxassetid://132715578501814",
			"rbxassetid://98690991388845"
		})
		localPlayer:GetAttributeChangedSignal("Coins"):Connect(function()
			FlowerAndCoinsClient.CoinAmount = localPlayer:GetAttribute("Coins")
			UpdateCoins(FlowerAndCoinsClient.CoinAmount)
		end)
		localPlayer:GetAttributeChangedSignal("Flowers"):Connect(function()
			local flowers = localPlayer:GetAttribute("Flowers") or 0
			local v3 = FlowerAndCoinsClient.FlowerAmount < flowers
			FlowerAndCoinsClient.FlowerAmount = flowers

			if v3 then
				task.delay(v, function()
					if flowers <= FlowerAndCoinsClient.FlowerAmount then
						UpdateFlowers(flowers, true)
					end
				end)
			else
				UpdateFlowers(flowers)
			end
		end)
		FlowerAndCoinsClient.CoinAmount = localPlayer:GetAttribute("Coins") or 0
		UpdateCoins(FlowerAndCoinsClient.CoinAmount)
		FlowerAndCoinsClient.FlowerAmount = localPlayer:GetAttribute("Flowers") or 0
		UpdateFlowers(FlowerAndCoinsClient.FlowerAmount)
	end)
end

return FlowerAndCoinsClient