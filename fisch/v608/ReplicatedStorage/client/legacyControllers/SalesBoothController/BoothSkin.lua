local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("StarterGui")
game:GetService("MarketplaceService")
game:GetService("Players")
local packages = ReplicatedStorage:WaitForChild("packages")
local Net = require(packages.Net)
local Trove = require(packages.Trove)
local legacyControllers = ReplicatedStorage:WaitForChild("client").legacyControllers
local DataController = require(legacyControllers.DataController)
require(ReplicatedStorage.shared.Monetization)
local ViewportModel = require(ReplicatedStorage.packages.ViewportModel)
local modules = ReplicatedStorage:WaitForChild("shared").modules
local SalesBooth = require(modules.SalesBooth)
local remoteEvent = Net:RemoteEvent("SalesBoothService/EquipSkin")
local salesBoothSkins = ReplicatedStorage.resources.models.SalesBoothSkins
local BoothSkin = {}
BoothSkin.__index = BoothSkin

function BoothSkin:Update()
	self.Collector:Clean()
	DataController.PlayerDataReplicator:WaitForLoaded()
	local index = DataController.PlayerDataReplicator:Index({ "SalesBooth" })

	for childName, item in SalesBooth.Items do
		local clone = self.Instance.ItemList.List.ScrollingFrame:FindFirstChild(childName)

		if not clone then
			clone = self.Instance.ItemList.List.ScrollingFrame.Template:Clone()
			clone.Name = childName
			clone.Label.Text = item.DisplayName or childName
			local v = childName
			local v2 = item
			clone.Activated:Connect(function()
				local index2 = DataController.PlayerDataReplicator:Index({ "SalesBooth" })

				if index2.CurrentSkin == v then
					return
				end

				local skin = index2.Skins[v]
				local v4

				if typeof(skin) == "table" then
					v4 = skin.stack > 0
				else
					v4 = skin == true or false
				end

				if v4 then
					remoteEvent:FireServer(v)
				else
					local productId = v2.ProductId
				end
			end)
			clone.Icon.Image = item.Icon or ""
			clone.LayoutOrder = item.Order

			if item.Icon then
				clone.Icon.ViewportFrame:Destroy()
			else
				local camera = Instance.new("Camera")
				camera.Parent = clone.Icon.ViewportFrame
				clone.Icon.ViewportFrame.CurrentCamera = camera
				local v3 = ViewportModel.new(clone.Icon.ViewportFrame, camera)
				local clone2 = salesBoothSkins:FindFirstChild(childName):Clone()
				clone2:PivotTo(CFrame.new(createVector(0, 1000, 0)) * CFrame.Angles(0, 3.141592653589793, 0))
				clone2.Parent = clone.Icon.ViewportFrame
				local boundingBox, _ = clone2:GetBoundingBox()
				v3:SetModel(clone2)
				CFrame.fromEulerAnglesYXZ(0, 0, 0.4363323129985824)
				local fitDistance = v3:GetFitDistance(boundingBox.Position)
				camera.CFrame = CFrame.lookAt(
					(boundingBox + vector.create(0, 0, fitDistance)).Position,
					boundingBox.Position
				)
				clone.Icon.ViewportFrame.Visible = true
			end

			clone.Parent = self.Instance.ItemList.List.ScrollingFrame
		end

		local skin = index.Skins[childName]
		local v2

		if typeof(skin) == "table" then
			v2 = skin.stack > 0
		else
			v2 = skin == true or false
		end

		clone.Price.Visible = item.ProductId and not v2
		clone.Locked.Visible = not v2
		local order = item.Order or 1

		if not v2 then
			order = 1000 + order
		end

		clone.LayoutOrder = order
		local visible = index.CurrentSkin == childName
		clone.Equipped.Visible = visible
		clone.Visible = not (item.ProductId or item.HideInInventory) or (item.ProductId and v2 and true or false)
	end
end

function BoothSkin:Toggle(visible: boolean?)
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

function BoothSkin:IsOpen()
	return self.Instance.Visible == true
end

function BoothSkin.new(instance)
	local object = setmetatable({}, BoothSkin)
	object.Instance = instance
	object.Collector = Trove.new()
	object.Instance:FindFirstChild("Close").Activated:Connect(function()
		object.OpenUI("EditBooth")
	end)
	DataController.PlayerDataReplicator:Observe({ "SalesBooth" }, function()
		if object:IsOpen() then
			object:Update()
		end
	end)
	object:Toggle(false)
	return object
end

return BoothSkin