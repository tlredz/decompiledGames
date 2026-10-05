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
local v10 = require3(ReplicatedStorage3.Controllers.Trading.IndexController)
local v11 = require3(ReplicatedStorage3.Shared.Statable)
local v12 = ReplicatedStorage3.Shared.LTM.GetLTM:Invoke("LavaFloor")
local v13 = v2.Client:WaitReplion("LimitedStockItems")
local v14 = nil
local v15 = nil
local v16 = nil
local v17 = nil
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
local v18 = nil
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
local v19 = {}
local count = 0
local count2 = 0
local halloweenGacha = ReplicatedStorage3.Assets.UI.HalloweenGacha
local LavaFloorLobbyCrate = {
	BalanceText = "",
	BalanceTextChanged = v8.new()
}
local v20 = nil

function LavaFloorLobbyCrate:DefaultSecret()
	if v20 then
		v20:Destroy()
		v20 = nil
	end

	local v21 = v7.RewardPool[count]

	if v21 and v21.LimitedStock then
		local formatted = `Received{v12.Id}LTM{v21.Reward.Value}{v21.Reward.Type}`
		local v22

		if v14 then
			v22 = v14:Get(formatted) and true or false
		else
			v22 = false
		end

		local reward = v21.Reward
		local v23 = not v22 and v21.Replacement and v13:Get("Loaded") and (v13:Get({ "Stock", reward.Value }) or 0) <= 0 and true or v22

		if v23 and v21.Replacement then
			reward = v21.Replacement.Reward
		end

		if reward then
			glow.Visible = true
			selected.Visible = false
			questionMark.Visible = false

			if v23 then
				desc1.Text = ""
			else
				v20 = v11.setPropertyComputed(desc1, "Text", function(callback)
					local v24 = callback((v11.getReplionPathState(v13, "Loaded"))) and callback((v11.getReplionPathState(
						v13,
						{ "Stock", reward.Value }
					))) or 0

					if v24 <= 0 and v13:Get("Loaded") then
						task.delay(0, function()
							self:DefaultSecret()
						end)
					end

					return (`{v4.ValueConvertor:AddCommas(v24)} LEFT`)
				end)
			end

			desc2.Text = reward.Value
			item.Image = reward.Icon or v4.Icons:GetIcon("DEFAULT_MISSING")
		end
	elseif v21 and v21.Reward then
		glow.Visible = true
		selected.Visible = false
		questionMark.Visible = false
		desc1.Text = "SECRET"
		desc2.Text = v21.Reward.Value
		item.Image = v21.Reward.Icon or v4.Icons:GetIcon("DEFAULT_MISSING")
	else
		glow.Visible = false
		selected.Visible = false
		questionMark.Visible = true
		desc1.Text = "SECRET"
		desc2.Text = "Sword/Explosion"
		item.Image = "rbxassetid://16456337904"
	end
end

function LavaFloorLobbyCrate:LoadItems()
	for k, v21 in v7.RewardPool do
		local v22 = v19[k]

		if not v22 then
			continue
		end

		local reward = v21.Reward
		v22.Vector.Image = reward.Icon or ""
		v22.Title.Text = reward.DisplayName
		v22.Label.Text = `{v21.Probability}%`
		local selected = v22:FindFirstChild("Selected")
		selected.Visible = false
		local inspect = v22:FindFirstChild("Inspect")

		if inspect then
			local reward2 = reward
			inspect.Activated:Connect(function()
				v10:Preview(reward2.Type, reward2.Value)
			end)
		end

		count += 1
	end

	count += 1
	label.Text = `{v7.RewardPool[count].Probability}%`
	self:DefaultSecret()
	local v21 = v7.RewardPool[count]
	local inspect = secret2:FindFirstChild("Inspect")

	if inspect and v21 then
		inspect.Activated:Connect(function()
			local reward = v21.Reward
			local formatted = `Received{v12.Id}LTM{v21.Reward.Value}{v21.Reward.Type}`
			local v22

			if v14 then
				v22 = v14:Get(formatted) and true or false
			else
				v22 = false
			end

			if (not v22 and v21.Replacement and v13:Get("Loaded") and (v13:Get({ "Stock", reward.Value }) or 0) <= 0 or v22) and v21.Replacement then
				reward = v21.Replacement.Reward
			end

			v10:Preview(reward.Type, reward.Value)
		end)
	end
