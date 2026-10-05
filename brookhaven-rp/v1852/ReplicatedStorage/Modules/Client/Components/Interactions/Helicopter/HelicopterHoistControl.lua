local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local HoistControls = require(ReplicatedStorage.Modules.Client.Components.UI.HoistControls)
local v = Component.new({
	Tag = "HelicopterHoistControl"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._controlJanitor = self._Janitor:Add(Janitor.new())
end

function v:Start()
	self._Janitor:Add(Remotes.connectComponentRemote(self.Instance, "TakeControl", function(p)
		self:TakeControl(p)
	end))
	self._Janitor:Add(Remotes.connectComponentRemote(self.Instance, "ReleaseControl", function()
		self:ReleaseControl()
	end))
end

function v:TakeControl()
	local panel = PanelController.GetPanel("HoistControls", "HoistControls")
	self._Janitor:AddPromise(HoistControls:WaitForInstance(panel.Instance):andThen(function(object)
		self._controlJanitor:Add(object.UpStateChanged:Connect(function(p)
			if object:GetSelectedHoist() ~= self.Instance.Name then
				return
			end

			Remotes.fireServerComponent(self.Instance, "HoistUp", p)
		end))
		self._controlJanitor:Add(object.DownStateChanged:Connect(function(p)
			if object:GetSelectedHoist() ~= self.Instance.Name then
				return
			end

			Remotes.fireServerComponent(self.Instance, "HoistDown", p)
		end))
		self._controlJanitor:Add(object.ChangeAttachment:Connect(function()
			if object:GetSelectedHoist() ~= self.Instance.Name then
				return
			end

			Remotes.fireServerComponent(self.Instance, "ChangeAttachment")
		end))
	end))
end

function v:ReleaseControl()
	PanelController.Close("HoistControls", "HoistControls")
	self._controlJanitor:Cleanup()
end

function v:Stop()
	self._Janitor:Destroy()
end

return v