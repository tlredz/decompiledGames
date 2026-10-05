-- failed to load script (decompiled with syntax error):
-- BqVpLaaLITaMtGVhuGZQLPiTo:32: Expected identifier when parsing expression, got `TournamentEvent{

local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
game:GetService("RunService")
game:GetService("TweenService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require3(ReplicatedStorage2:WaitForChild("UserInputService"))
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
game:GetService("StarterGui")
local clientGameModules = ReplicatedStorage3.ClientGameModules
local _ = ReplicatedStorage3.Common
local packages = ReplicatedStorage3.Packages
require3(ReplicatedStorage3.Packages.Replion)
local v = require3(ReplicatedStorage3.Packages.Net)
local v2 = require3(ReplicatedStorage3.Common.Utils)
require3(clientGameModules.GuiHandler)
require3(ReplicatedStorage3.Shared.Policy)
local v3 = require3(ReplicatedStorage3.Shared.FastUtils)
local v4 = require3(ReplicatedStorage3.Shared.TournamentEvent.TournamentEventCrate)
local v5 = require3(ReplicatedStorage3.Shared.TournamentEvent.TournamentEventData)
require3(ReplicatedStorage3.Common.MarketplaceService)
local v6 = require3(packages.Signal)
require3(ReplicatedStorage3.ClientGameModules.CreatePriceLabel)
require3(ReplicatedStorage3.ClientGameModules.CoreCall)
require3(ReplicatedStorage3.Controllers.Trading.TradeTokensController);
`TournamentEvent{v5.TournamentId}Currency`
local v7 = nil
v:RemoteEvent("ProcessTournamentEventRoll")
local remoteEvent = v:RemoteEvent("ClaimTournamentEventStreak")
local playerGui = Players.LocalPlayer.PlayerGui
local tournamentEventCrate = playerGui.TournamentEventCrate
local flag = false
local v8 = {}
local v9 = 0
local v10 = 0
local v11 = v6.new()
local halloweenGacha = ReplicatedStorage3.Assets.UI.HalloweenGacha

-- equivalent calls inferred from this helper; original call sites unknown
local function defaultSecret()
	local secret = tournamentEventCrate.Crates.Left.Items.Secret.Secret
	secret.Glow.Visible = false
	local selected = secret:FindFirstChild("Selected")
	selected.Visible = false
	secret.QuestionMark.Visible = true
	secret.Desc2.Text = "Sword/Explosion"
end

local TournamentEventCrateController = {}

function TournamentEventCrateController.ToggleChances(_, visible: boolean?)
	for _, v12 in v8 do
		local label = v12.Label
		local visible2

		if visible == nil then
			visible2 = not v12.Label.Visible
		else
			visible2 = visible
		end

		label.Visible = visible2
	end

	local label = tournamentEventCrate.Crates.Left.Items.Secret.Secret.Label

	if visible == nil then
		visible = not label.Visible
	end

	label.Visible = visible
end

function TournamentEventCrateController.Spin(_, list)
	while flag do
		task.wait()
	end

	local v12 = #list >= 10
	local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Circular, Enum.EasingDirection.Out, 0, false, 0)
	local v13 = v12 and 3 or 5
	v10 = #list
	v11:Fire()
	flag = true
	v3.fastTween(tournamentEventCrate.Crates.Left.Items.SpinButtons.Spin1, tweenInfo, {
		ImageColor3 = Color3.new(0.6, 0.6, 0.6)
	})
	tournamentEventCrate.Crates.Left.Items.SpinButtons.Spin1:RemoveTag("UI_ButtonHoverAnimation2")
	v3.fastTween(tournamentEventCrate.Crates.Left.Items.SpinButtons.Spin10, tweenInfo, {
		ImageColor3 = Color3.new(0.6, 0.6, 0.6)
	})
	tournamentEventCrate.Crates.Left.Items.SpinButtons.Spin10:RemoveTag("UI_ButtonHoverAnimation2")

	for _, v14 in list do
		v10 -= 1
		v11:Fire()
		local item = v4.Items[v14.Index]

		if v14.Replacement then
			local _ = item.Replacement
		else
			local _ = item.Reward
		end

		local isSecret = item.IsSecret == true
		defaultSecret() -- equivalent call inferred; original call site unknown
		local secret = tournamentEventCrate.Crates.Left.Items.Secret.Secret
		local v15 = v12 and 0.01 or 0.045

		for i = 1, v13 do
			for i2 = 1, v9 do
				for _, v16 in v8 do
					local selected = v16:FindFirstChild("Selected")
					selected.Visible = true
					v3.fastTween(selected, tweenInfo, {
						ImageTransparency = 1
					})
				end

				local selected = secret:FindFirstChild("Selected")
				selected.Visible = true
				v3.fastTween(selected, tweenInfo, {
					ImageTransparency = 1
				})

				if v9 <= i2 then
					v3.fastTween(selected, tweenInfo, {
						ImageTransparency = 0
					})
				else
					v3.fastTween(v8[i2]:FindFirstChild("Selected"), tweenInfo, {
						ImageTransparency = 0
					})
				end

				if i == v13 and i2 == v14.Index then
					break
				end

				local clone = halloweenGacha.bink:Clone()
				clone.Volume = clone.Volume or 0.34
				clone.Parent = playerGui
				clone:Play()
				task.delay(clone.TimeLength + 0.1, function()
					clone:Destroy()
				end)
				task.wait(v15)
				v15 = math.min(v15 * 1.015, 0.1)
			end
		end

		if isSecret then
			v2.Sounds:Play("SecretOpened")
			local lastTime = os.clock()
			local random = Random.new()

			while os.clock() - lastTime < 0.8 do
				local v16 = 9 * (1 - (os.clock() - lastTime) / 0.8)
				local number = random:NextNumber(-v16, v16)
				local number2 = random:NextNumber(-v16, v16)
				secret.Position = UDim2.fromScale(0.5, 0.5) + UDim2.fromOffset(number, number2)
				task.wait()
			end

			secret.Position = UDim2.fromScale(0.5, 0.5)
			secret.Glow.Item.Image = item.Reward.Icon or v2.Icons:GetIcon("DEFAULT_MISSING")
			secret.Glow.Visible = true
			secret.QuestionMark.Visible = false
			secret.Desc2.Text = item.Reward.DisplayName
			local clone = secret:Clone()
			clone.Parent = secret.Parent
			local tweenInfo2 = TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0)

			for _, descendant in clone:GetDescendants() do
				if descendant:IsA("TextLabel") or descendant:IsA("TextBox") or descendant:IsA("TextButton") then
					v3.fastTween(descendant, tweenInfo2, {
						TextTransparency = 1
					})
				elseif descendant:IsA("ImageLabel") or descendant:IsA("ImageButton") then
					v3.fastTween(descendant, tweenInfo2, {
						ImageTransparency = 1
					})
				elseif descendant:IsA("UIStroke") then
					v3.fastTween(descendant, tweenInfo2, {
						Transparency = 1
					})
				end
			end

			v3.fastTween(clone, tweenInfo2, {
				ImageTransparency = 1
			})
			v3.fastTween(clone, tweenInfo2, {
				Size = UDim2.fromScale(2.5, 2.5)
			}).Completed:Connect(function(p)
				clone:Destroy()
			end)
			task.wait(tweenInfo2.Time)
		end

		local clone = halloweenGacha.reward:Clone()
		clone.Parent = playerGui
		clone.Volume = 0.34
		clone:Play()
		task.spawn(function()
			local value = item.Reward.Value
			local icon = v2.Icons[`Get{item.Reward.Type}Icon`]

			if typeof(icon) == "function" then
				icon(v2.Icons, value)
			else
				`{item.Reward.Type}Skin`
			end

			local showAwardItem = v2.Network.Events.ShowAwardItem
			local type2 = item.Reward.Type
			local v17 = type(value) ~= "number" and 1 or value
			local valueConvertor = v2.ValueConvertor
			local v20

			if type(value) == "number" then
				v20 = `%s {item.Reward.DisplayName}`
			else
				v20 = item.Reward.DisplayName
			end

			showAwardItem(
				type2,
				v17,
				(`You received {valueConvertor:FormatMarkupColor(`{v20}`, Color3.new(0.2, 0.5, 1))}!`)
			)
		end)
		task.wait(0.5)
	end

	v3.fastTween(tournamentEventCrate.Crates.Left.Items.SpinButtons.Spin1, tweenInfo, {
		ImageColor3 = Color3.new(1, 1, 1)
	})
	v3.fastTween(tournamentEventCrate.Crates.Left.Items.SpinButtons.Spin10, tweenInfo, {
		ImageColor3 = Color3.new(1, 1, 1)
	})
	tournamentEventCrate.Crates.Left.Items.SpinButtons.Spin1:AddTag("UI_ButtonHoverAnimation2")
	tournamentEventCrate.Crates.Left.Items.SpinButtons.Spin10:AddTag("UI_ButtonHoverAnimation2")
	flag = false
end

function TournamentEventCrateController.SetupStreaks(_)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function getTicketsForStreak(p)
		for _, loginStreak in v4.LoginStreaks do
			if loginStreak.Streak == p then
				return loginStreak.Tickets
			end
		end

		return 0
	end

	local updatesByName = {}

	for k, v13 in {
		["1"] = tournamentEventCrate.Crates.Right.Main.List["1"],
		["2"] = tournamentEventCrate.Crates.Right.Main.List["2"],
		["3"] = tournamentEventCrate.Crates.Right.Main.List["3"],
		["4"] = tournamentEventCrate.Crates.Right.Main.List["4"]
	} do
		local v14 = v13
		local v15 = k

		local function update()
			local label = v14.Label

			if v7:Get({ "TournamentEventClaimedStreaks", (`Day{v14.Name}`) }) then
				v14.ImageColor3 = Color3.fromRGB(125, 125, 125)
				label.Text = "CLAIMED!"
			else
				local tournamentEventLoginStreak = v7:Get("TournamentEventLoginStreak")
				v14.ImageColor3 = Color3.new(1, 1, 1)
				local ticketsForStreak = getTicketsForStreak(tonumber(v15)) -- equivalent call inferred; original call site unknown
				label.Text = `{ticketsForStreak} Ticket{ticketsForStreak <= 1 and "" or "s"}`
				label.Visible = true

				if tonumber(v15) <= tournamentEventLoginStreak then
					label.Text = `+{ticketsForStreak} (Click to claim)`
					v14:SetAttribute("CanClaim", true)
				else
					v14:SetAttribute("CanClaim", nil)
				end
			end
		end

		local v16 = v13
		v13.Activated:Connect(function()
			if v7:Get({ "TournamentEventClaimedStreaks", (`Day{v16.Name}`) }) or not v16:GetAttribute("CanClaim") then
				return
			end

			v2.Sounds:Play("LTMSpin_ClaimSpins")
			remoteEvent:FireServer((tonumber(v16.Name)))
		end)
		update()
		updatesByName[v13.Name] = update
		v7:OnChange("TournamentEventClaimedStreaks", update)
	end

	local function updateStreaks()
		tournamentEventCrate.Crates.Right.Main.DayCount.DayCount.Label.Text = `{v7:Get("TournamentEventLoginStreak")} Days`

		for _, v13 in updatesByName do
			v13()
		end
	end

	v7:OnChange("TournamentEventLoginStreak", updateStreaks)
	v7:OnChange("TournamentEventClaimedStreaks", updateStreaks)
	task.spawn(updateStreaks)
end

function TournamentEventCrateController.Start(_) end

return TournamentEventCrateController