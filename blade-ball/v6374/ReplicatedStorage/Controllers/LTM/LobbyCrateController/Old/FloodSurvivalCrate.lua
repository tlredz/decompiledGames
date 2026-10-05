local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2:WaitForChild("UserInputService"))
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
game:GetService("StarterGui")
require3(ReplicatedStorage3.ServerInfo)
local v2 = require3(ReplicatedStorage3.Shared.LTM)

if not table.find(v2.serverProfiles, "FloodSurvival") then
	return {}
end

local activeLTM = v2.getActiveLTM("FloodSurvival")
local clientGameModules = ReplicatedStorage3.ClientGameModules
local _ = ReplicatedStorage3.Common
local packages = ReplicatedStorage3.Packages
local v3 = require3(ReplicatedStorage3.Packages.Replion)
local v4 = require3(ReplicatedStorage3.Packages.Net)
local v5 = require3(ReplicatedStorage3.Common.Utils)
local v6 = require3(clientGameModules.GuiHandler)
local v7 = require3(game.ReplicatedStorage.Shared.Policy)
local v8 = require3(ReplicatedStorage3.Shared.LTMCrateData)
require3(ReplicatedStorage3.Common.MarketplaceService)
local v9 = require3(packages.Signal)
local v10 = require3(ReplicatedStorage3.ClientGameModules.CoreCall)
local v11 = nil
local v12 = nil
local v13 = nil
local v14 = nil
local localPlayer = Players.LocalPlayer
local playerGui = nil
local lTMCrate = nil
local crates = nil
local left = nil
local right = nil
local odds = nil
local items = nil
local leftList = nil
local rightList = nil
local spinButtons = nil
local spin1 = nil
local spin10 = nil
local secret = nil
local secret2 = nil
local glow = nil
local item = nil
local selected = nil
local questionMark = nil
local desc2 = nil
local label = nil
local main = nil
local currency = nil
local add = nil
local amount = nil
local dayCount = nil
local label2 = nil
local list = nil
local timer = nil
local close = nil
local flag = false
local v15 = {}
local count = 0
local count2 = 0
local halloweenGacha = ReplicatedStorage3.Assets.UI.HalloweenGacha
local FloodSurvivalCrate = {
	BalanceText = "",
	BalanceTextChanged = v9.new(),
	DefaultSecret = function(self)
		glow.Visible = false
		selected.Visible = false
		questionMark.Visible = true
		desc2.Text = "Sword/Explosion"
	end,
	LoadItems = function(self)
		for k, v16 in v8.RewardPool do
			local v17 = v15[k]

			if not v17 then
				continue
			end

			local reward = v16.Reward
			v17.Vector.Image = reward.Icon or ""
			v17.Title.Text = reward.DisplayName
			v17.Label.Text = `{v16.Probability}%`
			local selected = v17:FindFirstChild("Selected")
			selected.Visible = false
			count += 1
		end

		count += 1
		label.Text = `{v8.RewardPool[count].Probability}%`
		self:DefaultSecret()
	end,
	ToggleChances = function(flag2: boolean?)
		for _, v16 in v15 do
			v16.Label.Visible = flag2 or not v16.Label.Visible
		end

		label.Visible = flag2 or not label.Visible
	end
}

local function ApplyTween(clone, p, uDim, p2, p3)
	local tween = TweenService:Create(
		clone,
		p3 or TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
		{
			[p] = uDim
		}
	)
	tween:Play()

	if not p2 then
		return
	end

	tween.Completed:Connect(function()
		clone:Destroy()
	end)
end

