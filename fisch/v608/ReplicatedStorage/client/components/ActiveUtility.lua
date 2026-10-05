local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local packages = ReplicatedStorage:WaitForChild("packages")
local Component = require(packages:WaitForChild("Component"))
local Trove = require(packages:WaitForChild("Trove"))
local Net = require(packages:WaitForChild("Net"))
local Timer = require(packages:WaitForChild("Timer"))
require(ReplicatedStorage.shared.modules.vessels)
local Utilities = require(ReplicatedStorage.shared.modules.Utilities)
local fish = require(ReplicatedStorage.shared.modules.library.fish)
local Spring = require(ReplicatedStorage.shared.utils.Spring)
local _ = Players.LocalPlayer
local legacyControllers = ReplicatedStorage.client.legacyControllers
require(legacyControllers:WaitForChild("NotificationController"))
local remoteEvent = Net:RemoteEvent("UtilityBoat/FinishedUtility", -1)
local remoteEvent2 = Net:RemoteEvent("UtilityBoat/FailedClick", -1)
local remoteEvent3 = Net:RemoteEvent("UtilityBoat/FailedUtility", -1)
local v = Component.new({
	Tag = "ActiveUtility"
})
v.minigameTrove = nil

local function ToTime(p: number)
	local v2 = math.floor(p / 86400)
	local v3 = p % 86400
	local v4 = math.floor(v3 / 3600)
	local v5 = v3 % 3600
	local v6 = math.floor(v5 / 60)
	local v7 = v5 % 60
	local v8 = ""

	if v2 >= 1 then
		v8 ..= `{string.format("%02d", v2)}d`
	end

	if v2 >= 1 or v4 >= 1 then
		v8 ..= `{v2 >= 1 and " " or ""}{string.format("%02d", v4)}h`
	end

	if v4 >= 1 or v6 >= 1 then
		v8 ..= `{v4 >= 1 and " " or ""}{string.format("%02d", v6)}m`
	end

	if v2 < 1 and v7 > 0 then
		return v8 .. `{v6 >= 1 and " " or ""}{string.format("%02d", v7)}s`
	end

	return v8
end

function v:Construct()
	self.trove = Trove.new()
	self.trove:AttachToInstance(self.Instance)
	self.timer = Timer.new(0.15)
	self.trove:Add(self.timer, "Destroy")
	local clone = script.DistantTimer:Clone()
	clone.Parent = self.Instance
	clone.Enabled = false
	self.trove:Add(clone)
	local clone2 = script.Prompt:Clone()
	clone2.ObjectText = self.Instance.Name
	clone2.Parent = self.Instance
	self.trove:Add(clone2)
	local clone3 = script.POIHeader:Clone()
	clone3.Parent = self.Instance
	self.trove:Add(clone3)
	self.poiHeader = clone3
	self.prompt = clone2
	self.distantTimer = clone
	local rotationSpring = Spring.new(0)
	rotationSpring.Speed = 40
	self.rotationSpring = rotationSpring

	if self.Instance:GetAttribute("InstantCatch") then
		self:BeginMinigame()
		self.Instance.Parent = ReplicatedStorage
	end
end