end

function LavaFloorLobbyCrate.ToggleChances(visible: boolean?)
	for _, v21 in v19 do
		local label3 = v21.Label
		local visible2

		if visible == nil then
			visible2 = not v21.Label.Visible
		else
			visible2 = visible
		end

		label3.Visible = visible2
	end

	local v21 = label

	if visible == nil then
		visible = not label.Visible
	end

	v21.Visible = visible
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

function LavaFloorLobbyCrate.SpinCrate(p, p2, p3)
	if flag then
		return
	end

	local replacement = v7.RewardPool[p]
	local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Circular, Enum.EasingDirection.Out, 0, false, 0)
	local limitedStock = replacement.LimitedStock

	if p2 and replacement.Replacement then
		replacement = replacement.Replacement
	end

	local v21 = p3 and 0.015 or 0.045
	local v22 = p3 and 3 or 5
	flag = true

	if not limitedStock then
		LavaFloorLobbyCrate:DefaultSecret()
	end

	for i = 1, v22 do
		for i2 = 1, count do
			for _, v23 in v19 do
				TweenService:Create(
					v23:FindFirstChild("Selected"),
					tweenInfo or TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
					{
						ImageTransparency = 1
					}
				):Play()
				local selected_2 = v23:FindFirstChild("Selected")
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
					v19[i2]:FindFirstChild("Selected"),
					tweenInfo or TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
					{
						ImageTransparency = 0
					}
				):Play()
			end

			if i == v22 and i2 == p then
				break
			end

			local clone = halloweenGacha.bink:Clone()
			clone.Parent = playerGui
			clone.Volume = clone.Volume or 0.34
			clone:Play()
			task.delay(clone.TimeLength + 0.1, function()
				clone:Destroy()
			end)
			task.wait(v21)
			v21 = math.min(v21 * 1.015, 0.1)
		end
	end

	if (replacement.Replacement or p2) and not limitedStock then
		local lastTime = tick()
		v4.Sounds:Play("SecretOpened")
		local v23 = 0.8
		local v24 = 9

		while tick() - lastTime < v23 do
			local v25 = v24 * (1 - (tick() - lastTime) / 0.8)
			local number = Random.new():NextNumber(-v25, v25)
			local number2 = Random.new():NextNumber(-v25, v25)
			secret2.Position = UDim2.new(0.5, number, 0.5, number2)
			task.wait()
		end

		secret2.Position = UDim2.new(0.5, 0, 0.5, 0)
		item.Image = replacement.Reward.Icon or ""
		glow.Visible = true
		questionMark.Visible = false
		desc2.Text = replacement.Reward.DisplayName
		v16:FireServer()
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
		v16:FireServer()
	end

	task.wait(0.5)

	if limitedStock then
		LavaFloorLobbyCrate:DefaultSecret()
	end

	flag = false
	local v23 = v14:Get(v12.TicketName) or 0

	if p3 and count2 < 9 and v23 > 0 then
		count2 += 1
		v15:FireServer(true)
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
			local v22 = RunService.PreRender:Wait()
			rotation += v22 * 30
			rotation %= 360

			if items then
				items.Rotation = rotation
			end
		end
	end)
end

