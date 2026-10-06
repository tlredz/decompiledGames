local module = require("@game/ReplicatedStorage/Omni")
local fusion = module.Libs.Fusion
local Presets = require(script.Presets)
local HUD = module.Interface:WaitForChild("HUD")
local left = HUD:WaitForChild("Left")
local bottom = HUD:WaitForChild("Bottom")
local quests = HUD:WaitForChild("Quests")
local weather = HUD:WaitForChild("Weather")
local stopButtons = HUD:WaitForChild("StopButtons")
local bottomLeftButtons = HUD:WaitForChild("BottomLeftButtons")
local gamemode = HUD:WaitForChild("Gamemode")
local gamemodeMinimap = HUD:WaitForChild("GamemodeMinimap")
local skill = HUD:WaitForChild("Skill")
local framesBackground = module.Interface:WaitForChild("FramesBackground")
local frames = module.Interface:WaitForChild("Frames")
local v = nil

for _, child in HUD:GetChildren() do
	if not (child.Name == "Multipliers" and child:FindFirstChild("List") and child:FindFirstChild("Arrow")) then
		continue
	end

	v = child
	break
end

local v3 = {}
local v4 = {}
local v5 = {}
local v6 = {}
local scope = fusion.scoped(fusion)
local value = scope:Value(false)
local Frame = {
	Connections = {},
	FrameSignal = module.Libs.GoodSignal.new(),
	HiderSignal = module.Libs.GoodSignal.new(),
	FramesChangedSignal = module.Libs.GoodSignal.new()
}

local function OnFrameSignal(p: string, p2: string)
	local v7 = Frame:Get(p2)

	if not v7 then
		return
	end

	if p == "Open" then
		if table.find(v6, p2) then
			return
		else
			table.insert(v6, p2)
		end
	elseif p == "Close" then
		local index = table.find(v6, p2)

		if not index then
			return
		end

		table.remove(v6, index)
	end

	if p == "Open" and v7.Preset == "Default" then
		Frame:CloseAll(p2)
	end

	Frame:SetGradientStateForFrame(p2, p == "Open")
	local v8 = Frame.Connections[p2] or {}

	for _, v9 in p == "Open" and v8.OnFrameOpened or v8.OnFrameClosed or {} do
		v9()
	end

	if #v6 == 0 then
		Frame:OpenPastUI(p2)
	end

	Frame:RefreshHUD()
	Frame.FramesChangedSignal:Fire()
end

local function SetupAnimations()
	local visible = scope:Value(nil)
	local value3 = scope:Value(nil)
	local value4 = scope:Value(nil)
	local value5 = scope:Value(nil)
	local value6 = scope:Value(nil)
	local value7 = scope:Value(nil)
	local value8 = scope:Value(nil)
	local value9 = scope:Value(nil)
	local value10 = scope:Value(nil)
	local value11 = scope:Value(nil)
	local value12 = scope:Value(nil)
	local value13 = scope:Value(nil)
	scope:Observer(value):onBind(function()
		if scope.peek(value) then
			visible:set(false)
			value3:set(1)
			value13:set(UDim2.fromScale(0.315, 0.925))
			value4:set(UDim2.fromScale(-0.006, 0.5))
			value5:set(UDim2.fromScale(0.5, 0.984))
			value6:set(UDim2.fromScale(0.995, 0.41))
			value7:set(UDim2.fromScale(0.995, 0.47))
			value8:set(UDim2.fromScale(0.995, 0.28))
			value9:set(UDim2.fromScale(0.65, 0.935))
			value10:set(UDim2.fromScale(0.006, 0.985))
			value11:set(UDim2.fromScale(0.5, 0.015))
			value12:set(UDim2.fromScale(0.98, 0.05))
		else
			visible:set(true)
			value3:set(0.5)
			value13:set(UDim2.fromScale(0.315, 1.125))
			value4:set(UDim2.fromScale(-0.2, 0.5))
			value5:set(UDim2.fromScale(0.5, 1.25))
			value6:set(UDim2.fromScale(1.25, 0.41))
			value7:set(UDim2.fromScale(1.25, 0.47))
			value8:set(UDim2.fromScale(1.25, 0.28))
			value9:set(UDim2.fromScale(0.5, 0.99))
			value10:set(UDim2.fromScale(0.006, 1.125))
			value11:set(UDim2.fromScale(0.5, -0.25))
			value12:set(UDim2.fromScale(1.25, 0.05))
		end
	end)
	scope:Hydrate(framesBackground)({
		Visible = visible,
		BackgroundTransparency = scope:Spring(value3, 40, 1)
	})
	scope:Hydrate(left)({
		Position = scope:Spring(value4, 40, 1)
	})
	scope:Hydrate(bottom)({
		Position = scope:Spring(value5, 40, 1)
	})
	scope:Hydrate(quests)({
		Position = scope:Spring(value6, 40, 1)
	})
	scope:Hydrate(v)({
		Position = scope:Spring(value7, 40, 1)
	})
	scope:Hydrate(weather)({
		Position = scope:Spring(value8, 40, 1)
	})
	scope:Hydrate(stopButtons)({
		Position = scope:Spring(value9, 40, 1)
	})
	scope:Hydrate(bottomLeftButtons)({
		Position = scope:Spring(value10, 40, 1)
	})
	scope:Hydrate(gamemode)({
		Position = scope:Spring(value11, 40, 1)
	})
	scope:Hydrate(skill)({
		Position = scope:Spring(value13, 40, 1)
	})
	scope:Hydrate(gamemodeMinimap)({
		Position = scope:Spring(value12, 40, 1)
	})
