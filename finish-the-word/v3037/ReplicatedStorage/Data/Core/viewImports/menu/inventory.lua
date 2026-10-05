local localPlayer = game.Players.LocalPlayer
local chairs = game.ReplicatedStorage.ReplicatedAssets.Chairs
local pets = game.ReplicatedStorage.ReplicatedAssets.Pets
game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")
local import = _G.import("event")
local import2 = _G.import("romodel")
local import3 = _G.import("global")
_G.import("iterator")
local import4 = _G.import("iterUtil")
_G.import("iconData")
local import5 = _G.import("itemModules")
local import6 = _G.import("viewImports")
local basic = import6:get("basic")
local menu = import6:get("menu")
local react = import6:get("react")
import6:get("ux")
local v = import6:get("item")
local v2 = {
	Chair = chairs,
	Pet = pets
}
local v3 = {
	Chair = "Chair"
}
local pages = {
	{
		Id = "Chair",
		Label = "Chairs",
		Icon = "Chair"
	},
	{
		Id = "Pet",
		Label = "Pets",
		Icon = "Pet"
	},
	{
		Id = "Title",
		Label = "Titles",
		Icon = "Cash"
	}
}
local v5 = {
	{
		Id = "Chair",
		Label = "Chairs"
	},
	{
		Id = "Pet",
		Label = "Pets"
	}
}
local model = import2.model(menu.Button, react.Reactive)

function model.init(p)
	return {
		KeyChains = { "Equip." .. p.ItemType },
		SavedChanged = function(p2, object)
			local equippedItemOfType = object:getEquippedItemOfType(p.ItemType, p.ItemType)

			if not equippedItemOfType then
				p2.Inner.TextLabel.Text = "Equip"
				return
			end

			local v6 = equippedItemOfType.Name == p.Id
			p2.Inner.TextLabel.Text = v6 and "Equipped" or "Equip"
		end,
		MouseButton1Down = function()
			import.remoteFire("toggleEquip", p.ItemType, p.Id)
		end
	}
end

local model2 = import2.model(basic.Viewport)

function model2.init(p)
	local v6 = v2[p.ItemType][p.Id]
	local v7 = v3[p.ItemType]

	if v7 then
		v6 = v6[v7] or v6
	end

	local clone = v6:Clone()
	return {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1
	}, {
		Camera = import2.make("Camera", {
			Name = "Camera",
			FieldOfView = 35
		}),
		World = import2.make("WorldModel", nil, {
			Item = import2.make(clone, {})
		})
	}
end

function model2:prespawn()
	local instance = self.Instance
	local instance2 = self.Camera.Instance
	local instance3 = self.World.Item.Instance
	instance.CurrentCamera = instance2
	local cframe = CFrame.new()
	instance3:PivotTo(cframe)
	local boundingBox, v6 = instance3:GetBoundingBox()
	local v7 = math.max(v6.X, v6.Y, v6.Z)
	instance2.CFrame = CFrame.lookAt(boundingBox.Position + Vector3.new(0, v7 * 0.35, v7 * 2.25), boundingBox.Position)
	local total = 0
	self.Con = RunService.RenderStepped:Connect(function(dt)
		total += dt * 0.7853981633974483
		instance3:PivotTo(cframe * CFrame.Angles(0, total, 0))
	end)
end

function model2:despawn()
	if not self.Con then
		return
	end

	self.Con:Disconnect()
	self.Con = nil
end

local model3 = import2.model(basic.ConstrainedElement, basic.Corner, basic.Stroke, basic.Gradient)

