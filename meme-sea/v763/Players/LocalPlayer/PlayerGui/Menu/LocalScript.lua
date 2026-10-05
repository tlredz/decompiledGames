local Players = game:GetService("Players")
game:GetService("CollectionService")
game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local modules = ReplicatedStorage:WaitForChild("Modules")
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript")
local FrameTrigger = require(modules:WaitForChild("FrameTrigger"))
local PlaySound = require(moduleScript:WaitForChild("PlaySound"))
local UIStrokeAdjuster = require(modules:WaitForChild("UIStrokeAdjuster"))
require(modules:WaitForChild("FadeModule"))
local Shiny = require(modules:WaitForChild("Shiny"))
local Setting = require(moduleScript:WaitForChild("Setting"))
local setting = Setting.Setting
local Abbreviate = require(moduleScript:WaitForChild("Abbreviate"))
local SetText = require(moduleScript:WaitForChild("SetText"))
local playerSettings = localPlayer:WaitForChild("PlayerSettings", 60)
local cooldown = localPlayer:WaitForChild("Cooldown")
local playerData = localPlayer:WaitForChild("PlayerData", 60)
local thaiLanguage = playerSettings:WaitForChild("ThaiLanguage")
local bedPoint = playerData:WaitForChild("BedPoint")
local sound_Effect = ReplicatedStorage:WaitForChild("Sound_Effect")
local otherEvent = ReplicatedStorage:WaitForChild("OtherEvent")
local guiEvents = otherEvent:WaitForChild("GuiEvents")
local pvpEvents = otherEvent:WaitForChild("PvpEvents")
local mainEvents = otherEvent:WaitForChild("MainEvents")
local guiEvents2 = otherEvent:WaitForChild("GuiEvents")
mainEvents:WaitForChild("Died")
local ability = mainEvents:WaitForChild("Ability")
local topbar = guiEvents2:WaitForChild("Topbar")
local enablePvp = pvpEvents:WaitForChild("EnablePvp")
local clickSound = sound_Effect:WaitForChild("ClickSound")
local parent = script.Parent
local gameGui = parent.Parent:WaitForChild("GameGui", 30)
local portalGui = parent.Parent:WaitForChild("PortalGui", 30)
local loadingGui = parent.Parent:FindFirstChild("LoadingGui", 30)
local questGui = parent.Parent:WaitForChild("QuestGui", 30)
local tradeGui = parent.Parent:WaitForChild("TradeGui", 30)
local mainGui = parent.Parent:WaitForChild("MainGui", 30)
local npcGui_Folder = parent.Parent:WaitForChild("NpcGui_Folder", 30)
local fightingStyle = parent.Parent:WaitForChild("FightingStyle", 30)
local weapon = parent.Parent:WaitForChild("Weapon", 30)
local power = parent.Parent:WaitForChild("Power", 30)
local menuFrame = parent.MenuFrame
local updateLog = menuFrame.UpdateLog
local trade = menuFrame.Trade
local settings = menuFrame.Settings
local compass = menuFrame.Compass
local auraColor = menuFrame.AuraColor
local color_Index = menuFrame.Color_Index
local gacha_Chances = menuFrame.Gacha_Chances
local boatList = menuFrame.BoatList
local party = menuFrame.Party
local menu = parent.Menu
local newRequests = trade.NewRequests
local newRequests2 = party.NewRequests
local newRequests3 = compass.NewRequests
local pvpDisabled = mainGui:WaitForChild("PvpDisabled")
local inCombat = mainGui:WaitForChild("InCombat")
local safezoneInfo = mainGui:WaitForChild("SafezoneInfo")
local holder = inCombat.Holder
local holder2 = safezoneInfo.Holder
local frame = pvpDisabled.Frame
local confirm = frame.ButtonFrame.Buttons.Confirm
local cancel = frame.ButtonFrame.Buttons.Cancel
local okay = holder.ButtonHolder.Okay
local okay2 = holder2.ButtonHolder.Okay
local menu2 = gameGui.Menu
local updateLog2 = gameGui.UpdateLog
local trade2 = gameGui.Trade
local settings2 = gameGui.Settings
local dropMoney = gameGui.DropMoney
local compass2 = gameGui.Compass
local auraColor2 = gameGui.AuraColor
local color_Index2 = gameGui.Color_Index
local gacha_Chances2 = gameGui.Gacha_Chances
local party2 = gameGui.Party
local boatList2 = gameGui.BoatList
local main = menu2.Main
local main2 = trade2.Main
local main3 = settings2.Main
local main4 = dropMoney.Main
local main5 = compass2.Main
local main6 = auraColor2.Main
local main7 = color_Index2.Main
local main8 = gacha_Chances2.Main
local main9 = party2.Main
local main10 = boatList2.Main
local safeFrame = parent.SafeFrame
local healthFrame = mainGui.HealthFrame
local dropMoney2 = menuFrame.DropMoney
local bedButton = menuFrame.BedButton
local textLabel = bedButton.TextLabel
local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local pvpDisabled_Time = setting.PvpDisabled_Time
local inCombat_Duration = setting.InCombat_Duration
local v = {
	Stats = UDim2.new(0.07, 0, 0.5, 0),
	Profile = UDim2.new(0.216, 0, 0.5, 0),
	Ability = UDim2.new(0.367, 0, 0.5, 0),
	Items = UDim2.new(0.517, 0, 0.5, 0),
	Shop = UDim2.new(0.665, 0, 0.5, 0),
	Quest = UDim2.new(0.07, 0, 0.5, 0),
	Island = UDim2.new(0.216, 0, 0.5, 0)
}
local connections = {}
local flag = false
local flag2 = false
local v3 = nil
local diedConnection = nil
local characterRemovingConnection = nil

while localPlayer:GetAttribute("LoadedData") == nil and not character and (localPlayer:GetAttribute("LoadedData") ~= true or not character) do
	task.wait(0.5)
end

connections[#connections + 1] = npcGui_Folder.ChildAdded:Connect(function(screenGui)
	if screenGui:IsA("ScreenGui") then
		UIStrokeAdjuster:TagScreenGui(screenGui)
	end
end)

if loadingGui then
	UIStrokeAdjuster:TagScreenGui(loadingGui)
end

UIStrokeAdjuster:TagScreenGui(tradeGui)
UIStrokeAdjuster:TagScreenGui(questGui)
local v4 = UserInputService.TouchEnabled == true or false

if v4 == true then
	menuFrame.Position = UDim2.new(0.03, 0, 0.59, 0)
	menuFrame.Size = UDim2.new(0.028, 0, 0.035, 5)
	menuFrame.Trade.Position = UDim2.new(0.21, 0, 1.1, 0)
	menuFrame.Settings.Position = UDim2.new(0.97, 0, 1.1, 0)
	menuFrame.Compass.Position = UDim2.new(1.76, 0, 1.1, 0)
	menuFrame.Party.Position = UDim2.new(2.56, 0, 1.1, 0)
	menuFrame.DropMoney.Position = UDim2.new(3.31, 0, 1.1, 0)
	menuFrame.BedButton.Position = UDim2.new(4.06, 0, 1.1, 0)
	pvpDisabled.Position = UDim2.new(0.5, 0, 1.5, -15)
	safezoneInfo.Position = UDim2.new(0.5, 0, 1.5, -15)
	inCombat.Position = UDim2.new(0.5, 0, 1.5, -15)
	menu.Position = UDim2.new(0.045, 0, 0.685, 0)
	menu.Size = UDim2.new(0.068, 1, 0.04, 3)
	local uIStroke = trade.NewRequests.Exclamation_Mark:FindFirstChild("UIStroke")
	local uIStroke2 = party.NewRequests.Exclamation_Mark:FindFirstChild("UIStroke")
	local uIStroke3 = safeFrame.InCombat.HoverFrame.Textlabel:FindFirstChild("UIStroke")
	local uIStroke4 = safeFrame.PvpDisabled.HoverFrame.Textlabel:FindFirstChild("UIStroke")
	local uIStroke5 = safeFrame.SafezoneInfo.HoverFrame.Textlabel:FindFirstChild("UIStroke")
	local uIStroke6 = menu.TextLabel:FindFirstChild("UIStroke")

	if uIStroke then
		uIStroke.Enabled = false
	end

	if uIStroke2 then
		uIStroke2.Enabled = false
	end

	if uIStroke3 then
		uIStroke3.Thickness = 1
	end

	if uIStroke4 then
		uIStroke4.Thickness = 1
	end

	if uIStroke5 then
		uIStroke5.Thickness = 1
	end

	if uIStroke6 then
		uIStroke6.Enabled = false
	end
