local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local WeaponEffects = require(game.ReplicatedStorage:WaitForChild("ChickenOrHero"):WaitForChild("Weapons"):WaitForChild("WeaponEffects"))
local CloneEchoMotion = require(game.ReplicatedStorage.ChickenOrHero.Weapons.CloneEchoMotion)
local UserGameSettings = UserSettings():GetService("UserGameSettings")
local v = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function refresh(p)
	local currentCamera = workspace.CurrentCamera
	WeaponEffects.update(
		p,
		currentCamera and currentCamera.CFrame.Position,
		WeaponEffects.detail(UserGameSettings.SavedQualityLevel)
	)
end

local function watchBlade(instance, state)
	local vFXWeld = instance:FindFirstChild("VFXWeld")
	local part0 = vFXWeld and vFXWeld:IsA("Weld") and vFXWeld.Part0

	if not part0 or part0 == state.blade then
		return
	end

	for _, connection in state.connections do
		connection:Disconnect()
	end

	table.clear(state.connections)
	state.blade = part0
	table.insert(state.connections, part0:GetPropertyChangedSignal("Transparency"):Connect(function()
		refresh(instance) -- equivalent call inferred; original call site unknown
	end))
	table.insert(state.connections, part0:GetPropertyChangedSignal("LocalTransparencyModifier"):Connect(function()
		refresh(instance) -- equivalent call inferred; original call site unknown
	end))
end

local function add(part)
	if not part:IsA("BasePart") or v[part] then
		return
	end

	local v2 = {
		connections = {},
		motion = CloneEchoMotion.build(part)
	}
	v[part] = v2
	watchBlade(part, v2)
	refresh(part) -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function remove(k)
	local v2 = v[k]

	if not v2 then
		return
	end

	for _, connection in v2.connections do
		connection:Disconnect()
	end

	v[k] = nil
end

local connection = CollectionService:GetInstanceAddedSignal(WeaponEffects.Tag):Connect(add)
local connection2 = CollectionService:GetInstanceRemovedSignal(WeaponEffects.Tag):Connect(remove)

for _, v2 in CollectionService:GetTagged(WeaponEffects.Tag) do
	add(v2)
end

local total = 0
local total2 = 0
local heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
	total += dt
	total2 += dt

	if total >= 0.2 then
		total = 0

		for k, v2 in v do
			if k.Parent then
				watchBlade(k, v2)
				refresh(k) -- equivalent call inferred; original call site unknown

				if not v2.motion then
					v2.motion = CloneEchoMotion.build(k)
				end
			else
				remove(k) -- equivalent call inferred; original call site unknown
			end
		end
	end

	local detail = WeaponEffects.detail(UserGameSettings.SavedQualityLevel)

	if total2 < (detail < 1 and 0.06666666666666667 or 0.03333333333333333) then
		return
	end

	total2 = 0
	local currentCamera = workspace.CurrentCamera
	local now = os.clock()

	for _, v2 in v do
		if v2.motion then
			CloneEchoMotion.step(v2.motion, now, currentCamera, detail)
		end
	end
end)
script.Destroying:Connect(function()
	connection:Disconnect()
	connection2:Disconnect()
	heartbeatConnection:Disconnect()

	for k in v do
		remove(k) -- equivalent call inferred; original call site unknown
	end
end)