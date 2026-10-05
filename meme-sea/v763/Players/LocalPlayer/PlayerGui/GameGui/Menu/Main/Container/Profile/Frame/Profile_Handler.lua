local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local SocialService = game:GetService("SocialService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript")
local modules = ReplicatedStorage:WaitForChild("Modules")
local sound_Effect = ReplicatedStorage:WaitForChild("Sound_Effect")
local otherEvent = ReplicatedStorage:WaitForChild("OtherEvent")
local mainEvents = otherEvent:WaitForChild("MainEvents")
local guiEvents = otherEvent:WaitForChild("GuiEvents")
local robloxPrompt = require(modules:WaitForChild("robloxPrompt"))
local Setting = require(moduleScript:WaitForChild("Setting"))
local Abbreviate = require(moduleScript:WaitForChild("Abbreviate"))
require(modules:WaitForChild("FrameTrigger"))
require(moduleScript:WaitForChild("PlaySound"))
local FadeModule = require(modules:WaitForChild("FadeModule"))
local Translate = require(moduleScript:WaitForChild("Translate"))
local playerData = localPlayer:WaitForChild("PlayerData", 60)
local playerSpecial = localPlayer:WaitForChild("PlayerSpecial", 60)
local ability = localPlayer:WaitForChild("Ability")
local country = playerData:WaitForChild("Country")
local level = playerData:WaitForChild("Level")
local playTime = playerData:WaitForChild("PlayTime")
local bounty = playerData:WaitForChild("Bounty")
local honor = playerData:WaitForChild("Honor")
local floppaKilled = playerData:WaitForChild("FloppaKilled")
local cheemsKilled = playerData:WaitForChild("CheemsKilled")
playerData:WaitForChild("SkillPoint")
local race = playerData:WaitForChild("Race")
local combatEquip = playerData:WaitForChild("CombatEquip")
local swordEquip = playerData:WaitForChild("SwordEquip")
local powerEquip = playerData:WaitForChild("PowerEquip")
local luck = playerData:WaitForChild("Luck")
local maxLuck = playerData:WaitForChild("MaxLuck")
local total_Money = playerData:WaitForChild("Total_Money")
local total_Gem = playerData:WaitForChild("Total_Gem")
local fishAwaken = ability:WaitForChild("FishAwaken")
local rabbitAwaken = ability:WaitForChild("RabbitAwaken")
local birdAwaken = ability:WaitForChild("BirdAwaken")
local doubleMoney = playerSpecial:WaitForChild("DoubleMoney")
local doubleExp = playerSpecial:WaitForChild("DoubleExp")
local doubleGem = playerSpecial:WaitForChild("DoubleGem")
local guiEvent = guiEvents:WaitForChild("GuiEvent")
local luck2 = mainEvents:WaitForChild("Luck")
local parent = script.Parent.Parent.Parent.Parent
local parent2 = parent.Parent
local _ = parent.HeadBar
local frame = parent.Container.Profile.Frame
local container = frame.Container
local boost_Container = frame.Boost_Container
local parent3 = frame.Parent
local boostFrame = frame.BoostFrame
local settings = container.LuckFrame.Settings
local luckFrame = frame.LuckFrame
local amount_Frame = luckFrame.Amount_Frame
local inputFrame = amount_Frame.InputFrame
local max = amount_Frame.Max
local slideFrame = amount_Frame.SlideFrame
local button = amount_Frame.SetFrame.Button
local button2 = amount_Frame.CloseFrame.Button
local input = inputFrame.Input
local X = inputFrame.X
local _ = Setting.Setting.MaxBounty
local max_Luck = Setting.Setting.Max_Luck
local avatarBust = Enum.ThumbnailType.AvatarBust
local size420x420 = Enum.ThumbnailSize.Size420x420
local userThumbnailAsync = nil
local v = nil
local maxLevel = Setting.Setting.MaxLevel
local flag = false
local renderSteppedConnection = nil
local touchEnabled = UserInputService.TouchEnabled == true
local clickSound = sound_Effect:WaitForChild("ClickSound")
local success, _ = pcall(function()
	userThumbnailAsync, v = Players:GetUserThumbnailAsync(localPlayer.UserId, avatarBust, size420x420)
end)

