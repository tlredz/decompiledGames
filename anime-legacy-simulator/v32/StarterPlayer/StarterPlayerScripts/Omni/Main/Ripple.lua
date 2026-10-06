local module = require("@game/ReplicatedStorage/Omni")
local userInputService = module.Services.UserInputService
local guiService = module.Services.GuiService
local fusion = module.Libs.Fusion
local ripple = nil
local template = nil
local v = {}
local v2 = {}
local Ripple = {}

local function GetTemplate()
	if template and template.Parent then
		return template
	end

	local playerGui = module.Instance:FindFirstChild("PlayerGui")
	ripple = playerGui and playerGui:FindFirstChild("Ripple")
	template = ripple and ripple:FindFirstChild("Template")
	return template
end

local function CreateRipple()
	local clone = template:Clone()
	clone.Name = "Ripple"
	clone.Visible = false
	clone.Parent = ripple
	local scope = fusion.scoped(fusion)
	local v3 = {
		Instance = clone,
		Scope = scope,
		Token = 0,
		Size = scope:Value(UDim2.fromScale(0, 0)),
		FillTransparency = scope:Value(0.6),
		StrokeTransparency = scope:Value(0)
	}
	v3.SizeSpring = scope:Spring(v3.Size, 10, 1)
	v3.FillSpring = scope:Spring(v3.FillTransparency, 10, 1)
	v3.StrokeSpring = scope:Spring(v3.StrokeTransparency, 10, 1)
	scope:Hydrate(clone)({
		Size = v3.SizeSpring,
		BackgroundTransparency = v3.FillSpring
	})
	local uIStroke = clone:FindFirstChildWhichIsA("UIStroke")

	if uIStroke then
		scope:Hydrate(uIStroke)({
			Transparency = v3.StrokeSpring
		})
	end

	return v3
end

local function GetRipple()
	local v3 = table.remove(v)

	if v3 then
		return v3
	end

	if #v2 < 10 then
		return (CreateRipple())
	end

	return table.remove(v2, 1)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ReleaseRipple(p)
	local index = table.find(v2, p)

	if not index then
		return
	end

	table.remove(v2, index)
	p.Instance.Visible = false
	table.insert(v, p)
end

local function GetInputPosition(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		return userInputService:GetMouseLocation()
	end

	local guiInset = guiService:GetGuiInset()

	if input.UserInputType == Enum.UserInputType.Touch then
		return Vector2.new(input.Position.X, input.Position.Y) + guiInset
	end

	if input.KeyCode ~= Enum.KeyCode.ButtonA then
		return nil
	end

	local selectedObject = guiService.SelectedObject

	if selectedObject then
		return selectedObject.AbsolutePosition + selectedObject.AbsoluteSize / 2 + guiInset
	end
end

function Ripple:Play(point: Vector2?)
	if not (template and template.Parent) then
		local playerGui = module.Instance:FindFirstChild("PlayerGui")
		ripple = playerGui and playerGui:FindFirstChild("Ripple")
		template = ripple and ripple:FindFirstChild("Template")
	end

	if not template then
		return
	end

	local v4 = table.remove(v)

	if not v4 then
		if #v2 < 10 then
			v4 = CreateRipple()
		else
			v4 = table.remove(v2, 1)
		end
	end

	local v5 = point or userInputService:GetMouseLocation()
	v4.Token += 1
	local token = v4.Token
	v4.SizeSpring:setPosition(UDim2.fromScale(0, 0))
	v4.FillSpring:setPosition(0.6)
	v4.StrokeSpring:setPosition(0)
	v4.Instance.Position = UDim2.fromOffset(v5.X, v5.Y)
	v4.Instance.Visible = true
	table.insert(v2, v4)
	v4.Size:set(UDim2.fromScale(0.05, 0.05))
	v4.FillTransparency:set(1)
	v4.StrokeTransparency:set(1)
	task.delay(0.6, function()
		if v4.Token ~= token then
			return
		end

		ReleaseRipple(v4) -- equivalent call inferred; original call site unknown
	end)
end

userInputService.InputBegan:Connect(function(input)
	local inputPosition = GetInputPosition(input)

	if not inputPosition then
		return
	end

	Ripple:Play(inputPosition)
end)
return Ripple