else
	menuFrame.Position = UDim2.new(0.03, 0, 0.73)
	menuFrame.Size = UDim2.new(0.028, 0, 0.035, 0)
	menuFrame.Trade.Position = UDim2.new(0.19, 0, 0, 0)
	menuFrame.Settings.Position = UDim2.new(0.94, 0, 0, 0)
	menuFrame.Compass.Position = UDim2.new(1.74, 0, 0, 0)
	menuFrame.Party.Position = UDim2.new(2.54, 0, 0, 0)
	menuFrame.DropMoney.Position = UDim2.new(3.29, 0, 0, 0)
	menuFrame.BedButton.Position = UDim2.new(4.04, 0, 0, 0)
	menu.Position = UDim2.new(0.045, 0, 0.765, 0)
end

local function CheckIfAlive(character2)
	if character2 and character2.Parent and character2:FindFirstChild("Humanoid") and character2:FindFirstChild("Humanoid").Parent and character2:FindFirstChild("Humanoid").Health > 0 and character2:FindFirstChild("Humanoid"):GetState() ~= Enum.HumanoidStateType.Dead then
		return true
	end

	return false
end

local function TextColor(p, p2)
	if p and p2 then
		return (`<font color="rgb({p2})">{p}</font>`)
	end
end

local function Disable_SkillGui()
	if fightingStyle.Enabled then
		fightingStyle.Enabled = false
	elseif weapon.Enabled then
		weapon.Enabled = false
	elseif power.Enabled then
		power.Enabled = false
	end
end

local function Disconnection(_) end

-- equivalent calls inferred from this helper; original call sites unknown
local function InCombatTime()
	flag = true
	coroutine.wrap(function()
		while character:GetAttribute("InCombat") and workspace:GetServerTimeNow() - character:GetAttribute("InCombat") < inCombat_Duration and flag do
			if safeFrame.InCombat.HoverFrame.ImageTransparency < 1 then
				safeFrame.InCombat.HoverFrame.Textlabel.Text = convertToHMS((math.clamp(
					inCombat_Duration - (workspace:GetServerTimeNow() - character:GetAttribute("InCombat")),
					0,
					inCombat_Duration
				)))
			end

			task.wait(0.25)
		end

		if flag then
			flag = false
		end
	end)()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function PvpDisabledTime()
	flag2 = true
	coroutine.wrap(function()
		while localPlayer:GetAttribute("PvpDisabled") and workspace:GetServerTimeNow() - localPlayer:GetAttribute("PvpDisabled") < pvpDisabled_Time and flag2 do
			if safeFrame.PvpDisabled.HoverFrame.ImageTransparency < 1 then
				safeFrame.PvpDisabled.HoverFrame.Textlabel.Text = convertToHMS((math.clamp(
					pvpDisabled_Time - (workspace:GetServerTimeNow() - localPlayer:GetAttribute("PvpDisabled")),
					0,
					pvpDisabled_Time
				)))
			end

			task.wait(0.25)
		end

		if flag2 then
			flag2 = false
		end
	end)()
end

local function StartCooldown(instance)
	bedButton.ImageTransparency = 0.5
	textLabel.Visible = true

	while instance and os.time() - instance:GetAttribute("StartCD") < 30 and CheckIfAlive(character) do
		textLabel.Text = `{30 - (os.time() - instance:GetAttribute("StartCD"))}`
		task.wait(0.25)
	end

	textLabel.Visible = false
	bedButton.ImageTransparency = 0
end

local function Show_PvpDisabled()
	if humanoid and humanoid.Parent and humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
		if localPlayer:GetAttribute("PvpDisabled") and not safeFrame.PvpDisabled.Visible then
			safeFrame.PvpDisabled.Visible = true
			TweenService:Create(safeFrame.PvpDisabled, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
				ImageTransparency = 0
			}):Play()
			PvpDisabledTime() -- equivalent call inferred; original call site unknown
		elseif localPlayer:GetAttribute("PvpDisabled") == nil and safeFrame.PvpDisabled.Visible then
			TweenService:Create(safeFrame.PvpDisabled, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
				ImageTransparency = 1
			}):Play()
			task.wait(0.25)
			safeFrame.PvpDisabled.Visible = false
			safeFrame.PvpDisabled.HoverFrame.Textlabel.Text = "10:00"
		end
	end
end

local function Show_Safezone()
	if character:GetAttribute("Safezone") and not safeFrame.SafezoneInfo.Visible then
		safeFrame.SafezoneInfo.Visible = true
		TweenService:Create(safeFrame.SafezoneInfo, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
			ImageTransparency = 0
		}):Play()
	elseif character:GetAttribute("Safezone") == false and safeFrame.SafezoneInfo.Visible then
		TweenService:Create(safeFrame.SafezoneInfo, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
			ImageTransparency = 1
		}):Play()
		task.wait(0.25)
		safeFrame.SafezoneInfo.Visible = false
	end
end

local function Teleport()
	if CheckIfAlive(character) and character:GetAttribute("Teleporting") == nil then
		if cooldown:FindFirstChild("TeleportCD") == nil then
			if humanoid.MoveDirection.Magnitude == 0 then
				if humanoid.Sit == false then
					if localPlayer:GetAttribute("Raiding") then
						if localPlayer:GetAttribute("TH") then
							SetText.SetText(localPlayer, "CustomMessage", {
								Message = "คุณไม่สามารถวาร์ประหว่างที่กำลังลงดันเจี้ยนอยู่ได้.",
								MessageColor = "Red"
							})
						else
							SetText.SetText(localPlayer, "CustomMessage", {
								Message = "You can't teleport while raiding.",
								MessageColor = "Red"
							})
						end
					else
						if localPlayer:GetAttribute("TH") then
							local setText = SetText.SetText
							local formatted = `&lt;{bedPoint.Value}&gt;`
							local v9

							if formatted then
								v9 = `<font color="rgb(100,255,100)">{formatted}</font>`
							end

							setText(localPlayer, "CustomMessage", {
								Message = `กำลังวาร์ปกลับไปยังเตียงของคุณ {v9}`,
								MessageColor = "White",
								Duration = 5
							})
						else
							local setText = SetText.SetText
							local formatted = `&lt;{bedPoint.Value}&gt;`
							local v9

							if formatted then
								v9 = `<font color="rgb(100,255,100)">{formatted}</font>`
							end

							setText(localPlayer, "CustomMessage", {
								Message = `Teleporting to your bed point {v9}`,
								MessageColor = "White",
								Duration = 5
							})
						end

						local teleportCD = ability:InvokeServer("Teleport") == true and cooldown:FindFirstChild("TeleportCD")

						if teleportCD then
							coroutine.wrap(StartCooldown)(teleportCD)
						end
					end
				elseif localPlayer:GetAttribute("TH") then
					SetText.SetText(localPlayer, "CustomMessage", {
						Message = "คุณไม่สามารถวาร์ประหว่างที่นั่งอยู่ได้.",
						MessageColor = "Red"
					})
				else
					SetText.SetText(localPlayer, "CustomMessage", {
						Message = "You can't teleport while seated.",
						MessageColor = "Red"
					})
				end
			elseif localPlayer:GetAttribute("TH") then
				SetText.SetText(localPlayer, "CustomMessage", {
					Message = "คุณไม่สามารถวาร์ประหว่างที่กำลังเคลื่อนที่อยู่ได้.",
					MessageColor = "Red"
				})
			else
				SetText.SetText(localPlayer, "CustomMessage", {
					Message = "You can't teleport while moving.",
					MessageColor = "Red"
				})
			end
		elseif localPlayer:GetAttribute("TH") then
			SetText.SetText(localPlayer, "CustomMessage", {
				Message = "คุณไม่สามารถเคลื่อนย้ายได้ในขณะที่คูลดาวน์อยู่.",
				MessageColor = "Red"
			})
		else
			SetText.SetText(localPlayer, "CustomMessage", {
				Message = "You can't teleport while on cooldown.",
				MessageColor = "Red"
			})
		end
	end
