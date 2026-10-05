local createVector = vector.create
local import = _G.import("romodel")
local import2 = _G.import("event")
local import3 = _G.import("global")
local import4 = _G.import("clientUtil")
local import5 = _G.import("itemModules")
local import6 = _G.import("abilityCollection")
local import7 = _G.import("configuration")
local import8 = _G.import("viewImports")
local basic = import8:get("basic")
local menu = import8:get("menu")
local react = import8:get("react")
local xpBar = import8:get("petBillboard").XpBar
local RunService = game:GetService("RunService")
local localPlayer = game.Players.LocalPlayer
local replicatedAssets = game.ReplicatedStorage.ReplicatedAssets
local PET = import7.PET
local v = nil
local model = import.model(basic.Viewport)

function model.init(p)
	local child = replicatedAssets.Pets:FindFirstChild(p.Id)
	return {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(1.4, 0, 1.4, 0),
		BackgroundTransparency = 1,
		LightColor = Color3.fromRGB(255, 255, 255)
	}, {
		Camera = import.make("Camera", {
			Name = "Camera",
			FieldOfView = 35
		}),
		World = import.make("WorldModel", nil, child and {
			Pet = import.make(child:Clone(), {})
		} or nil)
	}
end

function model:prespawn()
	local instance = self.Instance
	local instance2 = self.Camera.Instance
	local instance3 = self.World and self.World.Pet and self.World.Pet.Instance

	if not instance3 then
		return
	end

	instance.CurrentCamera = instance2
	local primaryPart = instance3.PrimaryPart or instance3:FindFirstChild("HumanoidRootPart", true) or instance3:FindFirstChildWhichIsA(
		"BasePart",
		true
	)

	if not primaryPart then
		return
	end

	instance3.PrimaryPart = primaryPart
	local v2 = CFrame.new() * CFrame.Angles(0, 3.141592653589793, 0)
	instance3:SetPrimaryPartCFrame(v2)
	local _, v3 = instance3:GetBoundingBox()
	local v4 = math.max(v3.X, v3.Y, v3.Z)
	local position = instance3.PrimaryPart.Position
	local zoom = import5:getItem("Pet", self.Id).Zoom or 0
	instance2.CFrame = CFrame.lookAt(
		position + Vector3.new(0, v4 * 0.16, v4 * 1.85 - zoom),
		position + Vector3.new(0, v4 * 0.08, 0)
	)
	local total = 0
	self.Con = RunService.RenderStepped:Connect(function(dt)
		if self.NoSpin then
			return
		end

		total += dt * 2.443460952792061

		if instance3 and instance3.Parent and instance3.PrimaryPart and instance3.PrimaryPart.Parent then
			instance3:SetPrimaryPartCFrame(v2 * CFrame.Angles(0, total, 0) * CFrame.new(0, v4 * 0.05, 0))
		else
			self.Con:Disconnect()
		end
	end)
end

function model:despawn()
	if not self.Con then
		return
	end

	self.Con:Disconnect()
	self.Con = nil
end

local model2 = import.model(menu.Button, react.Reactive)

function model2.init(p)
	return {
		Size = UDim2.new(0.4, 0, 1, 0),
		ZIndex = 2,
		KeyChains = { string.format("Equip.%s", p.ItemType) },
		SavedChanged = function(p2, object)
			local has = object:has("Equip", p.ItemType, p.Id)
			p2.Inner.TextLabel.Text = has and "Unequip" or "Equip"
		end,
		MouseButton1Down = function()
			local has = import3.get("playerSave", localPlayer):has("Equip", p.ItemType, p.Id)
			import2.remoteFire("toggleEquip", p.ItemType, p.Id, has)
		end
	}
end

local model3 = import.model(basic.Corner, basic.Gradient, basic.Stroke)

