local module = require("@game/ReplicatedStorage/Omni")
local fusion = module.Libs.Fusion
local Presets = require(script.Presets)
local v = {}
local Button = {}

function Button.Create(_, instance, p: string)
	local preset = Presets[p]

	if not preset then
		return
	end

	if v[instance] then
		return v[instance]
	end

	local object = setmetatable({}, preset)
	object.Instance = instance
	object.Scope = fusion.scoped(fusion)
	object.State = object.Scope:Value("Idle")
	object.Functions = {}
	object.Connections = {}
	object.OnEnterConnections = {}
	object.OnLeaveConnections = {}
	object.OnMoveConnections = {}
	object.OnPressConnections = {}
	object.OnReleaseConnections = {}
	object.Originals = {
		Size = instance.Size,
		Position = instance.Position
	}
	local uIScale = instance:FindFirstChildWhichIsA("UIScale")

	if not uIScale then
		uIScale = Instance.new("UIScale")
		uIScale.Parent = instance
	end

	object.UIScale = uIScale
	instance.Active = true
	instance.Selectable = true
	instance.Interactable = true
	object.Connections.PressStart = instance.MouseButton1Down:Connect(function(...)
		if instance.Parent == nil then
			return
		end

		object.State:set("Pressed")

		if instance.Interactable and instance.Active then
			module.Sound:PlayEffect("Interface.Button.Pressed", {
				Cooldown = 0.06
			})
		end

		for _, onPressConnection in object.OnPressConnections do
			onPressConnection()
		end
	end)
	object.Connections.PressEnd = instance.MouseButton1Up:Connect(function(...)
		if instance.Parent == nil then
			return
		end

		local state = object.Scope.peek(object.State)

		if state == "Pressed" then
			for _, v3 in object.Functions or {} do
				v3()
			end

			if not object then
				return
			end

			for _, onReleaseConnection in object.OnReleaseConnections do
				onReleaseConnection()
			end

			if not object then
				return
			end

			object.State:set(instance.Interactable and "Hover" or "Idle")
		elseif state == "Hover" then
			object.State:set("Idle")
		end
	end)
	object.Connections.Enter = instance.MouseEnter:Connect(function(...)
		if instance.Parent == nil then
			return
		end

		local state = object.Scope.peek(object.State)

		if state ~= "Pressed" then
			object.State:set("Hover")

			if state ~= "Hover" and instance.Interactable and instance.Active then
				module.Sound:PlayEffect("Interface.Button.Hovered", {
					Cooldown = 0.08
				})
			end
		end

		for _, onEnterConnection in object.OnEnterConnections do
			onEnterConnection()
		end
	end)
	object.Connections.Leave = instance.MouseLeave:Connect(function(...)
		if instance.Parent == nil then
			return
		end

		local v3 = object.Scope.peek(object.State) == "Pressed"
		object.State:set("Idle")

		if v3 then
			for _, onReleaseConnection in object.OnReleaseConnections do
				onReleaseConnection()
			end
		end

		if not object then
			return
		end

		for _, onLeaveConnection in object.OnLeaveConnections do
			onLeaveConnection()
		end
	end)
	object.Connections.Move = instance.MouseMoved:Connect(function(...)
		if instance.Parent == nil then
			return
		end

		for _, onMoveConnection in object.OnMoveConnections do
			onMoveConnection()
		end
	end)
	object.Connections.SelectionChanged = instance.SelectionChanged:Connect(function(_, _, p2)
		if instance.Parent == nil then
			return
		end

		if p2 ~= instance then
			object.State:set("Idle")
			return
		end

		if object.Scope.peek(object.State) ~= "Hover" and instance.Interactable and instance.Active then
			module.Sound:PlayEffect("Interface.Button.Hovered", {
				Cooldown = 0.08
			})
		end

		object.State:set("Hover")
	end)
	object.Connections.Interactable = instance:GetPropertyChangedSignal("Interactable"):Connect(function()
		if instance.Interactable then
			return
		end

		object.State:set("Idle")
	end)
	object.Connections.Ancestry = instance.AncestryChanged:Connect(function(_, parent)
		if not (instance and parent) then
			object:Destroy()
			object = nil
			v[instance] = nil
		end
	end)

	if object.Setup then
		object:Setup()
	end

	v[instance] = object
	return object
end

function Button.Get(_, p)
	return v[p]
end

return Button