end

local function Setup_ButtonEffects(p: string, p2)
	if p == "Confirm" then
		if p2.Frame.ButtonFrame.Buttons:FindFirstChild("Cancel") then
			connections[#connections + 1] = p2.Frame.ButtonFrame.Buttons.Cancel.MouseEnter:Connect(function()
				p2.Frame.ButtonFrame.Buttons.Cancel.ImageTransparency = 0
				p2.Frame.ButtonFrame.Buttons.Cancel.ButtonContent.ButtonMiddleContent.Text.TextTransparency = 0
			end)
			connections[#connections + 1] = p2.Frame.ButtonFrame.Buttons.Cancel.MouseLeave:Connect(function()
				p2.Frame.ButtonFrame.Buttons.Cancel.ImageTransparency = 0.3
				p2.Frame.ButtonFrame.Buttons.Cancel.ButtonContent.ButtonMiddleContent.Text.TextTransparency = 0.3
			end)
			connections[#connections + 1] = p2.Frame.ButtonFrame.Buttons.Cancel.MouseButton1Down:Connect(function()
				p2.Frame.ButtonFrame.Buttons.Cancel.ImageTransparency = 0.65
				p2.Frame.ButtonFrame.Buttons.Cancel.ButtonContent.ButtonMiddleContent.Text.TextTransparency = 0.65
			end)
			connections[#connections + 1] = p2.Frame.ButtonFrame.Buttons.Cancel.MouseButton1Up:Connect(function()
				p2.Frame.ButtonFrame.Buttons.Cancel.ImageTransparency = 0.3
				p2.Frame.ButtonFrame.Buttons.Cancel.ButtonContent.ButtonMiddleContent.Text.TextTransparency = 0.3
			end)
		end

		if p2.Frame.ButtonFrame.Buttons:FindFirstChild("Confirm") then
			connections[#connections + 1] = p2.Frame.ButtonFrame.Buttons.Confirm.MouseButton1Down:Connect(function()
				p2.Frame.ButtonFrame.Buttons.Confirm.ImageTransparency = 0.5
				p2.Frame.ButtonFrame.Buttons.Confirm.ButtonContent.ButtonMiddleContent.Text.TextTransparency = 0.5
			end)
			connections[#connections + 1] = p2.Frame.ButtonFrame.Buttons.Confirm.MouseButton1Up:Connect(function()
				p2.Frame.ButtonFrame.Buttons.Confirm.ImageTransparency = 0
				p2.Frame.ButtonFrame.Buttons.Confirm.ButtonContent.ButtonMiddleContent.Text.TextTransparency = 0
			end)
			connections[#connections + 1] = p2.Frame.ButtonFrame.Buttons.Confirm.MouseLeave:Connect(function()
				p2.Frame.ButtonFrame.Buttons.Confirm.ImageTransparency = 0
				p2.Frame.ButtonFrame.Buttons.Confirm.ButtonContent.ButtonMiddleContent.Text.TextTransparency = 0
			end)
		end
	elseif p == "Okay" and p2.Holder.ButtonHolder:FindFirstChild("Okay") then
		connections[#connections + 1] = p2.Holder.ButtonHolder.Okay.MouseButton1Down:Connect(function()
			p2.Holder.ButtonHolder.Okay.BackgroundTransparency = 0.5
			p2.Holder.ButtonHolder.Okay.TextTransparency = 0.5
		end)
		connections[#connections + 1] = p2.Holder.ButtonHolder.Okay.MouseButton1Up:Connect(function()
			p2.Holder.ButtonHolder.Okay.BackgroundTransparency = 0
			p2.Holder.ButtonHolder.Okay.TextTransparency = 0
		end)
		connections[#connections + 1] = p2.Holder.ButtonHolder.Okay.MouseLeave:Connect(function()
			p2.Holder.ButtonHolder.Okay.BackgroundTransparency = 0
			p2.Holder.ButtonHolder.Okay.TextTransparency = 0
		end)
	end
end

connections[#connections + 1] = bedButton.Activated:Connect(Teleport)
connections[#connections + 1] = localPlayer:GetAttributeChangedSignal("PvpDisabled"):Connect(Show_PvpDisabled)
connections[#connections + 1] = cancel.Activated:Connect(function()
	Active_InfoFrame("PvpDisabled", false)
end)
connections[#connections + 1] = okay2.Activated:Connect(function()
	Active_InfoFrame("SafezoneInfo", false)
end)
connections[#connections + 1] = okay.Activated:Connect(function()
	Active_InfoFrame("InCombat", false)
end)
connections[#connections + 1] = confirm.Activated:Connect(function()
	if localPlayer:GetAttribute("PvpDisabled") and not localPlayer:GetAttribute("Disabling_Pvp") then
		enablePvp:FireServer()
	end

	Active_InfoFrame("PvpDisabled", false)
end)
connections[#connections + 1] = character:GetAttributeChangedSignal("InCombat"):Connect(function()
	if character:GetAttribute("InCombat") and not safeFrame.InCombat.Visible then
		safeFrame.InCombat.Visible = true
		TweenService:Create(safeFrame.InCombat, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
			ImageTransparency = 0
		}):Play()
		InCombatTime() -- equivalent call inferred; original call site unknown
	elseif character:GetAttribute("InCombat") == nil and safeFrame.InCombat.Visible then
		TweenService:Create(safeFrame.InCombat, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
			ImageTransparency = 1
		}):Play()
		task.wait(0.1)
		safeFrame.InCombat.Visible = false
		safeFrame.InCombat.HoverFrame.Textlabel.Text = "00:30"
		Show_Safezone()
	end
end)