function model3.init(data)
	local item = import5:getItem(data.ItemType, data.Id)
	local color = replicatedAssets.Ui.Gradients[item.Rarity].Color
	local v2 = {
		Position = UDim2.new(1.05, 0, 0, 0),
		Size = UDim2.new(2, 0, 1.5, 0),
		BackgroundColor3 = Color3.new(0.1, 0.1, 0.1),
		Rotation = 0.1,
		ZIndex = 30,
		Visible = false,
		GradientColor = color,
		RotSpeed = 90,
		Thickness = 3
	}
	local v3 = {
		Name = import.make(basic.TextLabel, {
			Position = UDim2.new(0.05, 0, 0.05, 0),
			Size = UDim2.new(0.9, 0, 0.18, 0),
			Text = item.DisplayName,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 32
		}),
		Rarity = import.make(import.wrap(basic.TextLabel, basic.Gradient), {
			Position = UDim2.new(0.05, 0, 0.24, 0),
			Size = UDim2.new(0.9, 0, 0.14, 0),
			Text = item.Rarity,
			TextXAlignment = Enum.TextXAlignment.Left,
			GradientColor = color,
			ZIndex = 32
		}),
		Description = import.make(basic.TextLabel, {
			BackgroundTransparency = 1,
			Position = UDim2.new(0.05, 0, 0.4, 0),
			Size = UDim2.new(0.9, 0, data.ShowButtons == false and 0.55 or 0.32, 0),
			RichText = true,
			Text = data.ItemType == "Pet" and table.concat(import6:getAbilities(item):filter(function(p)
				return p.PetDescription ~= nil and not p.Silent
			end):map(function(p)
				return string.format("<font color=\"rgb(230,230,60)\">%s:</font> %s", p.DisplayName, p.PetDescription)
			end):array(), item.SameLine and " " or "\n") or item.Description or "",
			TextYAlignment = Enum.TextYAlignment.Top,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 32
		}),
		Buttons = 0
	}
	local buttons

	if data.ShowButtons ~= false then
		buttons = import.make(basic.EmptyList, {
			Position = UDim2.new(0.05, 0, 0.775, 0),
			Size = UDim2.new(0.9, 0, 0.175, 0),
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0.05, 0),
			ZIndex = 32
		}, {
			CloseButton = import.make(menu.Button, {
				Size = UDim2.new(0.4, 0, 1, 0),
				Text = "Close",
				ZIndex = 2,
				MouseButton1Down = function(p)
					p.Parent.Parent.Visible = false
					v = nil
				end
			}),
			EquipButton = import.make(model2, {
				ItemType = data.ItemType,
				Id = data.Id
			})
		}) or nil
	end

	v3.Buttons = buttons
	return v2, v3
end

local model4 = import.model(basic.Viewport, basic.Corner)

function model4.init(_)
	return {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.384, 0),
		Size = UDim2.new(1.17, 0, 1.4, 0),
		BackgroundTransparency = 1,
		LightColor = Color3.fromRGB(255, 255, 255),
		CornerRadius = UDim.new(0.1, 0)
	}, {
		Camera = import.make("Camera", {
			Name = "Camera",
			FieldOfView = 35
		}),
		World = import.make("WorldModel")
	}
end

function model4:prespawn()
	self.Instance.CurrentCamera = self.Camera.Instance

	if self.NoInitialRig then
		return
	end

	self:loadRig(localPlayer.UserId)
end

function model4:loadRig(p)
	if self.Con then
		self.Con:Disconnect()
		self.Con = nil
	end

	if self.Rig then
		self.Rig:Destroy()
		self.Rig = nil
	end

	self.World.Instance:ClearAllChildren()
	local instance = self.World.Instance
	local instance2 = self.Camera.Instance
	self.LoadGen = (self.LoadGen or 0) + 1
	local loadGen = self.LoadGen
	task.spawn(function()
		local success, result = pcall(function()
			local humanoidDescriptionFromUserId = game.Players:GetHumanoidDescriptionFromUserId(p)
			return game.Players:CreateHumanoidModelFromDescription(
				humanoidDescriptionFromUserId,
				Enum.HumanoidRigType.R6
			)
		end)

		if not (success and result) then
			return
		end

		if self.LoadGen ~= loadGen then
			result:Destroy()
			return
		end

		result.Name = "Player"
		result.Parent = instance
		self.Rig = result
		local humanoid = result:FindFirstChild("Humanoid")

		if humanoid then
			humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		end

		local primaryPart = result.PrimaryPart or result:FindFirstChild("HumanoidRootPart", true) or result:FindFirstChildWhichIsA(
			"BasePart",
			true
		)

		if not primaryPart then
			return
		end

		result.PrimaryPart = primaryPart
		local cframe = CFrame.lookAt(createVector(0, 0, 5), createVector(0, 0, 0))
		result:SetPrimaryPartCFrame(cframe)
		instance2.CFrame = CFrame.lookAt(createVector(0, 0, 0), createVector(0, 0, 5)) * CFrame.Angles(
			-0.20943951023931953,
			0,
			0
		) + createVector(0, 1.5, 0)
		local renderSteppedConnection = nil
		renderSteppedConnection = RunService.RenderStepped:Connect(function()
			if result.Parent and result.PrimaryPart then
				result:SetPrimaryPartCFrame(cframe)
			else
				renderSteppedConnection:Disconnect()
			end
		end)
		self.Con = renderSteppedConnection
	end)
