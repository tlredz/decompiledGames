local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("CollectionService")
game:GetService("RunService")
local PlayerStates = require(ReplicatedStorage.Modules.PlayerStates)
local Server = require(game.ReplicatedStorage.Modules.Server)
local v = Server:GetServerType() == Server.Servers.Neighborhood
local localPlayer = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local audioDeviceInput = localPlayer:WaitForChild("AudioDeviceInput", 1e999)

repeat
	task.wait()
until localPlayer.Character and localPlayer.Character.Parent == workspace

local audioListener = Instance.new("AudioListener")
local audioDeviceOutput = Instance.new("AudioDeviceOutput")
local part = Instance.new("Part")
part.Size = vector.create(1, 1, 1)
part.Anchored = true
part.CanCollide = false
part.Transparency = 1
part.Parent = workspace
local audioCompressor = Instance.new("AudioCompressor")
audioCompressor.MakeupGain = 15
audioCompressor.Ratio = 10
audioCompressor.Threshold = -35
audioCompressor.Parent = currentCamera
audioListener.Parent = currentCamera
audioDeviceOutput.Parent = currentCamera

local function CreateWire(p, targetInstance)
	local wire = Instance.new("Wire")
	wire.SourceInstance = p
	wire.TargetInstance = targetInstance
	wire.Parent = p
	wire.Name = `{p.Name} > {targetInstance.Name}`
	return wire
end

local wire = Instance.new("Wire")
wire.SourceInstance = audioListener
wire.TargetInstance = audioDeviceOutput
wire.Parent = audioListener
wire.Name = `{audioListener.Name} > {audioDeviceOutput.Name}`
local clone = audioListener:Clone()
clone.Name = "RadioListener"
clone.AudioInteractionGroup = "Radio"
clone.Parent = currentCamera

-- equivalent calls inferred from this helper; original call sites unknown
local function TriggerPartyChat()
	if not (localPlayer and localPlayer.Character) then
		return
	end

	local state = localPlayer:GetAttribute("State")

	if state ~= PlayerStates.Idle and state ~= PlayerStates.Queued then
		audioListener.Parent = currentCamera
		return
	end

	part.Position = localPlayer:GetAttribute("IdlePosition")
	audioListener.Parent = part
end

if v then
	TriggerPartyChat() -- equivalent call inferred; original call site unknown
	localPlayer:GetAttributeChangedSignal("IdlePosition"):Connect(TriggerPartyChat)
	localPlayer:GetAttributeChangedSignal("State"):Connect(TriggerPartyChat)
end

local function SetupRadioVC(parent)
	if not parent:FindFirstChild("FakeRadioEmitter") then
		local clone2 = script.FakeRadioEmitter:Clone()
		local v2 = audioDeviceInput
		local wire2 = Instance.new("Wire")
		wire2.SourceInstance = v2
		wire2.TargetInstance = clone2
		wire2.Parent = v2
		wire2.Name = `{v2.Name} > {clone2.Name}`
		clone2.Parent = parent
	end
end

local character = localPlayer.Character

if not character:FindFirstChild("FakeRadioEmitter") then
	local clone2 = script.FakeRadioEmitter:Clone()
	local wire2 = Instance.new("Wire")
	wire2.SourceInstance = audioDeviceInput
	wire2.TargetInstance = clone2
	wire2.Parent = audioDeviceInput
	wire2.Name = `{audioDeviceInput.Name} > {clone2.Name}`
	clone2.Parent = character
end

localPlayer.CharacterAdded:Connect(SetupRadioVC)