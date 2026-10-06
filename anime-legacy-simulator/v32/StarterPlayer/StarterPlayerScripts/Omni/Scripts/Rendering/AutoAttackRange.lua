local createVector = vector.create
local module = require("@game/ReplicatedStorage/Omni")
local fusion = module.Libs.Fusion
local client = workspace:WaitForChild("Client")
local maps = client:WaitForChild("Maps")
local autoAttackRange = module.Assets:WaitForChild("Models"):WaitForChild("AutoAttackRange")
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { maps, workspace.Terrain }
raycastParams.RespectCanCollide = true
raycastParams.IgnoreWater = true
local v = {}
local scope = nil
local v2 = nil
local v3 = nil
local clone = nil
local v4 = nil
local raycastResult = nil
local v5 = 0
local v6 = 0
local v7 = 0
local v8 = 0
local v9 = 0
local v10 = 0
local identity = CFrame.identity
local v11 = 1
local flag = false
local v12 = false
local flag2 = false
local AutoAttackRange = {}

local function GetBottomOffset(folder)
	local pivot = folder:GetPivot()
	local v13 = 1e999

	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") or part.Transparency >= 1 then
			continue
		end

		local objectSpace = pivot:ToObjectSpace(part.CFrame)
		local halfSize = part.Size / 2
		local v15 = math.abs(objectSpace.RightVector.Y) * halfSize.X + math.abs(objectSpace.UpVector.Y) * halfSize.Y + math.abs(objectSpace.LookVector.Y) * halfSize.Z
		v13 = math.min(v13, objectSpace.Position.Y - v15)
	end

	return v13 < 1e999 and -v13 / folder:GetScale() or 0
end

-- equivalent calls inferred from this helper; original call sites unknown
local function FinishHide()
	if not flag then
		return
	end

	flag = false
	v12 = false
	clone.Parent = nil
	v2:set(0)
	v3:setPosition(0)
	v3:setVelocity(0)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Hide()
	if flag and not v12 then
		v12 = true
		v2:set(0)
	end
end

local function UpdateSurface(humanoidRootPart)
	local now = os.clock()

	if now - v7 >= 0.03333333333333333 then
		v7 = now
		raycastResult = workspace:Raycast(humanoidRootPart.Position, createVector(0, -100, 0), raycastParams)
	end

	if not raycastResult then
		return false
	end

	local normal = raycastResult.Normal
	local position = raycastResult.Position
	local vector2 = Vector3.new(humanoidRootPart.Position.X, position.Y, humanoidRootPart.Position.Z)

	if math.abs(normal.Y) > 0.001 then
		vector2 -= createVector(0, 1, 0) * (normal:Dot(vector2 - position) / normal.Y)
	end

	identity = CFrame.new(vector2 + createVector(0, 0.03, 0))
	return true
end

local function GetRange()
	local now = os.clock()

	if now - v8 >= 0.5 then
		v8 = now
		v9 = module.Utils.PlayerStats.AutoAttackRange(module.Data, module.Instance)
	end

	return v9
end

local function UpdateAppearance(p: number)
	if not clone then
		return
	end

	local v13 = math.max(0.001, v11 * fusion.peek(v3))

	if v12 and v13 <= 0.001 then
		FinishHide() -- equivalent call inferred; original call site unknown
	else
		if math.abs(v13 - v6) > 0.00001 then
			clone:ScaleTo(v13)
			v6 = v13
		end

		v10 = (v10 - p * 0.20943951023931956) % 6.283185307179586
		clone:PivotTo(identity * CFrame.new(0, v5 * v13, 0) * CFrame.Angles(0, v10, 0))
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function RenderHidden(p: number)
	Hide() -- equivalent call inferred; original call site unknown

	if flag then
		UpdateAppearance(p)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ClearModel()
	FinishHide() -- equivalent call inferred; original call site unknown

	if clone then
		clone:Destroy()
		clone = nil
	end

	raycastResult = nil
	v7 = 0
	v6 = 0
	v10 = 0