function LavaFloorLobbyCrate.SpinWheel(p, _, p2)
	if flag then
		return
	end

	local _ = v7.RewardPool[p]
	TweenInfo.new(0.15, Enum.EasingStyle.Circular, Enum.EasingDirection.Out, 0, false, 0)
	local v22 = p2 and 4 or 10
	flag = true
	local v23 = (p - 1) * 360 / 8 + 22.5 + 5400
	local v24 = rotation
	local v25 = v23 - v24
	local v26 = 0
	local v27 = 0
	local now = 0
	task.delay(2 / v22, function()
		v4.Sounds:Play("ChristmasLTMSpin_Start", nil, {
			PlaybackSpeed = 9 / v22
		})
	end)
	stopIdle() -- equivalent call inferred; original call site unknown
	local lastTime = tick()
	local v28 = 0

	while true do
		RunService.PostSimulation:Wait()
		local v29 = math.min((tick() - lastTime) / v22, 1)
		rotation = v24 + v25 * (1 - 2 ^ (v29 * -10))
		rotation %= 360
		items.Rotation = rotation
		v18.Rotation = v28 + (v18.Rotation - v28) * 0.5
		local v30 = rotation // 45

		if v30 ~= v27 and os.clock() - now > 0.1 then
			now = os.clock()
			v27 = v30
		end

		if v26 ~= v30 then
			v28 += (1 - v29) * 12.5 + 12.5
			v26 = v30
		end

		v28 = math.min(v28 * 0.7, 25)

		if not (v29 >= 1) then
			continue
		end

		v4.Sounds:Play("ChristmasLTMSpin_Reward")
		v16:FireServer()
		task.wait(1)
		flag = false
		playIdle() -- equivalent call inferred; original call site unknown
		local v31 = v14:Get(v12.TicketName) or 0

		if p2 and count2 < 9 and v31 > 0 then
			count2 += 1
			v15:FireServer(true)
		end

		break
	end
end

function LavaFloorLobbyCrate.Spin(p, p2, p3)
	return LavaFloorLobbyCrate.SpinCrate(p, p2, p3)
end

function LavaFloorLobbyCrate:SetupStreaks()
	local v22 = {
		["1"] = list:FindFirstChild("1"),
		["2"] = list:FindFirstChild("2"),
		["3"] = list:FindFirstChild("3"),
		["4"] = list:FindFirstChild("4")
	}

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

	if v12.LoginStreak and v12.ClaimedStreaks and v12.LastLoginStreak then
		local updatesByName = {}

		for k, v23 in v22 do
			local button = v23:FindFirstChild("Button") or v23
			local v25 = v23
			local v26 = k

			local function update()
				local label3 = button.Label
				local v27 = v14:Get({ v12.ClaimedStreaks, (`Day{v25.Name}`) })
				local streakData = GetStreakData(tonumber(v26)) -- equivalent call inferred; original call site unknown
				v25.Days.Label.Text = `Day {streakData.Streak}`
				local tickets = streakData.Tickets
				label3.Text = `+{tickets} Ticket{tickets <= 1 and "" or "s"}`
				label3.Visible = true

				if v27 then
					v25.ImageColor3 = Color3.new(0.9, 0.9, 0.9)
					v25.Claimed.Visible = true
				else
					local v30 = v14:Get(v12.LoginStreak) or 0
					v25.ImageColor3 = Color3.new(1, 1, 1)
					v25.Claimed.Visible = false

					if button ~= v25 then
						button.Visible = true
					end

					if tonumber(v26) <= v30 then
						label3.Text = `+{tickets} (Click to claim)`
						v25:SetAttribute("CanClaim", true)
					else
						v25:SetAttribute("CanClaim", nil)
					end
				end
			end

			local v27 = v23
			button.Activated:Connect(function()
				if v14:Get({ v12.ClaimedStreaks, (`Day{v27.Name}`) }) or not v27:GetAttribute("CanClaim") then
					return
				end

				v4.Sounds:Play("LTMSpin_ClaimSpins")
				v17:FireServer((tonumber(v27.Name)))
			end)
			update()
			updatesByName[v23.Name] = update
			v14:OnChange(v12.ClaimedStreaks, update)
		end

		local function updateStreaks()
			label2.Text = `{v14:Get(v12.LoginStreak)} Days`

			for _, v23 in updatesByName do
				v23()
			end
		end

		v14:OnChange(v12.LastLoginStreak, updateStreaks)
		v14:OnChange(v12.LoginStreak, updateStreaks)
		v14:OnChange(v12.ClaimedStreaks, updateStreaks)
		task.spawn(updateStreaks)
	end
