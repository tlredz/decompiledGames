local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "LoadTestHouses"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local GameUtil = require(ReplicatedStorage.Modules.Shared.Game.GameUtil)

	if not GameUtil.isHouseTestingPlace() then
		self.Instance:RemoveTag(script.Name)
		return
	end

	local Remotes = require(ReplicatedStorage.Packages.Remotes)
	local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
	local template = self.Instance:FindFirstChild("Template")

	if template then
		local clones = {}
		self._Janitor:Add(PanelController.OnPanelOpened:Connect(function(_, p2)
			if p2 ~= "MainHouseMenu" then
				return
			end

			local v2 = Remotes.invokeServer("HouseTesting:LoadTestHouses")

			if not v2 then
				return
			end

			table.sort(v2)

			for k, v3 in v2 do
				local clone = template:Clone()
				clone.Visible = true
				clone.Name = v3
				clone.LayoutOrder = k
				clone:AddTag("LoadTestHouseButton")
				local textLabel = Instance.new("TextLabel")
				textLabel.Name = "TextLabel"
				textLabel.TextScaled = true
				textLabel.Size = UDim2.fromScale(1, 1)
				textLabel.BackgroundTransparency = 0
				textLabel.TextColor3 = Color3.new(1, 1, 1)
				textLabel.Text = v3
				textLabel.Parent = clone
				clone.Icon.Image = ""
				clone.Parent = self.Instance
				table.insert(clones, clone)
			end
		end))
		self._Janitor:Add(PanelController.OnPanelClosed:Connect(function(_, p2)
			if p2 ~= "MainHouseMenu" then
				return
			end

			for _, v2 in clones do
				v2:Destroy()
			end

			clones = {}
		end))
	else
		warn("Template button not found")
		self.Instance:RemoveTag(script.Name)
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v