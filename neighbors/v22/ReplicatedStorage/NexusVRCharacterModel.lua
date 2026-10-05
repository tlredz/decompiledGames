local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local NexusBufferedReplication = require(script:WaitForChild("Packages"):WaitForChild("NexusBufferedReplication"))
local Settings = require(script:WaitForChild("State"):WaitForChild("Settings"))
local instance = Settings.GetInstance()
local BufferProtocol = require(script:WaitForChild("Util"):WaitForChild("BufferProtocol"))
local bufferedRemoteEventSender = NexusBufferedReplication.Sender.BufferedRemoteEventSender
local enrollableRemoteEvent = NexusBufferedReplication.Sender.EnrollableRemoteEvent
local NexusVRCharacterModel = {
	SetConfiguration = function(_, state)
		local v = script:FindFirstChild("Configuration")

		if not v then
			v = Instance.new("StringValue")
			v.Name = "Configuration"
			v.Parent = script
		end

		local v2

		if state.Extra then
			v2 = state.Extra.HideVersion == true
		else
			v2 = false
		end

		if not state.Version then
			state.Version = {}
		end

		if not state.Version.Tag then
			state.Version.Tag = v2 and "Hidden" or "2.15.1"
		end

		if not state.Version.Commit then
			state.Version.Commit = v2 and "Hidden" or "c6e3ad0"
		end

		v.Value = HttpService:JSONEncode(state)
		instance:SetDefaults(state)
	end,
	Load = function(_)
		if ReplicatedStorage:FindFirstChild("NexusVRCharacterModel") then
			return
		end

		script.Name = "NexusVRCharacterModel"
		script.Parent = ReplicatedStorage
		local packages = not ReplicatedStorage:FindFirstChild("NexusVRCore") and script:FindFirstChild("Packages")

		if packages then
			local nexusvrcore = packages:FindFirstChild("nexus-vr-core", true)
			local nexusinstance = packages:FindFirstChild("nexus-instance", true)

			if nexusvrcore and nexusinstance then
				local clone = nexusvrcore:Clone()
				clone.Name = "NexusVRCore"
				clone:WaitForChild("Packages"):WaitForChild("NexusInstance"):Destroy()
				local clone2 = nexusinstance:Clone()
				clone2.Name = "NexusInstance"
				clone2.Parent = clone:WaitForChild("Packages")
				clone.Parent = ReplicatedStorage
			end
		end

		local Warnings = require(ReplicatedStorage:WaitForChild("NexusVRCharacterModel"):WaitForChild("Util"):WaitForChild("Warnings"))
		Warnings()
		local nexusVRCharacterModelClientLoader = script:WaitForChild("NexusVRCharacterModelClientLoader")
		nexusVRCharacterModelClientLoader.Parent = ReplicatedStorage
		local unreliableRemoteEvent = Instance.new("UnreliableRemoteEvent")
		unreliableRemoteEvent.Name = "UpdateInputs"
		unreliableRemoteEvent.Parent = script
		local remoteEvent = Instance.new("RemoteEvent")
		remoteEvent.Name = "ReplicationReady"
		remoteEvent.Parent = script
		local v = enrollableRemoteEvent.new(unreliableRemoteEvent)
		local v2 = bufferedRemoteEventSender.WithPlayerKeys(v, function(p)
			return BufferProtocol.Serialize(p)
		end)
		v2:StartDataSendingWithDelay(0.03333333333333333)
		unreliableRemoteEvent.OnServerEvent:Connect(function(p, p2)
			if typeof(p2) ~= "table" then
				return
			end

			v2:QueueData(p, p2)
		end)
		remoteEvent.OnServerEvent:Connect(function(p)
			v:EnrollPlayer(p)
		end)

		if instance:GetSetting("Extra.NexusVRBackpackEnabled") ~= false then
			local module = require(10728805649)
			module()
		end
	end
}
local Api = require(script:WaitForChild("Api"))
NexusVRCharacterModel.Api = Api()
return NexusVRCharacterModel