if success then
	frame.ProfileFrame.Profile.Image = userThumbnailAsync or "rbxassetid://13218221691"
else
	frame.ProfileFrame.Profile.Image = "rbxassetid://13218221691"
end

if UserInputService.TouchEnabled then
	frame.ProfileFrame.UIStroke.Thickness = 2
	frame.ProfileFrame.Profile.UIStroke.Thickness = 1
end

-- equivalent calls inferred from this helper; original call sites unknown
local function OpeningThisFrame()
	return parent2.Visible == true and parent2.Position == UDim2.new(0.5, 0, 0.5, 0) and parent.AllMenu:GetAttribute("CurrentOpen") == parent3.Name
end

-- equivalent calls inferred from this helper; original call sites unknown
local function canSendGameInvite(p)
	local success2, result = pcall(function()
		return SocialService:CanSendGameInviteAsync(p)
	end)
	return success2 and result
end

local function formatUptime(p)
	local v2 = math.floor(p / 3600)
	local v3 = math.floor(p % 3600 / 60)
	local v4 = p % 60
	return string.format("%02d:%02d:%02d", v2, v3, v4)
end

local function MultiplytoPercent(p)
	return p * 100 - 100
end

local function ShowMultipliers()
	boost_Container.MoneyFrame.Value.Text = `+{math.floor(localPlayer:GetAttribute("MoneyBoost") * 100 - 100)}%`
	boost_Container.ExpFrame.Value.Text = `+{math.floor(localPlayer:GetAttribute("ExpBoost") * 100 - 100)}%`
	boost_Container.GemFrame.Value.Text = `+{math.floor(localPlayer:GetAttribute("GemBoost") * 100 - 100)}%`
end

local function ShowMaxLuck()
	max:SetAttribute("MaxLuck", (math.clamp(maxLuck.Value, 1, (math.clamp(maxLuck.Value, 1, max_Luck)))))

	if localPlayer:GetAttribute("TH") then
		max.Text = `x{max:GetAttribute("MaxLuck")}`
	else
		max.Text = `{max:GetAttribute("MaxLuck")}x`
	end
end

local function ShowLuck()
	if luck and maxLuck then
		if luck.Value >= maxLuck.Value then
			if localPlayer:GetAttribute("TH") then
				container.LuckFrame.Value.Text = `x{luck.Value}`
			else
				container.LuckFrame.Value.Text = `{luck.Value}x`
			end
		elseif localPlayer:GetAttribute("TH") then
			container.LuckFrame.Value.Text = `x{luck.Value} (สูงสุด x{maxLuck.Value})`
		else
			container.LuckFrame.Value.Text = `{luck.Value}x (Max {maxLuck.Value}x)`
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ShowLuck_X()
	if localPlayer:GetAttribute("TH") then
		X.LayoutOrder = 0
	else
		X.LayoutOrder = 2
	end
end

local function ShowLevel()
	if not (maxLevel <= level.Value) then
		container.LevelFrame.Value.Text = `{level.Value}/{maxLevel}`
	elseif localPlayer:GetAttribute("TH") then
		container.LevelFrame.Value.Text = `{level.Value} (ตัน)`
	else
		container.LevelFrame.Value.Text = `{level.Value} (Max)`
	end
end

