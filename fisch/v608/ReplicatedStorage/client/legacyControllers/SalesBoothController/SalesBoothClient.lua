local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local packages = ReplicatedStorage:WaitForChild("packages")
local Net = require(packages.Net)
local Trove = require(packages.Trove)
local localPlayer = Players.LocalPlayer
local remoteEvent = Net:RemoteEvent("SalesBoothService/Claim", -1)
local remoteEvent2 = Net:RemoteEvent("SalesBoothService/UpdateInfo")
local remoteEvent3 = Net:RemoteEvent("SalesBoothService/PurchaseItem")
local remoteFunction = Net:RemoteFunction("SalesBoothService/RequestSalesBoothInfo")
local modules = ReplicatedStorage:WaitForChild("shared").modules
local SalesBooth = require(modules.SalesBooth)
require(modules.RodSkins)
local assets = require(ReplicatedStorage.shared.utils.assets)
local NumberUtils = require(ReplicatedStorage.shared.utils.NumberUtils)
local halos = require(ReplicatedStorage.shared.modules.library.halos)
local items = require(ReplicatedStorage.shared.modules.library.items)
local companions = require(ReplicatedStorage.shared.modules.library.companions)
local skins = require(ReplicatedStorage.shared.modules.library.companions.skins)
local legacyControllers = ReplicatedStorage:WaitForChild("client").legacyControllers
local RAPController = require(legacyControllers.RAPController)
local ShowroomController = require(ReplicatedStorage.client.legacyControllers.Shop.ShowroomController)
local salesBoothSkins = ReplicatedStorage:WaitForChild("resources").models.SalesBoothSkins
local confirmPrompt = ReplicatedStorage:WaitForChild("events"):WaitForChild("ConfirmPrompt")
local _ = script.CharacterTemplate
local SalesBoothClient = {}
SalesBoothClient.__index = SalesBoothClient

local function groundModel(instance, worldCFrame: CFrame, p)
	local v = worldCFrame.Position + createVector(0, 10, 0)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude

	if p then
		raycastParams.FilterDescendantsInstances = { p, instance }
	else
		raycastParams.FilterDescendantsInstances = { instance }
	end

	local raycastResult = workspace:Raycast(v, createVector(0, -30, 0), raycastParams)

	if not raycastResult then
		return
	end

	local _, v2 = instance:GetBoundingBox()
	instance:PivotTo(CFrame.new(raycastResult.Position + Vector3.new(0, v2.Y / 2, 0)) * (worldCFrame - worldCFrame.Position))
end

local function getModelWorldBottomY(folder)
	local v = nil

	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") or part.Transparency >= 1 then
			continue
		end

		local cFrame = part.CFrame
		local size = part.Size
		local v2 = 0.5 * (math.abs(cFrame.RightVector.Y) * size.X + math.abs(cFrame.UpVector.Y) * size.Y + math.abs(cFrame.LookVector.Y) * size.Z)
		local v3 = cFrame.Position.Y - v2

		if not v or v3 < v then
			v = v3
		end
	end

	return v
end

local function groundCompanionModel(instance, cframe: CFrame)
	local v = cframe.Position + createVector(0, 3, 0)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { instance }
	local raycastResult = workspace:Raycast(v, createVector(0, -8, 0), raycastParams)
	local Y

	if raycastResult then
		Y = raycastResult.Position.Y
	else
		Y = cframe.Position.Y
	end

	local modelWorldBottomY = getModelWorldBottomY(instance)

	if not modelWorldBottomY then
		return
	end

	local vector2 = Vector3.new(0, Y - modelWorldBottomY, 0)
	local rootPart = instance:FindFirstChild("RootPart")

	if rootPart then
		rootPart.CFrame += vector2
	else
		instance:PivotTo(instance:GetPivot() + vector2)
	end
end

