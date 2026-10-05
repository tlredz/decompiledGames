local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
game:GetService("StarterGui")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local playerGui = Players.LocalPlayer.PlayerGui
local v = require3(ReplicatedStorage2.Packages.Net)
local v2 = require3(ReplicatedStorage2.Common.Utils)
local v3 = require3(ReplicatedStorage2.Packages.Trove)
require3(ReplicatedStorage2.Packages.Signal)
local v4 = require3(ReplicatedStorage2.Packages.Replion)
require3(ReplicatedStorage2.Common.RewardInfo)
local v5 = require3(ReplicatedStorage2.Shared.WeightRandom)
local v6 = require3(ReplicatedStorage2.Shared.EasterGachaData)
local v7 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v8 = require3(ReplicatedStorage2.Controllers.GiftingController)
local v9 = require3(ReplicatedStorage2.ClientGameModules.CreatePriceLabel)
local v10 = require3(ReplicatedStorage2.Controllers.Trading.TradeTokensController)
local v11 = require3(ReplicatedStorage2.Shared.Policy)
local v12 = require3(ReplicatedStorage2.Shared["EggShaker.story"])
local v13 = require3(ReplicatedStorage2.Controllers.Easter.EasterPageController)
local remoteEvent = v:RemoteEvent("EasterGachaOpen")
local remoteFunction = v:RemoteFunction("EasterGachaRoll")
local remoteFunction2 = v:RemoteFunction("EasterGachaFreeRoll")
local easterEvent = playerGui:WaitForChild("EasterEvent")
local easterGacha = playerGui:WaitForChild("EasterGacha")
local hatchEgg = easterEvent:WaitForChild("Overview"):WaitForChild("Views"):WaitForChild("HatchEgg")
local cell = easterGacha.Cell
cell.Parent = nil
local EasterHatchEggController = {}
EasterHatchEggController.IsOpening = false
EasterHatchEggController.FastSpin = false

function EasterHatchEggController.Init(_)
	v13:RegisterPage("HatchEgg", hatchEgg)
end

