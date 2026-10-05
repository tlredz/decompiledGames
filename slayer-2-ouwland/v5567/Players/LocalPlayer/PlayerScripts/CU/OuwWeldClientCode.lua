local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local value = Enum.RenderPriority.Character.Value
local v = {}
local v2 = 0
local currentCamera = workspace.CurrentCamera

-- equivalent calls inferred from this helper; original call sites unknown
local function shouldTrack(cFrame: CFrame, position: Vector3)
	local vector = position - cFrame.Position
	local magnitude = vector.Magnitude
	return magnitude <= 25 or not (magnitude > 250) and vector:Dot(cFrame.LookVector) / magnitude >= 0.25
end

local function driveProxy(positions)
	local v3 = positions[1]
	local v4 = positions[2]
	local v5 = positions[5]
	local cFrame = v4.CFrame
	local position = (cFrame * v5.C1:Inverse()).Position
	local v6 = positions[6] or cFrame.Position
	local v7 = position - v6

	if v7.Magnitude > 0.001 then
		local raycastResult = workspace:Raycast(v6, v7, RaycastHelper.Crater)

		if raycastResult ~= nil then
			local v8 = raycastResult.Position + raycastResult.Normal * 2
			cFrame += v8 - position
			position = v8
		end
	end

	v3.CFrame = cFrame
	positions[6] = position
end

local function update()
	local cFrame = currentCamera.CFrame

	for i = #v, 1, -1 do
		local v3 = v[i]

		if v3[1] == nil or v3[2] == nil or v3[1].Parent == nil or v3[2].Parent == nil then
			if v3[1] ~= nil then
				v3[1]:RemoveTag("WeldPartThingOuw")
			end
		else
			-- equivalent call inferred; original call site unknown
			if shouldTrack(cFrame, v3[2].Position) then
				driveProxy(v3)
			else
				v3[6] = nil
			end
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function bind()
	RunService:BindToRenderStep("ouw-weld-render", value, update)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function unbind()
	RunService:UnbindFromRenderStep("ouw-weld-render")
end

local function TagAdded(instance)
	if instance == nil or instance:FindFirstChild("To") == nil or instance.To.Value == nil or instance:FindFirstChild("Weld") == nil or instance.Weld.Part1 == nil or instance:FindFirstChild("Start") == nil then
		return
	end

	local value2 = instance.To.Value
	table.insert(v, {
		instance,
		value2,
		instance.Start.Value,
		instance.Weld.Part1,
		instance.Weld
	})

	if v2 == 0 then
		bind() -- equivalent call inferred; original call site unknown
	end

	v2 += 1
end

local function TagRemoved(p)
	for i, v3 in ipairs(v) do
		if v3[1] ~= p then
			continue
		end

		if v3[1] ~= nil and v3[2] ~= nil and v3[1].Parent ~= nil and v3[2].Parent ~= nil then
			driveProxy(v3)
		end

		if v3[2] ~= nil and v3[4] ~= nil and v3[4].Parent ~= nil then
			local v4 = v3[2].CFrame * v3[5].C1:Inverse()
			v3[4].CFrame = RaycastHelper.ResolveCarryRelease(v3[2].CFrame.Position, v4, v3[3].Position)
		end

		table.remove(v, i)
		v2 -= 1

		if v2 ~= 0 then
			break
		end

		unbind() -- equivalent call inferred; original call site unknown
		break
	end
end

CollectionService:GetInstanceAddedSignal("WeldPartThingOuw"):Connect(TagAdded)
CollectionService:GetInstanceRemovedSignal("WeldPartThingOuw"):Connect(TagRemoved)