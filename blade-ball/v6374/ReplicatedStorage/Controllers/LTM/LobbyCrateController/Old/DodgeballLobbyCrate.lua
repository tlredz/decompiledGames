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

if require3(ReplicatedStorage3.ServerInfo).isLTMServer() then
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
local v12 = ReplicatedStorage3.Shared.LTM.GetLTM:Invoke("Dodgeball")
local v13 = v2.Client:WaitReplion("LimitedStockItems")
local v14 = nil
local v15 = nil
local v16 = nil
local v17 = nil
local localPlayer = Players.LocalPlayer
local playerGui = nil
local dodgeballLobbyCrate = nil
local crates = nil
local left = nil
local right = nil
local v18 = nil
local items = nil
local spinButtons = nil
local spin1 = nil
local spin10 = nil
local spinner = nil
local v19 = nil
local v20 = nil
local v21 = nil
local v22 = nil
local v23 = nil
local v24 = nil
local v25 = nil
local main = nil
local currency = nil
local add = nil
local amount = nil
local dayCount = nil
local label = nil
local list = nil
local timer = nil
local close = nil
local flag = false
local v26 = {}
local count = 0
local count2 = 0
local halloweenGacha = ReplicatedStorage3.Assets.UI.HalloweenGacha
local DodgeballLobbyCrate = {
	BalanceText = "",
	BalanceTextChanged = v8.new()
}
local v27 = nil
local activatedConnection = nil

function DodgeballLobbyCrate:DefaultSecret()
	if v27 then
		v27:Destroy()
		v27 = nil
	end

	local v28 = v7.RewardPool[count]

	if v28 and v28.LimitedStock then
		local formatted = `Received{v12.Id}LTM{v28.Reward.Value}{v28.Reward.Type}`
		local v29

		if v14 and v28.Replacement then
			v29 = v14:Get(formatted) and true or false
		else
			v29 = false
		end

		local reward = v28.Reward
		local v30 = not v29 and v28.Replacement and v13:Get("Loaded") and (v13:Get({ "Stock", reward.Value }) or 0) <= 0 and true or v29

		if v30 and v28.Replacement then
			reward = v28.Replacement.Reward
		end

		if reward then
			v20.Visible = true
			v22.Visible = false
			v23.Visible = false

			if v30 then
				v24.Text = ""
			else
				v27 = v11.setPropertyComputed(v24, "Text", function(callback)
					local v31 = not callback((v11.getReplionPathState(v13, "Loaded"))) and 0 or callback((v11.getReplionPathState(
						v13,
						{ "Stock", reward.Value }
					))) or 0
					local v32 = callback((v11.getReplionPathState(v13, { "InitialStock", reward.Value }))) or v31

					if v31 <= 0 and v13:Get("Loaded") then
						task.delay(0, function()
							self:DefaultSecret()
						end)
					end

					return (`{v4.ValueConvertor:AddCommas(v31)}/{v4.ValueConvertor:ShrinkNumber(v32)} LEFT`)
				end)
			end

			v25.Text = reward.Value
			v21.Image = reward.Icon or v4.Icons:GetIcon("DEFAULT_MISSING")
			local inspect = v19:FindFirstChild("Inspect")

			if inspect then
				if activatedConnection and activatedConnection.Connected then
					activatedConnection:Disconnect()
				end

				activatedConnection = inspect.Activated:Connect(function()
					v10:Preview(reward.Type, reward.Value)
				end)
			end
		end
	else
		v20.Visible = false
		v22.Visible = false
		v23.Visible = true
		v24.Text = "SECRET"
		v25.Text = "Sword/Explosion"
		v21.Image = "rbxassetid://16456337904"
	end

	self:UpdateProbability()
end

function DodgeballLobbyCrate:UpdateProbability()
	local clone = table.clone(v7.RewardPool)

	for i = #clone, 1, -1 do
		local v28 = clone[i]

		if not v28.LimitedStock or v28.Replacement then
			continue
		end

		local formatted = `Received{v12.Id}LTM{v28.Reward.Value}{v28.Reward.Type}`
		local v29 = v13:Get("Loaded") and v13:Get({ "Stock", v28.Reward.Value })

		if not (not v29 or v29 <= 0 or v14 and v14:Get(formatted)) then
			continue
		end

		clone[1].Probability += v28.Probability
		v28.Probability = 0
	end

	for k, v28 in clone do
		local v29 = v26[k]

		if not v29 then
			continue
		end

		local formatted = `{v28.Probability}%`
		v29.Amount.Text = formatted
	end