local function ShowCountry()
	if country.Value == "None" and country.Value == "" then
		if localPlayer.Name == localPlayer.DisplayName then
			frame.DisplayName.Text = `{localPlayer.DisplayName} (@{localPlayer.Name})`
		else
			frame.DisplayName.Text = `{localPlayer.Name}`
		end
	elseif localPlayer.Name == localPlayer.DisplayName then
		frame.DisplayName.Text = `[{country.Value}] {localPlayer.Name}`
	else
		frame.DisplayName.Text = `[{country.Value}] {localPlayer.DisplayName} (@{localPlayer.Name})`
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ShowTime()
	if playTime then
		local value = container.TimeFrame.Value
		local value2 = playTime.Value
		local v2 = math.floor(value2 / 3600)
		local v3 = math.floor(value2 % 3600 / 60)
		local v4 = value2 % 60
		value.Text = `{string.format("%02d:%02d:%02d", v2, v3, v4)}`
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ShowFame()
	container.FameFrame.Value.Text = `{Abbreviate.Comma(honor.Value)}`
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ShowBounty()
	container.BountyFame.Value.Text = `{Abbreviate.Comma(bounty.Value)}`
end

local function ShowRace()
	if fishAwaken.Value == true and race.Value == "Fish" or rabbitAwaken.Value == true and race.Value == "Rabbit" or birdAwaken.Value == true and race.Value == "Bird" then
		if localPlayer:GetAttribute("TH") then
			container.RaceFrame.Value.Text = `{Translate[race.Value]} (V2)`
		else
			container.RaceFrame.Value.Text = `{race.Value} (V2)`
		end
	elseif localPlayer:GetAttribute("TH") then
		container.RaceFrame.Value.Text = `{Translate[race.Value]} (V1)`
	else
		container.RaceFrame.Value.Text = `{race.Value} (V1)`
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ShowPowerEquip()
	container.PowerFrame.Value.Text = `{powerEquip.Value}`
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ShowSwordEquip()
	container.WeaponFrame.Value.Text = `{swordEquip.Value}`
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ShowCombatEquip()
	container.CombatFrame.Value.Text = `{combatEquip.Value}`
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ShowKills()
	container.FloppaKilled_Frame.Value.Text = `{Abbreviate.Comma(floppaKilled.Value)}`
	container.CheemKilled_Frame.Value.Text = `{Abbreviate.Comma(cheemsKilled.Value)}`
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ShowTotalMoney()
	container.TotalMoney.Value.Text = `${Abbreviate.Comma(total_Money.Value)}`
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ShowTotalGem()
	container.TotalGem.Value.Text = `{Abbreviate.Comma(total_Gem.Value)}`
end

local function ShowBoosts(_)
	local friendBoost = localPlayer:GetAttribute("FriendBoost")

	if localPlayer.MembershipType == Enum.MembershipType.Premium then
		if localPlayer:GetAttribute("TH") then
			boostFrame.Frame.Container.PremiumFrame.PremiumText.Text = "พรีเมี่ยม (✅)"
		else
			boostFrame.Frame.Container.PremiumFrame.PremiumText.Text = "Premium (✅)"
		end
	elseif localPlayer:GetAttribute("TH") then
		boostFrame.Frame.Container.PremiumFrame.PremiumText.Text = "พรีเมี่ยม (❌)"
	else
		boostFrame.Frame.Container.PremiumFrame.PremiumText.Text = "Premium (❌)"
	end

	if localPlayer:IsInGroup(15403828) then
		if localPlayer:GetAttribute("TH") then
			boostFrame.Frame.Container.GroupFrame.GroupText.Text = "สมาชิกกลุ่ม (✅)"
		else
			boostFrame.Frame.Container.GroupFrame.GroupText.Text = "Group Member (✅)"
		end
	elseif localPlayer:GetAttribute("TH") then
		boostFrame.Frame.Container.GroupFrame.GroupText.Text = "สมาชิกกลุ่ม (❌)"
	else
		boostFrame.Frame.Container.GroupFrame.GroupText.Text = "Group Member (❌)"
	end

	local v2 = doubleExp.Value == true and "✅" or "❌"
	local v3 = doubleMoney.Value == true and "✅" or "❌"
	local v4 = doubleGem.Value == true and "✅" or "❌"

	if localPlayer:GetAttribute("TH") then
		boostFrame.Frame.Container.ExpFrame.GamepassText.Text = `เกมพาส Double Exp ({v2})`
		boostFrame.Frame.Container.MoneyFrame.GamepassText.Text = `เกมพาส Double Money ({v3})`
		boostFrame.Frame.Container.GemFrame.GamepassText.Text = `เกมพาส Double Gem ({v4})`
		boostFrame.Frame.Container.FriendBoostFrame.FriendInviteText.Text = `บูสต์เพื่อน ({friendBoost * 100 / 10}/10)`
		boostFrame.Frame.Container.FriendBoostFrame.FriendInvite.Text = `+{friendBoost * 100}% (ทั้งหมด)`
	else
		boostFrame.Frame.Container.ExpFrame.GamepassText.Text = `Double Exp Gamepass ({v2})`
		boostFrame.Frame.Container.MoneyFrame.GamepassText.Text = `Double Money Gamepass ({v3})`
		boostFrame.Frame.Container.GemFrame.GamepassText.Text = `Double Gem Gamepass ({v4})`
		boostFrame.Frame.Container.FriendBoostFrame.FriendInviteText.Text = `Friend Boost ({friendBoost * 100 / 10}/10)`
		boostFrame.Frame.Container.FriendBoostFrame.FriendInvite.Text = `+{friendBoost * 100}% (All)`
	end