end

local function CreateModel()
	if clone then
		return
	end

	clone = autoAttackRange:Clone()
	v5 = GetBottomOffset(clone)

	for _, part in clone:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
	end

	clone:ScaleTo(0.001)
	v6 = 0.001
end

local function IsEnabled()
	local settings = module.Data and module.Data.Settings
	return settings ~= nil and settings["Auto Attack"] == true and settings["Show Auto Attack Range"] ~= false
end

function AutoAttackRange.Render(p: number)
	local settings = module.Data and module.Data.Settings
	local v13

	if settings == nil or settings["Auto Attack"] ~= true then
		v13 = false
	else
		v13 = settings["Show Auto Attack Range"] ~= false
	end

	if not (v13 or flag) then
		AutoAttackRange.Refresh()
		return
	end

	local character = module.Instance.Character

	if character ~= v4 then
		ClearModel() -- equivalent call inferred; original call site unknown
		v4 = character
	end

	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
	local v14 = humanoidRootPart and UpdateSurface(humanoidRootPart)

	if v13 then
		if humanoidRootPart and humanoid and not (humanoid.Health <= 0) then
			if v14 then
				local now = os.clock()

				if now - v8 >= 0.5 then
					v8 = now
					v9 = module.Utils.PlayerStats.AutoAttackRange(module.Data, module.Instance)
				end

				local v15 = v9

				if v15 <= 0 then
					RenderHidden(p) -- equivalent call inferred; original call site unknown
				else
					CreateModel()

					if not flag or v12 then
						v12 = false
						v2:set(1)
					end

					v11 = v15 / 10
					UpdateAppearance(p)

					if not flag then
						flag = true
						clone.Parent = client
					end
				end
			else
				RenderHidden(p) -- equivalent call inferred; original call site unknown
			end
		else
			RenderHidden(p) -- equivalent call inferred; original call site unknown
			raycastResult = nil
		end
	else
		RenderHidden(p) -- equivalent call inferred; original call site unknown
		AutoAttackRange.Refresh()
	end
end

function AutoAttackRange.Refresh()
	if not flag2 then
		return
	end

	v8 = 0
	local settings = module.Data and module.Data.Settings
	local v13

	if settings == nil or settings["Auto Attack"] ~= true then
		v13 = false
	else
		v13 = settings["Show Auto Attack Range"] ~= false
	end

	if not v13 and flag and not v12 then
		v12 = true
		v2:set(0)
	end

	if v13 or flag then
		if not v.Render then
			v7 = 0
			v.Render = module.Services.RunService.RenderStepped:Connect(AutoAttackRange.Render)
		end
	else
		if v.Render then
			v.Render:Disconnect()
			v.Render = nil
		end

		raycastResult = nil
	end
end

function AutoAttackRange.Destroy()
	flag2 = false

	for k, connection in v do
		connection:Disconnect()
		v[k] = nil
	end

	ClearModel() -- equivalent call inferred; original call site unknown
	v4 = nil

	if scope then
		scope:doCleanup()
		scope = nil
		v2 = nil
		v3 = nil
	end
end

function AutoAttackRange.Init()
	if flag2 then
		return
	end

	flag2 = true
	scope = fusion.scoped(fusion)
	v2 = scope:Value(0)
	v3 = scope:Spring(v2, 10, 1)
	v.Settings = module:OnDataChanged({ "Settings" }, AutoAttackRange.Refresh)
	v.CharacterRemoving = module.Instance.CharacterRemoving:Connect(function()
		if v.Render then
			v.Render:Disconnect()
			v.Render = nil
		end

		ClearModel() -- equivalent call inferred; original call site unknown
		v4 = nil
	end)
	v.CharacterAdded = module.Instance.CharacterAdded:Connect(AutoAttackRange.Refresh)
	v.Destroying = script.Destroying:Connect(AutoAttackRange.Destroy)
	AutoAttackRange.Refresh()
end

return AutoAttackRange