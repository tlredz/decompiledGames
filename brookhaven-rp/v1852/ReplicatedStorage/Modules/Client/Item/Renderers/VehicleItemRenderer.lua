local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemRenderer = require(ReplicatedStorage.Modules.Client.Item.ItemRenderer)
local CategoryItem = require(ReplicatedStorage.Modules.Shared.Item.CategoryItem)
local VehicleMiddleware = require(ReplicatedStorage.Modules.Shared.Item.Middleware.VehicleMiddleware)
local Object = require(ReplicatedStorage.Modules.Shared.Item.Object)
ItemRenderer.RegisterRenderer(ItemRenderer.VEHICLES_CONTEXT, VehicleMiddleware.VehicleItem, function(object, parent)
	if object.VehicleImpl.NoMotor ~= nil then
		local stringValue = Instance.new("StringValue")
		stringValue.Name = "NoMotor"
		stringValue.Value = object.VehicleImpl.NoMotor
		stringValue.Parent = parent
	end

	if object.VehicleImpl.Type ~= nil and object.VehicleImpl.Type == "boat" then
		local stringValue = Instance.new("StringValue")
		stringValue.Name = "Boat"
		stringValue.Parent = parent
	end

	if object.VehicleImpl.HighlightEffect then
		parent.HighlightEffect.Visible = true
	end

	if object.VehicleImpl.CornerIcon == nil then
		parent.CornerIcon:Destroy()
	else
		parent.CornerIcon.Visible = true
		parent.CornerIcon.Image = object.VehicleImpl.CornerIcon
	end

	if Object.InstanceOf(object, CategoryItem) and object:IsCategory() then
		local selected = parent:FindFirstChild("Selected")
		selected.Visible = true
	else
		parent:FindFirstChild("Selected"):Destroy()
	end

	return true
end)
return {}