local function CloseMenu_OnDead()
	if portalGui.Enabled then
		portalGui.Enabled = false
	end

	if menu2.Position == UDim2.new(0.5, 0, 0.5, 0) then
		CloseMenu(menu)
	elseif trade2.Position == UDim2.new(0.5, 0, 0.5, 0) then
		CloseMenu(trade)
	elseif settings2.Position == UDim2.new(0.5, 0, 0.5, 0) then
		CloseMenu(settings)
	elseif dropMoney.Position == UDim2.new(0.5, 0, 0.5, 0) then
		CloseMenu(dropMoney2)
	elseif compass2.Position == UDim2.new(0.5, 0, 0.5, 0) then
		CloseMenu(compass)
	elseif auraColor2.Position == UDim2.new(0.5, 0, 0.5, 0) then
		CloseMenu(auraColor)
	elseif color_Index2.Position == UDim2.new(0.5, 0, 0.5, 0) then
		CloseMenu(color_Index)
	elseif gacha_Chances2.Position == UDim2.new(0.5, 0, 0.5, 0) then
		CloseMenu(gacha_Chances)
	elseif party2.Position == UDim2.new(0.5, 0, 0.5, 0) then
		CloseMenu(party)
	elseif boatList2.Position == UDim2.new(0.5, 0, 0.5, 0) then
		CloseMenu(boatList)
	elseif pvpDisabled.Position == UDim2.new(0.5, 0, 0.5, pvpDisabled.Position.Y.Offset) then
		Active_InfoFrame("PvpDisabled", false)
	elseif inCombat.Position == UDim2.new(0.5, 0, 0.5, inCombat.Position.Y.Offset) then
		Active_InfoFrame("InCombat", false)
	elseif safezoneInfo.Position == UDim2.new(0.5, 0, 0.5, safezoneInfo.Position.Y.Offset) then
		Active_InfoFrame("SafezoneInfo", false)
	end

	if v3 then
		v3:Cancel()
		v3 = nil
	end
end

local function ShowHealth()
	local v5 = math.clamp(math.floor(humanoid.Health), 0, (math.floor(humanoid.MaxHealth)))
	local maxHealth = math.floor(humanoid.MaxHealth)

	if maxHealth >= 10000000 then
		if thaiLanguage.Value == true then
			healthFrame.HealthText.Text = `พลังชีวิต {Abbreviate.ShowNum(v5)}/{Abbreviate.ShowNum(maxHealth)}`
		else
			healthFrame.HealthText.Text = `Health {Abbreviate.ShowNum(v5)}/{Abbreviate.ShowNum(maxHealth)}`
		end
	elseif thaiLanguage.Value == true then
		healthFrame.HealthText.Text = `พลังชีวิต {v5}/{maxHealth}`
	else
		healthFrame.HealthText.Text = `Health {v5}/{maxHealth}`
	end

	if v5 / maxHealth < 0.2 then
		healthFrame.Health.Bottom.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(185, 22, 22)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(215, 26, 26))
		})
		healthFrame.Health.Top.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
		healthFrame.FullStroke.UiStroke.Color = Color3.fromRGB(255, 50, 50)
		healthFrame.HealthText.UIStroke.Color = Color3.fromRGB(63, 0, 0)
		healthFrame.BackgroundColor3 = Color3.fromRGB(100, 20, 20)
	else
		healthFrame.Health.Bottom.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 134, 40)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(91, 255, 32))
		})
		healthFrame.Health.Top.BackgroundColor3 = Color3.fromRGB(67, 234, 49)
		healthFrame.FullStroke.UiStroke.Color = Color3.fromRGB(69, 185, 1)
		healthFrame.HealthText.UIStroke.Color = Color3.fromRGB(31, 108, 22)
		healthFrame.BackgroundColor3 = Color3.fromRGB(39, 100, 8)
	end

	if maxHealth <= v5 then
		TweenService:Create(healthFrame.Health, TweenInfo.new(0.25, Enum.EasingStyle.Cubic), {
			Size = UDim2.new(1, 0, 1, 0)
		}):Play()
	else
		TweenService:Create(healthFrame.Health, TweenInfo.new(0.25, Enum.EasingStyle.Cubic), {
			Size = UDim2.new(v5 / maxHealth, 0, 1, 0)
		}):Play()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function TradeAmount_Changed()
	if trade2:GetAttribute("Amount") <= 0 then
		if newRequests.Visible then
			newRequests.Visible = false
		end
	elseif not newRequests.Visible then
		newRequests.Visible = true
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function CompassAmount_Changed()
	if compass2:GetAttribute("Amount") <= 0 then
		if newRequests3.Visible then
			newRequests3.Visible = false
		end
	elseif not newRequests3.Visible then
		newRequests3.Visible = true
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function PartyAmount_Changed()
	if party2:GetAttribute("Amount") <= 0 then
		if newRequests2.Visible then
			newRequests2.Visible = false
		end
	elseif not newRequests2.Visible then
		newRequests2.Visible = true
	end
end

local function Language_Changed()
	if menu and menu.Parent then
		if localPlayer:GetAttribute("TH") then
			menu.TextLabel.Text = "เมนู"
		else
			menu.TextLabel.Text = "Menu"
		end
	end

	if safeFrame and safeFrame.Parent then
		if localPlayer:GetAttribute("TH") then
			safeFrame.SafezoneInfo.HoverFrame.Textlabel.Text = "โซนปลอดภัย"
		else
			safeFrame.SafezoneInfo.HoverFrame.Textlabel.Text = "Safezone"
		end
	end
end

diedConnection = humanoid.Died:Connect(function()
	CloseMenu_OnDead()

	if diedConnection then
		diedConnection:Disconnect()
		diedConnection = nil
	end

	if characterRemovingConnection then
		characterRemovingConnection:Disconnect()
		characterRemovingConnection = nil
	end

	for _, connection in ipairs(connections) do
		if connection then
			connection:Disconnect()
		end
	end
end)
characterRemovingConnection = localPlayer.CharacterRemoving:Connect(function()
	CloseMenu_OnDead()

	if diedConnection then
		diedConnection:Disconnect()
		diedConnection = nil
	end

	if characterRemovingConnection then
		characterRemovingConnection:Disconnect()
		characterRemovingConnection = nil
	end

	for _, connection in ipairs(connections) do
		if connection then
			connection:Disconnect()
		end
	end
end)
CompassAmount_Changed() -- equivalent call inferred; original call site unknown
TradeAmount_Changed() -- equivalent call inferred; original call site unknown
PartyAmount_Changed() -- equivalent call inferred; original call site unknown

if fightingStyle.Enabled then
	fightingStyle.Enabled = false
elseif weapon.Enabled then
	weapon.Enabled = false
elseif power.Enabled then
	power.Enabled = false
end

ShowHealth()
Show_Safezone()
Show_PvpDisabled()
Language_Changed()
local teleportCD = cooldown:FindFirstChild("TeleportCD")

if teleportCD then
	task.spawn(StartCooldown, teleportCD)
end