end

local function ChangedAll()
	ShowLevel()
	ShowRace()
	ShowCombatEquip() -- equivalent call inferred; original call site unknown
	ShowPowerEquip() -- equivalent call inferred; original call site unknown
	ShowSwordEquip() -- equivalent call inferred; original call site unknown
	ShowTime() -- equivalent call inferred; original call site unknown
	ShowCountry()
	ShowFame() -- equivalent call inferred; original call site unknown
	ShowBounty() -- equivalent call inferred; original call site unknown
	ShowKills() -- equivalent call inferred; original call site unknown
	ShowLuck()
	ShowMultipliers()
	ShowTotalMoney() -- equivalent call inferred; original call site unknown
	ShowTotalGem() -- equivalent call inferred; original call site unknown

	if boostFrame.Visible == true then
		ShowBoosts()
	end
end

guiEvent.Event:Connect(function(p)
	local menuName = p.MenuName
	local action = p.Action

	if menuName == parent3.Name then
		if action == "Open" then
			ChangedAll()
		elseif action == "OpenBoostFrame" then
			ActiveBoostFrame(true)
			ChangedAll()
		elseif action == "CloseBoostFrame" then
			ActiveBoostFrame(false)
		end
	end
end)
level.Changed:Connect(function()
	if OpeningThisFrame() then
		ShowLevel()
	end
end)
race.Changed:Connect(function()
	if OpeningThisFrame() then
		ShowRace()
	end
end)
fishAwaken.Changed:Connect(function()
	if OpeningThisFrame() then
		ShowRace()
	end
end)
rabbitAwaken.Changed:Connect(function()
	if OpeningThisFrame() then
		ShowRace()
	end
end)
birdAwaken.Changed:Connect(function()
	if OpeningThisFrame() then
		ShowRace()
	end
end)
powerEquip.Changed:Connect(function()
	if OpeningThisFrame() then
		ShowPowerEquip() -- equivalent call inferred; original call site unknown
	end
end)
swordEquip.Changed:Connect(function()
	if OpeningThisFrame() then
		ShowSwordEquip() -- equivalent call inferred; original call site unknown
	end
end)
combatEquip.Changed:Connect(function()
	if OpeningThisFrame() then
		ShowCombatEquip() -- equivalent call inferred; original call site unknown
	end
end)
playTime.Changed:Connect(function()
	if OpeningThisFrame() and playTime then
		local value = container.TimeFrame.Value
		local value2 = playTime.Value
		local v2 = math.floor(value2 / 3600)
		local v3 = math.floor(value2 % 3600 / 60)
		local v4 = value2 % 60
		value.Text = `{string.format("%02d:%02d:%02d", v2, v3, v4)}`
	end
end)
country.Changed:Connect(function()
	if OpeningThisFrame() then
		ShowCountry()
	end
end)
bounty.Changed:Connect(function()
	if OpeningThisFrame() then
		ShowBounty() -- equivalent call inferred; original call site unknown
	end
end)
floppaKilled.Changed:Connect(function()
	if OpeningThisFrame() then
		ShowKills() -- equivalent call inferred; original call site unknown
	end
end)
cheemsKilled.Changed:Connect(function()
	if OpeningThisFrame() then
		ShowKills() -- equivalent call inferred; original call site unknown
	end
end)
maxLuck.Changed:Connect(function()
	if OpeningThisFrame() then
		ShowLuck()

		if luckFrame.Visible then
			ShowMaxLuck()
		end
	end
end)
honor.Changed:Connect(function()
	if OpeningThisFrame() then
		ShowFame() -- equivalent call inferred; original call site unknown
	end
end)
total_Money.Changed:Connect(function()
	if OpeningThisFrame() then
		ShowTotalMoney() -- equivalent call inferred; original call site unknown
	end
end)
total_Gem.Changed:Connect(function()
	if OpeningThisFrame() then
		ShowTotalGem() -- equivalent call inferred; original call site unknown
	end
end)
doubleExp.Changed:Connect(function()
	if OpeningThisFrame() then
		ShowMultipliers()

		if boostFrame.Visible == true then
			ShowBoosts()
		end
	end
end)
doubleMoney.Changed:Connect(function()
	if OpeningThisFrame() then
		ShowMultipliers()

		if boostFrame.Visible == true then
			ShowBoosts()
		end
	end
end)
doubleGem.Changed:Connect(function()
	if OpeningThisFrame() then
		ShowMultipliers()

		if boostFrame.Visible == true then
			ShowBoosts()
		end
	end
end)
luck.Changed:Connect(function()
	if OpeningThisFrame() then
		ShowLuck()
	end
end)
localPlayer:GetAttributeChangedSignal("MoneyBoost"):Connect(function()
	if OpeningThisFrame() then
		ShowMultipliers()
	end
end)
localPlayer:GetAttributeChangedSignal("ExpBoost"):Connect(function()
	if OpeningThisFrame() then
		ShowMultipliers()
	end
end)
localPlayer:GetAttributeChangedSignal("GemBoost"):Connect(function()
	if OpeningThisFrame() then
		ShowMultipliers()
	end
end)
localPlayer:GetAttributeChangedSignal("FriendBoost"):Connect(function()
	if OpeningThisFrame() then
		ShowMultipliers()

		if boostFrame.Visible == true then
			ShowBoosts()
		end
	end
end)
localPlayer:GetPropertyChangedSignal("MembershipType"):Connect(function()
	if OpeningThisFrame() then
		ShowMultipliers()

		if boostFrame.Visible == true then
			ShowBoosts()
		end
	end
end)
localPlayer:GetPropertyChangedSignal("Team"):Connect(function()
	if OpeningThisFrame() then
		ShowBounty() -- equivalent call inferred; original call site unknown
		ShowFame() -- equivalent call inferred; original call site unknown
	end
end)
frame.OpenBoost.Activated:Connect(function()
	clickSound:Play()
	ActiveBoostFrame(true)
end)
boostFrame.Frame.PremiumFrame.Premium.Activated:Connect(function()
	if localPlayer.MembershipType ~= Enum.MembershipType.Premium then
		MarketplaceService:PromptPremiumPurchase(localPlayer)
	elseif localPlayer:GetAttribute("TH") then
		robloxPrompt.newPrompt({
			title = "Meme Sea",
			image = "rbxassetid://8915050001",
			message = "คุณเป็นสมาชิกพรีเมียมอยู่แล้ว!",
			canOverride = true
		})
	else
		robloxPrompt.newPrompt({
			title = "Meme Sea",
			image = "rbxassetid://8915050001",
			message = "You are already a Premium Member!",
			canOverride = true
		})
	end
end)
local experienceInviteOptions = Instance.new("ExperienceInviteOptions")