local function playIdleAnimation(instance, index: string)
	local skin = skins.Skins[index]
	local v = skin and companions.Companions[skin.TargetCompanion]

	if not v then
		return
	end

	local animationController = instance:FindFirstChildOfClass("AnimationController")
	local animations = instance:FindFirstChild("Animations")

	if not (animationController and animations) then
		return
	end

	local v2 = animationController:FindFirstChildOfClass("Animator")

	if not v2 then
		v2 = Instance.new("Animator")
		v2.Parent = animationController
	end

	local animation = animations:FindFirstChild(v.StateAnimations and v.StateAnimations.Idle or animations:FindFirstChild("SitIdle") and "SitIdle" or "Idle")

	if not (animation and animation:IsA("Animation")) then
		return
	end

	local track = v2:LoadAnimation(animation)
	track.Looped = true
	track:Play(0)
end

local function GetModel(p: string, childName: string)
	local clone = nil

	if p == "RodSkins" then
		clone = assets.getAsync("skin", childName):WaitForChild("Skin"):Clone()
	elseif p == "Bobber" then
		clone = assets.getAsync("bobber", childName):Clone()
	elseif p == "Boat" then
		clone = assets.getAsync("vessel", childName, 300):Clone()

		for _, descendant in clone:GetDescendants() do
			if descendant:IsA("LuaSourceContainer") and not descendant:HasTag("StreamingSafe") or descendant:IsA("Seat") or descendant:IsA("VehicleSeat") then
				descendant:Destroy()
			elseif descendant:IsA("BasePart") and descendant ~= clone.PrimaryPart and descendant.Name ~= "RootPart" and (descendant.Transparency >= 1 or descendant:IsA("TrussPart")) then
				descendant:Destroy()
			end
		end

		local extentsSize = clone:GetExtentsSize()
		local scale = clone:GetScale()
		local v = math.min(
			4.585127830505371 / extentsSize.X,
			1.6781480312347412 / extentsSize.Y,
			3.7618613243103027 / extentsSize.Z,
			1
		)

		if v < 1 then
			clone:ScaleTo(v * scale)
		end
	elseif p == "Halo" then
		local halo = halos[childName]
		local v

		if halo then
			v = halo.ModelName or childName
		else
			v = childName
		end

		clone = assets.getAsync("halo", v):Clone()
	elseif p == "Lantern" then
		clone = assets.getAsync("lantern", childName):Clone()
	elseif p == "BoothSkin" then
		local child = ReplicatedStorage.resources.models.SalesBoothSkins:FindFirstChild(childName)

		if child then
			clone = child:Clone()
			local extentsSize = clone:GetExtentsSize()
			local scale = clone:GetScale()
			local v = math.min(5 / extentsSize.X, 5 / extentsSize.Y, 5 / extentsSize.Z, 1)

			if v < 1 then
				clone:ScaleTo(v * scale)
			end

			for _, part in clone:GetDescendants() do
				if not part:IsA("BasePart") then
					continue
				end

				part.Anchored = true
				part.CanCollide = false
			end
		end
	elseif p == "Glider" then
		local async = assets.getAsync("item", childName)

		if not async then
			return clone
		end

		local child = async:FindFirstChild(childName)
		local details

		if child then
			if childName == "Glider" then
				details = child:FindFirstChild("Details")
			else
				details = child:FindFirstChild("GliderModel")
			end
		end

		if not details then
			return clone
		end

		clone = details:Clone()
		local boundingBox, v = clone:GetBoundingBox()
		local part = Instance.new("Part")
		part.Name = "Root"
		part.Size = createVector(1, 1, 1)
		part.Transparency = 1
		part.CFrame = boundingBox
		part.Anchored = true
		part.CanCollide = false
		part.Parent = clone
		clone.PrimaryPart = part
		local scale = clone:GetScale()
		local v2 = math.min(8 / v.X, 8 / v.Y, 8 / v.Z, 1)

		if v2 < 1 then
			clone:ScaleTo(v2 * scale)
		end

		for _, part2 in clone:GetDescendants() do
			if not (part2:IsA("BasePart") and part2 ~= part) then
				continue
			end

			part2.Anchored = true
			part2.CanCollide = false
		end

		return clone
	elseif p == "CompanionSkin" then
		local skin = skins.Skins[childName]
		local v = skin and companions.Companions[skin.TargetCompanion]

		if v then
			local async = assets.getAsync("companion", (`{v.Model}/{childName}`))

			if async then
				clone = async:Clone()
				local rootPart = clone:FindFirstChild("RootPart")

				if rootPart then
					clone.PrimaryPart = rootPart
				end

				local extentsSize = clone:GetExtentsSize()
				local scale = clone:GetScale()
				local v2 = math.min(6 / extentsSize.X, 6 / extentsSize.Y, 6 / extentsSize.Z, 1)

				if v2 < 1 then
					clone:ScaleTo(v2 * scale)
				end
			end
		end
	end

	if p == "BoothSkin" then
		return clone
	end

	if not clone then
		return
	end

	clone:SetAttribute("Index", childName)

	for _, part in clone:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.Massless = true
		part.Anchored = false
	end

	clone.PrimaryPart.Anchored = true
	return clone
