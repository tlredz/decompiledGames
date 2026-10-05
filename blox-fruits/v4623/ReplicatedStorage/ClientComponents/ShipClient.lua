local Component = require(game.ReplicatedStorage.Modules.Component)
local Trove = require(game.ReplicatedStorage.Modules.Util.Trove)
local LastInput = require(game.ReplicatedStorage.Modules.LastInput)
local localPlayer = game.Players.LocalPlayer
local v = Component.new({
	Tag = "Ship",
	Ancestors = { workspace:WaitForChild("Boats") }
})

function v:Construct()
	self.trove = Trove.new()
end

function v.Start(p)
	local instance = p.Instance

	if instance.Parent == workspace._WorldOrigin then
		return
	end

	local humanoid = instance:WaitForChild("Humanoid")
	local v2 = math.clamp(instance:GetModelSize().X * 1.5, 0, 75)
	local clone = game.ReplicatedStorage.Assets.GUI.ShipHealthBBG:Clone()
	clone.Size = UDim2.fromScale(v2, v2 / 10)
	clone.Enabled = false
	clone.Parent = instance
	p.trove:Add(clone)
	local instances = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function reflectHealthbarVisibility()
		local v3 = false

		for _, v5 in instances do
			if not v5.Visible then
				continue
			end

			v3 = true
			break
		end

		local v5 = humanoid.Value < instance:GetAttribute("MaxHealth")
		clone.Enabled = not v3 and v5
	end

	p.trove:Add(humanoid.Changed:Connect(reflectHealthbarVisibility))

	-- equivalent calls inferred from this helper; original call sites unknown
	local function addOnscreenHealthBar(instance2)
		table.insert(instances, instance2)
		reflectHealthbarVisibility() -- equivalent call inferred; original call site unknown
		p.trove:Add(instance2:GetPropertyChangedSignal("Visible"):Connect(reflectHealthbarVisibility))
	end

	local main = localPlayer:WaitForChild("PlayerGui"):WaitForChild("Main")
	addOnscreenHealthBar(main:WaitForChild("BottomHUDList"):WaitForChild("ShipHealthBar")) -- equivalent call inferred; original call site unknown

	if LastInput:IsMobile() then
		addOnscreenHealthBar(main:WaitForChild("MobileShipHealthBar")) -- equivalent call inferred; original call site unknown
	end
end

function v.Stop(p)
	p.trove:Destroy()
end

return v