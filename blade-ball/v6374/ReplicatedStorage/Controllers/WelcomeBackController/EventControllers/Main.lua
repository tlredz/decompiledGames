local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Signal)
local v2 = require3(ReplicatedStorage2.Packages.Replion)
local v3 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v4 = require3(ReplicatedStorage2.Common.Utils.Utilities.Thread)
local v5 = require3(ReplicatedStorage2.Common.Utils.Utilities.ValueConvertor)
require3(ReplicatedStorage2.Shared.WelcomeBackData)
local v6 = nil
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local v7 = nil
local v8 = require3(ReplicatedStorage2.ClientGameModules.DeviceListener)
local character = nil
local alive = workspace:WaitForChild("Alive")
local newWelcomeBack = playerGui:WaitForChild("NewWelcomeBack")
local frame = newWelcomeBack.Frame
local sideBtns = frame.SideBtns
local views = frame.Views
local v9 = {}

local function fn()
	for _, v10 in v9 do
		v10()
	end
end

local v10 = {
	Selected = {
		Image = "rbxassetid://17259974055",
		HoverImage = "rbxassetid://17259974925",
		UIStrokeColor = Color3.fromRGB(108, 43, 0)
	},
	Unselected = {
		Image = "rbxassetid://17259976762",
		HoverImage = "rbxassetid://17259977737",
		UIStrokeColor = Color3.fromRGB(0, 33, 90)
	}
}
local visible = true
local v12 = v.new()
local Main = {
	GetRemainingEventTime = function(self)
		local serverTimeNow = workspace:GetServerTimeNow()
		return (math.max((v7:Get("WelcomeBackEvent.EventEndTime") or 0) - serverTimeNow, 0))
	end,
	SetNotificationStatus = function(self, flag: boolean)
		local v13 = visible
		visible = flag

		if flag ~= v13 then
			v12:Fire()
		end
	end,
	Init = function(_)
		v6 = require3(script.Parent.View)
	end
}

function Main.Start(_)
	v7 = v2.Client:WaitReplion("Data")

	local function UpdateMobilePosition()
		local tagged = CollectionService:GetTagged("WelcomeBackButton")

		for _, v13 in ipairs(tagged) do
			if not v8:IsMobile() then
				continue
			end

			local v14 = v8:IsMobile() and 0.12 or 0.77
			v13.AnchorPoint = Vector2.new(0.005, v14)
			v13.Position = UDim2.fromScale(0.009, v14)
			v13:SetAttribute("MovingPosition", UDim2.fromScale(0.009, v14))
		end
	end

	v8:Observe(UpdateMobilePosition)
	v12:Connect(function()
		local tagged = CollectionService:GetTagged("WelcomeBackButton")

		for _, v13 in ipairs(tagged) do
			v13.ImageLabel.Visible = visible
		end

		UpdateMobilePosition()
	end)

	if Main:GetRemainingEventTime() > 0 then
		v4.Every(1, UpdateButtons)
	end

	UpdateButtons()
	local tagged = CollectionService:GetTagged("WelcomeBackButton")

	for _, v13 in ipairs(tagged) do
		v13.MouseButton1Click:Connect(ToggleButton)
	end

	for _, child in ipairs((views:GetChildren())) do
		local name = child.Name
		v6:CreateView(name, child)
		local child2 = sideBtns:FindFirstChild(name)

		if child2 then
			local name2 = name
			child2.MouseButton1Click:Connect(function()
				v6:OpenView(name2)

				for k, v14 in v9 do
					v14()
				end
			end)
		end

		local v13 = v6:OnViewOpen(name)

		if v13 then
			v13:Connect(fn)
		end

		local v14 = v6:OnViewClosed(name)

		if v14 then
			v14:Connect(fn)
		end

		table.insert(v9, function()
			if not child2 then
				return
			end

			local selected

			if v6._selectedView == name then
				selected = v10.Selected
			else
				selected = v10.Unselected
			end

			child2.Image = selected.Image
			child2.HoverImage = selected.HoverImage
			local uIStroke = child2:FindFirstChildWhichIsA("UIStroke", true)

			if uIStroke then
				uIStroke.Color = selected.UIStrokeColor
			end
		end)
	end

	OnCreditsChanged(v7:Get("WelcomeBackEvent.ReturnCoins"))
	v7:OnChange("WelcomeBackEvent.ReturnCoins", OnCreditsChanged)
	local v13 = v7:Get("WelcomeBackEvent.EventEndTime") or 0
	frame.Timer:SetAttribute("EndTime", v13)
	frame.Timer:AddTag("GachaSpinExpiresTime")
	v6:OpenView("Login")

	-- equivalent calls inferred from this helper; original call sites unknown
	local function CharacterChanged()
		character = localPlayer.Character
	end

	localPlayer:GetPropertyChangedSignal("Character"):Connect(CharacterChanged)
	CharacterChanged() -- equivalent call inferred; original call site unknown
end

function OnCreditsChanged(value: number?)
	local v13 = value or 0

	if v13 then
		newWelcomeBack.Frame.TopFrame.Currency.Amount.Text = v5:AddCommas(v13)
	end
end

function UpdateButtons()
	local remainingEventTime = Main:GetRemainingEventTime()
	local formatTimeWithDaysFull = v5:FormatTimeWithDaysFull(remainingEventTime)
	local tagged = CollectionService:GetTagged("WelcomeBackButton")

	for _, v13 in ipairs(tagged) do
		v13.Timer.Text = formatTimeWithDaysFull
		v13.Visible = remainingEventTime > 0 and character and character.Parent ~= alive
	end
end

function ToggleButton()
	Main:SetNotificationStatus(false)

	if v3:IsOpen("NewWelcomeBack") then
		v6:Close()
	else
		v6:Open()
	end
end

return Main