if localPlayer:GetAttribute("TH") then
	experienceInviteOptions.PromptMessage = "เชิญเพื่อนของคุณสำหรับบูสต์เพื่อน!"
else
	experienceInviteOptions.PromptMessage = "Invite your friends for friend boost!"
end

boostFrame.Frame.InviteFrame.Invite.Activated:Connect(function()
	if canSendGameInvite(localPlayer) then
		local success2, result = pcall(function()
			SocialService:PromptGameInvite(localPlayer, experienceInviteOptions)
		end)

		if success2 then
			return
		else
			warn(result)
		end
	end
end)
boostFrame.Frame.Close.Activated:Connect(function()
	clickSound:Play()
	ActiveBoostFrame(false)
end)
button2.Activated:Connect(function()
	clickSound:Play()
	ActiveLuckFrame(false)
end)
settings.Activated:Connect(function()
	if luckFrame.Visible ~= false then
		ActiveLuckFrame(false)
		return
	end

	clickSound:Play()
	ShowMaxLuck()
	ShowLuck_X() -- equivalent call inferred; original call site unknown
	local number = Abbreviate.GetNumber(input.Text)

	if number then
		if maxLuck.Value < number then
			input.Text = maxLuck.Value
		elseif number < 1 then
			input.Text = 1
		end

		local v2

		if number then
			v2 = math.clamp(
				math.clamp(number - 1, 0, 999) / (math.clamp(tonumber(max:GetAttribute("MaxLuck")), 2, 999) - 1),
				0,
				1
			)
		else
			v2 = math.clamp(0 / (math.clamp(tonumber(max:GetAttribute("MaxLuck")), 2, 999) - 1), 0, 1)
		end

		TweenService:Create(slideFrame.Slide, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = UDim2.new(
				math.clamp(v2, 0, 1),
				0,
				slideFrame.Slide.Position.Y.Scale,
				slideFrame.Slide.Position.Y.Offset
			)
		}):Play()
		TweenService:Create(slideFrame.Bar, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(math.clamp(v2 + 0.035, 0, 1), 0, 1, 0)
		}):Play()
	end

	ActiveLuckFrame(true)
