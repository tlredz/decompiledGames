local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local GameContext = require(ReplicatedStorage.Modules.Core.GameContext)
local TrinketSlotsUpdater = {}
local v = nil
local size = nil
local uDim = nil
local size2 = nil
local uDim2 = nil
local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out, 0, false)

local function tweenSlotBounce(instance)
	local gui = GameContext.Gui

	if instance.Parent == gui then
		instance.Size = uDim2
		TweenService:Create(instance, tweenInfo, {
			Size = size2
		}):Play()
	else
		instance.Size = uDim
		TweenService:Create(instance, tweenInfo, {
			Size = size
		}):Play()
	end
end

local function findPreviewEquippedSlot(p)
	local margin = GameContext.Gui.SelectionFrame:FindFirstChild("Margin")
	local catalogFrame = margin and margin:FindFirstChild("CatalogFrame")
	local trinkets = catalogFrame and catalogFrame:FindFirstChild("Trinkets")
	local previewPane = trinkets and trinkets:FindFirstChild("PreviewPane")
	local equipped = previewPane and previewPane:FindFirstChild("Equipped")
	local equippedTrinkets = equipped and equipped:FindFirstChild("EquippedTrinkets")
	return equippedTrinkets and equippedTrinkets:FindFirstChild("EquippedTrinket" .. p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyTrinket(instance, value, module)
	if not instance then
		return
	end

	local object = instance:FindFirstChild("Object")

	if object and object.Value ~= value then
		tweenSlotBounce(instance)
	end

	if object then
		object.Value = value
	end

	local itemImage = instance:FindFirstChild("ItemImage")

	if itemImage then
		itemImage.Image = module.Icon
		itemImage.Visible = true
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearSlot(instance)
	if not instance then
		return
	end

	local object = instance:FindFirstChild("Object")

	if object then
		object.Value = "None"
	end

	local itemImage = instance:FindFirstChild("ItemImage")

	if itemImage then
		itemImage.Visible = false
	end
end

local function updateOneSlot(p, p2, instance)
	local previewEquippedSlot = findPreviewEquippedSlot(p)

	if p2.Value == "None" then
		clearSlot(previewEquippedSlot) -- equivalent call inferred; original call site unknown
		clearSlot(instance) -- equivalent call inferred; original call site unknown
	else
		local child = ReplicatedStorage.TrinketData:FindFirstChild(p2.Value)

		if child then
			local module = require(child)
			applyTrinket(previewEquippedSlot, p2.Value, module) -- equivalent call inferred; original call site unknown
			applyTrinket(instance, p2.Value, module) -- equivalent call inferred; original call site unknown
		end
	end
end

local function refreshPreviewExitButtons()
	local gui = GameContext.Gui

	if not gui.SelectionFrame.Visible then
		return
	end

	local margin = gui.SelectionFrame:FindFirstChild("Margin")
	local catalogFrame = margin and margin:FindFirstChild("CatalogFrame")
	local trinkets = catalogFrame and catalogFrame:FindFirstChild("Trinkets")
	local previewPane = trinkets and trinkets:FindFirstChild("PreviewPane")

	if not previewPane then
		return
	end

	local trinket1 = previewPane:FindFirstChild("Trinket1")
	local trinket2 = previewPane:FindFirstChild("Trinket2")
	local X = trinket1 and trinket1:FindFirstChild("X")
	local X2 = trinket2 and trinket2:FindFirstChild("X")

	if X then
		local itemImage = trinket1 and trinket1:FindFirstChild("ItemImage")
		X.Visible = itemImage ~= nil and itemImage.Image ~= "" and itemImage.Visible
	end

	if X2 then
		local itemImage = trinket2 and trinket2:FindFirstChild("ItemImage")
		X2.Visible = itemImage ~= nil and itemImage.Image ~= "" and itemImage.Visible
	end
end

function TrinketSlotsUpdater.update()
	if not v then
		return
	end

	updateOneSlot(1, v.Slot1, v.trinketSlot1UI)
	updateOneSlot(2, v.Slot2, v.trinketSlot2UI)
	refreshPreviewExitButtons()
end

function TrinketSlotsUpdater.init(p)
	v = p
	size = v.trinketSlot1 and v.trinketSlot1.Size or UDim2.new(0.1, 0, 0.1, 0)
	uDim = UDim2.new(size.X.Scale * 0.8, 0, size.Y.Scale * 0.8, 0)
	size2 = v.trinketSlot1UI and v.trinketSlot1UI.Size or UDim2.new(0.1, 0, 0.1, 0)
	uDim2 = UDim2.new(size2.X.Scale * 0.8, 0, size2.Y.Scale * 0.8, 0)
	GameContext.Update_Slots = TrinketSlotsUpdater.update
	GameContext.trinket1changed = v.Slot1.Changed:Connect(TrinketSlotsUpdater.update)
	GameContext.trinket2changed = v.Slot2.Changed:Connect(TrinketSlotsUpdater.update)
end

return TrinketSlotsUpdater