end

-- equivalent calls inferred from this helper; original call sites unknown
local function OnProximityPromptTriggered(object)
	if object.Owner == localPlayer then
		object.OpenUICallback("EditBooth")
	else
		remoteEvent:FireServer(object:GetUID())
	end
end

function SalesBoothClient:UpdateCharacter()
	if not self:GetOwner() then
		return
	end

	local owner = self:GetOwner()
	local character = self.Instance:FindFirstChild("Character")

	if character then
		if character:GetAttribute("Name") == owner.Name then
			return
		end

		self.OwnerCollector:Remove(character)
		character:Destroy()
	end

	local owner2 = self:GetOwner()
	local clone = script.CharacterTemplate:Clone()
	clone.Name = "Character"
	clone.Parent = self.Instance
	clone:PivotTo(self.Instance.Skin.CharacterPosition.CFrame)
	clone:SetAttribute("Name", owner2.Name)

	if owner2.UserId > 0 then
		clone.Humanoid:ApplyDescription(Players:GetHumanoidDescriptionFromUserId(owner2.UserId))
	end

	self.OwnerCollector:Add(clone)
end

function SalesBoothClient:UpdateFavoriteItems()
	if not self:GetOwner() then
		return
	end

	local v = {}

	for i = 1, SalesBooth.Types.RodSkins.DisplayLimit do
		local v2 = nil

		for i2 = 1, #self.ItemList do
			local v3 = self.ItemList[i2]

			if v3.Type ~= "RodSkins" or v3.Favorite ~= true or table.find(v, i2) then
				continue
			end

			table.insert(v, i2)
			v2 = v3
			break
		end

		local child = self.Instance.FavoritesItems:FindFirstChild((`RodSkins{i}`))

		if v2 then
			if child then
				if child:GetAttribute("Index") == v2.Index then
					continue
				end

				self.BoothCollector:Remove(child)
				child:Destroy()
			end

			local model = GetModel("RodSkins", v2.Index)
			model.Name = `RodSkins{i}`

			if model then
				model.handle.CFrame = self.Instance.Skin.SkinRoot["RodSkins" .. i].WorldCFrame
				model.Parent = self.Instance.FavoritesItems
				self.BoothCollector:Add(model)
			end
		elseif child then
			self.BoothCollector:Remove(child)
			child:Destroy()
		end
	end

	for i = 1, SalesBooth.Types.Bobber.DisplayLimit do
		local v2 = nil

		for i2 = 1, #self.ItemList do
			local v3 = self.ItemList[i2]

			if v3.Type ~= "Bobber" or v3.Favorite ~= true or table.find(v, i2) then
				continue
			end

			table.insert(v, i2)
			v2 = v3
			break
		end

		local child = self.Instance.FavoritesItems:FindFirstChild((`Bobber{i}`))

		if v2 then
			if child then
				if child:GetAttribute("Index") == v2.Index then
					continue
				end

				self.BoothCollector:Remove(child)
				child:Destroy()
			end

			local model = GetModel("Bobber", v2.Index)
			model.Name = `Bobber{i}`

			if model then
				model:PivotTo(self.Instance.Skin.SkinRoot["Bobber" .. i].WorldCFrame)
				model.Parent = self.Instance.FavoritesItems
				self.BoothCollector:Add(model)
			end
		elseif child then
			self.BoothCollector:Remove(child)
			child:Destroy()
		end
	end

	for i = 1, SalesBooth.Types.Boat.DisplayLimit do
		local v2 = nil

		for i2 = 1, #self.ItemList do
			local v3 = self.ItemList[i2]

			if v3.Type ~= "Boat" or v3.Favorite ~= true or table.find(v, i2) then
				continue
			end

			table.insert(v, i2)
			v2 = v3
			break
		end

		local child = self.Instance.FavoritesItems:FindFirstChild((`Boat{i}`))

		if v2 then
			if child then
				if child:GetAttribute("Index") == v2.Index then
					continue
				end

				self.BoothCollector:Remove(child)
				child:Destroy()
			end

			local model = GetModel("Boat", v2.Index)
			model.Name = `Boat{i}`

			if model then
				model:PivotTo(self.Instance.Skin.SkinRoot["Boat" .. i].WorldCFrame)
				model.Parent = self.Instance.FavoritesItems
				self.BoothCollector:Add(model)
			end
		elseif child then
			self.BoothCollector:Remove(child)
			child:Destroy()
		end
	end

	for i = 1, SalesBooth.Types.Halo.DisplayLimit do
		local v2 = nil

		for i2 = 1, #self.ItemList do
			local v3 = self.ItemList[i2]

			if v3.Type ~= "Halo" or v3.Favorite ~= true or table.find(v, i2) then
				continue
			end

			table.insert(v, i2)
			v2 = v3
			break
		end

		local child = self.Instance.FavoritesItems:FindFirstChild((`Halo{i}`))

		if v2 then
			if child then
				if child:GetAttribute("Index") == v2.Index then
					continue
				end

				self.BoothCollector:Remove(child)
				child:Destroy()
			end

			local model = GetModel("Halo", v2.Index)
			model.Name = `Halo{i}`

			if model then
				model:PivotTo(self.Instance.Skin.SkinRoot["Halo" .. i].WorldCFrame)
				model.Parent = self.Instance.FavoritesItems
				self.BoothCollector:Add(model)
			end
		elseif child then
			self.BoothCollector:Remove(child)
			child:Destroy()
		end
	end

	for i = 1, SalesBooth.Types.Lantern.DisplayLimit do
		local v2 = nil

		for i2 = 1, #self.ItemList do
			local v3 = self.ItemList[i2]

			if v3.Type ~= "Lantern" or v3.Favorite ~= true or table.find(v, i2) then
				continue
			end

			table.insert(v, i2)
			v2 = v3
			break
		end

		local child = self.Instance.FavoritesItems:FindFirstChild((`Lantern{i}`))

		if v2 then
			if child then
				if child:GetAttribute("Index") == v2.Index then
					continue
				end

				self.BoothCollector:Remove(child)
				child:Destroy()
			end

			local model = GetModel("Lantern", v2.Index)
			model.Name = `Lantern{i}`

			if model then
				local worldCFrame = self.Instance.Skin.SkinRoot["Lantern" .. i].WorldCFrame
				model:PivotTo(worldCFrame)
				groundModel(model, worldCFrame)
				model.Parent = self.Instance.FavoritesItems
				self.BoothCollector:Add(model)
			end
		elseif child then
			self.BoothCollector:Remove(child)
			child:Destroy()
		end
	end

	for i = 1, SalesBooth.Types.BoothSkin.DisplayLimit do
		local v2 = nil

		for i2 = 1, #self.ItemList do
			local v3 = self.ItemList[i2]

			if v3.Type ~= "BoothSkin" or v3.Favorite ~= true or table.find(v, i2) then
				continue
			end

			table.insert(v, i2)
			v2 = v3
			break
		end

		local child = self.Instance.FavoritesItems:FindFirstChild((`BoothSkin{i}`))

		if v2 then
			if child then
				if child:GetAttribute("Index") == v2.Index then
					continue
				end

				self.BoothCollector:Remove(child)
				child:Destroy()
			end

			local model = GetModel("BoothSkin", v2.Index)
			model.Name = `BoothSkin{i}`

			if model then
				local worldCFrame = self.Instance.Skin.SkinRoot["BoothSkin" .. i].WorldCFrame
				local boundingBox, v4 = model:GetBoundingBox()
				local v5 = model:GetPivot().Position.Y - (boundingBox.Position.Y - v4.Y / 2)
				model:PivotTo(CFrame.new(worldCFrame.Position + Vector3.new(0, v5, 0)) * (worldCFrame - worldCFrame.Position))
				model.Parent = self.Instance.FavoritesItems
				self.BoothCollector:Add(model)
			end
		elseif child then
			self.BoothCollector:Remove(child)
			child:Destroy()
		end
	end

	for i = 1, SalesBooth.Types.Glider.DisplayLimit do
		local v2 = nil

		for i2 = 1, #self.ItemList do
			local v3 = self.ItemList[i2]

			if v3.Type ~= "Glider" or v3.Favorite ~= true or table.find(v, i2) then
				continue
			end

			table.insert(v, i2)
			v2 = v3
			break
		end

		local child = self.Instance.FavoritesItems:FindFirstChild((`Glider{i}`))

		if v2 then
			if child then
				if child:GetAttribute("Index") == v2.Index then
					continue
				end

				self.BoothCollector:Remove(child)
				child:Destroy()
			end

			local gliderName = v2.GliderName or v2.Index
			local model = GetModel("Glider", gliderName)

			if model then
				model.Name = `Glider{i}`
				groundModel(model, self.Instance.Skin.SkinRoot["Glider" .. i].WorldCFrame)
				model.Parent = self.Instance.FavoritesItems
				self.BoothCollector:Add(model)
			end
		elseif child then
			self.BoothCollector:Remove(child)
			child:Destroy()
		end
	end

	for i = 1, SalesBooth.Types.CompanionSkin.DisplayLimit do
		local v2 = nil

		for i2 = 1, #self.ItemList do
			local v3 = self.ItemList[i2]

			if v3.Type ~= "CompanionSkin" or v3.Favorite ~= true or table.find(v, i2) then
				continue
			end

			table.insert(v, i2)
			v2 = v3
			break
		end

		local child = self.Instance.FavoritesItems:FindFirstChild((`CompanionSkin{i}`))

		if v2 then
			if child then
				if child:GetAttribute("Index") == v2.Index then
					continue
				end

				self.BoothCollector:Remove(child)
				child:Destroy()
			end

			local child2 = self.Instance.Skin.SkinRoot:FindFirstChild((`CompanionSkin{i}`))

			if child2 then
				local model = GetModel("CompanionSkin", v2.Index)

				if model then
					model.Name = `CompanionSkin{i}`
					local worldCFrame = child2.WorldCFrame
					local rootPart = model:FindFirstChild("RootPart")
					model.Parent = self.Instance.FavoritesItems

					if rootPart then
						rootPart.CFrame = worldCFrame
					else
						model:PivotTo(worldCFrame)
					end

					playIdleAnimation(model, v2.Index)
					groundCompanionModel(model, worldCFrame)
					local model2 = model
					task.defer(function()
						if model2.Parent then
							groundCompanionModel(model2, worldCFrame)
						end
					end)
					self.BoothCollector:Add(model)
				end
			end
		elseif child then
			self.BoothCollector:Remove(child)
			child:Destroy()
		end
	end
