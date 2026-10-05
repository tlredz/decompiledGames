local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
game:GetService("Teams")
local localPlayer = Players.LocalPlayer
local playerData = localPlayer:WaitForChild("PlayerData", 60)
local thaiLanguage = localPlayer:WaitForChild("PlayerSettings", 60):WaitForChild("ThaiLanguage")
local exp = playerData:WaitForChild("Exp")
local maxExp = playerData:WaitForChild("MaxExp")
local level = playerData:WaitForChild("Level")
local money = playerData:WaitForChild("Money")
local gem = playerData:WaitForChild("Gem")
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript")
local modules = ReplicatedStorage:WaitForChild("Modules")
local otherEvent = ReplicatedStorage:WaitForChild("OtherEvent")
local Abbreviate = require(moduleScript:WaitForChild("Abbreviate"))
local Setting = require(moduleScript:WaitForChild("Setting"))
require(moduleScript:WaitForChild("SetText"))
require(modules:WaitForChild("FadeModule"))
require(modules:WaitForChild("Shiny"))
otherEvent.MainEvents:WaitForChild("Ability")
local parent = script.Parent
local expFrame = parent.ExpFrame
local healthFrame = parent.HealthFrame
local playerName = parent.PlayerName
local cubic = Enum.EasingStyle.Cubic
local currencyFrame = parent.CurrencyFrame
local currencyFrame_Mobile = parent.CurrencyFrame_Mobile
local pvpDisabled = parent.PvpDisabled
local safezoneInfo = parent.SafezoneInfo
local inCombat = parent.InCombat
local maxLevel = Setting.Setting.MaxLevel
local touchEnabled = UserInputService.TouchEnabled == true
local currencyFrame_Mobile2

if touchEnabled then
	currencyFrame_Mobile2 = parent.CurrencyFrame_Mobile
else
	currencyFrame_Mobile2 = parent.CurrencyFrame
end

local money2 = currencyFrame_Mobile2.Money
local gem2 = currencyFrame_Mobile2.Gem

while localPlayer:GetAttribute("LoadedData") == nil or not localPlayer.Team do
	task.wait(0.5)
end

if touchEnabled == true then
	currencyFrame.Visible = false
	currencyFrame_Mobile.Visible = true
	expFrame.UiStroke.Thickness = 2.5
	healthFrame.UiStroke.Thickness = 2.5
	expFrame.FullStroke.UiStroke.Thickness = 1
	healthFrame.FullStroke.UiStroke.Thickness = 1
	playerName.Position = UDim2.new(0.13, 0, 0.84, 0)
	playerName.Size = UDim2.new(0.237, 0, 0.031, 2)

	for _, uIStroke in ipairs(currencyFrame_Mobile2:GetDescendants()) do
		if uIStroke:IsA("UIStroke") then
			uIStroke.Enabled = false
		end
	end

	for _, uIStroke in ipairs(pvpDisabled:GetDescendants()) do
		if uIStroke:IsA("UIStroke") then
			uIStroke.Enabled = false
		end
	end

	for _, uIStroke in ipairs(safezoneInfo:GetDescendants()) do
		if uIStroke:IsA("UIStroke") then
			uIStroke.Enabled = false
		end
	end

	for _, uIStroke in ipairs(inCombat:GetDescendants()) do
		if uIStroke:IsA("UIStroke") then
			uIStroke.Enabled = false
		end
	end

	local uIStroke = playerName:FindFirstChild("UIStroke")
	local uIStroke2 = healthFrame.HealthText:FindFirstChild("UIStroke")
	local uIStroke3 = expFrame.ExpText:FindFirstChild("UIStroke")

	if uIStroke then
		uIStroke.Enabled = false
	end

	if uIStroke2 then
		uIStroke2.Enabled = false
	end

	if uIStroke3 then
		uIStroke3.Enabled = false
	end
else
	currencyFrame_Mobile.Visible = false
	currencyFrame.Visible = true
	expFrame.UiStroke.Thickness = 4
	healthFrame.UiStroke.Thickness = 4