connections[#connections + 1] = localPlayer:GetAttributeChangedSignal("TH"):Connect(Language_Changed)
connections[#connections + 1] = humanoid.HealthChanged:Connect(ShowHealth)
connections[#connections + 1] = menu.Activated:Connect(function()
	ActiveMenu(menu)
end)
connections[#connections + 1] = trade.Activated:Connect(function()
	ActiveMenu(trade)
end)
connections[#connections + 1] = settings.Activated:Connect(function()
	ActiveMenu(settings)
end)
connections[#connections + 1] = dropMoney2.Activated:Connect(function()
	ActiveMenu(dropMoney2)
end)
connections[#connections + 1] = compass.Activated:Connect(function()
	ActiveMenu(compass)
end)
connections[#connections + 1] = party.Activated:Connect(function()
	ActiveMenu(party)
end)
connections[#connections + 1] = UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Enum.KeyCode.M then
		ActiveMenu(menu)
	end
end)
connections[#connections + 1] = main.HeadBar.Close.Activated:Connect(function()
	ActiveMenu(menu)
end)
connections[#connections + 1] = main2.HeadBar.Close.Activated:Connect(function()
	ActiveMenu(trade)
end)
connections[#connections + 1] = main3.HeadBar.Close.Activated:Connect(function()
	ActiveMenu(settings)
end)
connections[#connections + 1] = main4.HeadBar.Close.Activated:Connect(function()
	ActiveMenu(dropMoney2)
end)
connections[#connections + 1] = main5.HeadBar.Close.Activated:Connect(function()
	ActiveMenu(compass)
end)
connections[#connections + 1] = main6.HeadBar.Close.Activated:Connect(function()
	CloseMenu(auraColor)
	PlaySound.PlaySound(localPlayer, clickSound)
end)
connections[#connections + 1] = main7.HeadBar.Close.Activated:Connect(function()
	CloseMenu(color_Index)
	PlaySound.PlaySound(localPlayer, clickSound)
end)
connections[#connections + 1] = main8.HeadBar.Close.Activated:Connect(function()
	CloseMenu(gacha_Chances)
	PlaySound.PlaySound(localPlayer, clickSound)
end)
connections[#connections + 1] = main9.HeadBar.Close.Activated:Connect(function()
	CloseMenu(party)
	PlaySound.PlaySound(localPlayer, clickSound)
end)
connections[#connections + 1] = main10.HeadBar.Close.Activated:Connect(function()
	CloseMenu(boatList)
	PlaySound.PlaySound(localPlayer, clickSound)
end)
Setup_ButtonEffects("Confirm", pvpDisabled)
Setup_ButtonEffects("Okay", inCombat)
Setup_ButtonEffects("Okay", safezoneInfo)

for _, button in ipairs(main.AllMenu:GetChildren()) do
	if not button:IsA("GuiButton") then
		continue
	end

	local v5 = button
	connections[#connections + 1] = button.Activated:Connect(function()
		OpenOtherFrame(menu, v5)
	end)
end

for _, button in ipairs(main5.AllMenu:GetChildren()) do
	if not button:IsA("GuiButton") then
		continue
	end

	local v5 = button
	connections[#connections + 1] = button.Activated:Connect(function()
		OpenOtherFrame(compass, v5)
	end)
end

connections[#connections + 1] = guiEvents.GuiEvent.Event:Connect(function(p)
	local menuName = p.MenuName

	if menuName == "Menu" then
		if p.Action == "Close" then
			if menu2.Position == UDim2.new(0.5, 0, 0.5, 0) then
				CloseMenu(menu)
			elseif trade2.Position == UDim2.new(0.5, 0, 0.5, 0) then
				CloseMenu(trade)
			elseif settings2.Position == UDim2.new(0.5, 0, 0.5, 0) then
				CloseMenu(settings)
			elseif dropMoney.Position == UDim2.new(0.5, 0, 0.5, 0) then
				CloseMenu(dropMoney2)
			elseif compass2.Position == UDim2.new(0.5, 0, 0.5, 0) then
				CloseMenu(compass)
			elseif auraColor2.Position == UDim2.new(0.5, 0, 0.5, 0) then
				CloseMenu(auraColor)
			elseif color_Index2.Position == UDim2.new(0.5, 0, 0.5, 0) then
				CloseMenu(color_Index)
			elseif gacha_Chances2.Position == UDim2.new(0.5, 0, 0.5, 0) then
				CloseMenu(gacha_Chances)
			elseif party2.Position == UDim2.new(0.5, 0, 0.5, 0) then
				CloseMenu(party)
			elseif boatList2.Position == UDim2.new(0.5, 0, 0.5, 0) then
				CloseMenu(boatList)
			elseif pvpDisabled.Position == UDim2.new(0.5, 0, 0.5, pvpDisabled.Position.Y.Offset) then
				Active_InfoFrame("PvpDisabled", false)
			elseif inCombat.Position == UDim2.new(0.5, 0, 0.5, inCombat.Position.Y.Offset) then
				Active_InfoFrame("InCombat", false)
			elseif safezoneInfo.Position == UDim2.new(0.5, 0, 0.5, safezoneInfo.Position.Y.Offset) then
				Active_InfoFrame("SafezoneInfo", false)
			end

			if v3 then
				v3:Cancel()
				v3 = nil
			end
		end
	elseif menuName == "Settings" then
		if p.Action == "Open" then
			ActiveMenu(settings)
		end
	elseif menuName == "AuraColor" then
		if p.Action == "Open" and auraColor:GetAttribute("IsOpen") == false and auraColor:GetAttribute("CanOpen") == true then
			PlaySound.PlaySound(localPlayer, clickSound)
			OpenMenu(auraColor)
		end
	elseif menuName == "IndexColor" then
		if p.Action == "Open" and color_Index:GetAttribute("IsOpen") == false and color_Index:GetAttribute("CanOpen") == true then
			OpenMenu(color_Index)
		end
	elseif menuName == "BoatList" then
		local action = p.Action

		if action == "Open" then
			if boatList:GetAttribute("IsOpen") == false and boatList:GetAttribute("CanOpen") == true then
				OpenMenu(boatList)
			end
		elseif action == "Close" and boatList:GetAttribute("IsOpen") == true and boatList:GetAttribute("CanOpen") == true and boatList2.Position == UDim2.new(
			0.5,
			0,
			0.5,
			0
		) then
			CloseMenu(boatList)
		end
	elseif menuName == "GachaChances" and p.Action == "Open" and gacha_Chances:GetAttribute("IsOpen") == false and gacha_Chances:GetAttribute("CanOpen") == true then
		OpenMenu(gacha_Chances)
	end
end)
connections[#connections + 1] = thaiLanguage.Changed:Connect(ShowHealth)
connections[#connections + 1] = topbar.Event:Connect(function(p, _)
	if p == "UpdateLog" then
		ActiveMenu(updateLog)
	end
end)
connections[#connections + 1] = party2:GetAttributeChangedSignal("Amount"):Connect(PartyAmount_Changed)
connections[#connections + 1] = trade2:GetAttributeChangedSignal("Amount"):Connect(TradeAmount_Changed)
connections[#connections + 1] = compass2:GetAttributeChangedSignal("Amount"):Connect(CompassAmount_Changed)
connections[#connections + 1] = character:GetAttributeChangedSignal("Safezone"):Connect(function()
	Show_Safezone()
end)

for _, button in ipairs(safeFrame:GetChildren()) do
	if not button:IsA("GuiButton") then
		continue
	end

	local hoverFrame = button:FindFirstChild("HoverFrame")
	local textlabel

	if hoverFrame then
		textlabel = hoverFrame:FindFirstChild("Textlabel")
	end

	local uIStroke

	if textlabel then
		uIStroke = textlabel:FindFirstChild("UIStroke")
	end

	if not (hoverFrame and textlabel and uIStroke) then
		continue
	end

	if button.Name == "PvpDisabled" or button.Name == "SafezoneInfo" or button.Name == "InCombat" then
		local v5 = button
		connections[#connections + 1] = button.Activated:Connect(function()
			if mainGui[v5.Name].Position == UDim2.new(0.5, 0, 0.5, mainGui[v5.Name].Position.Y.Offset) then
				Active_InfoFrame(v5.Name, false)
			else
				Active_InfoFrame(v5.Name, true)
			end
		end)
	end

	local v5 = button
	local v6 = hoverFrame
	local v7 = textlabel
	local v8 = uIStroke
	connections[#connections + 1] = button.MouseEnter:Connect(function()
		if v5.Name == "InCombat" then
			if character:GetAttribute("InCombat") then
				safeFrame.InCombat.HoverFrame.Textlabel.Text = convertToHMS((math.clamp(
					inCombat_Duration - (workspace:GetServerTimeNow() - character:GetAttribute("InCombat")),
					0,
					inCombat_Duration
				)))
			end
		elseif v5.Name == "PvpDisabled" and localPlayer:GetAttribute("PvpDisabled") then
			safeFrame.PvpDisabled.HoverFrame.Textlabel.Text = convertToHMS((math.clamp(
				pvpDisabled_Time - (workspace:GetServerTimeNow() - localPlayer:GetAttribute("PvpDisabled")),
				0,
				pvpDisabled_Time
			)))
		end

		if v3 == nil then
			v3 = Shiny.new(v6.ShineFrame, 1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, -1, false, 0.5)
			v3:Play()
		end

		TweenService:Create(v6, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
			ImageTransparency = 0
		}):Play()
		TweenService:Create(v7, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
			TextTransparency = 0
		}):Play()
		TweenService:Create(v8, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
			Transparency = 0
		}):Play()
	end)
	local v9 = hoverFrame
	local v10 = textlabel
	local v11 = uIStroke
	connections[#connections + 1] = button.MouseLeave:Connect(function()
		if v3 then
			v3:Cancel()
			v3 = nil
		end

		TweenService:Create(v9, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
			ImageTransparency = 1
		}):Play()
		TweenService:Create(v10, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
			TextTransparency = 1
		}):Play()
		TweenService:Create(v11, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
			Transparency = 1
		}):Play()
	end)

	if not v4 then
		continue
	end

	local v12 = hoverFrame
	local v13 = textlabel
	local v14 = uIStroke
	connections[#connections + 1] = button.MouseButton1Up:Connect(function()
		if v3 then
			v3:Cancel()
			v3 = nil
		end

		TweenService:Create(v12, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
			ImageTransparency = 1
		}):Play()
		TweenService:Create(v13, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
			TextTransparency = 1
		}):Play()
		TweenService:Create(v14, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
			Transparency = 1
		}):Play()
	end)
	local v15 = button
	local v16 = hoverFrame
	local v17 = textlabel
	local v18 = uIStroke
	connections[#connections + 1] = button.MouseButton1Down:Connect(function()
		if v15.Name == "InCombat" then
			if character:GetAttribute("InCombat") then
				safeFrame.InCombat.HoverFrame.Textlabel.Text = convertToHMS((math.clamp(
					inCombat_Duration - (workspace:GetServerTimeNow() - character:GetAttribute("InCombat")),
					0,
					inCombat_Duration
				)))
			end
		elseif v15.Name == "PvpDisabled" and localPlayer:GetAttribute("PvpDisabled") then
			safeFrame.PvpDisabled.HoverFrame.Textlabel.Text = convertToHMS((math.clamp(
				pvpDisabled_Time - (workspace:GetServerTimeNow() - localPlayer:GetAttribute("PvpDisabled")),
				0,
				pvpDisabled_Time
			)))
		end

		if v3 == nil then
			v3 = Shiny.new(v16.ShineFrame, 1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, -1, false, 0.5)
			v3:Play()
		end

		TweenService:Create(v16, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
			ImageTransparency = 0
		}):Play()
		TweenService:Create(v17, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
			TextTransparency = 0
		}):Play()
		TweenService:Create(v18, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
			Transparency = 0
		}):Play()
	end)