function FloodSurvivalCrate.Spin(p, p2, p3)
	if flag then
		return
	end

	local replacement = v8.RewardPool[p]
	local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Circular, Enum.EasingDirection.Out, 0, false, 0)

	if p2 and replacement.Replacement then
		replacement = replacement.Replacement
	end

	local v16 = p3 and 0.015 or 0.045
	local v17 = p3 and 3 or 5
	flag = true
	FloodSurvivalCrate:DefaultSecret()

	for i = 1, v17 do
		for i2 = 1, count do
			for _, v18 in v15 do
				TweenService:Create(
					v18:FindFirstChild("Selected"),
					tweenInfo or TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
					{
						ImageTransparency = 1
					}
				):Play()
				local selected_2 = v18:FindFirstChild("Selected")
				selected_2.Visible = true
			end

			selected.Visible = true
			TweenService:Create(
				selected,
				tweenInfo or TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					ImageTransparency = 1
				}
			):Play()

			if count <= i2 then
				TweenService:Create(
					selected,
					tweenInfo or TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
					{
						ImageTransparency = 0
					}
				):Play()
			else
				TweenService:Create(
					v15[i2]:FindFirstChild("Selected"),
					tweenInfo or TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
					{
						ImageTransparency = 0
					}
				):Play()
			end

			if i == v17 and i2 == p then
				break
			end

			local clone = halloweenGacha.bink:Clone()
			clone.Parent = playerGui
			clone.Volume = clone.Volume or 0.34
			clone:Play()
			task.delay(clone.TimeLength + 0.1, function()
				clone:Destroy()
			end)
			task.wait(v16)
			v16 = math.min(v16 * 1.015, 0.1)
		end
	end

	if replacement.Replacement or p2 then
		local lastTime = tick()
		v5.Sounds:Play("SecretOpened")
		local v18 = 0.8
		local v19 = 9

		while tick() - lastTime < v18 do
			local v20 = v19 * (1 - (tick() - lastTime) / 0.8)
			local number = Random.new():NextNumber(-v20, v20)
			local number2 = Random.new():NextNumber(-v20, v20)
			secret2.Position = UDim2.new(0.5, number, 0.5, number2)
			task.wait()
		end

		secret2.Position = UDim2.new(0.5, 0, 0.5, 0)
		item.Image = replacement.Reward.Icon
		glow.Visible = true
		questionMark.Visible = false
		desc2.Text = replacement.Reward.DisplayName
		v13:FireServer()
		local clone = halloweenGacha.reward:Clone()
		clone.Volume = 0.34
		clone.Parent = playerGui
		clone:Play()
		local clone2 = secret2:Clone()
		clone2.Parent = secret2.Parent

		for _, descendant in clone2:GetDescendants() do
			if descendant:IsA("TextLabel") or descendant:IsA("TextBox") or descendant:IsA("TextButton") then
				TweenService:Create(
					descendant,
					TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
					{
						TextTransparency = 1
					}
				):Play()
			elseif descendant:IsA("ImageLabel") or descendant:IsA("ImageButton") then
				TweenService:Create(
					descendant,
					TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
					{
						ImageTransparency = 1
					}
				):Play()
			elseif descendant:IsA("UIStroke") then
				TweenService:Create(
					descendant,
					TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
					{
						Transparency = 1
					}
				):Play()
			end
		end

		TweenService:Create(clone2, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0), {
			ImageTransparency = 1
		}):Play()
		ApplyTween(clone2, "Size", UDim2.fromScale(2.5, 2.5), true)
	else
		local clone = halloweenGacha.reward:Clone()
		clone.Volume = 0.34
		clone.Parent = playerGui
		clone:Play()
		v13:FireServer()
	end

	task.wait(0.5)
	flag = false
	local v18 = v11:Get(activeLTM.TicketName) or 0

	if p3 and count2 < 9 and v18 > 0 then
		count2 += 1
		v12:FireServer(true)
	end
end