end

function DodgeballLobbyCrate:LoadItems()
	for k, v28 in v7.RewardPool do
		local v29 = v26[k]

		if not v29 then
			continue
		end

		local reward = v28.Reward
		v29.Image = reward.Icon or ""
		local inspect = v29:FindFirstChild("Inspect")

		if inspect then
			local reward2 = reward
			inspect.Activated:Connect(function()
				v10:Preview(reward2.Type, reward2.Value)
			end)
		end

		count += 1
	end

	self:UpdateProbability()
end

function DodgeballLobbyCrate.ToggleChances(_: boolean?) end

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

function DodgeballLobbyCrate.SpinCrate(p, p2, p3)
	if flag then
		return
	end

	local replacement = v7.RewardPool[p]
	local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Circular, Enum.EasingDirection.Out, 0, false, 0)
	local limitedStock = replacement.LimitedStock

	if p2 and replacement.Replacement then
		replacement = replacement.Replacement
	end

	local v28 = p3 and 0.015 or 0.045
	local v29 = p3 and 3 or 5
	flag = true

	if not limitedStock then
		DodgeballLobbyCrate:DefaultSecret()
	end

	for i = 1, v29 do
		for i2 = 1, count do
			for _, v30 in v26 do
				TweenService:Create(
					v30:FindFirstChild("Selected"),
					tweenInfo or TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
					{
						ImageTransparency = 1
					}
				):Play()
				local selected = v30:FindFirstChild("Selected")
				selected.Visible = true
			end

			v22.Visible = true
			TweenService:Create(
				v22,
				tweenInfo or TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					ImageTransparency = 1
				}
			):Play()

			if count <= i2 then
				TweenService:Create(
					v22,
					tweenInfo or TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
					{
						ImageTransparency = 0
					}
				):Play()
			else
				TweenService:Create(
					v26[i2]:FindFirstChild("Selected"),
					tweenInfo or TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
					{
						ImageTransparency = 0
					}
				):Play()
			end

			if i == v29 and i2 == p then
				break
			end

			local clone = halloweenGacha.bink:Clone()
			clone.Parent = playerGui
			clone.Volume = clone.Volume or 0.34
			clone:Play()
			task.delay(clone.TimeLength + 0.1, function()
				clone:Destroy()
			end)
			task.wait(v28)
			v28 = math.min(v28 * 1.015, 0.1)
		end
	end

	if (replacement.Replacement or p2) and not limitedStock then
		local lastTime = tick()
		v4.Sounds:Play("SecretOpened")
		local v30 = 0.8
		local v31 = 9

		while tick() - lastTime < v30 do
			local v32 = v31 * (1 - (tick() - lastTime) / 0.8)
			local number = Random.new():NextNumber(-v32, v32)
			local number2 = Random.new():NextNumber(-v32, v32)
			v19.Position = UDim2.new(0.5, number, 0.5, number2)
			task.wait()
		end

		v19.Position = UDim2.new(0.5, 0, 0.5, 0)
		v21.Image = replacement.Reward.Icon or ""
		v20.Visible = true
		v23.Visible = false
		v25.Text = replacement.Reward.DisplayName
		v16:FireServer()
		local clone = halloweenGacha.reward:Clone()
		clone.Volume = 0.34
		clone.Parent = playerGui
		clone:Play()
		local clone2 = v19:Clone()
		clone2.Parent = v19.Parent

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
		DodgeballLobbyCrate:DefaultSecret()
	end

	flag = false
	local v30 = v14:Get(v12.TicketName) or 0

	if p3 and count2 < 9 and v30 > 0 then
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
			local v29 = RunService.PreRender:Wait()
			rotation += v29 * 30
			rotation %= 360

			if items then
				items.Rotation = rotation
			end
		end
	end)
end

stopIdle() -- equivalent call inferred; original call site unknown
thread = task.spawn(function()
	while true do
		local v29 = RunService.PreRender:Wait()
		rotation += v29 * 30
		rotation %= 360

		if items then
			items.Rotation = rotation
		end
	end
end)

