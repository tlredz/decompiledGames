local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local packages = ReplicatedStorage.packages
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local Component = require(packages.Component)
local Trove = require(packages.Trove)
local _ = ReplicatedStorage:WaitForChild("shared").modules
local Monetization = require(ReplicatedStorage.shared.Monetization)
local SalesBooth = require(ReplicatedStorage.shared.modules.SalesBooth)
local items = SalesBooth.Items
local salesBoothSkins = ReplicatedStorage:WaitForChild("resources").models.SalesBoothSkins
local NotificationController = require(ReplicatedStorage.client.legacyControllers.NotificationController)
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local localPlayer = Players.LocalPlayer
legacyLocalPlayerData.fetch()

local function formatTime(i)
	local v = math.floor(i / 86400)
	local v2 = math.floor(i % 86400 / 3600)
	local v3 = math.floor(i % 3600 / 60)
	local v4 = i % 60
	local v5 = ""

	if v > 0 then
		v5 ..= v .. "d"
	end

	if v2 > 0 then
		v5 ..= v2 .. "h"
	end

	if v3 > 0 then
		v5 ..= v3 .. "m"
	end

	if v4 > 0 or v5 == "" then
		return v5 .. v4 .. "s"
	end

	return v5
end

local v = Component.new({
	Tag = "BoothSeller"
})

function v:Construct()
	self.trove = Trove.new()

	if not items[self.Instance:GetAttribute("Booth")] then
		return
	end

	self.Prompt = Instance.new("ProximityPrompt", self.Instance.Prompt)
	self.Prompt.Style = Enum.ProximityPromptStyle.Custom
	self.Prompt.ObjectText = self.Instance:GetAttribute("Booth")
	self.Instance.Timer.UI.Title.Text = self.Instance:GetAttribute("Booth")
	local robuxPrice = Monetization:GetRobuxPrice(items[self.Instance:GetAttribute("Booth")].ProductId)

	if robuxPrice then
		self.Prompt.ActionText = `Buy for [{utf8.char(57346)} {tostring(robuxPrice)}]`
	end

	self:LoadSkin()
end

function v:LoadSkin()
	local child = salesBoothSkins:FindFirstChild(self.Instance:GetAttribute("Booth"))

	if child then
		local clone = child:Clone()
		clone:PivotTo(self.Instance.Parent:GetPivot())
		self.Instance.Parent.Decorations:ClearAllChildren()

		for _, child2 in clone.Decorations:GetChildren() do
			child2.Parent = self.Instance.Parent.Decorations
		end

		clone:Destroy()
	end
end

function v.Start(data)
	local item = items[data.Instance:GetAttribute("Booth")]

	if not item then
		return
	end

	data.trove:Add(data.Prompt.Triggered:Connect(function(player)
		if player == localPlayer then
			DataController.PlayerDataReplicator:WaitForLoaded()

			if DataController.PlayerDataReplicator:Index({ "SalesBooth" }).Skins[data.Instance:GetAttribute("Booth")] then
				NotificationController:Notify("You already have this booth skin!")
			else
				Monetization.BuyProduct:FireServer(item.ProductId)
			end
		end
	end))

	if not item.EndTime then
		data.Instance.Timer.UI.Time.Visible = false
		return
	end

	data.Instance.Timer.UI.Time.Visible = true
	local v2 = math.max(0, item.EndTime - os.time())
	data.trove:Add(task.spawn(function()
		if v2 > 0 then
			for i = v2, 0, -1 do
				data.Instance.Timer.UI.Time.Text = `{formatTime(i)}`
				task.wait(1)
			end
		end

		if data.Instance:IsDescendantOf(workspace) then
			data.Instance.Parent = game.ReplicatedStorage
		end
	end))
end

function v.Stop(p)
	p.trove:Clean()
end

return v