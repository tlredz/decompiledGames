local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local packages = ReplicatedStorage:WaitForChild("packages")
local Component = require(packages.Component)
local Trove = require(packages.Trove)
local Net = require(packages.Net)
local Signal = require(packages.Signal)
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local cache = legacyLocalPlayerData.fetch():WaitForChild("Cache")
local clockCompleted = Signal.new()
local indexesByName = {}
local v2 = {}
local remoteFunction = Net:RemoteFunction("KrakenPuzzleService/ConfirmButton")
local remoteFunction2 = Net:RemoteFunction("KrakenPuzzleService/Finished")
local component = Component.new({
	Tag = "KrakenPuzzleClock"
})

function component:GetCurrentAngle()
	return (self.index - 1) * 30
end

function component:LoopMovement(p: number)
	self.angle = self.angle or self:GetCurrentAngle()
	self.lastAngle = self.lastAngle or 0
	self.angle += p * 10
	local v4 = self.spawnCFrame * CFrame.Angles(math.rad(self.angle), 0, 0)
	self.moveInstance.Value = v4
	local lastAngle = self.lastAngle + 30

	if lastAngle <= math.floor(self.angle / 30) * 30 then
		self.lastAngle = lastAngle
		local clock = self.Instance:FindFirstChild("Clock")
		local clockBase = clock and clock:FindFirstChild("ClockBase")

		if clockBase then
			local clock2 = clockBase:FindFirstChild("Clock")
			local sound = clock2 and clock2:FindFirstChild("Sound")

			if sound then
				sound:Play()
			end
		end
	end
end

function component:Show(folder, enabled: boolean)
	local descendants = folder:GetDescendants()
	table.insert(descendants, folder)

	for _, instance in descendants do
		if instance:IsA("BasePart") then
			instance.Transparency = enabled == true and 0 or 1
		elseif instance:IsA("ProximityPrompt") then
			instance.Enabled = enabled
		end
	end
end

function component:MovePointer(p: number)
	local v4 = (p - 1) * 30
	local v5 = self.spawnCFrame * CFrame.Angles(math.rad(v4), 0, 0)
	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear)
	TweenService:Create(self.moveInstance, tweenInfo, {
		Value = v5
	}):Play()
	local clock = self.Instance:FindFirstChild("Clock")
	local clockBase = clock and clock:FindFirstChild("ClockBase")

	if clockBase then
		local clock2 = clockBase:FindFirstChild("Clock")
		local sound = clock2 and clock2:FindFirstChild("Sound")

		if sound then
			sound:Play()
		end
	end
end

function component:PlayKillAnimation()
	if Players.LocalPlayer.Character then
		Players.LocalPlayer.Character:SetAttribute("KrakenDeathAnim", 0)
	end

	local tweenInfo = TweenInfo.new(3, Enum.EasingStyle.Quint)

	for k, position in self.positions do
		TweenService:Create(k.PrimaryPart, tweenInfo, {
			CFrame = position[true]
		}):Play()
	end

	task.wait(2)

	for _, track in self.tracks do
		track:Play()
	end

	ReplicatedStorage.events.drown:FireServer()
	task.wait(5)

	for _, track in self.tracks do
		track:Stop()
	end

	for k, position in self.positions do
		if k and k.Parent and k.PrimaryPart then
			k.PrimaryPart.CFrame = position[false]
		end
	end
end

function component:Construct()
	self.trove = Trove.new()
	self.tracks = {}
	self.positions = {}
	self.index = indexesByName[self.Instance.Name] or 1
	self.moveInstance = Instance.new("CFrameValue")
	self.spawnCFrame = self.Instance:WaitForChild("Clock"):WaitForChild("Pointer"):GetPivot()
	self.tries = 0
	self.secondTrove = Trove.new()
	self.secondTrove:Add(self.moveInstance)
end

function component:CanInteract()
	return self.Instance:GetAttribute("RequiredDoor") == nil or cache:FindFirstChild((`Door.{self.Instance:GetAttribute("RequiredDoor")}`)) ~= nil
end

