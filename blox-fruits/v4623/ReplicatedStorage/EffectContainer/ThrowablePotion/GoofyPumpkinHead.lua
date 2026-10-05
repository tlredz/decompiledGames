local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
require(ReplicatedStorage:WaitForChild("Mouse"))
local _ = Util.Sound
local _ = workspace.Map
local _ = Util.Debris
require(game.ReplicatedStorage.FX)
game:GetService("TweenService")
local Players = game:GetService("Players")
game:GetService("UserInputService")
local RunService = game:GetService("RunService")
game:GetService("TweenService")
local _ = Players.LocalPlayer
local Sound = require(game.ReplicatedStorage.Util.Sound)

local function setupHead(char)
	char.Archivable = true
	local clone = char:Clone()
	clone:ScaleTo(0.1)
	local head = char:FindFirstChild("Head")
	char:FindFirstChild("Humanoid")

	if not head then
		return
	end

	local head2 = clone.Head
	local neck = head2.Neck
	neck.Part0 = char.UpperTorso
	local neckC = neck.C0.Rotation * CFrame.new(neck.C0.Position)
	local neckC2 = neck.C1.Rotation * CFrame.new(neck.C1.Position)
	clone:ScaleTo(1)
	local model = Instance.new("Model", head)
	head2.Parent = model

	for _, accessory in clone:GetChildren() do
		if not (accessory:IsA("Accessory") and (accessory.AccessoryType == Enum.AccessoryType.Hat or accessory.AccessoryType == Enum.AccessoryType.Hair or accessory.AccessoryType == Enum.AccessoryType.Face)) then
			continue
		end

		local handle = accessory:FindFirstChild("Handle")

		if not handle then
			continue
		end

		accessory.Parent = head2
		handle.AccessoryWeld.Part1 = head2
	end

	return {
		CloneNeckPointer = neck,
		NeckPointer = head.Neck,
		cloneHead = model,
		NeckC1 = neckC2,
		NeckC0 = neckC
	}
end

local function resizeHead() end

return function(data)
	task.wait(data.delay)
	local handle = data.accessory:WaitForChild("Handle")
	local v = { "HalloweenPotions_PumpkinHead_SpinEnd_01" }
	Sound:Play(v[math.random(1, #v)], handle)
	local specialMesh = handle:FindFirstChildWhichIsA("SpecialMesh")
	local total = 0.1

	while handle:IsDescendantOf(workspace) do
		handle.AccessoryWeld.C0 *= CFrame.fromEulerAnglesYXZ(0, math.rad(total), 0)
		total += task.wait() * 60 * 0.5
		specialMesh.Scale += createVector(1, 1, 1) * task.wait()
	end

	local v2 = setupHead(data.char)
	local cloneHead = v2.cloneHead
	local neckC0 = v2.NeckC0
	local neckC1 = v2.NeckC1
	local neckPointer = v2.NeckPointer
	local cloneNeckPointer = v2.CloneNeckPointer

	-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
	local function easeOutBack(p)
		return 1 + 2.70158 * (p - 1) ^ 3 + 1.70158 * (p - 1) ^ 2
	end

	local function easeInExpoBounce(p: number)
		return (math.clamp(math.pow(2, (p - 1) * 10) + math.sin(p * 3.141592653589793 * 3) * (1 - p) * 0.2, 0, 1.1))
	end

	local lastTime = tick()

	repeat
		RunService.Heartbeat:Wait()
		local v3 = math.clamp((tick() - lastTime) / 0.5, 0, 1)
		local v4 = 0 + 1 * easeOutBack(v3)
		cloneNeckPointer.C0 = neckPointer.C0:Lerp(neckC0, v4 * 1 / 2)
		cloneNeckPointer.C1 = neckPointer.C1:Lerp(neckC1, v4 * 1 / 2)
		cloneHead:ScaleTo(1 - v4 * 1 * 0.9)
	until v3 >= 1

	for _, part in cloneHead:GetDescendants() do
		if part:IsA("BasePart") then
			part.Transparency = 0
		end
	end

	local lastTime2 = tick()
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function()
		local v3 = math.clamp((tick() - lastTime2) / 0.5, 0, 1)
		local v4 = 1 + -1 * easeOutBack(v3)
		cloneNeckPointer.C0 = neckPointer.C0:Lerp(neckC0, v4 * 1 / 2)
		cloneNeckPointer.C1 = neckPointer.C1:Lerp(neckC1, v4 * 1 / 2)
		cloneHead:ScaleTo(1 - v4 * 1 * 0.9)

		if v3 <= 0 then
			heartbeatConnection:Disconnect()
		end
	end)
	task.wait(1)
	cloneHead:Destroy()
end