function FloodSurvivalCrate:SetupStreaks()
	local v16 = {
		["1"] = list:FindFirstChild("1"),
		["3"] = list:FindFirstChild("2"),
		["5"] = list:FindFirstChild("3"),
		["7"] = list:FindFirstChild("4")
	}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function GetStreakData(p)
		for _, dailyLoginStreak in v8.DailyLoginStreaks do
			if dailyLoginStreak.Streak == p then
				return dailyLoginStreak
			end
		end

		return 0
	end

	if activeLTM.LoginStreak and activeLTM.ClaimedStreaks and activeLTM.LastLoginStreak then
		local updatesByName = {}

		for k, v17 in v16 do
			local v18 = v17
			local v19 = k

			local function update()
				local label3 = v18.Label
				local v20 = v11:Get({ activeLTM.ClaimedStreaks, (`Day{v18.Name}`) })
				local streakData = GetStreakData(tonumber(v19)) -- equivalent call inferred; original call site unknown
				v18.Days.Label.Text = `Day {streakData.Streak}`

				if v20 then
					v18.ImageColor3 = Color3.new(0.9, 0.9, 0.9)
					v18.Claimed.Visible = true
					label3.Text = ""
				else
					local v23 = v11:Get(activeLTM.LoginStreak) or 0
					v18.ImageColor3 = Color3.new(1, 1, 1)
					v18.Claimed.Visible = false
					local tickets = streakData.Tickets
					label3.Text = `+{tickets} Ticket{tickets <= 1 and "" or "s"}`
					label3.Visible = true

					if tonumber(v19) <= v23 then
						label3.Text = `+{tickets} (Click to claim)`
						v18:SetAttribute("CanClaim", true)
					else
						v18:SetAttribute("CanClaim", nil)
					end
				end
			end

			local v20 = v17
			v17.Activated:Connect(function()
				if v11:Get({ activeLTM.ClaimedStreaks, (`Day{v20.Name}`) }) or not v20:GetAttribute("CanClaim") then
					return
				end

				v5.Sounds:Play("LTMSpin_ClaimSpins")
				v14:FireServer((tonumber(v20.Name)))
			end)
			update()
			updatesByName[v17.Name] = update
			v11:OnChange(activeLTM.ClaimedStreaks, update)
		end

		local function updateStreaks()
			label2.Text = `{v11:Get(activeLTM.LoginStreak)} Days`

			for _, v17 in updatesByName do
				v17()
			end
		end

		v11:OnChange(activeLTM.LastLoginStreak, updateStreaks)
		v11:OnChange(activeLTM.LoginStreak, updateStreaks)
		v11:OnChange(activeLTM.ClaimedStreaks, updateStreaks)
		task.spawn(updateStreaks)
	end
end

function FloodSurvivalCrate.UpdateSpins()
	local v16 = v11:Get(activeLTM.TicketName) or 0
	amount.Text = v5.ValueConvertor:AddCommas(v16)
	FloodSurvivalCrate.BalanceText = amount.Text
	FloodSurvivalCrate.BalanceTextChanged:Fire(FloodSurvivalCrate.BalanceText)
end

function FloodSurvivalCrate.Init(_) end

