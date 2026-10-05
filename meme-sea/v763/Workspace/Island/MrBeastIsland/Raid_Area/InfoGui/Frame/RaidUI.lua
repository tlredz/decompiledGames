local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local parent = script.Parent.Parent.Parent
local parent2 = script.Parent
local player_Amount = parent2:WaitForChild("Player_Amount")
local starting = parent2:WaitForChild("Starting")

local function Format(p)
	return string.format("%02i", p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function convertToHMS(p)
	local v = (p - p % 60) / 60
	local v2 = p - v * 60
	local v3 = v - (v - v % 60) / 60 * 60
	return string.format("%02i", v3) .. ":" .. string.format("%02i", v2)
end

local function Update_PlayerAmount()
	if localPlayer:GetAttribute("TH") then
		player_Amount.Text = `ดันเจี้ยน ({parent:GetAttribute("Current_Player")}/{parent:GetAttribute("Max_Players")})`
	else
		player_Amount.Text = `Raid ({parent:GetAttribute("Current_Player")}/{parent:GetAttribute("Max_Players")})`
	end

	if parent:GetAttribute("Current_Player") > 0 then
		if starting.TextTransparency ~= 0 then
			TweenService:Create(starting, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
				TextTransparency = 0,
				TextStrokeTransparency = 0
			}):Play()
		end
	elseif starting.TextTransparency ~= 1 then
		TweenService:Create(starting, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			TextTransparency = 1,
			TextStrokeTransparency = 1
		}):Play()
	end
end

local function Update_Countdown()
	if parent:GetAttribute("Current_Player") > 0 then
		if starting.TextTransparency ~= 0 then
			TweenService:Create(starting, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
				TextTransparency = 0,
				TextStrokeTransparency = 0
			}):Play()
		end

		if localPlayer:GetAttribute("TH") then
			starting.Text = ("กำลังจะเริ่มในอีก %*"):format(convertToHMS(parent:GetAttribute("Starting")))
		else
			starting.Text = ("Starting in %*"):format(convertToHMS(parent:GetAttribute("Starting")))
		end
	else
		if starting.TextTransparency ~= 1 then
			TweenService:Create(starting, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
				TextTransparency = 1,
				TextStrokeTransparency = 1
			}):Play()
		end

		task.wait(0.1)

		if localPlayer:GetAttribute("TH") then
			starting.Text = ("กำลังจะเริ่มในอีก %*"):format(convertToHMS(parent:GetAttribute("Countdown_Time")))
		else
			starting.Text = ("Starting in %*"):format(convertToHMS(parent:GetAttribute("Countdown_Time")))
		end
	end
end

Update_PlayerAmount()
Update_Countdown()
parent:GetAttributeChangedSignal("Current_Player"):Connect(Update_PlayerAmount)
parent:GetAttributeChangedSignal("Starting"):Connect(Update_Countdown)
localPlayer:GetAttributeChangedSignal("TH"):Connect(function()
	Update_PlayerAmount()
	Update_Countdown()
end)