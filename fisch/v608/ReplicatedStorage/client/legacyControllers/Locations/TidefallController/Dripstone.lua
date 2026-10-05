local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local packages = ReplicatedStorage:WaitForChild("packages")
local Net = require(packages.Net)
local remoteEvent = Net:RemoteEvent("Tidefall/DripstoneDrop")
local remoteEvent2 = Net:RemoteEvent("Tidefall/DripstoneReset")
local remoteEvent3 = Net:RemoteEvent("Tidefall/DripstoneHit")
local parent = Workspace:FindFirstChild("TidefallDripstoneCollapse_Client")

if not parent then
	parent = Instance.new("Folder")
	parent.Name = "TidefallDripstoneCollapse_Client"
	parent.Parent = Workspace
end

local v2 = {}

local function findDripstoneById(p: string)
	for _, v3 in ipairs(CollectionService:GetTagged("Dripstone")) do
		if v3:GetAttribute("DripstoneId") == p then
			return v3
		end
	end

	return nil
end

local function waitForDripstone(p: string, p2: number)
	local dripstoneById = findDripstoneById(p)

	if dripstoneById then
		return dripstoneById
	end

	local lastTime = os.clock()

	while os.clock() - lastTime < p2 do
		task.wait(0.25)
		local dripstoneById2 = findDripstoneById(p)

		if dripstoneById2 then
			return dripstoneById2
		end
	end

	return nil
end

local function setTransparent(part, flag: boolean)
	local localTransparencyModifier = flag and 1 or 0

	if part:IsA("BasePart") then
		part.LocalTransparencyModifier = localTransparencyModifier
	end

	for _, part2 in ipairs(part:GetDescendants()) do
		if part2:IsA("BasePart") then
			part2.LocalTransparencyModifier = localTransparencyModifier
		end
	end
end

local function playDropVisual(instance, p: number, cframe: CFrame)
	if instance.Parent == nil then
		return
	end

	local clone = instance:Clone()
	clone:RemoveTag("Dripstone")
	setTransparent(instance, true)
	local primaryPart = clone.PrimaryPart
	local clone2 = script.ParticleAttach:Clone()
	clone2.Parent = primaryPart

	for _, emitter in clone2:GetChildren() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emitter.Enabled = true
		local v3 = emitter
		task.delay(0.3, function()
			v3.Enabled = false
		end)
	end

	for _, part in ipairs(clone:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = true
		part.CanCollide = false
		part.LocalTransparencyModifier = 0
	end

	clone.Parent = parent
	clone2.FallStart:Play()
	clone2.FallIdle:Play()
	local pivot = clone:GetPivot()
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = 0
	local v3 = cframe - primaryPart.Size * createVector(0, 1, 0)
	local changedConnection = numberValue.Changed:Connect(function()
		clone:PivotTo(pivot:Lerp(v3, numberValue.Value))
	end)
	local tween = TweenService:Create(
		numberValue,
		TweenInfo.new(p / 0.85, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
		{
			Value = 1
		}
	)
	task.delay(p * 0.85, function()
		clone2.Impact:Play()

		for _, emitter in clone2:GetChildren() do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter.Enabled = true
			local v4 = emitter
			task.delay(0.3, function()
				v4.Enabled = false
			end)
		end
	end)
	tween.Completed:Once(function()
		changedConnection:Disconnect()
		numberValue:Destroy()
		primaryPart.LocalTransparencyModifier = 1
		clone2.FallIdle:Stop()
		clone2.CFrame = primaryPart.PivotOffset * CFrame.fromOrientation(0, 3.141592653589793, 0)
		task.delay(5, function()
			clone:Destroy()
		end)
	end)
	tween:Play()
end

return {
	Start = function(_)
		CollectionService:GetInstanceAddedSignal("Dripstone"):Connect(function(instance)
			local dripstoneId = instance:GetAttribute("DripstoneId")

			if type(dripstoneId) == "string" and v2[dripstoneId] == true then
				setTransparent(instance, true)
			end
		end)
		remoteEvent.OnClientEvent:Connect(function(_: string, p: string, p2: number, cframe: CFrame)
			v2[p] = true
			local v3 = waitForDripstone(p, 8)

			if not v3 then
				return
			end

			playDropVisual(v3, p2, cframe)
		end)
		remoteEvent2.OnClientEvent:Connect(function(_: string)
			for k, _ in pairs(v2) do
				local dripstoneById = findDripstoneById(k)

				if dripstoneById then
					setTransparent(dripstoneById, false)
				end
			end

			table.clear(v2)

			for _, child in ipairs(parent:GetChildren()) do
				child:Destroy()
			end
		end)
		remoteEvent3.OnClientEvent:Connect(function(vector2: Vector3)
			local character = Players.LocalPlayer.Character
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")

			if not (humanoidRootPart and humanoid) then
				return
			end

			humanoid:ChangeState(Enum.HumanoidStateType.Physics)
			humanoidRootPart:ApplyImpulse(((humanoidRootPart.Position - vector2) * createVector(1, 0, 1)).Unit * humanoidRootPart.AssemblyMass * 50 + Vector3.new(
				0,
				25 * humanoidRootPart.AssemblyMass,
				0
			))
			task.delay(5, function()
				humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
			end)
		end)
	end
}