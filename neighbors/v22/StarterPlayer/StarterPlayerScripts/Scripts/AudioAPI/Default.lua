local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local currentCamera = workspace.CurrentCamera
local audioDeviceOutput = currentCamera:WaitForChild("AudioListener"):WaitForChild("Wire"):WaitForChild("AudioDeviceOutput")
local folder = Instance.new("Folder", workspace)
folder.Name = "Equalizers"
require(ReplicatedStorage.Modules.PlayerStates)

local function CreateEqualizer(audioEmitter, parent)
	local audioEqualizer = Instance.new("AudioEqualizer")
	audioEqualizer.Parent = folder
	audioEqualizer.MidRange = NumberRange.new(400, 3000)
	audioEqualizer:SetAttribute("MaxDistance", audioEmitter:GetAttribute("MaxDistance"))
	audioEmitter:GetAttributeChangedSignal("MaxDistance"):Connect(function()
		audioEqualizer:SetAttribute("MaxDistance", audioEmitter:GetAttribute("MaxDistance"))
	end)
	audioEmitter.Destroying:Connect(function()
		audioEqualizer:Destroy()
	end)

	if not parent then
		return audioEqualizer
	end

	local objectValue = Instance.new("ObjectValue")
	objectValue.Name = "ModelReference"
	objectValue.Parent = audioEqualizer
	objectValue.Value = parent

	if parent.Name == "Handle" then
		audioEqualizer.Name = `Equalizer{(parent:FindFirstChildOfClass("Model") or parent:FindFirstAncestorOfClass("Player")).Name}{parent.Parent.Name}`
		return audioEqualizer
	end

	audioEqualizer.Name = `Equalizer{parent.Name}{audioEmitter.Name}`
	return audioEqualizer
end

local function CreateWire(p, targetInstance)
	local wire = Instance.new("Wire")
	wire.SourceInstance = p
	wire.TargetInstance = targetInstance
	wire.Parent = p
	wire.Name = `{p.Name} > {targetInstance.Name}`
	return wire
end

local function SetupCompressor()
	local audioCompressor = Instance.new("AudioCompressor")
	audioCompressor.Parent = currentCamera
	audioCompressor.MakeupGain = 5
	audioCompressor.Ratio = 10
	audioCompressor.Threshold = -20
	local targetInstance = audioDeviceOutput
	local wire = Instance.new("Wire")
	wire.SourceInstance = audioCompressor
	wire.TargetInstance = targetInstance
	wire.Parent = audioCompressor
	wire.Name = `{audioCompressor.Name} > {targetInstance.Name}`
end

local function HandleFreshEmitter(audioEmitter)
	if audioEmitter:FindFirstAncestorOfClass("StarterGear") or not audioEmitter:IsA("AudioEmitter") then
		return
	end

	local parent = audioEmitter.Parent
	local playerFromCharacter = Players:GetPlayerFromCharacter(parent)
	local wire = audioEmitter:WaitForChild("Wire")
	local v = CreateEqualizer(audioEmitter, parent)

	if playerFromCharacter then
		Players.PlayerRemoving:Connect(function(player)
			if playerFromCharacter == player then
				v:Destroy()
			end
		end)
		playerFromCharacter.CharacterRemoving:Connect(function()
			v:Destroy()
		end)
	end

	local sourceInstance = wire.SourceInstance
	local wire2 = Instance.new("Wire")
	wire2.SourceInstance = sourceInstance
	wire2.TargetInstance = v
	wire2.Parent = sourceInstance
	wire2.Name = `{sourceInstance.Name} > {v.Name}`
	local targetInstance = wire.TargetInstance
	local wire3 = Instance.new("Wire")
	wire3.SourceInstance = v
	wire3.TargetInstance = targetInstance
	wire3.Parent = v
	wire3.Name = `{v.Name} > {targetInstance.Name}`
	wire:Destroy()
end

local function Lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Rescale(value: number, numberRange: NumberRange, numberRange2: NumberRange)
	return (math.clamp(value, numberRange.Min, numberRange.Max) - numberRange.Min / (numberRange.Max - numberRange.Min)) * (numberRange2.Max - numberRange2.Min) + numberRange2.Min
end

RunService.RenderStepped:Connect(function()
	if not folder then
		return
	end

	for _, child in folder:GetChildren() do
		local modelReference = child:FindFirstChild("ModelReference")

		if not (modelReference and modelReference.Value) then
			break
		end

		local value = modelReference.Value
		local playerFromCharacter = Players:GetPlayerFromCharacter(value)
		local v = value:GetPivot().Position - currentCamera.CFrame.Position
		local rescale = Rescale(
			v.Unit:Dot(currentCamera.CFrame.LookVector),
			NumberRange.new(-1, 1),
			NumberRange.new(-5, 0)
		) -- equivalent call inferred; original call site unknown
		local maxDistance = child:GetAttribute("MaxDistance") or 80
		local v3 = math.max(v.Magnitude, 1)
		local v5 = Rescale(1 + -1 * (v3 / maxDistance), NumberRange.new(0, 1), NumberRange.new(-10, 10)) -- equivalent call inferred; original call site unknown
		local highGain = rescale + v5

		if maxDistance < v3 or playerFromCharacter and playerFromCharacter:GetAttribute("UsingVoiceTool") then
			highGain = -80
			v5 = -80
		end

		child.HighGain = highGain
		child.LowGain = v5
		child.MidGain = v5
	end
end)
local audioCompressor = Instance.new("AudioCompressor")
audioCompressor.Parent = currentCamera
audioCompressor.MakeupGain = 5
audioCompressor.Ratio = 10
audioCompressor.Threshold = -20
local wire = Instance.new("Wire")
wire.SourceInstance = audioCompressor
wire.TargetInstance = audioDeviceOutput
wire.Parent = audioCompressor
wire.Name = `{audioCompressor.Name} > {audioDeviceOutput.Name}`

for _, v in CollectionService:GetTagged("RbxDefaultVoiceEmitter") do
	HandleFreshEmitter(v)
end

CollectionService:GetInstanceAddedSignal("RbxDefaultVoiceEmitter"):Connect(HandleFreshEmitter)

for _, v in CollectionService:GetTagged("WalkieEmitter") do
	HandleFreshEmitter(v)
end

CollectionService:GetInstanceAddedSignal("WalkieEmitter"):Connect(HandleFreshEmitter)