function DodgeballLobbyCrate.SpinWheel(p, _, p2)
	if flag then
		return
	end

	local _ = v7.RewardPool[p]
	TweenInfo.new(0.15, Enum.EasingStyle.Circular, Enum.EasingDirection.Out, 0, false, 0)
	local v29 = p2 and 4 or 10
	flag = true
	local v30 = (p - 1) * 360 / 8 + 22.5 + 5400
	local v31 = rotation
	local v32 = v30 - v31
	local v33 = 0
	local v34 = 0
	local now = 0
	task.delay(2 / v29, function()
		v4.Sounds:Play("ChristmasLTMSpin_Start", nil, {
			PlaybackSpeed = 9 / v29
		})
	end)
	stopIdle() -- equivalent call inferred; original call site unknown
	local lastTime = tick()
	local v35 = 0

	while true do
		RunService.PostSimulation:Wait()
		local v36 = math.min((tick() - lastTime) / v29, 1)
		rotation = v31 + v32 * (1 - 2 ^ (v36 * -10))
		rotation %= 360
		items.Rotation = rotation
		spinner.Rotation = v35 + (spinner.Rotation - v35) * 0.5
		local v37 = rotation // 45

		if v37 ~= v34 and os.clock() - now > 0.1 then
			now = os.clock()
			v34 = v37
		end

		if v33 ~= v37 then
			v35 += (1 - v36) * 12.5 + 12.5
			v33 = v37
		end

		v35 = math.min(v35 * 0.7, 25)

		if not (v36 >= 1) then
			continue
		end

		v4.Sounds:Play("ChristmasLTMSpin_Reward")
		v16:FireServer()
		task.wait(1)
		flag = false
		playIdle() -- equivalent call inferred; original call site unknown
		local v38 = v14:Get(v12.TicketName) or 0

		if p2 and count2 < 9 and v38 > 0 then
			count2 += 1
			v15:FireServer(true)
		end

		break
	end
end

function DodgeballLobbyCrate.Spin(p, p2, p3)
	return DodgeballLobbyCrate.SpinWheel(p, p2, p3)
end

