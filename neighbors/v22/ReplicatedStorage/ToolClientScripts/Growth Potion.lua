local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Janitor = require(ReplicatedStorage.Modules.Janitor)
local UI = require(ReplicatedStorage.Modules.UI)
local mouse = Players.LocalPlayer:GetMouse()
local v = {
	MinScale = 0.35,
	MaxScale = 4,
	StepFactor = 0.05
}
require(ReplicatedStorage.Modules.Tool)

local function getPercent(p: number)
	return (p - 0.35) / 3.65
end

local function step(p: number, p2: number)
	return p - p % p2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getMoverValue(vector: Vector3)
	if vector.Y > 0.8 then
		return 1
	end

	if vector.Y < -0.8 then
		return -1
	end

	return 0
end

local GrowthPotion = {}

function GrowthPotion:Equipped()
	if self.Janitor then
		self.Janitor:Destroy()
	end

	self.Janitor = Janitor.new()
	self.Gui = script.Scaler:Clone()
	self.Gui.Parent = self.PlayerGui
	local frame = self.Gui.Frame
	local dragger = frame.Dragger
	local currentScale = frame.CurrentScale
	local v2 = false
	local growthScale = self.Character:GetAttribute("GrowthScale") or 1
	local lastTime = os.clock()

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateLabel()
		currentScale.Text = `Scale: {math.round(growthScale * 100)}%`
	end

	local function updateDraggerPosition(p: number, p2: number)
		local v3 = math.lerp(0.35, 4, p)
		growthScale = v3
		dragger.Position = dragger.Position:Lerp(UDim2.new(p, 0, 0.5, 0), p2 * 15)
		updateLabel() -- equivalent call inferred; original call site unknown

		if os.clock() - lastTime > 0.15 then
			lastTime = os.clock()
			self:FireEvent("SetScale", v3)
		end

		return v3
	end

	local function resetToDefault()
		growthScale = 1
		dragger.Position = UDim2.new((growthScale - v.MinScale) / (v.MaxScale - v.MinScale), 0, 0.5, 0)
		updateLabel() -- equivalent call inferred; original call site unknown
		self:FireEvent("SetScale", 1)
	end

	local v3 = growthScale
	dragger.Position = UDim2.new((v3 - v.MinScale) / (v.MaxScale - v.MinScale), 0, 0.5, 0)
	updateLabel() -- equivalent call inferred; original call site unknown
	local janitor = self.Janitor
	janitor:Add(dragger.MouseButton1Down:Connect(function()
		v2 = true

		while v2 and self.Character and self.Character:FindFirstChild(self.Tool.Name) do
			local v4 = RunService.Heartbeat:Wait()
			local X = frame.AbsoluteSize.X
			local v5 = frame.AbsolutePosition.X + X * 0.5
			local v8 = math.clamp((mouse.X - v5) / X, -0.5, 0.5) + 0.5
			updateDraggerPosition(v8 - v8 % 0.05, v4)
		end

		self:FireEvent("SetScale", growthScale)
	end))
	janitor:Add(dragger.MouseButton1Up:Connect(function()
		v2 = false
	end))
	janitor:Add(frame.Default.Activated:Connect(resetToDefault))
	janitor:Add(self.Gui.VR.Default.Activated:Connect(resetToDefault))
	local total = 0
	local v4 = 0
	janitor:Add(UserInputService.InputChanged:Connect(function(input, gameProcessed: boolean)
		if not gameProcessed and input.KeyCode == Enum.KeyCode.Thumbstick2 then
			v4 = getMoverValue(input.Position)
		end
	end))
	janitor:Add(RunService.Heartbeat:Connect(function(dt: number)
		if v4 == 0 then
			return
		end

		total += dt

		if total > 0.15 then
			total = 0
			updateDraggerPosition(
				math.clamp((growthScale - v.MinScale) / (v.MaxScale - v.MinScale) + 0.05 * v4, 0, 1),
				0.06666666666666667
			)
		end
	end))
	janitor:Add(mouse.Button1Up:Connect(function()
		v2 = false
	end))
	UI:Bind(frame.Default)
end

function GrowthPotion:Unequipped()
	if self.Gui then
		self.Gui:Destroy()
		self.Gui = nil
	end

	if self.Janitor then
		self.Janitor:Destroy()
		self.Janitor = nil
	end
end

function GrowthPotion:Destroyed()
	if self.Gui then
		self.Gui:Destroy()
		self.Gui = nil
	end

	if self.Janitor then
		self.Janitor:Destroy()
		self.Janitor = nil
	end
end

return GrowthPotion