end

function Active_InfoFrame(childName: string, flag3: boolean)
	local DELAY_DURATION = 0.5

	if childName == "PvpDisabled" then
		if flag3 == true and pvpDisabled:GetAttribute("IsOpen") == false and pvpDisabled:GetAttribute("CanOpen") then
			CloseOtherMenu(safeFrame:FindFirstChild("PvpDisabled"))
			pvpDisabled:SetAttribute("CanOpen", false)

			if not pvpDisabled.Visible then
				pvpDisabled.Visible = true
			end

			pvpDisabled.Position = UDim2.new(0.5, 0, 1.5, pvpDisabled.Position.Y.Offset)
			TweenService:Create(pvpDisabled, tweenInfo, {
				Position = UDim2.new(0.5, 0, 0.5, pvpDisabled.Position.Y.Offset)
			}):Play()
			pvpDisabled:SetAttribute("IsOpen", true)
			pvpDisabled:SetAttribute("CanOpen", true)
		elseif flag3 == false and pvpDisabled:GetAttribute("IsOpen") and pvpDisabled:GetAttribute("CanOpen") then
			pvpDisabled:SetAttribute("CanOpen", false)
			TweenService:Create(pvpDisabled, tweenInfo, {
				Position = UDim2.new(0.5, 0, 1.5, pvpDisabled.Position.Y.Offset)
			}):Play()
			pvpDisabled:SetAttribute("IsOpen", false)
			pvpDisabled:SetAttribute("CanOpen", true)
			task.delay(DELAY_DURATION, function()
				if pvpDisabled.Position == UDim2.new(0.5, 0, 1.5, pvpDisabled.Position.Y.Offset) and pvpDisabled.Visible then
					pvpDisabled.Visible = false
				end
			end)
		end
	elseif childName == "SafezoneInfo" then
		if flag3 == true and safezoneInfo:GetAttribute("IsOpen") == false and safezoneInfo:GetAttribute("CanOpen") then
			CloseOtherMenu(safeFrame:FindFirstChild("SafezoneInfo"))
			safezoneInfo:SetAttribute("CanOpen", false)

			if not safezoneInfo.Visible then
				safezoneInfo.Visible = true
			end

			safezoneInfo.Position = UDim2.new(0.5, 0, 1.5, safezoneInfo.Position.Y.Offset)
			TweenService:Create(safezoneInfo, tweenInfo, {
				Position = UDim2.new(0.5, 0, 0.5, safezoneInfo.Position.Y.Offset)
			}):Play()
			safezoneInfo:SetAttribute("IsOpen", true)
			safezoneInfo:SetAttribute("CanOpen", true)
		elseif flag3 == false and safezoneInfo:GetAttribute("IsOpen") and safezoneInfo:GetAttribute("CanOpen") then
			safezoneInfo:SetAttribute("CanOpen", false)
			TweenService:Create(safezoneInfo, tweenInfo, {
				Position = UDim2.new(0.5, 0, 1.5, safezoneInfo.Position.Y.Offset)
			}):Play()
			safezoneInfo:SetAttribute("IsOpen", false)
			safezoneInfo:SetAttribute("CanOpen", true)
			task.delay(DELAY_DURATION, function()
				if safezoneInfo.Position == UDim2.new(0.5, 0, 1.5, safezoneInfo.Position.Y.Offset) and safezoneInfo.Visible then
					safezoneInfo.Visible = false
				end
			end)
		end
	elseif childName == "InCombat" then
		if flag3 == true and inCombat:GetAttribute("IsOpen") == false and inCombat:GetAttribute("CanOpen") then
			CloseOtherMenu(safeFrame:FindFirstChild("InCombat"))
			inCombat:SetAttribute("CanOpen", false)

			if not inCombat.Visible then
				inCombat.Visible = true
			end

			inCombat.Position = UDim2.new(0.5, 0, 1.5, inCombat.Position.Y.Offset)
			TweenService:Create(inCombat, tweenInfo, {
				Position = UDim2.new(0.5, 0, 0.5, inCombat.Position.Y.Offset)
			}):Play()
			inCombat:SetAttribute("IsOpen", true)
			inCombat:SetAttribute("CanOpen", true)
		elseif flag3 == false and inCombat:GetAttribute("IsOpen") and inCombat:GetAttribute("CanOpen") then
			inCombat:SetAttribute("CanOpen", false)
			TweenService:Create(inCombat, tweenInfo, {
				Position = UDim2.new(0.5, 0, 1.5, inCombat.Position.Y.Offset)
			}):Play()
			inCombat:SetAttribute("IsOpen", false)
			inCombat:SetAttribute("CanOpen", true)
			task.delay(DELAY_DURATION, function()
				if inCombat.Position == UDim2.new(0.5, 0, 1.5, inCombat.Position.Y.Offset) and inCombat.Visible then
					inCombat.Visible = false
				end
			end)
		end
	end
