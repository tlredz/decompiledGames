local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ServerScriptService")
local toolsExtras = ReplicatedStorage:WaitForChild("Models").ToolsExtras
local packages = ReplicatedStorage:WaitForChild("Packages")
local Net = require(packages.Net)
local Debounce = require(packages.Debounce)
local parent = script.Parent
local parent2 = parent.Parent.Parent
local track = nil
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

-- equivalent calls inferred from this helper; original call sites unknown
local function LoadAnimations()
	if track then
		return
	end

	track = parent2.Character:WaitForChild("Humanoid"):WaitForChild("Animator"):LoadAnimation(script.Attack)
	track.Priority = Enum.AnimationPriority.Action4
	track.Looped = false
end

parent.Activated:Connect(function()
	local success, result = pcall(function()
		return Net:Invoke("UseItem")
	end)

	if not success or type(result) ~= "number" then
		return
	end

	if track then
		track:Play()
	end

	Debounce(`ItemUse/MedusaAttackAnimation/{parent2.Name}`, result - workspace:GetServerTimeNow())
end)
parent.Equipped:Connect(function()
	if clone then
		clone:Destroy()
	end

	if heartbeatConnection then
		heartbeatConnection:Disconnect()
	end

	LoadAnimations() -- equivalent call inferred; original call site unknown
	clone = toolsExtras.Ring:Clone()
	clone.Union.Color = Color3.new(0, 0.882353, 1)
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

	if track and track.IsPlaying then
		track:Stop()
	end
end)