function component:Start()
	local function Setup()
		local amountOfLegs = self.Instance:GetAttribute("AmountOfLegs") or 3

		while #self.Instance:WaitForChild("Holes"):WaitForChild("Legs"):GetChildren() ~= amountOfLegs do
			task.wait(1)
		end

		for _, child in self.Instance:WaitForChild("Holes"):WaitForChild("Legs"):GetChildren() do
			local animator = child:WaitForChild("AnimationController"):WaitForChild("Animator")
			self.tracks[child] = animator:LoadAnimation(script.IdleLeg)
			self.positions[child] = {
				[false] = child.PrimaryPart.CFrame,
				[true] = child:GetAttribute("GoalCFrame")
			}
		end

		self.pointer = self.Instance:WaitForChild("Clock"):WaitForChild("Pointer")
		local proximityPrompt = self.Instance:WaitForChild("Clock"):WaitForChild("Button"):WaitForChild("Button"):WaitForChild("ProximityPrompt")
		self.trove:Add(proximityPrompt.Triggered:Connect(function()
			if not self:CanInteract() then
				ReplicatedStorage.events.anno_localthought:Fire("Seems like I need to do something else first...")
			elseif remoteFunction:InvokeServer(self.Instance.Name, self.index) == true then
				v2[self.Instance.Name] = true
				clockCompleted:Fire(v2)
				self.trove:Clean()
				self.Instance:WaitForChild("Clock"):WaitForChild("Button"):WaitForChild("Button"):WaitForChild("Success"):Play()
				self:Show(self.Instance:WaitForChild("Clock"):WaitForChild("Button"), false)
				self:Show(self.Instance:WaitForChild("Left"), false)
				self:Show(self.Instance:WaitForChild("Right"), false)
			else
				self.Instance:WaitForChild("Clock"):WaitForChild("Button"):WaitForChild("Button"):WaitForChild("Fail"):Play()
				self.index = 1
				self.tries += 1
				self:MovePointer(self.index)

				if self.tries >= 2 then
					self.tries = 0
					self:PlayKillAnimation()
				end
			end
		end))
		self.secondTrove:Add(self.moveInstance:GetPropertyChangedSignal("Value"):Connect(function()
			self.pointer:PivotTo(self.moveInstance.Value)
		end))

		local function PromptClick(p: number)
			if not self:CanInteract() then
				ReplicatedStorage.events.anno_localthought:Fire("Seems like I need to do something else first...")
				return
			end

			local v4 = self.index + p
			self.index = v4 < 1 and 12 or v4 > 12 and 1 or v4
			indexesByName[self.Instance.Name] = self.index
			self:MovePointer(self.index)
		end

		local proximityPrompt2 = self.Instance:WaitForChild("Left"):WaitForChild("ProximityPrompt")
		self.trove:Add(proximityPrompt2.Triggered:Connect(function()
			PromptClick(-1)
		end))
		local proximityPrompt3 = self.Instance:WaitForChild("Right"):WaitForChild("ProximityPrompt")
		self.trove:Add(proximityPrompt3.Triggered:Connect(function()
			PromptClick(1)
		end))
		self:MovePointer(self.index)

		if v2[self.Instance.Name] then
			self.trove:Clean()
			self:Show(self.Instance:WaitForChild("Clock"):WaitForChild("Button"), false)
			self:Show(self.Instance:WaitForChild("Left"), false)
			self:Show(self.Instance:WaitForChild("Right"), false)
			self.secondTrove:Add(RunService.RenderStepped:Connect(function(dt: number)
				self:LoopMovement(dt)
			end))
		else
			self:Show(self.Instance:WaitForChild("Clock"):WaitForChild("Button"), true)
			self:Show(self.Instance:WaitForChild("Left"), true)
			self:Show(self.Instance:WaitForChild("Right"), true)
		end

		if remoteFunction2:InvokeServer(self.Instance.Name) == true then
			v2[self.Instance.Name] = true
			clockCompleted:Fire(v2)
			self.trove:Clean()
			self.Instance:WaitForChild("Clock"):WaitForChild("Button"):WaitForChild("Button"):WaitForChild("Success"):Play()
			self:Show(self.Instance:WaitForChild("Clock"):WaitForChild("Button"), false)
			self:Show(self.Instance:WaitForChild("Left"), false)
			self:Show(self.Instance:WaitForChild("Right"), false)
		end
	end

	local thread = coroutine.create(Setup)
	self.trove:Add(thread)
	coroutine.resume(thread)
end

function component:Stop()
	self.trove:Destroy()
	self.secondTrove:Destroy()
end

return {
	Component = component,
	ClockCompleted = clockCompleted,
	RequestList = function()
		return v2
	end
}