end

function Frame.Create(_, instance, preset: string)
	if v3[instance.Name] then
		return
	end

	local preset2 = Presets[preset]

	if not preset2 then
		return
	end

	local uIScale = instance:FindFirstChildWhichIsA("UIScale")

	if not uIScale then
		uIScale = Instance.new("UIScale")
		uIScale.Parent = instance
	end

	local object = setmetatable({}, preset2)
	object.Name = instance.Name
	object.Preset = preset
	object.Scope = fusion.scoped(fusion)
	object.Hidden = object.Scope:Value(false)
	object.State = object.Scope:Value("Closed")
	object.Instance = instance
	object.UIScale = uIScale
	object.Gradients = {}
	object.Connections = {}
	object.Originals = {
		Size = uIScale.Scale,
		Position = instance.Position
	}
	object.Connections.Gradients = module.Utils.Instance:ObserveDescendants(instance, function(uIGradient)
		if not (uIGradient and uIGradient:IsA("UIGradient")) then
			return
		end

		local gradient = module.Gradient:CreateGradient(uIGradient)

		if not gradient then
			return
		end

		if not instance.Visible then
			gradient:Pause()
		end

		object.Gradients[uIGradient] = gradient
	end)
	object.Connections.GradientsRemoving = instance.DescendantRemoving:Connect(function(descendant)
		if object.Gradients[descendant] then
			object.Gradients[descendant] = nil
		end
	end)
	object.Connections.Ancestry = instance.AncestryChanged:Connect(function(_, parent)
		if parent == nil then
			object:Destroy()
			table.clear(object.Gradients)
			v3[instance] = nil
		end
	end)
	object:Setup()
	v3[instance.Name] = object
	return object
end

function Frame.OnFrameOpened(_, name: string, callback)
	if type(callback) ~= "function" then
		return
	end

	if typeof(name) == "Instance" then
		name = name.Name
	end

	if not name or typeof(name) ~= "string" then
		return
	end

	if not Frame.Connections[name] then
		Frame.Connections[name] = {
			OnFrameOpened = {},
			OnFrameClosed = {}
		}
	end

	table.insert(Frame.Connections[name].OnFrameOpened, callback)
end

function Frame.OnFrameClosed(_, name: string, callback)
	if type(callback) ~= "function" then
		return
	end

	if typeof(name) == "Instance" then
		name = name.Name
	end

	if not name or typeof(name) ~= "string" then
		return
	end

	if not Frame.Connections[name] then
		Frame.Connections[name] = {
			OnFrameOpened = {},
			OnFrameClosed = {}
		}
	end

	table.insert(Frame.Connections[name].OnFrameClosed, callback)
end

function Frame.IsFrameOpened(_, name: string)
	if typeof(name) == "Instance" then
		name = name.Name
	end

	return typeof(name) == "string" and table.find(v6, name) ~= nil
end

function Frame.GetOpenedFramesAmount(_)
	return #v6
end

function Frame.GetOpenedFrames(_)
	return v6
end

function Frame:Get(name: string)
	if typeof(name) == "Instance" then
		name = name.Name
	end

	if name and typeof(name) == "string" then
		return v3[name]
	end
end

