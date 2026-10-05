local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("StarterGui")
local Players = game:GetService("Players")
local packages = ReplicatedStorage:WaitForChild("packages")
local Trove = require(packages.Trove)
local Net = require(packages.Net)
local legacyControllers = ReplicatedStorage:WaitForChild("client").legacyControllers
local DataController = require(legacyControllers.DataController)
local modules = ReplicatedStorage:WaitForChild("shared").modules
local SalesBooth = require(modules.SalesBooth)
local items = require(ReplicatedStorage.shared.modules.library.items)
local NumberUtils = require(ReplicatedStorage.shared.utils.NumberUtils)
local remoteEvent = Net:RemoteEvent("SalesBoothService/RemoveItem")
local remoteEvent2 = Net:RemoteEvent("SalesBoothService/Claim")
local remoteEvent3 = Net:RemoteEvent("SalesBoothService/FavoriteItem")
local remoteEvent4 = Net:RemoteEvent("SalesBoothService/UpdateInfo")
local EditBooth = {}
EditBooth.__index = EditBooth
local itemList = nil

function EditBooth:Update()
	self.Collector:Clean()

	if not itemList then
		DataController.PlayerDataReplicator:WaitForLoaded()
		itemList = DataController.PlayerDataReplicator:Index({ "SalesBooth", "ItemList" })

		if not itemList then
			warn("no sales booth data found?? how?? help??")
			return
		end
	end

	local v = false

	for k, v2 in itemList do
		local clone = self.Instance.ItemList.List.ScrollingFrame.ItemTemplate:Clone()
		clone.Name = k
		local v3 = SalesBooth.Types[v2.Type].Data[v2.GliderName or v2.Index]

		if v2.Type == "Glider" then
			v3 = items.Items[v2.GliderName or v2.Index]
		end

		if v2.Value == -1 then
			clone.Price.Text = "Trading"
		else
			clone.Price.Text = `S$ {NumberUtils:ToString(v2.Value, 2)}`
		end

		clone.Label.Text = v3 and v3.DisplayText or v2.GliderName or v2.Index
		clone.Icon.Image = v3.Icon or ""
		self.Collector:Add(clone)
		clone.Visible = true
		clone.Favorite.Visible = v2.Favorite == true
		clone.Parent = self.Instance.ItemList.List.ScrollingFrame
		v = v2.Favorite == true or v
		clone.LayoutOrder = k - (v2.Favorite == true and 500 or 0)
		local v4 = k
		self.Collector:Connect(clone.RemoveButton.Activated, function()
			remoteEvent:FireServer(v4)
		end)
		local v5 = k
		self.Collector:Connect(clone.Activated, function()
			remoteEvent3:FireServer(v5)
		end)
	end

	if v then
		self.Instance.Header.Tutorial.Visible = false
	else
		self.Instance.Header.Tutorial.Visible = true
	end

	if #itemList < 12 then
		local clone = self.Instance.ItemList.List.ScrollingFrame.AddTemplate:Clone()
		clone.Parent = self.Instance.ItemList.List.ScrollingFrame
		clone.Visible = true
		self.Collector:Add(clone)
		self.Collector:Connect(clone.Activated, function()
			self.OpenUI("SellItem")
		end)
	end
end

function EditBooth:Toggle(visible: boolean?)
	if visible == nil then
		visible = not self.Instance.Visible or nil
	end

	local visible2 = self.Instance.Visible
	self.Instance.Visible = visible

	if visible ~= visible2 then
		if visible == false then
			self.Collector:Clean()

			if self.CloseCallback then
				self.CloseCallback(self.Instance.Name)
			end
		else
			self:Update()
		end
	end
end

function EditBooth:IsOpen()
	return self.Instance.Visible == true
end

function EditBooth.new(instance)
	local object = setmetatable({}, EditBooth)
	object.Instance = instance
	object.Collector = Trove.new()
	object.Instance:FindFirstChild("Close").Activated:Connect(function()
		object:Toggle(false)
	end)
	object.Instance.Options.Unclaim.Activated:Connect(function()
		object:Toggle(false)
		remoteEvent2:FireServer("")
	end)
	object.Instance.Options.Edit.Activated:Connect(function()
		object.OpenUI("BoothSkin")
	end)
	remoteEvent4.OnClientEvent:Connect(function(_, p)
		if p.Owner == Players.LocalPlayer then
			itemList = p.ItemList

			if object:IsOpen() then
				object:Update()
			end
		end
	end)
	object:Toggle(false)
	return object
end

return EditBooth