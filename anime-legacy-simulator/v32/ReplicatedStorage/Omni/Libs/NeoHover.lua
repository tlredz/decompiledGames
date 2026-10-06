local HttpService = game:GetService("HttpService")
local module = require("@game/ReplicatedStorage/Omni/Libs/Fusion")
local Controller = require(script.Controller)
local Signals = require(script.Signals)
local v = {}
local v2 = {}
local NeoHover = {
	Signals = Signals,
	Create = function(guiObject, identifier: string?)
		if not (guiObject and guiObject:IsA("GuiObject")) then
			return
		end

		if v[guiObject] then
			return v[guiObject]
		end

		local screenGui = guiObject:FindFirstAncestorOfClass("ScreenGui")

		if not screenGui then
			return
		end

		if typeof(identifier) ~= "string" then
			identifier = HttpService:GenerateGUID(false)
		end

		local scaler = guiObject:FindFirstChildWhichIsA("UIScale")

		if not scaler then
			scaler = Instance.new("UIScale")
			scaler.Scale = 1
			scaler.Parent = guiObject
		end

		local object = setmetatable({}, Controller)
		object.Instance = guiObject
		object.Identifier = identifier
		object.Interface = screenGui
		object.Scaler = scaler
		object.OriginalScale = scaler.Scale
		object.Scope = module.scoped(module)
		object.CurrentScale = object.Scope:Value(0)
		object.CurrentPosition = object.Scope:Value(UDim2.fromOffset(0, 0))
		object.ScalerSpring = object.Scope:Spring(object.CurrentScale, 25, 1)
		object.PositionSpring = object.Scope:Spring(object.CurrentPosition, 25, 1)
		object.Enabled = true
		object.UpdateMode = "Mouse"
		object.Connections = {}
		object.LabelTweens = {}
		object.OriginalSize = guiObject.Size
		object.Connections.Scale = scaler:GetPropertyChangedSignal("Scale"):Connect(function()
			local v4 = math.floor(scaler.Scale * 100) / 100
			guiObject.Visible = object.Enabled and v4 > 0
		end)
		object.Connections.Ancestry = guiObject.AncestryChanged:Connect(function(_, parent)
			if parent == nil then
				object:Destroy()
				v[guiObject] = nil
			end
		end)
		object.Scope:Hydrate(scaler)({
			Scale = object.ScalerSpring
		})
		object.Scope:Hydrate(guiObject)({
			Position = object.PositionSpring
		})
		object:Close()
		v[guiObject] = object
		return object
	end,
	GetByInstance = function(guiObject)
		if guiObject and guiObject:IsA("GuiObject") then
			return v[guiObject]
		end
	end,
	GetByIdentifier = function(value: string)
		if typeof(value) ~= "string" then
			return
		end

		for _, v3 in v do
			if v3.Identifier == value then
				return v3
			end
		end

		return nil
	end
}

function NeoHover.GetByPseudoIdentifier(value: string)
	if typeof(value) ~= "string" then
		return
	end

	if v2[value] then
		return v2[value]
	end

	local v3 = NeoHover.GetByIdentifier(value) or NeoHover.GetByIdentifier(value .. "s") or NeoHover.GetByIdentifier(string.sub(
		value,
		1,
		#value - 1
	) .. "ies")

	if not v3 then
		return
	end

	v2[value] = v3
	return v3
end

Signals.HoverOpened:Connect(function(p: string)
	for _, v3 in v do
		if v3.Identifier ~= p and v3.RestrictedToOne then
			v3:Close()
		end
	end
end)
return NeoHover