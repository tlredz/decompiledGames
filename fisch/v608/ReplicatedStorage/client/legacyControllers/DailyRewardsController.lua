local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Net = require(ReplicatedStorage.packages.Net)
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
require(ReplicatedStorage.client.legacyControllers.CurrencyController)
local localPlayer = Players.LocalPlayer
local dailyRewards = localPlayer.PlayerGui:WaitForChild("DailyRewards")
local frame = dailyRewards.Frame
local remoteEvent = Net:RemoteEvent("DailyReward/Show", -1)
local remoteEvent2 = Net:RemoteEvent("DailyReward/Claim")
local DailyRewardsController = {}

function DailyRewardsController:Show(p)
	if not localPlayer:GetAttribute("SpawnFinished") then
		localPlayer:GetAttributeChangedSignal("SpawnFinished"):Wait()
	end

	local dailystreak = legacyLocalPlayerData.fetch():WaitForChild("Stats"):FindFirstChild("dailystreak")

	if not dailystreak then
		return
	end

	local value = dailystreak.Value
	local v = math.floor(value / 7)
	local v2 = value % 7
	local container = frame:FindFirstChild("Day0-5").Container

	local function ApplyRewardData(instance, p2: number)
		local v3 = p[tostring(p2)]
		local display = v3.Display
		local icon = v3.Icon
		local text = v3.Reward[2]
		local dayLabel = instance:FindFirstChild("DayLabel")
		dayLabel.Text = `[Day {p2 + 1 + 7 * v}]`
		local itemName = instance:FindFirstChild("ItemName")

		if display then
			text = string.gsub(display, " ", "<br/>") or text
		end

		itemName.Text = text
		local imageLabel = instance:FindFirstChild("ImageLabel")
		imageLabel.Image = icon or ""
	end

	for _, frame2 in container:GetChildren() do
		if not frame2:IsA("Frame") then
			continue
		end

		local v3 = string.split(frame2.Name, "Day")[2]

		if not v3 then
			continue
		end

		local v4 = tonumber(v3)

		if not v4 then
			continue
		end

		if frame2:FindFirstChild("Claimed") then
			frame2:FindFirstChild("Claimed"):Destroy()
		end

		if frame2:FindFirstChild("Claim") then
			frame2:FindFirstChild("Claim"):Destroy()
		end

		if v4 <= v2 - 1 then
			local clone = script.Claimed:Clone()
			clone.Parent = frame2
		end

		ApplyRewardData(frame2, v4)
	end

	ApplyRewardData(frame:FindFirstChild("Day6"), 6)
	local parent = container:FindFirstChild((`Day{v2}`)) or frame:FindFirstChild("Day6")

	if not parent then
		return
	end

	local claim

	if parent.Name == "Day6" then
		claim = parent:FindFirstChild("Claim")
		local uIStroke = claim:FindFirstChild("UIStroke")
		local corner = claim:FindFirstChild("corner")
		local label = claim:FindFirstChild("Label")
		local color = Color3.fromRGB(170, 255, 114)
		uIStroke.Color = color
		corner.ImageColor3 = color
		label.TextColor3 = color
		claim.AutoButtonColor = true
	else
		claim = script.Claim:Clone()
		claim.Parent = parent
	end

	dailyRewards.Enabled = true

	if UserInputService.PreferredInput == Enum.PreferredInput.Gamepad then
		local selectedObjectChangedConnection = nil
		selectedObjectChangedConnection = GuiService:GetPropertyChangedSignal("SelectedObject"):Connect(function()
			if dailyRewards.Enabled then
				if GuiService.SelectedObject ~= claim then
					GuiService.SelectedObject = claim
				end
			elseif selectedObjectChangedConnection then
				selectedObjectChangedConnection:Disconnect()
			end
		end)
		task.defer(function()
			if dailyRewards.Enabled and claim.Parent then
				GuiService.SelectedObject = claim
			end
		end)
		claim.Activated:Once(function()
			if selectedObjectChangedConnection then
				selectedObjectChangedConnection:Disconnect()
			end

			GuiService.SelectedObject = nil
			dailyRewards.Enabled = false
			remoteEvent2:FireServer()
		end)
	else
		claim.Activated:Once(function()
			dailyRewards.Enabled = false
			remoteEvent2:FireServer()
		end)
	end
end

function DailyRewardsController:Start()
	remoteEvent.OnClientEvent:Connect(function(p)
		self:Show(p)
	end)
end

return DailyRewardsController