function Frame.SetHidden(_, p: string, flag: boolean)
	local v7 = Frame:Get(p)

	if not v7 then
		return
	end

	v7.Hidden:set(flag == true)
end

function Frame:Open(p: string)
	local v7 = Frame:Get(p)

	if not v7 then
		return
	end

	v7.State:set("Opened")
	Frame.FrameSignal:Fire("Open", v7.Name)
end

function Frame.Close(_, p: string)
	local v7 = Frame:Get(p)

	if not v7 then
		return
	end

	v7.State:set("Closed")
	Frame.FrameSignal:Fire("Close", v7.Name)
end

function Frame.Toggle(_, p: string)
	local v7 = Frame:Get(p)

	if not v7 then
		return
	end

	if v7.Scope.peek(v7.State) == "Opened" then
		v7.State:set("Closed")
		Frame.FrameSignal:Fire("Close", v7.Name)
	else
		v7.State:set("Opened")
		Frame.FrameSignal:Fire("Open", v7.Name)
	end
end

function Frame:CloseAll(p: string)
	for _, v7 in v3 do
		if not (not p or v7.Name ~= p) then
			continue
		end

		v7.State:set("Closed")
		Frame.FrameSignal:Fire("Close", v7.Name)
	end
end

function Frame:CloseHUD()
	value:set(false)
end

function Frame:OpenHUD()
	value:set(true)
end

function Frame:IsBlockingFrameOpened()
	for _, v7 in v6 do
		local v8 = Frame:Get(v7)

		if v8 and (v8.Preset == "Default" or v8.Preset == "Overlay2") then
			return true
		end
	end

	return false
end

function Frame:RefreshHUD()
	if Frame:IsBlockingFrameOpened() then
		Frame:CloseHUD()
	else
		Frame:OpenHUD()
	end
end

function Frame:RefreshUIHiders()
	local v7 = false

	for _, v9 in v4 do
		if not v9 then
			continue
		end

		v7 = true
		break
	end

	module.Inset.Enabled = not v7
	module.Interface.Enabled = not v7
	Frame.HiderSignal:Fire()
end

function Frame.AddUIHider(_, value2: string)
	if type(value2) ~= "string" or v4[value2] then
		return
	end

	v4[value2] = true
	Frame:RefreshUIHiders()
end

function Frame.RemoveUIHider(_, value2: string)
	if not (type(value2) == "string" and v4[value2]) then
		return
	end

	v4[value2] = nil
	Frame:RefreshUIHiders()
end

function Frame.IsUIHidden(_)
	for _ in v4 do
		return true
	end

	return false
end

function Frame:RefreshFramesHiders()
	local v7 = false

	for _, v9 in v5 do
		if not v9 then
			continue
		end

		v7 = true
		break
	end

	frames.Visible = not v7
end

function Frame.AddFramesHider(_, value2: string)
	if type(value2) ~= "string" or v5[value2] then
		return
	end

	v5[value2] = true
	Frame:RefreshFramesHiders()
end

function Frame.RemoveFramesHider(_, value2: string)
	if not (type(value2) == "string" and v5[value2]) then
		return
	end

	v5[value2] = nil
	Frame:RefreshFramesHiders()
end

function Frame.IsFramesHidden(_)
	for _ in v5 do
		return true
	end

	return false
end

function Frame.SetPastUI(_, name: string)
	if typeof(name) == "Instance" then
		name = name.Name
	end

	if typeof(name) ~= "string" and name ~= nil then
		return
	end

	module.Cache:Set({ "PastUI" }, name)
end

function Frame:OpenPastUI(p: string)
	local v7 = module.Cache:Get({ "PastUI" })

	if v7 and v7 ~= p then
		Frame:Open(v7)
	elseif v7 then
		Frame:RemovePastUI()
	end
end

function Frame:RemovePastUI()
	module.Cache:Set({ "PastUI" }, nil)
end

function Frame:SetGradientStateForFrame(p: string, flag: boolean)
	local v7 = Frame:Get(p)

	if not v7 then
		return
	end

	for k, gradient in v7.Gradients do
		if k and k.Parent then
			if flag then
				gradient:Play()
			else
				gradient:Pause()
			end
		else
			v7.Gradients[k] = nil
		end
	end
end

function Frame.Init(_)
	Frame:RefreshHUD()
	Frame:RefreshUIHiders()
	Frame:RefreshFramesHiders()
	Frame.FrameSignal:Connect(OnFrameSignal)
	SetupAnimations()
end

return Frame