function model3.init(p)
	local itemType = p.ItemType

	if itemType == "Pet" or itemType == "Title" then
		return {
			Scale = 0.22,
			BackgroundTransparency = 1,
			StrokeWidth = 0
		}, {
			ItemLabel = import2.make(v.ItemLabel, {
				Size = UDim2.new(1, 0, 1, 0),
				Id = p.Id,
				ItemType = itemType,
				ShowXpBar = itemType == "Pet"
			})
		}
	end

	local item = import5:getItem(itemType, p.Id)
	return {
		AspectRatio = 0.75,
		Scale = 0.22,
		StrokeWidth = 4,
		BorderStrokePosition = Enum.BorderStrokePosition.Inner,
		CornerRadius = UDim.new(0.075, 0),
		BackgroundColor3 = Color3.new(1, 1, 1),
		GradientColor = ColorSequence.new(
			Color3.new(0.0509804, 0.690196, 0.921569),
			Color3.new(0.0352941, 0.921569, 0.890196)
		)
	}, {
		EquipButton = import2.make(model, {
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(0.5, 0, 0.92, 0),
			Size = UDim2.new(0.75, 0, 0.2, 0),
			Id = p.Id,
			ItemType = itemType,
			ZIndex = 3
		}),
		TitleLabel = import2.make(basic.TextLabel, {
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0.075, 0),
			Size = UDim2.new(0.75, 0, 0.2, 0),
			StrokeWidth = 3,
			Text = item.DisplayName,
			ZIndex = 2
		}),
		Icon = import2.make(model2, {
			Id = p.Id,
			ItemType = itemType
		})
	}
end

local model4 = import2.model(react.Reactive, basic.EmptyList)

function model4.init(p)
	return {
		Position = UDim2.new(0.5, 0, 0, 0),
		Size = UDim2.new(1, 0, 1, 0),
		AnchorPoint = Vector2.new(0.5, 0),
		Padding = UDim.new(0.03, 0),
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		AutomaticSize = Enum.AutomaticSize.Y,
		Wraps = true,
		KeyChains = { "Inventory." .. p.ItemType },
		SavedChanged = function(object, p2)
			local result = {}

			for _, v6 in ipairs(p2.Inventory[p.ItemType]:getTable()) do
				table.insert(result, import2.make(model3, {
					Id = v6.Config.Id,
					ItemType = p.ItemType
				}))
			end

			object:ClearReactiveChildren()
			return nil, result
		end
	}
end

local model5 = import2.model("ScrollingFrame", basic.Corner)

function model5.init(p)
	local v6 = {
		BackgroundTransparency = 1,
		Position = UDim2.new(0.03, 0, 0.21, 0),
		Size = UDim2.new(0.94, 0, 0.775, 0),
		ScrollBarThickness = 12,
		ScrollBarImageTransparency = 1,
		CanvasSize = UDim2.new()
	}
	local v7 = {
		Inner = import2.make(model4, {
			ItemType = p.ItemType
		}),
		EmptyState = 0
	}
	local make = import2.make
	local wrapped = import2.wrap(basic.EmptyElement, react.Reactive)
	local v8 = {
		Size = UDim2.new(1, 0, 1, 0),
		KeyChains = { "Inventory." .. p.ItemType },
		SavedChanged = function(p2, p3)
			p2.Visible = #p3.Inventory[p.ItemType]:getTable() == 0 and (p.ItemType == "Pet" or p.ItemType == "Title")
		end
	}
	local getButton

	if p.ItemType == "Pet" then
		getButton = import2.make(menu.Button, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.45, 0),
			Size = UDim2.new(0.35, 0, 0.2, 0),
			Text = "Get Pets",
			MouseButton1Down = function(p2)
				local character = localPlayer.Character

				if not character then
					return
				end

				local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

				if not humanoidRootPart or import3.get("playerSession", localPlayer).Sitting then
					return
				end

				humanoidRootPart.CFrame = workspace.Meta.PetTeleport.CFrame
				p2.Ui:Destroy()
			end
		}) or nil
	end

	local helpLabel

	if p.ItemType == "Title" then
		helpLabel = import2.make(basic.TextLabel, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.45, 0),
			Size = UDim2.new(0.7, 0, 0.2, 0),
			Text = "Earn titles by leveling up",
			StrokeWidth = 2
		}) or nil
	end

	v7.EmptyState = make(wrapped, v8, {
		GetButton = getButton,
		HelpLabel = helpLabel
	})
	return v6, v7
end

