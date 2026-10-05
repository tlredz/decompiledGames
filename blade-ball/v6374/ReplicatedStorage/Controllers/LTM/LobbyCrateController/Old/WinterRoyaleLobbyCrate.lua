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

if not require3(ReplicatedStorage3.ServerInfo).isLTMServer() then
	return {}
end

local clientGameModules = ReplicatedStorage3.ClientGameModules
local _ = ReplicatedStorage3.Common
local packages = ReplicatedStorage3.Packages
local v2 = require3(ReplicatedStorage3.Packages.Replion)
local v3 = require3(ReplicatedStorage3.Packages.Net)
local v4 = require3(ReplicatedStorage3.Common.Utils)
local v5 = require3(clientGameModules.GuiHandler)
local v6 = require3(game.ReplicatedStorage.Shared.Policy)
local v7 = require3(ReplicatedStorage3.Shared.LTMCrateData)
require3(ReplicatedStorage3.Common.MarketplaceService)
local v8 = require3(packages.Signal)
require3(ReplicatedStorage3.Controllers.NotificationController)
local v9 = require3(ReplicatedStorage3.ClientGameModules.CoreCall)
local v10 = require3(ReplicatedStorage3.Shared.Statable)
local v11 = ReplicatedStorage3.Shared.LTM.GetLTM:Invoke("WinterRoyale")
local v12 = nil
local v13 = nil
local v14 = nil
local v15 = nil
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
local v16 = nil
local secret = nil
local secret2 = nil
local glow = nil
local item = nil
local selected = nil
local questionMark = nil
local desc1 = nil
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
local v17 = {}
local count = 0
local count2 = 0
local v18 = v2.Client:WaitReplion("LimitedStockItems")
local halloweenGacha = ReplicatedStorage3.Assets.UI.HalloweenGacha
local WinterRoyaleLobbyCrate = {
	BalanceText = "",
	BalanceTextChanged = v8.new()
}
local v19 = nil

function WinterRoyaleLobbyCrate:DefaultSecret()
	if v19 then
		v19:Destroy()
		v19 = nil
	end

	local v20 = v7.RewardPool[count]

	if v20 and v20.LimitedStock then
		local formatted = `Received{v11.Id}LTM{v20.Reward.Value}{v20.Reward.Type}`
		local v21

		if v12 then
			v21 = v12:Get(formatted) and true or false
		else
			v21 = false
		end

		local reward = v20.Reward
		local v22 = not v21 and v20.Replacement and v18:Get("Loaded") and (v18:Get({ "Stock", reward.Value }) or 0) <= 0 and true or v21

		if v22 and v20.Replacement then
			reward = v20.Replacement.Reward
		end

		if reward then
			glow.Visible = true
			selected.Visible = false
			questionMark.Visible = false

			if v22 then
				desc1.Text = ""
			else
				v19 = v10.setPropertyComputed(desc1, "Text", function(callback)
					local v23 = callback((v10.getReplionPathState(v18, "Loaded"))) and callback((v10.getReplionPathState(
						v18,
						{ "Stock", reward.Value }
					))) or 0

					if v23 <= 0 and v18:Get("Loaded") then
						task.delay(0, function()
							self:DefaultSecret()
						end)
					end

					return (`{v4.ValueConvertor:AddCommas(v23)} LEFT`)
				end)
			end

			desc2.Text = reward.Value
			item.Image = reward.Icon or v4.Icons:GetIcon("DEFAULT_MISSING")
		end
	else
		glow.Visible = false
		selected.Visible = false
		questionMark.Visible = true
		desc1.Text = "SECRET"
		desc2.Text = "Sword/Explosion"
		item.Image = "rbxassetid://16456337904"
	end
end

function WinterRoyaleLobbyCrate:LoadItems()
	for k, v20 in v7.RewardPool do
		local v21 = v17[k]

		if not v21 then
			continue
		end

		local reward = v20.Reward
		v21.Vector.Image = reward.Icon or ""
		v21.Title.Text = reward.DisplayName
		v21.Label.Text = `{v20.Probability}%`
		local selected = v21:FindFirstChild("Selected")
		selected.Visible = false
		count += 1
	end

	count += 1
	label.Text = `{v7.RewardPool[count].Probability}%`
	self:DefaultSecret()
end

