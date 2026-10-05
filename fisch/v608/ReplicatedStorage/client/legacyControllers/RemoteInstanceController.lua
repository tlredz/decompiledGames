local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Net = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("Net"))
local module = require("./HudController")
local remoteEvent = Net:RemoteEvent("RemoteInstance/Destroy", 1e999)
local remoteEvent2 = Net:RemoteEvent("RemoteInstance/PromptTrigger", 1e999)
return {
	Start = function(_)
		local model = Instance.new("Model")
		model.Name = "RemoteStreamedInstances"
		model.ModelStreamingMode = Enum.ModelStreamingMode.Persistent
		model.Parent = workspace
		remoteEvent.OnClientEvent:Connect(function(items)
			for _, item in pairs(items) do
				if item then
					task.spawn(item.Destroy, item)
				end
			end
		end)
		CollectionService:GetInstanceAddedSignal("RemoteProximityPrompt"):Connect(function(instance)
			instance.Triggered:Connect(function()
				remoteEvent2:FireServer(instance:GetAttribute("Id"))
			end)
		end)
		local remoteInstanceStream = module:GetPlayerGui():WaitForChild("remoteInstanceStream")
		remoteInstanceStream.ChildAdded:Connect(function(child)
			child.Parent = model
		end)

		for _, child in remoteInstanceStream:GetChildren() do
			child.Parent = model
		end
	end
}