end

function SalesBoothClient:UpdateProximityPrompt()
	local owner = self:GetOwner()
	self.ProximityPrompt.ObjectText = "Sales Booth"

	if owner then
		if owner ~= localPlayer then
			self.ProximityPrompt.Enabled = false
			return
		end

		self.ProximityPrompt.ActionText = "Edit Booth"
	else
		if localPlayer:GetAttribute("HasSalesBooth") then
			self.ProximityPrompt.Enabled = false
			return
		end

		self.ProximityPrompt.ActionText = "Claim"
	end

	self.ProximityPrompt.Enabled = true
end

function SalesBoothClient:UpdateBoothSkin()
	if self:GetOwner() then
		local skin = self.Instance:FindFirstChild("Skin")

		if skin then
			if skin:GetAttribute("Skin") == self.LastSkin then
				return
			end

			self.OwnerCollector:Remove(skin)
			skin:Destroy()
		end

		local clone = salesBoothSkins:FindFirstChild(self.LastSkin):Clone()
		clone:SetAttribute("Skin", self.LastSkin)
		clone.Name = "Skin"
		clone.Parent = self.Instance
		clone:PivotTo(self.Instance.PrimaryPart.CFrame)
		self.OwnerCollector:Add(clone)
	else
		local skin = self.Instance:FindFirstChild("Skin")

		if localPlayer:GetAttribute("HasSalesBooth") == true then
			if skin then
				self.OwnerCollector:Remove(skin)
				skin:Destroy()
			end
		else
			if skin and skin:GetAttribute("ToClaim") ~= true then
				self.OwnerCollector:Remove(skin)
				skin:Destroy()
				skin = nil
			end

			if not skin then
				local clone = salesBoothSkins:FindFirstChild("Default"):Clone()
				clone:SetAttribute("ToClaim", true)
				clone.Name = "Skin"
				clone.Parent = self.Instance
				clone:PivotTo(self.Instance.PrimaryPart.CFrame)

				for _, part in clone:FindFirstChild("Decorations"):GetDescendants() do
					if part:IsA("BasePart") then
						part.Transparency = 0.8
					end
				end

				self.OwnerCollector:Add(clone)
			end
		end
	end