end)
slideFrame.Slide.MouseButton1Down:Connect(function()
	StartSliding(slideFrame)
end)
slideFrame.MouseButton1Down:Connect(function()
	StartSliding(slideFrame)
end)
button.Activated:Connect(function()
	local amount = Abbreviate.GetNumber(input.Text) or 1

	if amount and luck then
		if maxLuck.Value < amount then
			input.Text = maxLuck.Value
		elseif amount < 1 then
			input.Text = 1
		end

		if amount <= maxLuck.Value then
			sound_Effect.Upgrade:Play()
			luck2:FireServer({
				Action = "Set_Luck",
				Amount = amount
			})
		end
	end

	ActiveLuckFrame(false)
end)
localPlayer:GetAttributeChangedSignal("TH"):Connect(function()
	if localPlayer:GetAttribute("TH") then
		experienceInviteOptions.PromptMessage = "เชิญเพื่อนของคุณสำหรับบูสต์เพื่อน!"
	else
		experienceInviteOptions.PromptMessage = "Invite your friends for friend boost!"
	end

	ShowLuck_X() -- equivalent call inferred; original call site unknown
end)

if touchEnabled then
	input:GetPropertyChangedSignal("Text"):Connect(function()
		input.Text = input.Text:gsub("%D+", "")
		local number = Abbreviate.GetNumber(input.Text)

		if number then
			local v2

			if number then
				v2 = math.clamp(
					math.clamp(number - 1, 0, 999) / (math.clamp(tonumber(max:GetAttribute("MaxLuck")), 2, 999) - 1),
					0,
					1
				)
			else
				v2 = math.clamp(0 / (math.clamp(tonumber(max:GetAttribute("MaxLuck")), 2, 999) - 1), 0, 1)
			end

			TweenService:Create(slideFrame.Slide, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = UDim2.new(
					math.clamp(v2, 0, 1),
					0,
					slideFrame.Slide.Position.Y.Scale,
					slideFrame.Slide.Position.Y.Offset
				)
			}):Play()
			TweenService:Create(slideFrame.Bar, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = UDim2.new(math.clamp(v2 + 0.035, 0, 1), 0, 1, 0)
			}):Play()
		end
	end)
	input.FocusLost:Connect(function()
		local number = Abbreviate.GetNumber(input.Text)

		if number then
			if maxLuck.Value < number then
				input.Text = maxLuck.Value
			elseif number < 1 then
				input.Text = 1
			end
		end
	end)