end

function model4:despawn()
	if self.Con then
		self.Con:Disconnect()
		self.Con = nil
	end

	if self.Rig then
		self.Rig:Destroy()
		self.Rig = nil
	end
end

local v2 = {
	Pet = model,
	Player = model4
}
local wrapped = import.wrap(basic.Corner, basic.Gradient)
local model5 = import.model(basic.ConstrainedElement, basic.Corner, basic.Gradient)

function model5.init(data)
	local _ = data.CanHover
	local v3 = data.ItemType == "Player" and {
		Rarity = "Mythic"
	} or import5:getItem(data.ItemType, data.Id)
	local v4 = {
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		CornerRadius = UDim.new(0.11249999999999999, 0),
		_Events = {
			MouseEnter = data.Hoverable and function(p)
				p.Popup.Visible = true
			end or nil,
			MouseLeave = data.Hoverable and function(p)
				p.Popup.Visible = false
			end or nil
		}
	}
	local make = import.make
	local v7 = {
		Location = "Center",
		CornerRadius = UDim.new(0.10500000000000001, 0),
		Size = UDim2.new(0.95, 0, 0.96, 0),
		BackgroundColor3 = Color3.new(1, 1, 1),
		GradientColor = replicatedAssets.Ui.Gradients[v3.Rarity].Color,
		RotSpeed = 90
	}
	local make2 = import.make
	local v10 = {
		Location = "Center",
		CornerRadius = UDim.new(0.09, 0),
		Size = UDim2.new(0.9, 0, 0.9, 0),
		BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	}
	local make3 = import.make
	local v13 = {
		Location = "Center",
		CornerRadius = UDim.new(0.07500000000000001, 0),
		Size = UDim2.new(0.95, 0, 0.95, 0),
		BackgroundColor3 = Color3.new(0.2, 0.2, 0.2),
		RotSpeed = 90,
		GradientColor = replicatedAssets.Ui.Gradients[v3.Rarity].Color
	}
	local chanceLabel

	if data.Chance then
		chanceLabel = import.make(basic.TextLabel, {
			Position = UDim2.new(0.07, 0, 0, 0),
			Size = UDim2.new(0.5, 0, 0.4, 0),
			Text = data.Chance * 100 .. "%",
			TextXAlignment = Enum.TextXAlignment.Left,
			StrokeWidth = 2,
			ZIndex = 2
		}) or nil
	end

	local viewport

	if v2[data.ItemType] then
		viewport = import.make(v2[data.ItemType], {
			Id = data.Id,
			NoInitialRig = data.NoInitialRig
		}) or nil
	end

	local xpBar2

	if data.ShowXpBar then
		xpBar2 = import.make(xpBar, {
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(0.5, 0, 0.98, 0),
			Size = UDim2.new(0.9, 0, 0.22, 0),
			PetId = data.Id,
			ZIndex = 3
		}) or nil
	end

	return v4, {
		InnerStroke = make(wrapped, v7, {
			InnerStroke2 = make2(wrapped, v10, {
				Inner = make3(wrapped, v13, {
					ChanceLabel = chanceLabel,
					Viewport = viewport,
					XpBar = xpBar2
				})
			})
		}),
		Popup = data.Hoverable and import.make(model3, {
			Id = data.Id,
			ItemType = data.ItemType,
			ShowButtons = false
		}) or nil
	}