end

function OpenOtherFrame(p, p2)
	if p.Name == "Menu" then
		if main.AllMenu:GetAttribute("CurrentOpen") ~= p2.Name then
			for _, frame2 in ipairs(main.Container:GetChildren()) do
				if frame2:IsA("Frame") and frame2.Name ~= p2.Name then
					FrameTrigger.CloseFrame(frame2.Name, main.Container)
				end
			end

			main.AllMenu:SetAttribute("CurrentOpen", p2.Name)
			guiEvents.GuiEvent:Fire({
				MenuName = main.AllMenu:GetAttribute("CurrentOpen"),
				Action = "Open"
			})
			PlaySound.PlaySound(localPlayer, clickSound)
			FrameTrigger.OpenFrame(p2.Name, main.Container)
			TextEffect(main.AllMenu, p2)
		end
	elseif p.Name == "Compass" and main5.AllMenu:GetAttribute("CurrentOpen") ~= p2.Name then
		for _, frame2 in ipairs(main5.Container:GetChildren()) do
			if frame2:IsA("Frame") and frame2.Name ~= p2.Name then
				FrameTrigger.CloseFrame(frame2.Name, main5.Container)
			end
		end

		main5.AllMenu:SetAttribute("CurrentOpen", p2.Name)
		PlaySound.PlaySound(localPlayer, clickSound)
		FrameTrigger.OpenFrame(p2.Name, main5.Container)
		TextEffect(main5.AllMenu, p2)
	end
end

function ActiveMenu(instance)
	if CheckIfAlive(character) then
		if instance.Name == "Menu" then
			if instance:GetAttribute("IsOpen") == false and instance:GetAttribute("CanOpen") == true then
				PlaySound.PlaySound(localPlayer, clickSound)
				OpenMenu(instance)
			elseif instance:GetAttribute("IsOpen") == true and instance:GetAttribute("CanOpen") == true then
				PlaySound.PlaySound(localPlayer, clickSound)
				CloseMenu(instance)
			end
		elseif instance.Name == "Trade" then
			if instance:GetAttribute("IsOpen") == false and instance:GetAttribute("CanOpen") == true then
				PlaySound.PlaySound(localPlayer, clickSound)
				OpenMenu(instance)
			elseif instance:GetAttribute("IsOpen") == true and instance:GetAttribute("CanOpen") == true then
				PlaySound.PlaySound(localPlayer, clickSound)
				CloseMenu(instance)
			end
		elseif instance.Name == "Settings" then
			if instance:GetAttribute("IsOpen") == false and instance:GetAttribute("CanOpen") == true then
				PlaySound.PlaySound(localPlayer, clickSound)
				OpenMenu(instance)
			elseif instance:GetAttribute("IsOpen") == true and instance:GetAttribute("CanOpen") == true then
				PlaySound.PlaySound(localPlayer, clickSound)
				CloseMenu(instance)
			end
		elseif instance.Name == "UpdateLog" then
			if instance:GetAttribute("IsOpen") == false and instance:GetAttribute("CanOpen") == true then
				PlaySound.PlaySound(localPlayer, clickSound)
				OpenMenu(instance)
			elseif instance:GetAttribute("IsOpen") == true and instance:GetAttribute("CanOpen") == true then
				PlaySound.PlaySound(localPlayer, clickSound)
				CloseMenu(instance)
			end
		elseif instance.Name == "DropMoney" then
			if instance:GetAttribute("IsOpen") == false and instance:GetAttribute("CanOpen") == true then
				PlaySound.PlaySound(localPlayer, clickSound)
				OpenMenu(instance)
			elseif instance:GetAttribute("IsOpen") == true and instance:GetAttribute("CanOpen") == true then
				PlaySound.PlaySound(localPlayer, clickSound)
				CloseMenu(instance)
			end
		elseif instance.Name == "Compass" then
			if instance:GetAttribute("IsOpen") == false and instance:GetAttribute("CanOpen") == true then
				PlaySound.PlaySound(localPlayer, clickSound)
				OpenMenu(instance)
			elseif instance:GetAttribute("IsOpen") == true and instance:GetAttribute("CanOpen") == true then
				PlaySound.PlaySound(localPlayer, clickSound)
				CloseMenu(instance)
			end
		elseif instance.Name == "Party" then
			if instance:GetAttribute("IsOpen") == false and instance:GetAttribute("CanOpen") == true then
				PlaySound.PlaySound(localPlayer, clickSound)
				OpenMenu(instance)
			elseif instance:GetAttribute("IsOpen") == true and instance:GetAttribute("CanOpen") == true then
				PlaySound.PlaySound(localPlayer, clickSound)
				CloseMenu(instance)
			end
		end
	end
end

function TextEffect(instance, p)
	for _, button in ipairs(instance:GetChildren()) do
		if button:IsA("GuiButton") and button ~= p then
			button.TextLabel.TextTransparency = 0.5
		end
	end

	TweenService:Create(
		instance.Parent.Line.Divider.Indicator,
		TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
		{
			Position = v[p.Name]
		}
	):Play()
	p.TextLabel.TextTransparency = 0
end

function Format(p)
	return string.format("%02i", p)
end

function convertToHMS(p)
	local v5 = (p - p % 60) / 60
	local v6 = p - v5 * 60
	local v7 = v5 - (v5 - v5 % 60) / 60 * 60
	return Format(v7) .. ":" .. Format(v6)
end

function CloseMenu(instance)
	if instance:GetAttribute("IsOpen") == true and instance:GetAttribute("CanOpen") == true then
		instance:SetAttribute("CanOpen", false)
		local v5

		if instance.Name == "Menu" then
			v5 = menu2
		elseif instance.Name == "Trade" then
			v5 = trade2
		elseif instance.Name == "Settings" then
			v5 = settings2
		elseif instance.Name == "DropMoney" then
			v5 = dropMoney
		elseif instance.Name == "Compass" then
			v5 = compass2
		elseif instance.Name == "AuraColor" then
			v5 = auraColor2
		elseif instance.Name == "Color_Index" then
			v5 = color_Index2
		elseif instance.Name == "Gacha_Chances" then
			v5 = gacha_Chances2
		elseif instance.Name == "Party" then
			v5 = party2
		elseif instance.Name == "BoatList" then
			v5 = boatList2
		else
			v5 = updateLog2
		end

		if v5.Name == "Menu" and menu2.Main.Container.Profile.Frame.BoostFrame.Visible == true then
			guiEvents.GuiEvent:Fire({
				MenuName = main.AllMenu:GetAttribute("CurrentOpen"),
				Action = "CloseBoostFrame"
			})
		end

		if instance.Name == "UpdateLog" then
			topbar:Fire("UpdateLog_Set", "Disable")
		end

		TweenService:Create(v5, tweenInfo, {
			Position = UDim2.new(0.5, 0, 1.5, 0)
		}):Play()
		instance:SetAttribute("IsOpen", false)
		instance:SetAttribute("CanOpen", true)
		task.delay(0.5, function()
			if v5.Position == UDim2.new(0.5, 0, 1.5, 0) and v5.Visible then
				v5.Visible = false
			end
		end)
	end
end

