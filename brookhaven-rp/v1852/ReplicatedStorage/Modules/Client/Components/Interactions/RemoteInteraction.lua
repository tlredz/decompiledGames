local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local v = Component.new({
	Tag = "RemoteInteraction"
})
local InteractionPrompt = require(ReplicatedStorage.Modules.Client.Components.Interactions.InteractionPrompt)

function v:Construct()
	self._Janitor = Janitor.new()
	self.interactionPrompt = InteractionPrompt:WaitForInstance(self.Instance):expect()
end

function v:Start()
	self._Janitor:Add(self.interactionPrompt.Interacted:Connect(function()
		Remotes.fireServerComponent(self.Instance, "PromptInteract")
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v