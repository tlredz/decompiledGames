local module = require("@game/ReplicatedStorage/Omni")
local fusion = module.Libs.Fusion
local color = Color3.fromRGB(0, 255, 149)
local color2 = Color3.fromRGB(255, 51, 99)
local frames = module.Interface:WaitForChild("Frames")
local v = {}
local flag = false

-- equivalent calls inferred from this helper; original call sites unknown
local function GetColor(p: string)
	return module.Data.Settings[p] == true and color2 or color
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ClearBinding(p)
	local v2 = v[p]

	if not v2 then
		return
	end

	v[p] = nil
	v2:doCleanup()
end

local function Bind(instance, p: string)
	local main = instance:WaitForChild("ShowAnimation"):WaitForChild("Main")
	local icon = main:WaitForChild("Icon")

	if v[main] then
		return
	end

	local scope = fusion.scoped(fusion)
	local value = scope:Value(GetColor(p))
	local spring = scope:Spring(value, 10, 1)
	v[main] = scope
	module.Button:Create(main, "Small")
	scope:Observer(spring):onBind(function()
		icon.ImageColor3 = scope.peek(spring)
	end)
	local connection = module:OnDataChanged({ "Settings", p }, function()
		value:set(GetColor(p))
	end)
	table.insert(scope, function()
		connection:Disconnect()
	end)
	table.insert(scope, main.Activated:Connect(function()
		local v2 = module.Data.Settings[p] == true
		module.Signal:Fire("General", "Settings", "Set", p, not v2)
	end))
	table.insert(scope, main.Destroying:Connect(function()
		ClearBinding(main) -- equivalent call inferred; original call site unknown
	end))
	table.insert(scope, icon.Destroying:Connect(function()
		ClearBinding(main) -- equivalent call inferred; original call site unknown
	end))
end

local AnimationVisibility = {
	Destroy = function()
		for k in v do
			ClearBinding(k) -- equivalent call inferred; original call site unknown
		end

		flag = false
	end,
	Init = function()
		if flag then
			return
		end

		flag = true

		for _, childName in { "Gacha", "Traits", "Breathings" } do
			Bind(frames:WaitForChild(childName), "Hide Gacha Animation")
		end

		Bind(frames:WaitForChild("Star"):WaitForChild("OtherButtons"), "Hide Star Animation")
	end
}
script.Destroying:Connect(AnimationVisibility.Destroy)
return AnimationVisibility