local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Signal = require(ReplicatedStorage.Packages.Signal)
local RunService = game:GetService("RunService")
local v = Component.new({
	Tag = "LotRoot"
})

function v:Construct()
	self.PropertyBuild = Signal.new()
	self.PropertyBuilt = Signal.new()
	self.PropertyDestroy = Signal.new()
	self.PropertyDestroyed = Signal.new()
	self.claimed = false
end

function v:Start()
	self.ownerValue = self.Instance:WaitForChild("Owner")
	self.ownerObjValue = self.Instance:WaitForChild("OwnerObj")
	self.numberValue = self.Instance:WaitForChild("Number"):WaitForChild("Number")
end

function v:SetHouseSignText(text: string, image: string)
	self.Instance.BuyHouse.A.B.C.Text = text
	self.Instance.BuyHouse.A.B.PlayerPic.Image = image
end

function v:ToggleHouseSignVisible(flag: boolean)
	local v2 = {
		self.Instance.BuyHouse,
		self.Instance.RPName,
		self.Instance.Number,
		self.Instance:FindFirstChild("Hand"),
		self.Instance:FindFirstChild("PlotName"),
		self.Instance:FindFirstChild("Plot Name")
	}

	if flag then
		for _, v3 in v2 do
			v3:AddTag("HouseHideHouseSign")
		end
	else
		for _, v3 in v2 do
			v3:RemoveTag("HouseHideHouseSign")
		end
	end
end

function v:GetId()
	return self.numberValue.Value
end

function v:GetOwner()
	return self.ownerObjValue.Value
end

function v.IsClaimed(p)
	return p.claimed
end

function v:SetYoungRoddoOwner()
	self.claimed = true
	local YoungRoddoUtil = require(ReplicatedStorage.Modules.Shared.LiveOps.YoungRoddoUtil)
	self.ownerValue.Value = "Young Roddo"
	self.Instance.Name = "Young Roddo's House"
	self:SetHouseSignText(
		"Young Roddo",
		"https://www.roblox.com/headshot-thumbnail/image?userId=" .. YoungRoddoUtil.Config.USER_ID .. "&width=420&height=420&format=png"
	)
	self:ToggleHouseSignVisible(true)
	local rPName = self.Instance.RPName.SurfaceGUI.Frame:FindFirstChild("RPName")
	rPName.Text = "SPECIAL EVENT!"
	rPName.Visible = true
	local id = self:GetId()

	for _, stringValue in workspace.WorkspaceCom["001_MapCameras"]:GetDescendants() do
		if not (stringValue:IsA("StringValue") and (stringValue.Value == "House# " .. id or stringValue.Value == "Room# " .. id or stringValue.Value == "Apartment# " .. id)) then
			continue
		end

		local houseOwned = stringValue.Parent:FindFirstChild("HouseOwned")

		if houseOwned ~= nil then
			houseOwned.Value = true
		end
	end

	local type = self.Instance:GetAttribute("Type")
	local ID = self.Instance:GetAttribute("ID")
	local child = workspace.WorkspaceCom["001_MapCameras_Alt"]:FindFirstChild(type)

	if not child then
		print("lotTypeFolder not found")
		return
	end

	local child2 = child:FindFirstChild(ID)

	if not child2 then
		print("lotNewIdFolder not found")
		return
	end

	local houseOwned = child2:FindFirstChild("HouseOwned")
	local rPInfo = child2:FindFirstChild("RPInfo")

	if houseOwned ~= nil and rPInfo ~= nil then
		houseOwned.Value = true
		rPInfo.Value = "SPECIAL EVENT!"
	end

	self.Instance.Hand.Hand.Frame.Visible = false
end