function v:BeginMinigame()
	if self.Instance:GetAttribute("Owner") ~= Players.LocalPlayer.UserId or v.minigameTrove then
		return
	end

	local maid = self.trove:Extend()
	v.minigameTrove = maid
	maid:Add(function()
		v.minigameTrove = nil
	end)
	local clone = script.Minigame:Clone()
	clone.Parent = Players.LocalPlayer.PlayerGui
	v.minigameTrove:Add(clone)
	local ring = clone.Progress.Ring
	local bar = clone.Progress.Bar
	local marker = clone.Progress.Marker
	local timer = clone.Progress.Timer
	local v2 = ring.AbsoluteSize.X / 2 - 12
	local catchSpeed = Utilities.all[self.Instance.Name].CatchSpeed
	local v3 = math.random(0, 360)
	local _ = Utilities.all[self.Instance.Name].CatchAngle
	local flag = false
	local v4 = self.Instance:GetAttribute("PotentialEscape") - workspace:GetServerTimeNow()
	local result = self.Instance:GetAttribute("Result")
	local v5 = math.ceil(fish[result].Resilience / 50)
	local character = Players.LocalPlayer.Character
	local humanoid = character and character:FindFirstChild("Humanoid")
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
	v.minigameTrove:Add(function()
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
	end)
	local v6 = math.random(0, 360)
	self.rotationSpring.Target = v6
	self.rotationSpring.Position = v6
	clone.Progress.UIScale.Scale = 0
	TweenService:Create(clone.Progress.UIScale, TweenInfo.new(0.1), {
		Scale = 1
	}):Play()
	maid:Connect(RunService.RenderStepped, function(p: number)
		v3 = (v3 + catchSpeed * p) % 360
		local v7 = math.rad(v3)
		local v8 = math.cos(v7) * v2
		local v9 = math.sin(v7) * v2
		local _ = marker.AbsoluteSize / 2
		marker.Position = UDim2.new(0.5, v8, 0.5, v9)
		marker.Rotation = v3 + 90
		bar.Rotation = self.rotationSpring.Position
		local v10 = self.Instance:GetAttribute("PotentialEscape") - workspace:GetServerTimeNow()

		if v10 > 0 then
			timer.Label.Text = `Time Left: {ToTime(v10)}`
			timer.Label.Visible = true
			local v11 = math.clamp(v10 / v4, 0, 1)
			timer.Progress.Bar.Size = UDim2.fromScale(v11, 1)
		else
			remoteEvent3:FireServer(self.Instance)
			maid:Destroy()
		end
	end)
	maid:Connect(UserInputService.InputBegan, function(p, p2)
		if p2 and p.KeyCode ~= Enum.KeyCode.ButtonA or flag then
			return
		end

		if p.KeyCode == Enum.KeyCode.ButtonA or p.UserInputType == Enum.UserInputType.MouseButton1 or p.UserInputType == Enum.UserInputType.Touch then
			flag = true
			task.delay(0.3, function()
				flag = false
			end)
			local v7 = (v3 + 90) % 360
			clone.Progress.UIScale.Scale = 1

			if -2.5 + self.rotationSpring.Position <= v7 and v7 <= 92.5 + self.rotationSpring.Position then
				v5 -= 1
				script.Success:Play()
				TweenService:Create(
					clone.Progress.UIScale,
					TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, true, 0),
					{
						Scale = 1.1
					}
				):Play()

				if v5 <= 0 then
					remoteEvent:FireServer(self.Instance)
				else
					self.rotationSpring.Target = math.random(0, 300)
				end
			else
				remoteEvent2:FireServer(self.Instance)
				local potentialEscape = self.Instance:GetAttribute("PotentialEscape")
				self.Instance:SetAttribute("PotentialEscape", potentialEscape - 10)
				TweenService:Create(
					clone.Progress.UIScale,
					TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, true, 0),
					{
						Scale = 0.9
					}
				):Play()
			end
		end
	end)
end

function v:Start()
	if self.Instance:GetAttribute("Owner") == Players.LocalPlayer.UserId then
		self.timer:Start()
		self.trove:Connect(self.prompt.Triggered, function()
			if self.Instance:GetAttribute("Owner") ~= Players.LocalPlayer.UserId then
				return
			end

			if self.Instance:GetAttribute("CatchableAt") - workspace:GetServerTimeNow() <= 0 then
				self:BeginMinigame()
			end
		end)
		local position = self.Instance:GetPivot().Position
		self.trove:Connect(self.timer.Tick, function()
			local v2 = self.Instance:GetAttribute("CatchableAt") - workspace:GetServerTimeNow()
			local v3 = self.Instance:GetAttribute("PotentialEscape") - workspace:GetServerTimeNow()
			Players.LocalPlayer:DistanceFromCharacter(position)
			local timer = self.poiHeader.timer
			local textColor

			if v2 >= 0 or v3 < 15 then
				textColor = Color3.fromRGB(255, 17, 69)
			else
				textColor = Color3.fromRGB(32, 255, 95)
			end

			timer.TextColor3 = textColor
			local uIStroke = self.poiHeader.timer.UIStroke
			local color

			if v2 >= 0 or v3 < 15 then
				color = Color3.fromRGB(43, 7, 15)
			else
				color = Color3.fromRGB(8, 43, 11)
			end

			uIStroke.Color = color

			if v2 > 0 then
				self.poiHeader.timer.Text = ToTime(v2)
				self.poiHeader.title.Text = "Catches In"
				self.prompt.Enabled = false
				self.distantTimer.Frame.Icon.title.Text = ToTime(v2)
			else
				self.distantTimer.Frame.Icon.title.Text = "READY!"

				if v3 <= 0 then
					self.poiHeader.timer.Text = "?"
				else
					self.poiHeader.timer.Text = ToTime(v3)
				end

				self.poiHeader.title.Text = "READY NOW!"
				self.prompt.Enabled = true
			end
		end)
	else
		self.prompt.Enabled = false
		self.poiHeader.Enabled = false
		self.distantTimer.Enabled = false
	end
end

function v.Stop(p)
	p.trove:Destroy()
end

return v