local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local packages = ReplicatedStorage:WaitForChild("packages")
local Component = require(packages:WaitForChild("Component"))
local Net = require(packages:WaitForChild("Net"))
local Trove = require(packages:WaitForChild("Trove"))
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local remoteFunction = Net:RemoteFunction("FrozenLeverPuzzle/RequestEnabledLevers", -1)
local tweenInfo = TweenInfo.new(3, Enum.EasingStyle.Quint)
local v = {
	[true] = Color3.fromRGB(97, 129, 180),
	[false] = Color3.fromRGB(59, 59, 59)
}
local _ = Players.LocalPlayer
legacyLocalPlayerData.fetch()
local v2 = Component.new({
	Tag = "LeversPuzzle"
})

function v2:SetEnabled(flag: boolean)
	if flag == true then
		if self.enabled == true then
			return
		end

		self.enabled = true

		if self.Instance:FindFirstChild("Crystal") then
			self.Instance.Crystal:ScaleTo(0.6)
		end

		if self.Instance:FindFirstChild("FakeRod") then
			self.Instance.FakeRod:Destroy()
		end

		for _, child in self.Instance:WaitForChild("Ice Warpers Rod"):WaitForChild("Details"):GetChildren() do
			child.Transparency = child:GetAttribute("DefaultTransparency")
		end

		local promptTemplate = self.Instance:WaitForChild("Ice Warpers Rod"):WaitForChild("handle"):WaitForChild("PromptTemplate")
		promptTemplate.Enabled = true
	else
		self.enabled = true
		local tweenInfo2 = TweenInfo.new(6, Enum.EasingStyle.Linear)
		TweenService:Create(self.crystalScale, tweenInfo2, {
			Value = 0.6
		}):Play()
		task.wait(4)
		local tweenInfo3 = TweenInfo.new(8, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
		TweenService:Create(self.Instance:WaitForChild("FakeRod").PrimaryPart, tweenInfo3, {
			CFrame = self.Instance:WaitForChild("RodTarget").CFrame
		}):Play()

		for _, descendant in self.Instance:WaitForChild("FakeRod"):GetDescendants() do
			if descendant:IsA("ParticleEmitter") then
				descendant.Enabled = true
			elseif descendant:IsA("Sound") then
				descendant:Play()
			end
		end

		task.wait(8)

		for _, child in self.Instance:WaitForChild("Ice Warpers Rod"):WaitForChild("Details"):GetChildren() do
			child.Transparency = child:GetAttribute("DefaultTransparency")
		end

		local promptTemplate_2 = self.Instance:WaitForChild("Ice Warpers Rod"):WaitForChild("handle"):WaitForChild("PromptTemplate")
		promptTemplate_2.Enabled = true
		task.wait(1)

		for _, emitter in self.Instance:WaitForChild("FakeRod"):GetDescendants() do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		task.wait(1)
		self.Instance:WaitForChild("FakeRod"):Destroy()
	end
end

function v2:SetLightState(childName: string, flag: boolean, flag2: boolean?)
	self.lightsStates[childName] = flag
	local child = self.lights:FindFirstChild(childName)

	if not child then
		return
	end

	TweenService:Create(child, tweenInfo, {
		Color = v[self.lightsStates[childName]]
	}):Play()
	local count = 0

	for _, lightsState in self.lightsStates do
		if lightsState == true then
			count += 1
		end
	end

	if #self.lights:GetChildren() == count then
		self:SetEnabled(flag2)
	end
end

function v2:Construct()
	self.trove = Trove.new()
	self.lights = self.Instance:WaitForChild("Base"):WaitForChild("Lights")
	self.enabled = false
	self.crystalScale = Instance.new("NumberValue")
	self.crystalScale.Value = 1
	self.trove:Add(self.crystalScale)
	self.lightsStates = {}

	for _, child in self.lights:GetChildren() do
		self.lightsStates[child.Name] = false
	end
end

function v2:Start()
	local v3 = remoteFunction:InvokeServer()

	for k, v4 in v3 do
		self:SetLightState(k, v4, true)
	end

	self.trove:Add(self.crystalScale.Changed:Connect(function()
		self.Instance:WaitForChild("Crystal"):ScaleTo((math.clamp(self.crystalScale.Value, 0.01, 1e999)))
	end))
end

function v2.Stop(p)
	p.trove:Destroy()
end

return v2