function FloodSurvivalCrate:Start()
	v11 = v3.Client:WaitReplion("Data")
	v12 = v4:RemoteEvent("ProcessLTMRoll")
	v13 = v4:RemoteEvent("ClaimLTMReward")
	v14 = v4:RemoteEvent("ClaimLTMStreak")
	playerGui = localPlayer:WaitForChild("PlayerGui")
	lTMCrate = playerGui:WaitForChild("LTMCrate")
	crates = lTMCrate:WaitForChild("Crates")
	left = crates:WaitForChild("Left")
	right = crates:WaitForChild("Right")
	odds = left:WaitForChild("Odds")
	items = left:WaitForChild("Items")
	leftList = items:WaitForChild("LeftList")
	rightList = items:WaitForChild("RightList")
	spinButtons = items:WaitForChild("SpinButtons")
	spin1 = spinButtons:WaitForChild("Spin1")
	spin10 = spinButtons:WaitForChild("Spin10")
	secret = items:WaitForChild("Secret")
	secret2 = secret:WaitForChild("Secret")
	glow = secret2:WaitForChild("Glow")
	item = glow:WaitForChild("Item")
	selected = secret2:WaitForChild("Selected")
	questionMark = secret2:WaitForChild("QuestionMark")
	desc2 = secret2:WaitForChild("Desc2")
	label = secret2:WaitForChild("Label")
	main = right:WaitForChild("Main")
	currency = right:WaitForChild("Currency")
	add = currency:WaitForChild("Add")
	amount = currency:WaitForChild("List"):WaitForChild("Amount")
	dayCount = main:WaitForChild("DayCount")
	label2 = dayCount:WaitForChild("DayCount"):WaitForChild("Label")
	list = main:WaitForChild("List")
	timer = main:WaitForChild("Timer")
	close = right:WaitForChild("Close")
	v15[1] = leftList:WaitForChild("Crate1")
	v15[2] = leftList:WaitForChild("Crate2")
	v15[3] = leftList:WaitForChild("Crate3")
	v15[4] = leftList:WaitForChild("Crate4")
	v15[5] = rightList:WaitForChild("Crate5")
	v15[6] = rightList:WaitForChild("Crate6")
	v15[7] = rightList:WaitForChild("Crate7")
	v15[8] = rightList:WaitForChild("Crate8")

	if RunService:IsStudio() then
		v.InputBegan:Connect(function(input, gameProcessed)
			if input.KeyCode == Enum.KeyCode.J and not gameProcessed and localPlayer.UserId == 33836554 then
				v6:Open("LTMCrate")
			end
		end)
	end

	close.MouseButton1Click:Connect(function()
		v6:Close("LTMCrate")
	end)
	v6:OnGuiOpen("LTMCrate", function()
		v10(Enum.CoreGuiType.PlayerList, false)
	end)
	v6:OnGuiClose("LTMCrate", function()
		v10(Enum.CoreGuiType.PlayerList, true)
	end)
	add.MouseButton1Click:Connect(function()
		v6:Open("LTMTickets")
	end)
	spin1.MouseButton1Click:Connect(function()
		if flag then
			return
		end

		count2 = 0
		v12:FireServer()
	end)
	spin10.MouseButton1Click:Connect(function()
		if flag or (v11:Get(activeLTM.TicketName) or 0) < 10 then
			return
		end

		count2 = 0
		v12:FireServer(true)
	end)
	odds.MouseButton1Click:Connect(function()
		self.ToggleChances()
	end)
	v12.OnClientEvent:Connect(FloodSurvivalCrate.Spin)
	v11:OnChange(activeLTM.TicketName, FloodSurvivalCrate.UpdateSpins)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function ReflectPolicy()
		local policyInfo = v7:GetPolicyInfo()
		add.Visible = not policyInfo.ArePaidRandomItemsRestricted
	end

	ReflectPolicy() -- equivalent call inferred; original call site unknown
	v7.PolicyInfoAdded:Connect(ReflectPolicy)

	local function UpdateDailyStreakTime()
		local v16 = v11:Get(activeLTM.LastLoginStreak)

		if not v16 then
			dayCount.Label.Text = "Something went wrong!"
			return
		end

		local v17 = math.clamp(v16 + 86400 - workspace:GetServerTimeNow(), 0, 1e999)
		dayCount.Label.Text = `Next rewards: {v5.ValueConvertor:FormatTimeHHMMSS(v17)}`
	end

	local v16 = activeLTM.getGameMode() == "Storm" and 5 or 1
	v5.Thread.Every(v16, function()
		local dateTime = DateTime.fromUnixTimestamp(workspace:GetServerTimeNow())
		local formatTimeWithDaysFull = v5.ValueConvertor:FormatTimeWithDaysFull(v8.TimeLength.UnixTimestamp - dateTime.UnixTimestamp)
		timer.Text = `{formatTimeWithDaysFull}`
		UpdateDailyStreakTime()
	end)
	self:LoadItems()
	self.UpdateSpins()
	self:SetupStreaks()
	self.ToggleChances(false)
end

return FloodSurvivalCrate