end

local v = false
local v2 = {
	RodSkins = "RodSkin",
	Glider = "Item"
}

function SalesBoothClient:GodIHateThisModule(_, p: number)
	local owner = self:GetOwner()

	if not owner then
		return
	end

	local items2 = table.create(#self.ItemList)

	for k, v4 in self.ItemList do
		local v5 = SalesBooth.Types[v4.Type].Data[v4.GliderName or v4.Index]

		if not (v5 and v5.DisplayText or v4.GliderName) then
			local _ = v4.Index
		end

		local icon = v5.Icon or ""

		if v4.Type == "Glider" then
			icon = items.Items[v4.GliderName or v4.Index].Icon or ""
		end

		table.insert(items2, {
			Index = v4.Index,
			Name = v4.GliderName or v4.Index,
			Icon = icon,
			Price = v4.Value,
			Order = k,
			Type = v2[v4.Type] or v4.Type
		})
	end

	ShowroomController:ShowBooth({
		Owner = owner,
		UID = self:GetUID(),
		Items = items2
	}, p)
end

function SalesBoothClient:UpdateItemList()
	self.BoothCollector:Clean()

	if not (self:GetOwner() and self.ItemList ~= nil) then
		return
	end

	local clone = script.ItemSurface:Clone()
	clone.Name = `SalesBooth.{self:GetUID()}`
	clone.Parent = localPlayer.PlayerGui
	clone.Adornee = self.Instance.Skin.ItemPanel
	self.BoothCollector:Add(clone)

	for i = 1, #self.ItemList do
		local v3 = self.ItemList[i]
		local v4 = SalesBooth.Types[v3.Type].Data[v3.GliderName or v3.Index]
		local displayText = v4 and v4.DisplayText or v3.GliderName or v3.Index
		local icon = v4 and v4.Icon or ""

		if v3.Type == "Glider" then
			icon = items.Items[v3.GliderName or v3.Index].Icon or ""
		end

		local clone2 = script.ItemTemplate:Clone()
		clone2.Name = i
		clone2.LayoutOrder = i - (v3.Favorite == true and 500 or 0)
		clone2.Visible = true

		if v3.Value == -1 then
			clone2.Buy.Label.Text = "<b>Send Offer</b>"
		else
			clone2.Buy.Label.Text = `<b>S$</b> <font transparency=".25">{NumberUtils:ToString(v3.Value, 2)}</font>`
		end

		clone2.Viewport.Header.Text = displayText
		clone2.Viewport.Icon.Image = icon
		clone2.Parent = clone.ScrollingFrame
		self.BoothCollector:Add(clone2)
		self.BoothCollector:Connect(clone2.Buy.Activated, function()
			if self:GetOwner() == localPlayer or v then
				return
			end

			if v3.Value ~= -1 then
				v = true
				local rAPAsync = RAPController:GetRAPAsync(v3.Type, v3.GliderName or v3.Index)
				local v7 = rAPAsync and `\n<font color="#00FF00">Sales Average: {NumberUtils:ToString(rAPAsync, 2)} S$</font>` or ""
				local v8 = confirmPrompt:Invoke(
					"Confirm Purchase",
					`Are you sure you want to purchase {displayText} for {NumberUtils:ToString(v3.Value, 2)} S$?{v7}`,
					"Cannot be undone!"
				)
				v = false

				if not v8 then
					return
				end
			end

			remoteEvent3:FireServer(self:GetUID(), v3.Type, v3.Index, v3.Value)
		end)
		local v8 = i
		self.BoothCollector:Add(clone2.Viewport.Activated:Connect(function()
			self:GodIHateThisModule(clone2, v8)
		end))
	end
end

function SalesBoothClient:UpdateInfo(data)
	self.ItemList = data.ItemList
	self.LastSkin = data.Skin

	if self.Owner ~= data.Owner then
		self.OwnerCollector:Clean()
		self.Owner = data.Owner
	end

	self:UpdateBoothSkin()
	self:UpdateCharacter()
	self:UpdateItemList()
	self:UpdateProximityPrompt()
	self:UpdateFavoriteItems()
end

function SalesBoothClient:GetUID()
	return self.UID
end

function SalesBoothClient:GetOwner()
	return self.Owner
end

function SalesBoothClient.new(instance, openUICallback)
	local object = setmetatable({}, SalesBoothClient)
	object.UID = instance.Name
	object.Instance = instance
	object.Collector = Trove.new()
	object.OwnerCollector = Trove.new()
	object.Collector:Add(object.OwnerCollector, "Destroy")
	object.OpenUICallback = openUICallback
	object.ProximityPrompt = Instance.new("ProximityPrompt", object.Instance.Root)
	object.ProximityPrompt.MaxActivationDistance = 20
	object.ProximityPrompt.Style = Enum.ProximityPromptStyle.Custom
	object.ProximityPrompt.RequiresLineOfSight = false
	object.ProximityPrompt.HoldDuration = 0.5
	object.Collector:Add(object.ProximityPrompt)
	object.BoothCollector = Trove.new()
	object.Collector:Add(object.BoothCollector, "Destroy")
	object.Collector:Add(object.ProximityPrompt.Triggered:Connect(function()
		OnProximityPromptTriggered(object) -- equivalent call inferred; original call site unknown
	end))
	object:UpdateInfo(remoteFunction:InvokeServer(object:GetUID()))
	object.Collector:Add(remoteEvent2.OnClientEvent:Connect(function(p: string, ...)
		if p ~= object:GetUID() then
			return
		end

		object:UpdateInfo(...)
	end))
	object.Collector:Add(localPlayer:GetAttributeChangedSignal("HasSalesBooth"):Connect(function()
		object:UpdateProximityPrompt()
		object:UpdateBoothSkin()
	end))
	return object
end

function SalesBoothClient:Destroy()
	self.Collector:Destroy()
end

return SalesBoothClient