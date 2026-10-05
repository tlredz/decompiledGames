local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Net = require(ReplicatedStorage.packages.Net)
local assets = require(ReplicatedStorage.shared.utils.assets)
local remoteEvent = Net:RemoteEvent("MermaidCove/AltarStart")
local remoteEvent2 = Net:RemoteEvent("MermaidCove/AltarClaim")
local shellChangeExplosion = ReplicatedStorage.resources.vfx.ShellChangeExplosion

-- equivalent calls inferred from this helper; original call sites unknown
local function findAltarBed()
	return CollectionService:GetTagged("ShellAltarBed")[1]
end

-- equivalent calls inferred from this helper; original call sites unknown
local function findAltarPrompt()
	local v = CollectionService:GetTagged("ShellAltar")[1]

	if v then
		return v:FindFirstChildWhichIsA("ProximityPrompt", true)
	end

	return nil
end

local function getItemDisplay(name: string)
	local async = assets.getAsync("item", name)

	if async then
		local clone = async:FindFirstChild(name):Clone()

		for _, part in clone:GetDescendants() do
			if not part:IsA("BasePart") then
				continue
			end

			part.Anchored = true
			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
		end

		local v

		if clone:IsA("Model") then
			v = clone.PrimaryPart
		end

		return clone, v or clone:FindFirstChildWhichIsA("BasePart", true) or clone
	else
		local part = Instance.new("Part")
		part.Name = name
		part.Size = createVector(2, 1, 2)
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.Material = Enum.Material.Sand
		part.Color = Color3.fromRGB(255, 220, 180)
		return part, part
	end
end

local function runAltarSequence(objectText: string)
	local altarBed = findAltarBed() -- equivalent call inferred; original call site unknown

	if not altarBed then
		remoteEvent2:FireServer()
		return
	end

	local cFrame = altarBed.CFrame * CFrame.new(0, 2.5, 0)
	local clone = shellChangeExplosion:Clone()
	clone:AddTag("IgnorePerformance")
	clone.Transparency = 1
	clone.Anchored = true
	clone.CFrame = cFrame
	clone.Parent = workspace

	for _, v2 in clone:QueryDescendants("ParticleEmitter") do
		v2:Emit(v2:GetAttribute("EmitCount"))
	end

	task.delay(3, function()
		if clone.Parent then
			clone:Destroy()
		end
	end)
	local itemDisplay, parent = getItemDisplay(objectText)
	itemDisplay:PivotTo(cFrame)
	itemDisplay.Parent = workspace
	local altarPrompt = findAltarPrompt() -- equivalent call inferred; original call site unknown

	if altarPrompt then
		altarPrompt.Enabled = false
	end

	local proximityPrompt = Instance.new("ProximityPrompt")
	proximityPrompt.Style = Enum.ProximityPromptStyle.Custom
	proximityPrompt.ActionText = "Take"
	proximityPrompt.ObjectText = objectText
	proximityPrompt.HoldDuration = 0
	proximityPrompt.MaxActivationDistance = 12
	proximityPrompt.RequiresLineOfSight = false
	proximityPrompt.Parent = parent
	local lastTime = os.clock()
	local renderSteppedConnection = nil
	renderSteppedConnection = RunService.RenderStepped:Connect(function()
		if not itemDisplay.Parent then
			renderSteppedConnection:Disconnect()
			return
		end

		local v3 = os.clock() - lastTime
		local v4 = math.sin(v3 * 2) * 0.4
		local cframe = CFrame.Angles(0, v3 * 0.6, 0)
		itemDisplay:PivotTo(cFrame * CFrame.new(0, v4, 0) * cframe)
	end)
	proximityPrompt.Triggered:Once(function()
		renderSteppedConnection:Disconnect()
		itemDisplay:Destroy()

		if altarPrompt then
			altarPrompt.Enabled = true
		end

		remoteEvent2:FireServer()
	end)
end

return {
	Start = function(_)
		remoteEvent.OnClientEvent:Connect(function(p)
			task.spawn(runAltarSequence, p)
		end)
	end
}