function DodgeballLobbyCrate:SetupStreaks()
	local v29 = {
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

		for k, v30 in v29 do
			local button = v30:FindFirstChild("Button") or v30
			local v32 = v30
			local v33 = k

			local function update()
				local label2 = button.Label
				local v34 = v14:Get({ v12.ClaimedStreaks, (`Day{v32.Name}`) })
				local streakData = GetStreakData(tonumber(v33)) -- equivalent call inferred; original call site unknown
				v32.Days.Label.Text = `Day {streakData.Streak}`
				local tickets = streakData.Tickets
				label2.Text = `+{tickets} Ticket{tickets <= 1 and "" or "s"}`
				label2.Visible = true

				if v34 then
					v32.ImageColor3 = Color3.new(0.9, 0.9, 0.9)
					v32.Claimed.Visible = true
				else
					local v37 = v14:Get(v12.LoginStreak) or 0
					v32.ImageColor3 = Color3.new(1, 1, 1)
					v32.Claimed.Visible = false

					if button ~= v32 then
						button.Visible = true
					end

					if tonumber(v33) <= v37 then
						label2.Text = `+{tickets} (Click to claim)`
						v32:SetAttribute("CanClaim", true)
					else
						v32:SetAttribute("CanClaim", nil)
					end
				end
			end

			local v34 = v30
			button.Activated:Connect(function()
				local v35 = v14:Get({ v12.ClaimedStreaks, (`Day{v34.Name}`) })
				print(v35)

				if v35 or not v34:GetAttribute("CanClaim") then
					return
				end

				v4.Sounds:Play("LTMSpin_ClaimSpins")
				v17:FireServer((tonumber(v34.Name)))
			end)
			update()
			updatesByName[v30.Name] = update
			v14:OnChange(v12.ClaimedStreaks, update)
		end

		local function updateStreaks()
			label.Text = `{v14:Get(v12.LoginStreak)} Days`

			for _, v30 in updatesByName do
				v30()
			end
		end

		v14:OnChange(v12.LastLoginStreak, updateStreaks)
		v14:OnChange(v12.LoginStreak, updateStreaks)
		v14:OnChange(v12.ClaimedStreaks, updateStreaks)
		task.spawn(updateStreaks)
	end
end

function DodgeballLobbyCrate.UpdateSpins()
	local v29 = v14:Get(v12.TicketName) or 0
	amount.Text = v4.ValueConvertor:AddCommas(v29)
	DodgeballLobbyCrate.BalanceText = amount.Text
	DodgeballLobbyCrate.BalanceTextChanged:Fire(DodgeballLobbyCrate.BalanceText)
end

function DodgeballLobbyCrate.Init(_) end

function DodgeballLobbyCrate:Start()
	v14 = v2.Client:WaitReplion("Data")
	v15 = v3:RemoteEvent("ProcessLTMRoll")
	v16 = v3:RemoteEvent("ClaimLTMReward")
	v17 = v3:RemoteEvent("ClaimLTMStreak")
	playerGui = localPlayer:WaitForChild("PlayerGui")
	dodgeballLobbyCrate = playerGui:WaitForChild("DodgeballLobbyCrate")
	crates = dodgeballLobbyCrate:WaitForChild("Crates")
	left = crates:WaitForChild("Left")
	right = crates:WaitForChild("Right")
	items = left:WaitForChild("Items")
	spinButtons = left:WaitForChild("SpinButtons")
	spin1 = spinButtons:WaitForChild("Spin1")
	spin10 = spinButtons:WaitForChild("Spin10")
	spinner = left:WaitForChild("Spinner")
	main = right:WaitForChild("Main")
	currency = right:WaitForChild("Currency")
	add = currency:WaitForChild("Add")
	amount = currency:WaitForChild("List"):WaitForChild("Amount")
	dayCount = main:WaitForChild("DayCount")
	label = dayCount:WaitForChild("DayCount"):WaitForChild("Label")
	list = main:WaitForChild("List")
	timer = main:WaitForChild("Timer")
	close = right:WaitForChild("Close")
	v26[1] = items:WaitForChild("1")
	v26[2] = items:WaitForChild("2")
	v26[3] = items:WaitForChild("3")
	v26[4] = items:WaitForChild("4")
	v26[5] = items:WaitForChild("5")
	v26[6] = items:WaitForChild("6")
	v26[7] = items:WaitForChild("7")
	v26[8] = items:WaitForChild("8")

	if RunService:IsStudio() then
		v.InputBegan:Connect(function(input, gameProcessed)
			if input.KeyCode == Enum.KeyCode.J and not gameProcessed and localPlayer.UserId == 33836554 then
				v5:Open("DodgeballLobbyCrate")
			end
		end)
	end

	close.MouseButton1Click:Connect(function()
		v5:Close("DodgeballLobbyCrate")
	end)
	workspace.Alive.ChildAdded:Connect(function(child)
		if child.Name == localPlayer.Name and v5:IsOpen("DodgeballLobbyCrate") then
			v5:Close("DodgeballLobbyCrate")
		end
	end)
	v5:OnGuiOpen("DodgeballLobbyCrate", function()
		v9(Enum.CoreGuiType.PlayerList, false)
	end)
	v5:OnGuiClose("DodgeballLobbyCrate", function()
		v9(Enum.CoreGuiType.PlayerList, true)
	end)
	add.MouseButton1Click:Connect(function()
		v5:Open("DodgeballLobbyTickets")
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

	if v18 then
		v18.MouseButton1Click:Connect(function()
			self.ToggleChances()
		end)
	end

	v15.OnClientEvent:Connect(DodgeballLobbyCrate.Spin)
	v14:OnChange(v12.TicketName, DodgeballLobbyCrate.UpdateSpins)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function ReflectPolicy()
		local policyInfo = v6:GetPolicyInfo()
		add.Visible = not policyInfo.ArePaidRandomItemsRestricted
	end

	ReflectPolicy() -- equivalent call inferred; original call site unknown
	v6.PolicyInfoAdded:Connect(ReflectPolicy)

	local function UpdateDailyStreakTime()
		local v29 = v14:Get(v12.LastLoginStreak)

		if not v29 then
			dayCount.Label.Text = "Something went wrong!"
			return
		end

		local v30 = math.clamp(v29 + 86400 - workspace:GetServerTimeNow(), 0, 1e999)
		dayCount.Label.Text = `Next rewards: {v4.ValueConvertor:FormatTimeHHMMSS(v30)}`
	end

	local v29 = v12.getGameMode() == "Storm" and 5 or 1
	v4.Thread.Every(v29, function()
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

return DodgeballLobbyCrate