local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ServerScriptService")
local packages = ReplicatedStorage:WaitForChild("Packages")
local Net = require(packages.Net)
require(packages.Debounce)
local toolsExtras = ReplicatedStorage:WaitForChild("Models").ToolsExtras
local parent = script.Parent
local parent2 = parent.Parent.Parent
local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
local clone = nil
local heartbeatConnection = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function SetupHumanoidFunction()
	local character = parent2.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if humanoid then
		humanoid.Died:Once(function()
			local child = workspace:FindFirstChild((`{parent2.Name}.Ring`))

			if child then
				child:Destroy()
			end

			if heartbeatConnection then
				heartbeatConnection:Disconnect()
			end
		end)
	end
end

local function TweenRing(p)
	if not clone then
		return
	end

	local numberValue = Instance.new("NumberValue", script)
	numberValue.Value = p and 0.0001 or 0.6
	numberValue.Changed:Connect(function(p2)
		if clone then
			clone:ScaleTo(p2)
		end
	end)
	local tween = TweenService:Create(numberValue, tweenInfo, {
		Value = p and 0.6 or 0.0001
	})
	tween:Play()
	tween.Completed:Connect(function()
		numberValue:Destroy()
	end)
	tween.Completed:Wait()
end

parent.Activated:Connect(function()
	Net:RemoteEvent("UseItem"):FireServer()
end)
parent.Equipped:Connect(function()
	if clone then
		clone:Destroy()
	end

	if heartbeatConnection then
		heartbeatConnection:Disconnect()
	end

	clone = toolsExtras.Ring:Clone()
	clone.Name = `{parent2.Name}.Ring`
	clone:PivotTo(parent2.Character:GetPivot())
	clone.Parent = workspace
	TweenRing(true)
	SetupHumanoidFunction() -- equivalent call inferred; original call site unknown
	heartbeatConnection = RunService.Heartbeat:Connect(function()
		local character = parent2.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and humanoidRootPart.Parent and clone then
			clone:PivotTo(humanoidRootPart:GetPivot() * CFrame.new(0, -3, 0))
		end
	end)
end)
parent.Unequipped:Connect(function()
	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end

	TweenRing(false)

	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end

	if clone then
		clone:Destroy()
		clone = nil
	end
end)