else
	input:GetPropertyChangedSignal("Text"):Connect(function()
		input.Text = input.Text:gsub("%D+", "")
		local number = Abbreviate.GetNumber(input.Text)

		if number then
			if maxLuck.Value < number then
				input.Text = maxLuck.Value
			elseif number < 1 then
				input.Text = 1
			end

			local v2

			if number then
				v2 = math.clamp(
					math.clamp(number - 1, 0, 999) / (math.clamp(tonumber(max:GetAttribute("MaxLuck")), 2, 999) - 1),
					0,
					1
				)
			else
				v2 = math.clamp(0 / (math.clamp(tonumber(max:GetAttribute("MaxLuck")), 2, 999) - 1), 0, 1)
			end

			TweenService:Create(slideFrame.Slide, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = UDim2.new(
					math.clamp(v2, 0, 1),
					0,
					slideFrame.Slide.Position.Y.Scale,
					slideFrame.Slide.Position.Y.Offset
				)
			}):Play()
			TweenService:Create(slideFrame.Bar, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = UDim2.new(math.clamp(v2 + 0.035, 0, 1), 0, 1, 0)
			}):Play()
		end
	end)
end

UserInputService.InputEnded:Connect(function(input2)
	if input2.UserInputType == Enum.UserInputType.MouseButton1 then
		if flag == true then
			flag = false

			if renderSteppedConnection then
				renderSteppedConnection:Disconnect()
				renderSteppedConnection = nil
			end
		end
	elseif input2.UserInputType == Enum.UserInputType.Touch and flag == true then
		flag = false

		if renderSteppedConnection then
			renderSteppedConnection:Disconnect()
			renderSteppedConnection = nil
		end
	end
end)

function StartSliding(p)
	if flag == false then
		if renderSteppedConnection then
			renderSteppedConnection:Disconnect()
			renderSteppedConnection = nil
		end

		flag = true
		renderSteppedConnection = RunService.RenderStepped:Connect(function()
			if flag then
				local X2 = UserInputService:GetMouseLocation().X
				local X3 = p.AbsoluteSize.X
				local v2 = math.clamp((X2 - p.AbsolutePosition.X) / X3, 0, 1)
				local v3 = math.floor(tonumber(max:GetAttribute("MaxLuck")) * v2 + 1)

				if input.Text ~= math.clamp(v3, 1, (tonumber(max:GetAttribute("MaxLuck")))) then
					input.Text = math.clamp(v3, 1, (tonumber(max:GetAttribute("MaxLuck"))))
				end
			elseif renderSteppedConnection then
				renderSteppedConnection:Disconnect()
				renderSteppedConnection = nil
			end
		end)
	end
end

function ActiveLuckFrame(p)
	if p == true and luckFrame.Visible == false then
		luckFrame.Visible = true
		FadeModule.FadeIn(luckFrame, 0.25)
	elseif p == false and luckFrame.Visible == true then
		FadeModule.FadeOut(luckFrame, 0.25)
		task.wait(0.25)
		luckFrame.Visible = false
	end
end

function ActiveBoostFrame(p)
	if p == true and boostFrame.Visible == false then
		boostFrame.Visible = true
		FadeModule.FadeIn(boostFrame, 0.25)
		ShowBoosts()
	elseif p == false and boostFrame.Visible == true then
		FadeModule.FadeOut(boostFrame, 0.25)
		task.wait(0.25)
		boostFrame.Visible = false
	end
end