function model5:prespawn()
	if self.SizeCon then
		return
	end

	local uIListLayout = self.Inner.Instance:FindFirstChildOfClass("UIListLayout")

	-- equivalent calls inferred from this helper; original call sites unknown
	local function update()
		local Y = uIListLayout.AbsoluteContentSize.Y
		self.Inner.Instance.Size = UDim2.new(1, 0, 0, Y)
		self.Instance.CanvasSize = UDim2.new(0, 0, 0, Y)
	end

	self.SizeCon = uIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
	update() -- equivalent call inferred; original call site unknown
end

function model5:despawn()
	if not self.SizeCon then
		return
	end

	self.SizeCon:Disconnect()
	self.SizeCon = nil
end

local model6 = import2.model(menu.Button)

function model6.init(p)
	return {
		Size = UDim2.new(0.4, 0, 0.7, 0),
		Text = p.Label,
		MouseButton1Down = function(p2)
			p2.Ui.Content.Main.Pages:open(p.Id)
		end
	}
end

local model7 = import2.model(basic.ScrollingList, basic.Padding)

function model7.init(_)
	local result = {}

	for _, v6 in ipairs(v5) do
		table.insert(result, import2.make(model6, {
			Id = v6.Id,
			Label = v6.Label
		}))
	end

	table.insert(result, import2.make(basic.EmptyElement, {
		Size = UDim2.new(0.1, 0, 1, 0),
		LayoutOrder = 999
	}))
	return {
		Position = UDim2.new(0.4, 0, 0.045, 0),
		Size = UDim2.new(0.49, 0, 0.15, 0),
		Padding = UDim.new(0.05, 0),
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		AutomaticCanvasSize = Enum.AutomaticSize.X,
		CanvasSize = UDim2.new(),
		BackgroundTransparency = 1,
		ScrollBarThickness = 0,
		PaddingLeft = UDim.new(0.01, 0),
		PaddingRight = UDim.new(0.01, 0)
	}, result
end

local model8 = import2.model(menu.MenuContainer)

function model8.init(p)
	return {
		Title = "Inventory"
	}, {
		TabBar = import2.make(model7),
		PagesList = import2.make(menu.PagesList, {
			Pages = pages
		}),
		Pages = import2.make(menu.Pages, {
			DefaultPageId = p.DefaultPageId or pages[2].Id
		}, import4.toDict(pages, function(_, p2)
			return p2.Id, import2.make(model5, {
				ItemType = p2.Id
			})
		end)),
		Scrollbar = import2.make(import2.wrap(basic.Stroke, basic.Corner), {
			AnchorPoint = Vector2.new(1, 0),
			Size = UDim2.new(0, 12, 0.15, 0),
			BackgroundColor3 = Color3.fromHSV(0.06975, 0.865034, 0.639216),
			Thickness = 3
		})
	}
end

function model8:prespawn()
	local RunService2 = game:GetService("RunService")
	self.Con = RunService2.RenderStepped:Connect(function()
		local openPage = self.Pages:getOpenPage()

		if not openPage then
			return
		end

		local Y = openPage.CanvasPosition.Y
		local Y2 = openPage.AbsoluteCanvasSize.Y
		local Y3 = openPage.AbsoluteSize.Y

		if Y2 == 0 then
			return
		end

		local scale = openPage.Position.Y.Scale
		local scale2 = openPage.Size.Y.Scale
		local v6 = math.min(1, Y3 / Y2)
		self.Scrollbar.Visible = v6 < 0.95
		self.Scrollbar.Size = UDim2.new(0, 12, scale2 * v6, 0)
		self.Scrollbar.Position = UDim2.new(0.97, 0, scale + Y / Y2 * scale2, 0)
	end)
end

function model8.despawn(p)
	p.Con:Disconnect()
end

local model9 = import2.model("ScreenGui", basic.Ui)

function model9.init(p)
	return {
		IgnoreGuiInset = true,
		Name = "Store",
		Scale = 0.55,
		AspectRatio = 1.777,
		Location = "Center",
		Content = {
			Main = import2.make(model8, {
				DefaultPageId = p.PageId
			})
		}
	}
end

return {
	Inventory = model9
}