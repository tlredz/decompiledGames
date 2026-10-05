local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local GhostCharacter = require(ReplicatedStorage.Modules.Client.Components.CharacterEffects.GhostCharacter)
local OnlyRunOnPlayerHotbar = require(ReplicatedStorage.Modules.Shared.Components.Tools.Extensions.OnlyRunOnPlayerHotbar)
local v = Component.new({
	Tag = "GhostDetectorTool",
	Extensions = { OnlyRunOnPlayerHotbar }
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._equipJanitor = Janitor.new()
	self.blinkTweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.In, -1, true)
	self.meterBucketIndex = 5
	self.meterInterval = 3
end

function v:UpdateMeter(meterBucketIndex: number)
	self.meterBucketIndex = meterBucketIndex
	self.meterInterval = ({
		0.2,
		0.5,
		1,
		2,
		900
	})[self.meterBucketIndex]
end

function v:Beep()
	local sensorsParts = self.Instance:FindFirstChild("SensorsParts")

	if not sensorsParts then
		return
	end

	local color2 = ({
		Color3.fromRGB(0, 255, 0),
		Color3.fromRGB(255, 255, 0),
		Color3.fromRGB(255, 128, 0),
		Color3.fromRGB(255, 0, 0),
		(Color3.fromRGB(0, 0, 0))
	})[self.meterBucketIndex]
	local color = Color3.fromRGB(0, 0, 0)
	local v3 = math.max(0.05, self.meterInterval * 0.5)
	local tweenInfo = TweenInfo.new(v3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false)
	local tweenInfo2 = TweenInfo.new(v3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false)

	for _, child in sensorsParts:GetChildren() do
		child.Color = color
		local tween = TweenService:Create(child, tweenInfo, {
			Color = color2
		})
		local v4 = TweenService:Create(child, tweenInfo2, {
			Color = color
		})
		tween.Completed:Once(function()
			v4:Play()
		end)
		tween:Play()
	end

	local handle = self.Instance.Handle
	local clone = handle:FindFirstChild("Beep"):Clone()
	clone.Parent = handle
	clone.Ended:Once(function()
		for _, child in sensorsParts:GetChildren() do
			child.Color = color
		end

		clone:Destroy()
	end)
	clone:Play()
end

function v:StartTool()
	self.isEquipped = true
	self._equipJanitor:Cleanup()
	local total = 0
	local v2 = {
		25,
		35,
		55,
		70,
		80
	}
	self.meterBucketIndex = 5
	self.meterInterval = 3
	local v3 = {
		35,
		45,
		50,
		65,
		80
	}
	self._equipJanitor:Add(RunService.Stepped:Connect(function(_, dt)
		if total < 0.2 then
			total += dt
			return
		end

		total = 0
		local v4 = 5
		local parent = self.Instance.Parent

		if not parent then
			return
		end

		local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")
		local lookVector = humanoidRootPart.CFrame.LookVector

		for _, v5 in GhostCharacter:GetAll() do
			local instance = v5.Instance

			if not instance then
				continue
			end

			local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				continue
			end

			local v6 = humanoidRootPart2.Position - humanoidRootPart.Position
			local magnitude = v6.Magnitude

			if magnitude == 0 then
				continue
			end

			local v7 = math.deg((math.acos((math.clamp(lookVector:Dot(v6.Unit), -1, 1)))))
			local v8 = 5

			if v7 <= v3[5] then
				for k, v10 in v3 do
					if not (v7 <= v10) then
						continue
					end

					v8 = k
					break
				end
			end

			local v9 = 5

			for k, v11 in v2 do
				if not (magnitude < v11) then
					continue
				end

				v9 = k
				break
			end

			local v11 = math.max(v9, v8)

			if v11 < v4 then
				v4 = v11
			end
		end

		self:UpdateMeter(v4)
	end))
	local total2 = 0
	self._equipJanitor:Add(RunService.Stepped:Connect(function(_, dt)
		total2 += dt

		if total2 < self.meterInterval then
			return
		end

		total2 = 0
		self:Beep()
	end))
end

function v:StopTool()
	self.isEquipped = false
	self._equipJanitor:Cleanup()
end

function v:Start()
	local instance = self.Instance
	local _ = Players.LocalPlayer

	if instance.Parent and instance.Parent:IsA("Model") then
		self:StartTool()
	end

	self._Janitor:Add(instance.Equipped:Connect(function()
		self:StartTool()
	end))
	self._Janitor:Add(instance.Unequipped:Connect(function()
		self:StopTool()
	end))
end

function v:Stop()
	self._equipJanitor:Destroy()
	self._Janitor:Destroy()
end

return v