function EasterHatchEggController:Open(list, flag: boolean)
	while self.IsOpening do
		task.wait()
	end

	self.IsOpening = true
	v7:Open("EasterGacha", true)
	v7:Lock("EasterGacha", true)

	if flag then
		task.wait(1.5)
	end

	local count = 0
	local v14 = {}
	local clones = {}
	local v15 = {}
	local clones2 = {}

	for _, v16 in list do
		if v16.IsGolden then
			count += 1
		end
	end

	local v16 = false

	for _, v18 in list do
		if v18.IsGolden then
			continue
		end

		v16 = true
		break
	end

	easterGacha.Frame.Row2.Visible = #list > 5
	easterGacha.Frame.UIGridLayout.CellSize = UDim2.fromScale(1, #list > 5 and 0.5 or 0.8)
	local fastSpin = self.FastSpin
	local count2 = 0
	local count3 = 0

	for k, v18 in list do
		local row2

		if k > 5 then
			row2 = easterGacha.Frame.Row2
		else
			row2 = easterGacha.Frame.Row1
		end

		local clone = cell:Clone()
		clone.Parent = row2

		if v18.IsGolden then
			count2 += 1
			table.insert(v14, v12(clone, v18, fastSpin, v16, k, count2, #list, count))
			table.insert(clones, clone)
		else
			count3 += 1
			table.insert(v15, v12(clone, v18, fastSpin, v16, k, count3, #list, count))
			table.insert(clones2, clone)
		end
	end

	if #v15 > 0 or #v14 > 0 then
		task.wait((#v14 > 0 and 1 or 2) + 2.8 + (fastSpin and -0.3 or 0))

		for _, v18 in v15 do
			v18()
		end

		for _, v18 in clones2 do
			v18.Parent = ReplicatedStorage2
			Debris:AddItem(v18, 1)
		end
	end

	if #v14 > 0 then
		task.wait(7)

		for _, v18 in v14 do
			v18()
		end

		for _, v18 in clones do
			v18.Parent = ReplicatedStorage2
			Debris:AddItem(v18, 1)
		end
	end

	v7:Unlock("EasterGacha", true)
	v7:Close("EasterGacha", true)
	v13:Open()
	self.IsOpening = false
end

function EasterHatchEggController:Start()
	local v14 = v4.Client:WaitReplion("Data")

	if not v14 then
		return
	end

	local scroll = hatchEgg.TopRewardFrame.Frame.Vector.Scroll
	local tween = TweenService:Create(scroll, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Position = UDim2.fromScale(-1, 0)
	})
	local tween2 = TweenService:Create(scroll, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Position = UDim2.fromScale(0, 0)
	})
	local tween3 = TweenService:Create(scroll, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Position = UDim2.fromScale(-1, 0)
	})
	local tween4 = TweenService:Create(scroll, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Position = UDim2.fromScale(0, 0)
	})

	local function tweenScroll(p, p2, flag: boolean?, flag2: boolean?)
		if flag2 then
			p2, p = p, p2
		end

		scroll.Vector1.Image = p.Icon or ""
		scroll.Vector1.DisplayName.Text = p.DisplayName or ""
		scroll.Vector2.Image = p2.Icon or ""
		scroll.Vector2.DisplayName.Text = p2.DisplayName or ""
		local v15 = scroll
		local position

		if flag2 then
			position = UDim2.fromScale(-1, 0)
		else
			position = UDim2.new()
		end

		v15.Position = position

		if flag then
			if flag2 then
				tween4:Play()
				tween4.Completed:Wait()
			else
				tween3:Play()
				tween3.Completed:Wait()
			end
		elseif flag2 then
			tween2:Play()
			tween2.Completed:Wait()
		else
			tween:Play()
			tween.Completed:Wait()
		end
	end

	local v15 = {}
	local clone = {}

	local function updateArrayRewards()
		table.clear(v15)
		local rewards = v6.GetRewards(v14, v6.Rewards, true)

		for k, reward in rewards do
			if k.Type == "GoldenReward" then
				table.insert(v15, {
					IsGolden = true,
					Chance = reward,
					Reward = k.TargetReward
				})
			else
				table.insert(v15, {
					Chance = reward,
					Reward = k
				})
			end
		end

		table.sort(v15, function(a, b)
			return b.Chance < a.Chance
		end)
		clone = table.clone(v15)

		for i = #clone, 1, -1 do
			local v16 = clone[i]

			if not (v16.IsGolden and v16.Reward) then
				table.remove(clone, i)
			end
		end
	end

	v14:OnChange("ExplosionSkins.Unlocked", updateArrayRewards)
	v14:OnChange("SwordSkins.Unlocked", updateArrayRewards)
	v14:OnChange("Emotes.Unlocked", updateArrayRewards)
	v14:OnChange("Abilities.Unlocked", updateArrayRewards)
	updateArrayRewards()
	local v16 = 1
	task.spawn(function()
		local flag = false
		local flag2 = false
		local v17 = clone[1]
		local v18 = clone[1]
		hatchEgg.TopRewardFrame.Frame.Previous.Activated:Connect(function()
			if flag2 then
				return
			end

			flag2 = true
			flag = true
			v17 = v18
			v16 -= 1

			if v16 <= 0 then
				v16 = #clone
			end

			v18 = clone[v16]
			local reward = v17.Reward
			local reward2 = v18.Reward
			scroll.Vector1.Image = reward2.Icon or ""
			scroll.Vector1.DisplayName.Text = reward2.DisplayName or ""
			scroll.Vector2.Image = reward.Icon or ""
			scroll.Vector2.DisplayName.Text = reward.DisplayName or ""
			scroll.Position = UDim2.fromScale(-1, 0)
			tween4:Play()
			tween4.Completed:Wait()
			v17 = v18
			flag2 = false
		end)
		hatchEgg.TopRewardFrame.Frame.Next.Activated:Connect(function()
			if flag2 then
				return
			end

			flag2 = true
			flag = true
			v17 = v18
			v16 += 1

			if v16 > #clone then
				v16 = 1
			end

			v18 = clone[v16]
			local reward = v17.Reward
			local reward2 = v18.Reward
			scroll.Vector1.Image = reward.Icon or ""
			scroll.Vector1.DisplayName.Text = reward.DisplayName or ""
			scroll.Vector2.Image = reward2.Icon or ""
			scroll.Vector2.DisplayName.Text = reward2.DisplayName or ""
			scroll.Position = UDim2.new()
			tween3:Play()
			tween3.Completed:Wait()
			v17 = v18
			flag2 = false
		end)

		while true do
			task.wait()

			if #clone == 0 or flag2 then
				continue
			end

			if flag then
				flag = false
				task.wait(5)
			else
				v16 += 1

				if v16 > #clone then
					v16 = 1
				end

				local v19 = clone[v16]

				if v19 then
					v18 = v19
					local reward = v17.Reward
					local reward2 = v18.Reward
					scroll.Vector1.Image = reward.Icon or ""
					scroll.Vector1.DisplayName.Text = reward.DisplayName or ""
					scroll.Vector2.Image = reward2.Icon or ""
					scroll.Vector2.DisplayName.Text = reward2.DisplayName or ""
					scroll.Position = UDim2.new()
					tween:Play()
					tween.Completed:Wait()
					task.wait(3)

					if not flag then
						v17 = v18
					end
				end
			end
		end
	end)
	v9(hatchEgg.BottomButtons.Spin1.Amount, v6.Products[1].ProductId, "DevProduct", "Open x1\n:robux:%s")
	v9(hatchEgg.BottomButtons.Spin10.Amount, v6.Products[10].ProductId, "DevProduct", "Open x10\n:robux:%s")
	remoteEvent.OnClientEvent:Connect(function(...)
		self:Open(...)
	end)
	hatchEgg.BottomButtons.GiftButton.Activated:Connect(function()
		v8:SetGift(v6.Products[10].GiftName)
	end)
	hatchEgg.BottomButtons.Spin1.Activated:Connect(function()
		v10:PromptPurchase(v6.Products[1].ProductId, Enum.InfoType.Product)
	end)
	hatchEgg.BottomButtons.Spin10.Activated:Connect(function()
		v10:PromptPurchase(v6.Products[10].ProductId, Enum.InfoType.Product)
	end)
	hatchEgg.SpinButton.Activated:Connect(function()
		local expect = v14:GetExpect("EasterGacha.Spins")
		local expect2 = v14:GetExpect("EasterGacha.FreeSpins")
		local v17 = nil

		if expect > 0 then
			v17 = remoteFunction
		elseif expect2 > 0 then
			v17 = remoteFunction2
		end

		if v17 then
			local v18, v19 = v17:InvokeServer()

			if v18 then
				self:Open(v19)
			else
				SoundService.UI.error:Play()
			end
		end
	end)
	local list = hatchEgg.OddsFrame.Main.List
	local v17 = v3.new()
	hatchEgg.Odds.Activated:Connect(function()
		hatchEgg.OddsFrame.Visible = not hatchEgg.OddsFrame.Visible

		if hatchEgg.OddsFrame.Visible then
			v17:Clean()
			local rewards = v6.GetRewards(v14, v6.Rewards, true)
			local weights = v5.getWeights(rewards)
			local v18 = {}

			for k, relativeWeight in weights.relativeWeights do
				v18[weights.options[k]] = math.floor(relativeWeight * 100 * 100) / 100
			end

			for targetReward, reward in rewards do
				local v19 = v18[targetReward] or reward
				local template = list.UIGridLayout.Template

				if targetReward.Type == "GoldenReward" then
					template = list.UIGridLayout.GoldenTemplate
					targetReward = targetReward.TargetReward
				end

				local clone2 = v17:Clone(template)
				clone2.Value.Text = targetReward.DisplayName
				clone2.Vector.Image = targetReward.Icon or ""
				clone2.Percentage.Text = `{v19}%`
				clone2.LayoutOrder = math.floor(v19 * 1000)
				clone2.Parent = list
			end
		end
	end)
	hatchEgg.SkipAnimationFrame.Activated:Connect(function(_, _: number)
		hatchEgg.SkipAnimationFrame.CheckMark.Visible = not hatchEgg.SkipAnimationFrame.CheckMark.Visible
		self.FastSpin = hatchEgg.SkipAnimationFrame.CheckMark.Visible
	end)
	hatchEgg.SpinButton.PriceList.Amount.Text = v6.FreePrice
	v2.Thread.Every(1, function()
		workspace:GetServerTimeNow()
		local expect = v14:GetExpect("EasterGacha.Spins")
		local expect2 = v14:GetExpect("EasterGacha.FreeSpins")
		local v18 = v14:GetExpect("EasterGacha.LastFreeSpin") + 86400
		hatchEgg.SpinButton.SpinAmount.Text = not (expect > 0) and "" or `Spin ({expect})`
		hatchEgg.SpinButton.SpinAmount.Visible = expect > 0
		hatchEgg.SpinButton.PriceList.Visible = expect <= 0
		hatchEgg.SpinButton.ImageColor3 = expect <= 0 and expect2 <= 0 and Color3.fromRGB(100, 100, 100) or Color3.fromRGB(
			255,
			255,
			255
		)
		hatchEgg.SpinButton.TextLabel.Visible = expect > 0 or expect2 > 0
		local left = hatchEgg.SpinButton.Left
		local text

		if expect > 0 then
			text = ""
		elseif expect2 > 0 then
			text = `({expect2} left today)`
		else
			text = `(restocks in {v2.ValueConvertor:FormatTimeWithDays(v18 - workspace:GetServerTimeNow())})`
		end

		left.Text = text
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updatePolicyInfo(policyInfo)
		if not policyInfo then
			return
		end

		hatchEgg.BottomButtons.Visible = not policyInfo.ArePaidRandomItemsRestricted
	end

	local policyInfo = v11:GetPolicyInfo()

	if policyInfo.ArePaidRandomItemsRestricted == nil then
		v11.PolicyInfoAdded:Connect(updatePolicyInfo)
	end

	updatePolicyInfo(policyInfo) -- equivalent call inferred; original call site unknown
end

return EasterHatchEggController