function v:SetOwner(player)
	self.claimed = true
	self.ownerValue.Value = player.Name
	self.ownerObjValue.Value = player
	self.Instance.Name = player.Name .. "House"
	self:SetHouseSignText(
		self:GetOwner().Name,
		"https://www.roblox.com/headshot-thumbnail/image?userId=" .. self:GetOwner().UserId .. "&width=420&height=420&format=png"
	)
	self:ToggleHouseSignVisible(true)
	local character = player.Character

	if character ~= nil then
		local rPName = self.Instance.RPName.SurfaceGUI.Frame:FindFirstChild("RPName")

		if character.Head:FindFirstChild("NameGUI") ~= nil then
			rPName.Text = character.Head.NameGUI.TextBox.Text
			rPName.Visible = true
		end
	end

	local id = self:GetId()

	for _, stringValue in workspace.WorkspaceCom["001_MapCameras"]:GetDescendants() do
		if not (stringValue:IsA("StringValue") and (stringValue.Value == "House# " .. id or stringValue.Value == "Room# " .. id or stringValue.Value == "Apartment# " .. id)) then
			continue
		end

		local houseOwned = stringValue.Parent:FindFirstChild("HouseOwned")
		local rPInfo = stringValue.Parent:FindFirstChild("RPInfo")
		local rPName = player.PlayersBag:FindFirstChild("RPName")

		if not (houseOwned ~= nil and rPInfo ~= nil) then
			continue
		end

		houseOwned.Value = true
		rPInfo.Value = rPName.Value
	end

	local type = self.Instance:GetAttribute("Type")
	local ID = self.Instance:GetAttribute("ID")
	local child = workspace.WorkspaceCom["001_MapCameras_Alt"]:FindFirstChild(type)

	if not child then
		print("lotTypeFolder not found")
		return
	end

	local child2 = child:FindFirstChild(ID)

	if not child2 then
		print("lotNewIdFolder not found")
		return
	end

	local houseOwned = child2:FindFirstChild("HouseOwned")
	local rPInfo = child2:FindFirstChild("RPInfo")

	if houseOwned ~= nil and rPInfo ~= nil then
		houseOwned.Value = true
		rPInfo.Value = player.PlayersBag:FindFirstChild("RPName").Value
	end

	self.Instance.Hand.Hand.Frame.Visible = false
end

function v:Vacate()
	self.claimed = false
	self.ownerValue.Value = ""
	self.ownerObjValue.Value = nil
	self.Instance.Name = "For Sale"
	local rPName = self.Instance.RPName.SurfaceGUI.Frame:FindFirstChild("RPName")
	rPName.Text = "RP Name / Info"
	rPName.Visible = false
	self:SetHouseSignText("Vacant", "rbxassetid://4272010132")
	self:ToggleHouseSignVisible(false)
	local id = self:GetId()

	for _, stringValue in workspace.WorkspaceCom["001_MapCameras"]:GetDescendants() do
		if not (stringValue:IsA("StringValue") and (stringValue.Value == "House# " .. id or stringValue.Value == "Room# " .. id or stringValue.Value == "Apartment# " .. id)) then
			continue
		end

		local houseOwned = stringValue.Parent:FindFirstChild("HouseOwned")
		local rPInfo = stringValue.Parent:FindFirstChild("RPInfo")

		if not (houseOwned ~= nil and rPInfo ~= nil) then
			continue
		end

		houseOwned.Value = false
		rPInfo.Value = ""
	end

	local type = self.Instance:GetAttribute("Type")
	local ID = self.Instance:GetAttribute("ID")
	local child = workspace.WorkspaceCom["001_MapCameras_Alt"]:FindFirstChild(type)

	if not child then
		print("lotTypeFolder not found")
		return
	end

	local child2 = child:FindFirstChild(ID)

	if not child2 then
		print("lotNewIdFolder not found")
		return
	end

	local houseOwned = child2:FindFirstChild("HouseOwned")
	local rPInfo = child2:FindFirstChild("RPInfo")

	if houseOwned ~= nil and rPInfo ~= nil then
		houseOwned.Value = false
		rPInfo.Value = ""
	end

	self.Instance.Hand.Hand.Frame.Visible = true

	if RunService:IsServer() then
		local ServerScriptService = game:GetService("ServerScriptService")
		local PropertyBusinessSign = require(ServerScriptService.Modules.Components.Housing.Objects.PropertyBusinessSign)
		local PropertyDisasters = require(ServerScriptService.Modules.Components.Housing.PropertyDisasters)

		for _, v2 in PropertyBusinessSign:GetAll() do
			if v2.Instance:IsDescendantOf(self.Instance) then
				v2:ResetText()
			end
		end

		for _, v2 in PropertyDisasters:GetAll() do
			if v2.Instance:IsDescendantOf(self.Instance) then
				v2:DisableAll()
			end
		end
	end
end

function v.SetRPName(p, text: string)
	local rPName = p.Instance.RPName.SurfaceGUI.Frame:FindFirstChild("RPName")
	rPName.Text = text
	rPName.Visible = true
end

function v.Stop(data)
	data.PropertyBuild:Destroy()
	data.PropertyBuilt:Destroy()
	data.PropertyDestroy:Destroy()
	data.PropertyDestroyed:Destroy()
end

return v