function CloseOtherMenu(p)
	for _, button in ipairs(safeFrame:GetChildren()) do
		if not (button:IsA("GuiButton") and mainGui[button.Name].Position == UDim2.new(
			0.5,
			0,
			0.5,
			mainGui[button.Name].Position.Y.Offset
		)) then
			continue
		end

		if button.Name == p.Name then
			continue
		end

		Active_InfoFrame(button.Name, false)
		break
	end

	for _, button in ipairs(menuFrame:GetChildren()) do
		if not (button:IsA("GuiButton") and button.Name ~= p.Name and button:GetAttribute("IsOpen") == true and button:GetAttribute("CanOpen") == true) then
			continue
		end

		CloseMenu(button)
		break
	end

	if p.Name ~= "Menu" and menu:GetAttribute("IsOpen") == true and menu:GetAttribute("CanOpen") == true then
		CloseMenu(menu)
	end

	if p.Name ~= "UpdateLog" and updateLog:GetAttribute("IsOpen") == true then
		updateLog:SetAttribute("IsOpen", false)
	end
end

function OpenMenu(instance)
	if instance.Name == "Menu" then
		CloseOtherMenu(menu)
		instance:SetAttribute("CanOpen", false)

		if not menu2.Visible then
			menu2.Visible = true
		end

		menu2.Position = UDim2.new(0.5, 0, 1.5, 0)
		TweenService:Create(menu2, tweenInfo, {
			Position = UDim2.new(0.5, 0, 0.5, 0)
		}):Play()
		guiEvents.GuiEvent:Fire({
			MenuName = main.AllMenu:GetAttribute("CurrentOpen"),
			Action = "Open"
		})
		TextEffect(main.AllMenu, main.AllMenu:FindFirstChild(main.AllMenu:GetAttribute("CurrentOpen")))
		instance:SetAttribute("IsOpen", true)
		instance:SetAttribute("CanOpen", true)
	elseif instance.Name == "Trade" then
		trade2:SetAttribute("Amount", 0)
		CloseOtherMenu(trade)
		instance:SetAttribute("CanOpen", false)

		if not trade2.Visible then
			trade2.Visible = true
		end

		trade2.Position = UDim2.new(0.5, 0, 1.5, 0)
		TweenService:Create(trade2, tweenInfo, {
			Position = UDim2.new(0.5, 0, 0.5, 0)
		}):Play()
		guiEvents.GuiEvent:Fire({
			MenuName = "Trading",
			Action = "Open"
		})
		instance:SetAttribute("IsOpen", true)
		instance:SetAttribute("CanOpen", true)
	elseif instance.Name == "Settings" then
		CloseOtherMenu(settings)
		instance:SetAttribute("CanOpen", false)

		if not settings2.Visible then
			settings2.Visible = true
		end

		settings2.Position = UDim2.new(0.5, 0, 1.5, 0)
		TweenService:Create(settings2, tweenInfo, {
			Position = UDim2.new(0.5, 0, 0.5, 0)
		}):Play()
		instance:SetAttribute("IsOpen", true)
		instance:SetAttribute("CanOpen", true)
	elseif instance.Name == "UpdateLog" then
		CloseOtherMenu(updateLog)
		instance:SetAttribute("CanOpen", false)

		if not updateLog2.Visible then
			updateLog2.Visible = true
		end

		updateLog2.Position = UDim2.new(0.5, 0, 1.5, 0)
		TweenService:Create(updateLog2, tweenInfo, {
			Position = UDim2.new(0.5, 0, 0.5, 0)
		}):Play()
		instance:SetAttribute("IsOpen", true)
		instance:SetAttribute("CanOpen", true)
	elseif instance.Name == "DropMoney" then
		CloseOtherMenu(dropMoney2)
		instance:SetAttribute("CanOpen", false)

		if not dropMoney.Visible then
			dropMoney.Visible = true
		end

		dropMoney.Position = UDim2.new(0.5, 0, 1.5, 0)
		TweenService:Create(dropMoney, tweenInfo, {
			Position = UDim2.new(0.5, 0, 0.5, 0)
		}):Play()
		instance:SetAttribute("IsOpen", true)
		instance:SetAttribute("CanOpen", true)
	elseif instance.Name == "Compass" then
		compass2:SetAttribute("Amount", 0)
		CloseOtherMenu(compass)
		instance:SetAttribute("CanOpen", false)

		if not compass2.Visible then
			compass2.Visible = true
		end

		compass2.Position = UDim2.new(0.5, 0, 1.5, 0)
		TweenService:Create(compass2, tweenInfo, {
			Position = UDim2.new(0.5, 0, 0.5, 0)
		}):Play()
		instance:SetAttribute("IsOpen", true)
		instance:SetAttribute("CanOpen", true)
	elseif instance.Name == "AuraColor" then
		CloseOtherMenu(auraColor)
		instance:SetAttribute("CanOpen", false)

		if not auraColor2.Visible then
			auraColor2.Visible = true
		end

		auraColor2.Position = UDim2.new(0.5, 0, 1.5, 0)
		TweenService:Create(auraColor2, tweenInfo, {
			Position = UDim2.new(0.5, 0, 0.5, 0)
		}):Play()
		instance:SetAttribute("IsOpen", true)
		instance:SetAttribute("CanOpen", true)
		guiEvents.GuiEvent:Fire({
			MenuName = "AuraColor",
			Action = "Refresh"
		})
	elseif instance.Name == "BoatList" then
		CloseOtherMenu(boatList)
		instance:SetAttribute("CanOpen", false)

		if not boatList2.Visible then
			boatList2.Visible = true
		end

		boatList2.Position = UDim2.new(0.5, 0, 1.5, 0)
		TweenService:Create(boatList2, tweenInfo, {
			Position = UDim2.new(0.5, 0, 0.5, 0)
		}):Play()
		instance:SetAttribute("IsOpen", true)
		instance:SetAttribute("CanOpen", true)
		guiEvents.GuiEvent:Fire({
			MenuName = "Refresh_BoatList",
			Action = "Open"
		})
	elseif instance.Name == "Color_Index" then
		CloseOtherMenu(color_Index)
		instance:SetAttribute("CanOpen", false)

		if not color_Index2.Visible then
			color_Index2.Visible = true
		end

		color_Index2.Position = UDim2.new(0.5, 0, 1.5, 0)
		TweenService:Create(color_Index2, tweenInfo, {
			Position = UDim2.new(0.5, 0, 0.5, 0)
		}):Play()
		instance:SetAttribute("IsOpen", true)
		instance:SetAttribute("CanOpen", true)
		guiEvents.GuiEvent:Fire({
			MenuName = "ColorIndex",
			Action = "Refresh"
		})
	elseif instance.Name == "Gacha_Chances" then
		CloseOtherMenu(gacha_Chances)
		instance:SetAttribute("CanOpen", false)

		if not gacha_Chances2.Visible then
			gacha_Chances2.Visible = true
		end

		gacha_Chances2.Position = UDim2.new(0.5, 0, 1.5, 0)
		TweenService:Create(gacha_Chances2, tweenInfo, {
			Position = UDim2.new(0.5, 0, 0.5, 0)
		}):Play()
		instance:SetAttribute("IsOpen", true)
		instance:SetAttribute("CanOpen", true)
		guiEvents.GuiEvent:Fire({
			MenuName = "ChancesGacha",
			Action = "Open"
		})
	elseif instance.Name == "Party" then
		party2:SetAttribute("Amount", 0)
		CloseOtherMenu(party)
		instance:SetAttribute("CanOpen", false)

		if not party2.Visible then
			party2.Visible = true
		end

		party2.Position = UDim2.new(0.5, 0, 1.5, 0)
		TweenService:Create(party2, tweenInfo, {
			Position = UDim2.new(0.5, 0, 0.5, 0)
		}):Play()
		instance:SetAttribute("IsOpen", true)
		instance:SetAttribute("CanOpen", true)
		guiEvents.GuiEvent:Fire({
			MenuName = "Party",
			Action = "Open"
		})
	end
end