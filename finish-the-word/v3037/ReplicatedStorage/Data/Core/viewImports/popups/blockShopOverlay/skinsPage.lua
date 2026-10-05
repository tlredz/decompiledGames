local createVector = vector.create
local import = _G.import("romodel")
local import2 = _G.import("event")
local import3 = _G.import("sync")
local import4 = _G.import("global")
local import5 = _G.import("itemModules")
_G.import("iconData")
_G.import("mathUtil")
local import6 = _G.import("viewImports")
local basic = import6:get("basic")
local react = import6:get("react")
local menu = import6:get("menu")
local answerInput = import6:get("gameplay").AnswerInput
local eggBillboard = import6:get("eggBillboard")
local localPlayer = game.Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local v = {}

for k, v2 in pairs(import5:getPenultimateNode("Skin").Content) do
	table.insert(v, {
		Id = k,
		Data = v2.Value
	})
end

table.sort(v, function(a, b)
	return a.Data.DirectPrice < b.Data.DirectPrice
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function getCamCFrame()
	local origin = workspace.Meta.Shop:FindFirstChild("Origin")

	if not origin then
		return currentCamera.CFrame
	end

	local lookVector = origin.CFrame.LookVector
	return CFrame.lookAt(
		origin.Position + createVector(0, 2, 0) + lookVector * 7,
		origin.Position + createVector(0, 1.5, 0)
	)
end

local model = import.model(basic.ImageButton, basic.Corner)

function model.init(data)
	return {
		NoAspectRatio = true,
		BackgroundTransparency = 0,
		BackgroundColor3 = Color3.fromRGB(30, 25, 50),
		Size = UDim2.new(0, 60, 0, 60),
		AnchorPoint = data.Anchor,
		Position = data.Position,
		CornerRadius = UDim.new(0.25, 0)
	}, {
		ButtonLabel = import.make(basic.TextLabel, {
			Location = "Center",
			Size = UDim2.new(0.7, 0, 0.7, 0),
			Text = data.Label,
			StrokeWidth = 3
		})
	}
end

local model2 = import.model(menu.Button, react.Reactive)

function model2.init(_)
	return {
		KeyChains = { "Equip.Skin", "Inventory.Skin" },
		SavedChanged = function(state, object)
			local skinId = state.SkinId
			local has = object:has("Inventory", "Skin", skinId)
			local v2 = has and object:has("Equip", "Skin", skinId)
			local parent = state.Parent
			local costContainer = parent.CostContainer

			if has and parent and costContainer then
				costContainer.Visible = false
			end

			if v2 then
				state.Inner.TextLabel.Text = "Unequip"
				state.ActionState = "unequip"
			elseif has then
				state.Inner.TextLabel.Text = "Equip"
				state.ActionState = "equip"
			else
				state.Inner.TextLabel.Text = "Buy"
				state.ActionState = "buy"
			end
		end,
		MouseButton1Down = function(p)
			local skinId = p.SkinId
			local actionState = p.ActionState
			local item = import5:getItem("Skin", skinId)

			if actionState == "buy" then
				import3.request("purchaseSkin", function()
					import2.remoteFire("toggleEquip", "Skin", skinId)
				end, function(p2)
					if not p2 then
						return
					end

					if p2 == "Not enough " .. item.Currency then
						import2.fire("openMenu", "Store", {
							PageId = "DeveloperProducts"
						})
					elseif p2 == "VIP is required" then
						import2.fire("openMenu", "Store", {
							PageId = "GamePasses"
						})
					end

					import2.fire("signal", p2)
				end)(skinId)
			elseif actionState == "equip" or actionState == "unequip" then
				import2.remoteFire("toggleEquip", "Skin", skinId)
			end
		end
	}
end

local model3 = import.model(basic.EmptyElement)

function model3.init()
	local v2 = v[1]
	local has = import4.get("playerSave", localPlayer):has("Inventory", "Skin", v2)
	local v3 = {
		Size = UDim2.new(1, 0, 1, 0),
		CurrentSkinIndex = 1
	}
	local v4 = {
		LeftButton = import.make(model, {
			Label = "<",
			Anchor = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 20, 0.5, 0),
			MouseButton1Down = function(p)
				local parent = p.Parent
				parent:navigate(parent.CurrentSkinIndex - 1)
			end
		}),
		RightButton = import.make(model, {
			Label = ">",
			Anchor = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -20, 0.5, 0),
			MouseButton1Down = function(p)
				local parent = p.Parent
				parent:navigate(parent.CurrentSkinIndex + 1)
			end
		}),
		AnswerInput = import.make(answerInput, {
			Location = "Center",
			Size = UDim2.new(0.9, 0, 0.12, 0)
		}),
		CostContainer = 0,
		ActionButton = 0
	}
	local costContainer

	if not has then
		costContainer = import.make(eggBillboard.CostContainer, {
			BackgroundTransparency = 1,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Position = UDim2.new(0.5, 0, 0.725, 0),
			Size = UDim2.new(0.2, 0, 0.075, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Cost = v2.Data.DirectPrice,
			Currency = v2.Data.Currency
		}) or nil
	end

	v4.CostContainer = costContainer
	v4.ActionButton = import.make(model2, {
		Position = UDim2.new(0.5, 0, 0.85, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.new(0.2, 0, 0.1, 0),
		SkinId = v2.Id
	})
	return v3, v4
end

function model3:render()
	local v2 = v[self.CurrentSkinIndex]
	self.AnswerInput:correct(v2.Data.DisplayName, v2.Id)
end

function model3:navigate(currentSkinIndex)
	if currentSkinIndex < 1 or #v < currentSkinIndex then
		return
	end

	self.CurrentSkinIndex = currentSkinIndex

	if self.CostContainer then
		self.CostContainer:Destroy()
	end

	if self.ActionButton then
		self.ActionButton:Destroy()
	end

	local v2 = v[currentSkinIndex]
	local has = import4.get("playerSave", localPlayer):has("Inventory", "Skin", v2.Id)
	local apply = import.apply
	local costContainer

	if not has then
		costContainer = import.make(eggBillboard.CostContainer, {
			BackgroundTransparency = 1,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Position = UDim2.new(0.5, 0, 0.725, 0),
			Size = UDim2.new(0.2, 0, 0.075, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Cost = v2.Data.DirectPrice,
			Currency = v2.Data.Currency
		}) or nil
	end

	apply(self, nil, {
		CostContainer = costContainer,
		ActionButton = import.make(model2, {
			Position = UDim2.new(0.5, 0, 0.85, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.new(0.2, 0, 0.1, 0),
			SkinId = v2.Id
		})
	})
	self:render()
end

function model3:prespawn()
	self.PrevCameraType = currentCamera.CameraType
	currentCamera.CameraType = Enum.CameraType.Scriptable
	local currentCamera2 = currentCamera
	local camCFrame = getCamCFrame() -- equivalent call inferred; original call site unknown
	currentCamera2.CFrame = camCFrame
	self:render()
end

function model3.despawn(p)
	currentCamera.CameraType = p.PrevCameraType or Enum.CameraType.Custom
end

return {
	SkinsPage = model3
}