end

function LavaFloorLobbyCrate.UpdateSpins()
	local v22 = v14:Get(v12.TicketName) or 0
	amount.Text = v4.ValueConvertor:AddCommas(v22)
	LavaFloorLobbyCrate.BalanceText = amount.Text
	LavaFloorLobbyCrate.BalanceTextChanged:Fire(LavaFloorLobbyCrate.BalanceText)
end

function LavaFloorLobbyCrate.Init(_) end

function LavaFloorLobbyCrate:Start()
	v14 = v2.Client:WaitReplion("Data")
	v15 = v3:RemoteEvent("ProcessLTMRoll")
	v16 = v3:RemoteEvent("ClaimLTMReward")
	v17 = v3:RemoteEvent("ClaimLTMStreak")
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
	v19[1] = leftList:WaitForChild("Crate1")
	v19[2] = leftList:WaitForChild("Crate2")
	v19[3] = leftList:WaitForChild("Crate3")
	v19[4] = leftList:WaitForChild("Crate4")
	v19[5] = rightList:WaitForChild("Crate5")
	v19[6] = rightList:WaitForChild("Crate6")
	v19[7] = rightList:WaitForChild("Crate7")
	v19[8] = rightList:WaitForChild("Crate8")

	if RunService:IsStudio() then
		v.InputBegan:Connect(function(input, gameProcessed)
			if input.KeyCode == Enum.KeyCode.J and not gameProcessed and localPlayer.UserId == 33836554 then
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
		v15:FireServer()
	end)
	spin10.MouseButton1Click:Connect(function()
		if flag or (v14:Get(v12.TicketName) or 0) < 10 then
			return
		end

		count2 = 0
		v15:FireServer(true)
	end)

	if odds then
		odds.MouseButton1Click:Connect(function()
			self.ToggleChances()
		end)
	end

	v15.OnClientEvent:Connect(LavaFloorLobbyCrate.Spin)
	v14:OnChange(v12.TicketName, LavaFloorLobbyCrate.UpdateSpins)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function ReflectPolicy()
		local policyInfo = v6:GetPolicyInfo()
		add.Visible = not policyInfo.ArePaidRandomItemsRestricted
	end

	ReflectPolicy() -- equivalent call inferred; original call site unknown
	v6.PolicyInfoAdded:Connect(ReflectPolicy)

	local function UpdateDailyStreakTime()
		local v22 = v14:Get(v12.LastLoginStreak)

		if not v22 then
			dayCount.Label.Text = "Something went wrong!"
			return
		end

		local v23 = math.clamp(v22 + 86400 - workspace:GetServerTimeNow(), 0, 1e999)
		dayCount.Label.Text = `Next rewards: {v4.ValueConvertor:FormatTimeHHMMSS(v23)}`
	end

	local v22 = v12.getGameMode() == "Storm" and 5 or 1
	v4.Thread.Every(v22, function()
		local dateTime = DateTime.fromUnixTimestamp(workspace:GetServerTimeNow())
		local formatTimeWithDaysFull = v4.ValueConvertor:FormatTimeWithDaysFull(v7.TimeLength.UnixTimestamp - dateTime.UnixTimestamp)
		timer.Text = `{formatTimeWithDaysFull}`
		UpdateDailyStreakTime()
	end)
	self:LoadItems()
	self.UpdateSpins()
	self:SetupStreaks()
	self.ToggleChances(false)
end

return LavaFloorLobbyCrate