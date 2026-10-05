local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage:WaitForChild("packages")
local Component = require(packages.Component)
local Trove = require(packages.Trove)
local Net = require(packages.Net)
local legacyControllers = ReplicatedStorage:WaitForChild("client").legacyControllers
local NotificationController = require(legacyControllers.NotificationController)
local modules = ReplicatedStorage:WaitForChild("client").modules
local legacyLocalPlayerData = require(modules.legacyLocalPlayerData)
local carrotInteractedWithPrompt = legacyLocalPlayerData.fetch():WaitForChild("Cache"):WaitForChild("CarrotInteractedWithPrompt")
local remoteEvent = Net:RemoteEvent("CarrotService/ClaimCode")
local v = Component.new({
	Tag = "CarrotCode"
})

function v:Setup()
	self.ProximityPrompt = Instance.new("ProximityPrompt")
	self.ProximityPrompt.ActionText = "Claim"
	self.ProximityPrompt.HoldDuration = 1
	self.ProximityPrompt.Parent = self.Instance
	self.ProximityPrompt.RequiresLineOfSight = false
	self.Collector:Add(self.ProximityPrompt.Triggered:Connect(function()
		remoteEvent:FireServer()
	end))
	self.Collector:Add(self.ProximityPrompt)
	self.Collector:Add(carrotInteractedWithPrompt.Changed:Connect(function()
		if carrotInteractedWithPrompt.Value == true then
			NotificationController:Notify(
				"<font color='#FFB347'><b>?? You discovered a strange note!</b></font> <font color='#FFA500'>Scrawled on it: <i><b>“Glub Glub Luck Luck”</b></i></font> <font color='#FF7F50'>(Maybe someone’s waiting to hear this...)</font>",
				15,
				"starsfalling"
			)
			self:Clear()
		end
	end))
end

function v:Clear()
	self.Instance:ClearAllChildren()
end

function v:Construct()
	self.Collector = Trove.new()
end

function v:Start()
	if carrotInteractedWithPrompt.Value == false then
		self:Setup()
	else
		self:Clear()
	end
end

function v.Stop(p)
	p.Collector:Destroy()
end

return v