local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local ClickDetectorWithTool = require(ReplicatedStorage.Modules.Client.Components.UI.ClickDetectorWithTool)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local ConfirmationPanel = require(ReplicatedStorage.Modules.Client.UI.ConfirmationPanel)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local ToolRoot = require(ReplicatedStorage.Modules.Client.Components.Tools.ToolRoot)
local JettsConfig = require(ReplicatedStorage.Modules.Shared.DB.World.JettsConfig)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local v = Component.new({
	Tag = "GarbageBin"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Interact(player)
	local tool = player.Character:FindFirstChildOfClass("Tool")

	if tool then
		local panel = PanelController.GetPanel("NoResetGUIHandler", "ConfirmationPanel")

		if not panel then
			return
		end

		ComponentUtil.FindAndWaitForAncestorComponent(panel.Instance, "ConfirmationPanel", ConfirmationPanel):Init(
			"Are you sure you want to discard this tool?",
			function(flag: boolean)
				if flag then
					local component = ComponentUtil.GetComponentFromInstance(tool, ToolRoot)

					if not component then
						return
					end

					component:DeleteTool()
				end
			end
		)
	else
		local config = JettsConfig.GetConfig()

		if config.EMPTY_HANDS_GARBAGE_BIN_MESSAGE and config.EMPTY_HANDS_GARBAGE_BIN_MESSAGE ~= "" then
			NotificationController.NotifyCenter(config.EMPTY_HANDS_GARBAGE_BIN_MESSAGE)
		end
	end
end

function v:Start()
	local clickDetector = self.Instance:FindFirstChild("ClickDetector")

	if not clickDetector then
		warn("GarbageBin - ClickDetector not found")
		return
	end

	self.clickDetector = ComponentUtil.GetComponentFromInstance(clickDetector, ClickDetectorWithTool)
	self._Janitor:Add(self.clickDetector.MouseClick:Connect(function(p)
		self:Interact(p)
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v