end

local function ShowLevel(_)
	if maxLevel <= level.Value then
		if thaiLanguage.Value then
			playerName.Text = `{localPlayer.Name} • เลเวล {level.Value} (ตัน)`
		else
			playerName.Text = `{localPlayer.Name} • Lv. {level.Value} (Max)`
		end
	elseif thaiLanguage.Value then
		playerName.Text = `{localPlayer.Name} • เลเวล {level.Value}`
	else
		playerName.Text = `{localPlayer.Name} • Lv. {level.Value}`
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ShowMoney()
	if thaiLanguage.Value then
	end

	money2.Text = `${Abbreviate.Comma(money.Value)}`
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ShowGem()
	if thaiLanguage.Value then
		gem2.Text = `เพชร • {Abbreviate.Comma(gem.Value)}`
	else
		gem2.Text = `Gem • {Abbreviate.Comma(gem.Value)}`
	end
end

local function ShowExp()
	if maxLevel <= level.Value then
		if exp.Value >= maxExp.Value then
			if thaiLanguage.Value then
				expFrame.ExpText.Text = `ค่าประสบการณ์ {maxExp.Value}/{maxExp.Value}`
			else
				expFrame.ExpText.Text = `Exp {maxExp.Value}/{maxExp.Value}`
			end

			TweenService:Create(expFrame.Exp, TweenInfo.new(0.25, cubic), {
				Size = UDim2.new(1, 0, 1, 0)
			}):Play()
		else
			if thaiLanguage.Value then
				expFrame.ExpText.Text = `ค่าประสบการณ์ {exp.Value}/{maxExp.Value}`
			else
				expFrame.ExpText.Text = `Exp {exp.Value}/{maxExp.Value}`
			end

			TweenService:Create(expFrame.Exp, TweenInfo.new(0.25, cubic), {
				Size = UDim2.new(exp.Value / maxExp.Value, 0, 1, 0)
			}):Play()
		end
	else
		if thaiLanguage.Value then
			expFrame.ExpText.Text = `ค่าประสบการณ์ {exp.Value}/{maxExp.Value}`
		else
			expFrame.ExpText.Text = `Exp {exp.Value}/{maxExp.Value}`
		end

		if exp.Value >= maxExp.Value then
			TweenService:Create(expFrame.Exp, TweenInfo.new(0.25, cubic), {
				Size = UDim2.new(1, 0, 1, 0)
			}):Play()
		else
			TweenService:Create(expFrame.Exp, TweenInfo.new(0.25, cubic), {
				Size = UDim2.new(exp.Value / maxExp.Value, 0, 1, 0)
			}):Play()
		end
	end
end

local function TextColor(p, p2)
	if p and p2 then
		return (`<font color="rgb({p2})">{p}</font>`)
	end
end

local function TranslateText()
	if thaiLanguage.Value == true then
		expFrame.ExpText.Size = UDim2.new(1, 0, 0.9, 0)
		healthFrame.HealthText.Size = UDim2.new(1, 0, 0.9, 0)
	else
		expFrame.ExpText.Size = UDim2.new(1, 0, 1, 0)
		healthFrame.HealthText.Size = UDim2.new(1, 0, 1, 0)
	end
end

ShowExp()
ShowLevel()
ShowMoney() -- equivalent call inferred; original call site unknown
ShowGem() -- equivalent call inferred; original call site unknown
TranslateText()
exp.Changed:Connect(ShowExp)
maxExp.Changed:Connect(ShowExp)
level.Changed:Connect(ShowLevel)
money.Changed:Connect(ShowMoney)
gem.Changed:Connect(ShowGem)
thaiLanguage.Changed:Connect(function()
	TranslateText()
	ShowExp()
	ShowLevel()
	ShowMoney() -- equivalent call inferred; original call site unknown
	ShowGem() -- equivalent call inferred; original call site unknown
end)