function WinterRoyaleLobbyCrate.ToggleChances(visible: boolean?)
	for _, v20 in v17 do
		local label3 = v20.Label
		local visible2

		if visible == nil then
			visible2 = not v20.Label.Visible
		else
			visible2 = visible
		end

		label3.Visible = visible2
	end

	local v20 = label

	if visible == nil then
		visible = not label.Visible
	end

	v20.Visible = visible
end

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

function WinterRoyaleLobbyCrate.SpinCrate(p, p2, p3)
	if flag then
		return
	end

	local replacement = v7.RewardPool[p]
	local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Circular, Enum.EasingDirection.Out, 0, false, 0)
	local limitedStock = replacement.LimitedStock

	if p2 and replacement.Replacement then
		replacement = replacement.Replacement
	end

	local v20 = p3 and 0.015 or 0.045
	local v21 = p3 and 3 or 5
	flag = true

	if not limitedStock then
		WinterRoyaleLobbyCrate:DefaultSecret()
	end

	for i = 1, v21 do
		for i2 = 1, count do
			for _, v22 in v17 do
				TweenService:Create(
					v22:FindFirstChild("Selected"),
					tweenInfo or TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
					{
						ImageTransparency = 1
					}
				):Play()
				local selected_2 = v22:FindFirstChild("Selected")
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
					v17[i2]:FindFirstChild("Selected"),
					tweenInfo or TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
					{
						ImageTransparency = 0
					}
				):Play()
			end

			if i == v21 and i2 == p then
				break
			end

			local clone = halloweenGacha.bink:Clone()
			clone.Parent = playerGui
			clone.Volume = clone.Volume or 0.34
			clone:Play()
			task.delay(clone.TimeLength + 0.1, function()
				clone:Destroy()
			end)
			task.wait(v20)
			v20 = math.min(v20 * 1.015, 0.1)
		end
	end

	if (replacement.Replacement or p2) and not limitedStock then
		local lastTime = tick()
		v4.Sounds:Play("SecretOpened")
		local v22 = 0.8
		local v23 = 9

		while tick() - lastTime < v22 do
			local v24 = v23 * (1 - (tick() - lastTime) / 0.8)
			local number = Random.new():NextNumber(-v24, v24)
			local number2 = Random.new():NextNumber(-v24, v24)
			secret2.Position = UDim2.new(0.5, number, 0.5, number2)
			task.wait()
		end

		secret2.Position = UDim2.new(0.5, 0, 0.5, 0)
		item.Image = replacement.Reward.Icon or ""
		glow.Visible = true
		questionMark.Visible = false
		desc2.Text = replacement.Reward.DisplayName
		v14:FireServer()
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
		v14:FireServer()
	end

	task.wait(0.5)

	if limitedStock then
		WinterRoyaleLobbyCrate:DefaultSecret()
	end

	flag = false
	local v22 = v12:Get(v11.TicketName) or 0

	if p3 and count2 < 9 and v22 > 0 then
		count2 += 1
		v13:FireServer(true)
	end
end

local rotation = 0
local thread = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function stopIdle()
	if thread then
		task.cancel(thread)
		thread = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playIdle()
	stopIdle() -- equivalent call inferred; original call site unknown
	thread = task.spawn(function()
		while true do
			local v21 = RunService.PreRender:Wait()
			rotation += v21 * 30
			rotation %= 360

			if items then
				items.Rotation = rotation
			end
		end
	end)
end

function WinterRoyaleLobbyCrate.SpinWheel(p, _, p2)
	if flag then
		return
	end

	local _ = v7.RewardPool[p]
	TweenInfo.new(0.15, Enum.EasingStyle.Circular, Enum.EasingDirection.Out, 0, false, 0)
	local v21 = p2 and 4 or 10
	flag = true
	local v22 = (p - 1) * 360 / 8 + 22.5 + 5400
	local v23 = rotation
	local v24 = v22 - v23
	local v25 = 0
	local v26 = 0
	local now = 0
	task.delay(2 / v21, function()
		v4.Sounds:Play("ChristmasLTMSpin_Start", nil, {
			PlaybackSpeed = 9 / v21
		})
	end)
	stopIdle() -- equivalent call inferred; original call site unknown
	local lastTime = tick()
	local v27 = 0

	while true do
		RunService.PostSimulation:Wait()
		local v28 = math.min((tick() - lastTime) / v21, 1)
		rotation = v23 + v24 * (1 - 2 ^ (v28 * -10))
		rotation %= 360
		items.Rotation = rotation
		v16.Rotation = v27 + (v16.Rotation - v27) * 0.5
		local v29 = rotation // 45

		if v29 ~= v26 and os.clock() - now > 0.1 then
			now = os.clock()
			v26 = v29
		end

		if v25 ~= v29 then
			v27 += (1 - v28) * 12.5 + 12.5
			v25 = v29
		end

		v27 = math.min(v27 * 0.7, 25)

		if not (v28 >= 1) then
			continue
		end

		v4.Sounds:Play("ChristmasLTMSpin_Reward")
		v14:FireServer()
		task.wait(1)
		flag = false
		playIdle() -- equivalent call inferred; original call site unknown
		local v30 = v12:Get(v11.TicketName) or 0

		if p2 and count2 < 9 and v30 > 0 then
			count2 += 1
			v13:FireServer(true)
		end

		break
	end