end

local model6 = import.model(model5)

function model6.init(data)
	return {
		Size = UDim2.new(0.35, 0, 0.35, 0),
		ItemType = data.ItemType,
		Id = data.Id,
		Hoverable = true,
		Chance = data.Chance,
		ShowXpBar = data.ShowXpBar
	}
end

function model6.spawn(data)
	local popup = data.Popup

	if not popup then
		return
	end

	local popupSize = data.PopupSize or 1
	local viewportSize = workspace.CurrentCamera.ViewportSize
	local absolutePosition = data.Instance.AbsolutePosition
	local absoluteSize = data.Instance.AbsoluteSize
	local vector2 = Vector2.new(
		2 * popupSize * popup.Parent.Instance.AbsoluteSize.X,
		1.5 * popupSize * popup.Parent.Instance.AbsoluteSize.Y
	)
	local v3 = -0.05
	local v4 = 0
	local v5, v6

	if absolutePosition.X + absoluteSize.X + vector2.X > viewportSize.X then
		v5 = 1
		v6 = -0.05
	else
		v5 = 0
		v6 = 1.05
	end

	if absolutePosition.Y + absoluteSize.Y + vector2.Y > viewportSize.Y then
		v4 = 1
		v3 = 1.05
	end

	popup.AnchorPoint = Vector2.new(v5, v4)
	popup.Position = UDim2.new(v6, 0, v3, 0)
end

local model7 = import.model(basic.ImageButton, react.Reactive)

function model7.init(data)
	return {
		MouseButton1Down = function(p)
			if v and v ~= p then
				v.Popup.Visible = false
			end

			v = p
			p.RewardFrame.Popup.Visible = false
			p.Popup.Visible = true
			p.Popup.Size = UDim2.new(0, 0, 0, 0)
			p.Popup:tween(TweenInfo.new(0.4, Enum.EasingStyle.Back), {
				Size = UDim2.new(2, 0, 1.5, 0)
			})
			import4.sound("Pop1")
		end,
		KeyChains = { string.format("Equip.%s", data.ItemType) },
		SavedChanged = function(object, object2)
			local has = object2:has("Equip", data.ItemType, data.Id)
			object:ClearReactiveChildren()
			return nil, {
				EquippedLabel = import.make(basic.TextLabel, {
					Position = UDim2.new(0.12, 0, 0.09, 0),
					Size = UDim2.new(1, 0, 0.125, 0),
					TextXAlignment = Enum.TextXAlignment.Left,
					Text = has and "Equipped" or "",
					TextColor3 = Color3.fromRGB(107, 255, 99),
					StrokeWidth = 2,
					ZIndex = 10
				})
			}
		end
	}, {
		Popup = import.make(model3, {
			Id = data.Id,
			ItemType = data.ItemType
		}),
		RewardFrame = import.make(model6, {
			Size = UDim2.new(1, 0, 1, 0),
			Id = data.Id,
			ShowXpBar = data.ShowXpBar,
			ItemType = data.ItemType
		}),
		LevelLabel = data.ShowXpBar and import.make(import.wrap(basic.TextLabel, react.LinkedText), {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(0.88, 0, 0.09, 0),
			Size = UDim2.new(0.5, 0, 0.125, 0),
			TextXAlignment = Enum.TextXAlignment.Right,
			StrokeWidth = 2,
			ZIndex = 10,
			KeyChains = { "Inventory.Pet" },
			TextSavedChanged = function(_, object)
				local id = object:findId("Inventory", "Pet", data.Id)

				if id then
					return "Lvl " .. math.clamp(
						math.floor(1 + 99 * (math.clamp(id.Config.XP or 0, 0, PET.PET_MAX_XP) / PET.PET_MAX_XP) ^ PET.PET_LEVEL_GROWTH),
						1,
						100
					)
				end

				return "Lvl 1"
			end
		}) or nil
	}
end

return {
	PetViewport = model,
	PetRewardFrame = model6,
	RewardFrame = model5,
	ItemLabel = model7
}