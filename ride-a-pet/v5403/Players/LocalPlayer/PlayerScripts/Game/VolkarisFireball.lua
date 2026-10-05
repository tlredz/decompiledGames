local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Guardian = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("Guardian"))
local VolkarisLairAnimation = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("VolkarisLairAnimation"))
local effects = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Effects")
local rEVolkarisFireball = ReplicatedStorage:WaitForChild("packages"):WaitForChild("Net"):WaitForChild(
	"RE/VolkarisFireball",
	1e999
)
local v = {}
local folder = nil
local renderSteppedConnection = nil
local v2 = false

local function GetFolder()
	if not (folder and folder.Parent) then
		folder = Instance.new("Folder")
		folder.Name = "VolkarisFireballs"
		folder.Parent = workspace
	end

	return folder
end

local function Prepare(folder2)
	local descendants = folder2:GetDescendants()
	table.insert(descendants, folder2)

	for _, part in descendants do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.CastShadow = false
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function StopRenderIfIdle()
	if next(v) == nil and renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end
end

local function Step()
	local serverTimeNow = workspace:GetServerTimeNow()

	for k, v3 in v do
		if v3.EndAt <= serverTimeNow then
			v3.Model:Destroy()
			v[k] = nil
		elseif v3.LaunchAt <= serverTimeNow then
			local v4 = v3.From + v3.Velocity * (serverTimeNow - v3.LaunchAt)
			v3.Model:PivotTo(CFrame.lookAt(v4, v4 + v3.Velocity))

			if not v3.Shown then
				v3.Shown = true
				local model = v3.Model

				if not (folder and folder.Parent) then
					folder = Instance.new("Folder")
					folder.Name = "VolkarisFireballs"
					folder.Parent = workspace
				end

				model.Parent = folder
			end
		end
	end

	StopRenderIfIdle() -- equivalent call inferred; original call site unknown
end

local function PlayThrow()
	for _, v3 in CollectionService:GetTagged(Guardian.RigTag) do
		if not v3:IsDescendantOf(workspace) then
			continue
		end

		local success, result = pcall(VolkarisLairAnimation.Fireball, v3)

		if not success then
			warn("[VolkarisFireball] " .. tostring(result))
		end
	end
end

local function Launch(p, from, velocity, launchAt, value2)
	if typeof(from) ~= "Vector3" or typeof(velocity) ~= "Vector3" or type(launchAt) ~= "number" or type(value2) ~= "number" then
		return
	end

	PlayThrow()
	local currentCamera = workspace.CurrentCamera

	if currentCamera and (currentCamera.CFrame.Position - from).Magnitude > 1500 then
		return
	end

	local child = effects:FindFirstChild(Guardian.FireballAsset)

	if child then
		local clone = child:Clone()
		Prepare(clone)
		v[p] = {
			Model = clone,
			From = from,
			Velocity = velocity,
			LaunchAt = launchAt,
			EndAt = launchAt + value2,
			Shown = false
		}

		if not renderSteppedConnection then
			renderSteppedConnection = RunService.RenderStepped:Connect(Step)
		end
	elseif not v2 then
		v2 = true
		warn("[VolkarisFireball] Assets.Effects." .. Guardian.FireballAsset .. " is missing - fireballs are invisible")
	end
end

local function Impact(p, p2)
	local v3 = v[p]

	if not v3 then
		return
	end

	v[p] = nil
	StopRenderIfIdle() -- equivalent call inferred; original call site unknown
	local model = v3.Model

	if typeof(p2) == "Vector3" then
		model:PivotTo(CFrame.lookAt(p2, p2 + v3.Velocity))
	end

	if not (folder and folder.Parent) then
		folder = Instance.new("Folder")
		folder.Name = "VolkarisFireballs"
		folder.Parent = workspace
	end

	model.Parent = folder
	local descendants = model:GetDescendants()
	table.insert(descendants, model)
	local v4 = 0

	for _, instance in descendants do
		if instance:IsA("ParticleEmitter") then
			instance:Emit(20)
			instance.Enabled = false
			v4 = math.max(v4, instance.Lifetime.Max)
		elseif instance:IsA("Trail") or instance:IsA("Beam") or instance:IsA("Light") then
			instance.Enabled = false
		elseif instance:IsA("BasePart") then
			instance.LocalTransparencyModifier = 1
		end
	end

	task.delay(math.min(v4, 3), function()
		model:Destroy()
	end)
end

rEVolkarisFireball.OnClientEvent:Connect(function(p, p2, ...)
	if p == "Launch" then
		Launch(p2, ...)
	elseif p == "Impact" then
		Impact(p2, ...)
	end
end)