end

function WinterRoyaleLobbyCrate.Spin(p, p2, p3)
	return WinterRoyaleLobbyCrate.SpinCrate(p, p2, p3)
end

function WinterRoyaleLobbyCrate:SetupStreaks()
	if not (v7.DailyLoginStreaks and v11.ClaimedStreaks) then
		return
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function GetStreakData(p)
		for _, dailyLoginStreak in v7.DailyLoginStreaks do
			if dailyLoginStreak.Streak == p then
				return dailyLoginStreak
			end
		end

		return {
			Streak = 0,
			Tickets = 0
		}
	end

	local updatesByName = {}

	for k, v22 in {
		["1"] = list:FindFirstChild("1"),
		["2"] = list:FindFirstChild("2"),
		["3"] = list:FindFirstChild("3"),
		["4"] = list:FindFirstChild("4")
	} do
		local button = v22:FindFirstChild("Button") or v22
		local v24 = v22
		local v25 = k

		local function update()
			local count3 = button.Count
			local v26 = v12:Get({ v11.ClaimedStreaks, (`Day{v24.Name}`) })
			local streakData = GetStreakData(tonumber(v25)) -- equivalent call inferred; original call site unknown
			v24.Days.Label.Text = `Day {streakData.Streak}`
			local tickets = streakData.Tickets
			count3.Text = `+{tickets}`
			count3.Visible = true

			if v26 then
				v24.ImageColor3 = Color3.new(0.9, 0.9, 0.9)
				v24.Claimed.Visible = true
			else
				local v29 = v12:Get(v11.LoginStreak) or 0
				v24.ImageColor3 = Color3.new(1, 1, 1)
				v24.Claimed.Visible = false

				if button ~= v24 then
					button.Visible = true
				end

				if tonumber(v25) <= v29 then
					count3.Text = `+{tickets} (Click to claim)`
					v24:SetAttribute("CanClaim", true)
				else
					v24:SetAttribute("CanClaim", nil)
				end
			end
		end

		local v26 = v22
		button.Activated:Connect(function()
			if v12:Get({ v11.ClaimedStreaks, (`Day{v26.Name}`) }) or not v26:GetAttribute("CanClaim") then
				return
			end

			v4.Sounds:Play("LTMSpin_ClaimSpins")
			v15:FireServer((tonumber(v26.Name)))
		end)
		update()
		updatesByName[v22.Name] = update
		v12:OnChange(v11.ClaimedStreaks, update)
	end

	local function updateStreaks()
		label2.Text = `{v12:Get(v11.LoginStreak)} Days`

		for _, v22 in updatesByName do
			v22()
		end
	end

	v12:OnChange(v11.LastLoginStreak, updateStreaks)
	v12:OnChange(v11.LoginStreak, updateStreaks)
	v12:OnChange(v11.ClaimedStreaks, updateStreaks)
	task.spawn(updateStreaks)
end

function WinterRoyaleLobbyCrate.UpdateSpins()
	if not v11.TicketName then
		return
	end

	local v21 = v12:Get(v11.TicketName) or 0
	amount.Text = v4.ValueConvertor:AddCommas(v21)
	WinterRoyaleLobbyCrate.BalanceText = amount.Text
	WinterRoyaleLobbyCrate.BalanceTextChanged:Fire(WinterRoyaleLobbyCrate.BalanceText)
end

function WinterRoyaleLobbyCrate.Init(_) end

