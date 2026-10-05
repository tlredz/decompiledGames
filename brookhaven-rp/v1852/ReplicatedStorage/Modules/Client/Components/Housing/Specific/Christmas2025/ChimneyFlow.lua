local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local InteractionPrompt = require(ReplicatedStorage.Modules.Client.Components.Interactions.InteractionPrompt)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local v = Component.new({
	Tag = "ChimneyFlow"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._debounce = false
end

function v:Start()
	local goUp = self.Instance:WaitForChild("GoUp")
	local goDown = self.Instance:WaitForChild("GoDown")
	local component = ComponentUtil.GetComponentFromInstance(goUp, InteractionPrompt)
	local component2 = ComponentUtil.GetComponentFromInstance(goDown, InteractionPrompt)
	self._Janitor:Add(component.Interacted:Connect(function()
		self:LaunchPlayer()
	end))
	self._Janitor:Add(component2.Interacted:Connect(function()
		self:GoDown()
	end))
end

function v:LaunchPlayer()
	if self._debounce then
		return
	end

	self._debounce = true
	task.delay(0.2, function()
		self._debounce = false
	end)
	local goUp = self.Instance:WaitForChild("GoUp")
	local character = Players.LocalPlayer.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	Remotes.fireServerComponent(self.Instance, "AddVFX")
	humanoidRootPart.CFrame = goUp.CFrame + createVector(0, 1, 0)
	task.wait(0.1)
	humanoidRootPart:ApplyImpulse(createVector(0, 1, 0) * humanoidRootPart.AssemblyMass * 150)
end

function v:GoDown()
	if self._debounce then
		return
	end

	self._debounce = true
	task.delay(0.2, function()
		self._debounce = false
	end)
	local character = Players.LocalPlayer.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	humanoidRootPart.CFrame = self.Instance:WaitForChild("GoDown").CFrame
	Remotes.fireServerComponent(self.Instance, "AddVFX")
end

function v:Stop()
	self._Janitor:Destroy()
end

return v