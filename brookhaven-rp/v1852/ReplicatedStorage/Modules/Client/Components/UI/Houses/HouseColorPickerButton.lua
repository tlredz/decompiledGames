local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
require(ReplicatedStorage.Modules.Shared.Housing.LotUtil)
local UIColorPickerLimited = require(ReplicatedStorage.Modules.Client.Components.UI.UIColorPickerLimited)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local v = Component.new({
	Tag = "HouseColorPickerButton"
})
local HousePanel = require(ReplicatedStorage.Modules.Client.Components.UI.Houses.HousePanel)
local HouseTelemetry = require(ReplicatedStorage.Modules.Client.Components.UI.Houses.HouseTelemetry)
local UIColorPicker = require(ReplicatedStorage.Modules.Client.Components.UI.UIColorPicker)
require(ReplicatedStorage.Modules.Client.Telemetry.TelemetryController)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local PlayerBagUtil = require(ReplicatedStorage.Modules.Shared.PlayerData.PlayerBagUtil)
local LotUtil = require(ReplicatedStorage.Modules.Shared.Housing.LotUtil)

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
	local game8Settings = playerGui:WaitForChild("Player8Handler"):WaitForChild("Game8Settings")
	local module = require(game8Settings)
	local pickingHouseColor = module.PickingHouseColor
	local playersHouse = module.PlayersHouse
	local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
	local colorPickerLimited = playerGui:WaitForChild("MainGUIHandler"):WaitForChild("ColorPickerLimited")
	local component = ComponentUtil.GetComponentFromInstance(colorPickerLimited, UIColorPickerLimited)

	if not ComponentUtil.FindAndWaitForAncestorComponent(self.Instance, "HousePanel", HousePanel) then
		return
	end

	self.colorPickerPanel = self.Instance.Panel.Value

	if self.colorPickerPanel then
		self.colorPickerPanel:AddTag("Panel")
	end

	local playerBagInstance = PlayerBagUtil.GetPlayerBagInstance(Players.LocalPlayer, "HouseNumber")
	local value = playerBagInstance and playerBagInstance.Value
	local folder

	if value ~= nil then
		folder = LotUtil.GetProperty(value)
	end

	local v2 = folder:FindFirstChild("MainHouseScript") ~= nil

	if folder ~= nil then
		if folder:HasTag("PropertyColorable") or folder:HasTag("PropertyMansionColorable") then
			v2 = true
		else
			for _, descendant in folder:GetDescendants() do
				if not (descendant:HasTag("PropertyColorable") or descendant:HasTag("PropertyMansionColorable") or descendant:HasTag("PropertySetColor")) then
					continue
				end

				v2 = true
				break
			end
		end
	end

	if not v2 then
		self.Instance.Visible = false
		return
	end

	local instance = self.Instance
	self._Janitor:Add(instance.MouseButton1Click:Connect(function()
		if not self.colorPickerPanel then
			return
		end

		HouseTelemetry.Click(self.Tag)
		local colorLimits = nil
		local playerOwnedLotNumber = LotUtil.GetPlayerOwnedLotNumber(Players.LocalPlayer)

		if playerOwnedLotNumber ~= nil then
			local property = LotUtil.GetProperty(playerOwnedLotNumber)

			if property ~= nil then
				local model = property:FindFirstChild("Model")
				local disableColorChange

				if model ~= nil then
					disableColorChange = model:FindFirstChild("DisableColorChange")
				end

				if disableColorChange == nil or not disableColorChange:IsA("BoolValue") or disableColorChange.Value ~= true then
					if property:GetAttribute("HasColorLimit") == true then
						colorLimits = property:WaitForChild("ColorLimits")
					end
				else
					NotificationController.NotifyCenter("You cannot change the color of this house")
					return
				end
			end
		end

		if colorLimits == nil then
			if PanelController.IsOpen("MainGUIHandler", "HouseColorPicker") then
				PanelController.Close("MainGUIHandler", "HouseColorPicker")
				return
			end

			PanelController.ToggleGroup("HousePanels", false)
			PanelController.Open("MainGUIHandler", "HouseColorPicker")
		else
			if PanelController.IsOpen("MainGUIHandler", "ColorPickerLimited") then
				PanelController.Close("MainGUIHandler", "ColorPickerLimited")
				return
			end

			self.dbHouseColor = false
			component:Show("Select a color", colorLimits, function(color: Color3)
				if self.dbHouseColor then
					return
				end

				self.dbHouseColor = true
				task.delay(0.35, function()
					self.dbHouseColor = false
				end)
				playersHouse:FireServer(pickingHouseColor, color)
			end)
		end
	end))

	if not self.colorPickerPanel then
		return
	end

	self.colorPickerComponent = ComponentUtil.FindAndWaitForAncestorComponent(
		self.colorPickerPanel,
		"UIColorPicker",
		UIColorPicker
	)

	if not self.colorPickerComponent then
		return
	end

	self.colorPickerComponent.OnColorConfirmed:Connect(function(color: Color3, flag: boolean)
		Remotes.fireServer("Property:SetColor", color, flag)
		playersHouse:FireServer(pickingHouseColor, color)
	end)
	task.spawn(function()
		local value2 = PlayerBagUtil.GetPlayerBagInstance(Players.LocalPlayer, "HouseNumber").Value
		local folder2 = LotUtil.GetProperty(value2)

		if folder2 == nil then
			return
		end

		local defaultColor = folder2:FindFirstChild("DefaultColor", true)

		if defaultColor ~= nil and defaultColor:IsA("Color3Value") then
			self.colorPickerComponent.Instance:SetAttribute("DefaultColor", defaultColor.Value)
			return
		end

		local v3 = {}

		local function addColor(color: Color3)
			v3[color] = (v3[color] or 0) + 1
		end

		local v4 = nil
		local v5

		if folder2:HasTag("PropertyMansionColorable") then
			v5 = folder2
		end

		for _, model in folder2:GetChildren() do
			if not (model:IsA("Model") and model:HasTag("PropertyColorable")) then
				continue
			end

			v4 = model
			break
		end

		if v4 == nil then
			for _, model in folder2:GetDescendants() do
				if model:IsA("Model") and model:HasTag("PropertyColorable") then
					v4 = model
					break
				elseif v5 == nil and model:HasTag("PropertyMansionColorable") then
					v5 = model
				end
			end
		end

		if v4 == nil then
			if v5 == nil then
				for _, part in folder2:GetChildren() do
					if not (part.Name == "Color" and (part:IsA("BasePart") or part:IsA("MeshPart"))) then
						continue
					end

					local color = part.Color
					v3[color] = (v3[color] or 0) + 1
				end

				if next(v3) == nil then
					for _, part in folder2:GetDescendants() do
						if not (part.Name == "Color" and (part:IsA("BasePart") or part:IsA("MeshPart"))) then
							continue
						end

						local color = part.Color
						v3[color] = (v3[color] or 0) + 1
					end
				end
			else
				local _001_FloorColor = v5:FindFirstChild("001_FloorColor", true)

				if _001_FloorColor ~= nil then
					for _, texture in _001_FloorColor:GetDescendants() do
						if not texture:IsA("Texture") then
							continue
						end

						local color3 = texture.Color3
						v3[color3] = (v3[color3] or 0) + 1
					end
				end

				local _001_MatColor = v5:FindFirstChild("001_MatColor", true)

				if _001_MatColor ~= nil then
					for _, part in _001_MatColor:GetChildren() do
						if not part:IsA("BasePart") then
							continue
						end

						local color = part.Color
						v3[color] = (v3[color] or 0) + 1
					end
				end
			end
		else
			for _, part in v4:GetChildren() do
				if not (part:IsA("BasePart") or part:IsA("MeshPart")) then
					continue
				end

				local color = part.Color
				v3[color] = (v3[color] or 0) + 1
			end
		end

		if next(v3) == nil then
			for _, part in folder2:GetDescendants() do
				if not (part:IsA("BasePart") and part:HasTag("PropertySetColor")) then
					continue
				end

				local color = part.Color
				v3[color] = (v3[color] or 0) + 1
			end
		end

		local v7 = 0
		local v8 = nil

		for k, v9 in v3 do
			if not (v7 < v9) then
				continue
			end

			v8 = k
			v7 = v9
		end

		if v8 then
			self.colorPickerComponent.Instance:SetAttribute("DefaultColor", v8)
		end
	end)
end

function v:Stop()
	self._Janitor:Destroy()
end

return v