function WinterRoyaleLobbyCrate:Start()
	v12 = v2.Client:WaitReplion("Data")
	v13 = v3:RemoteEvent("ProcessLTMRoll")
	v14 = v3:RemoteEvent("ClaimLTMReward")
	v15 = v3:RemoteEvent("ClaimLTMStreak")
	playerGui = localPlayer:WaitForChild("PlayerGui")
	lTMCrate = playerGui:WaitForChild("LTMCrate")
	crates = lTMCrate:WaitForChild("Crates")
	left = crates:WaitForChild("Left")
	right = crates:WaitForChild("Right")
	items = left:WaitForChild("Items")
	odds = left:WaitForChild("Odds")
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
	desc1 = secret2:WaitForChild("Desc1")
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
	v17[1] = leftList:WaitForChild("Crate1")
	v17[2] = leftList:WaitForChild("Crate2")
	v17[3] = leftList:WaitForChild("Crate3")
	v17[4] = leftList:WaitForChild("Crate4")
	v17[5] = rightList:WaitForChild("Crate5")
	v17[6] = rightList:WaitForChild("Crate6")
	v17[7] = rightList:WaitForChild("Crate7")
	v17[8] = rightList:WaitForChild("Crate8")

	if RunService:IsStudio() then
		v.InputBegan:Connect(function(input, gameProcessed)
			if input.KeyCode == Enum.KeyCode.J and not gameProcessed and (localPlayer.UserId == 33836554 or localPlayer.UserId == 813163219) then
				v5:Open("LTMCrate")
			end
		end)
	end

	close.MouseButton1Click:Connect(function()
		v5:Close("LTMCrate")
	end)
	workspace.Alive.ChildAdded:Connect(function(child)
		if child.Name == localPlayer.Name and v5:IsOpen("LTMCrate") then
			v5:Close("LTMCrate")
		end
	end)
	v5:OnGuiOpen("LTMCrate", function()
		v9(Enum.CoreGuiType.PlayerList, false)
	end)
	v5:OnGuiClose("LTMCrate", function()
		v9(Enum.CoreGuiType.PlayerList, true)
	end)
	add.MouseButton1Click:Connect(function()
		v5:Open("LTMTickets")
	end)
	spin1.MouseButton1Click:Connect(function()
		if flag then
			return
		end

		count2 = 0
		v13:FireServer()
	end)
	spin10.MouseButton1Click:Connect(function()
		if flag or (v12:Get(v11.TicketName) or 0) < 10 then
			return
		end

		count2 = 0
		v13:FireServer(true)
	end)

	if odds then
		odds.MouseButton1Click:Connect(function()
			self.ToggleChances()
		end)
	end

	v13.OnClientEvent:Connect(WinterRoyaleLobbyCrate.Spin)
	v12:OnChange(v11.TicketName, WinterRoyaleLobbyCrate.UpdateSpins)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function ReflectPolicy()
		local policyInfo = v6:GetPolicyInfo()
		add.Visible = not policyInfo.ArePaidRandomItemsRestricted
	end

	ReflectPolicy() -- equivalent call inferred; original call site unknown
	v6.PolicyInfoAdded:Connect(ReflectPolicy)

	local function UpdateDailyStreakTime()
		if not v11.LastLoginStreak then
			return
		end

		local v21 = v12:Get(v11.LastLoginStreak)

		if not v21 then
			dayCount.Label.Text = "Something went wrong!"
			return
		end

		local v22 = math.clamp(v21 + 86400 - workspace:GetServerTimeNow(), 0, 1e999)
		dayCount.Label.Text = `Next rewards: {v4.ValueConvertor:FormatTimeHHMMSS(v22)}`
	end

	local v21 = v11.getGameMode() == "Storm" and 5 or 1
	v4.Thread.Every(v21, function()
		local dateTime = DateTime.fromUnixTimestamp(workspace:GetServerTimeNow())
		local formatTimeWithDaysFull = v4.ValueConvertor:FormatTimeWithDaysFull(v7.TimeLength.UnixTimestamp - dateTime.UnixTimestamp)
		timer.Text = formatTimeWithDaysFull
		UpdateDailyStreakTime()
	end)
	self:LoadItems()
	self.UpdateSpins()
	self:SetupStreaks()
	self.ToggleChances(false)
end

return WinterRoyaleLobbyCrate