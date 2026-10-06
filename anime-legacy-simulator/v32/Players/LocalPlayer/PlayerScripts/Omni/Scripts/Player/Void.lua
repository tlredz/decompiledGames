local createVector = vector.create
local module = require("@game/ReplicatedStorage/Omni")
local v = {}
local v2 = {}
local v3 = nil
local v4 = 0
local v5 = 0
local Void = {}

local function IsCurrent(player)
	local data = module.Data
	local v6

	if v3 == player and module.Instance.Character == player.Character and player.Humanoid.Health > 0 then
		v6 = player.HRP:IsDescendantOf(player.Character)

		if v6 then
			if data == nil or data.Maps.Current ~= player.MapName or data.Gamemode ~= player.Gamemode then
				return false
			else
				return data.GamemodeSession == player.Session
			end
		end
	else
		return false
	end

	return v6
end

local function Finish(player)
	if v3 ~= player then
		return
	end

	v3 = nil
	v4 = os.clock() + 1
	player.Character:SetAttribute("VoidRecovering", nil)
	local thread = player.Thread

	if thread and not player.Teleporting and thread ~= coroutine.running() and coroutine.status(thread) == "suspended" then
		task.cancel(thread)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Reset()
	if v3 then
		Finish(v3)
	end

	v4 = 0
end

local function GetOceanHeight()
	local client = workspace:FindFirstChild("Client")
	local ocean = client and client:FindFirstChild("Ocean")
	local ocean2 = ocean and ocean:FindFirstChild("Ocean")
	local water1 = ocean2 and ocean2:FindFirstChild("Water1")

	if water1 and water1:IsA("BasePart") then
		return water1.CFrame:PointToWorldSpace((Vector3.new(0, water1.Size.Y / 2, 0))).Y
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Untrack(k)
	local v6 = v2[k]

	if not v6 then
		return
	end

	v2[k] = nil

	for _, connection in v6 do
		connection:Disconnect()
	end
end

local function Track(part)
	if not part:IsA("BasePart") or v2[part] then
		return
	end

	local v6 = {}
	v2[part] = v6

	local function UpdateTouch()
		if v6.Touched then
			v6.Touched:Disconnect()
			v6.Touched = nil
		end

		if not part.CanTouch then
			return
		end

		v6.Touched = part.Touched:Connect(function(otherPart)
			local character = module.Instance.Character

			if not (character and otherPart:IsDescendantOf(character)) then
				return
			end

			if part:IsDescendantOf(workspace) and part:HasTag("Void") then
				Void.Return()
			end
		end)
	end

	v6.CanTouch = part:GetPropertyChangedSignal("CanTouch"):Connect(UpdateTouch)

	if v6.Touched then
		v6.Touched:Disconnect()
		v6.Touched = nil
	end

	if not part.CanTouch then
		return
	end

	v6.Touched = part.Touched:Connect(function(otherPart)
		local character = module.Instance.Character

		if not (character and otherPart:IsDescendantOf(character)) then
			return
		end

		if part:IsDescendantOf(workspace) and part:HasTag("Void") then
			Void.Return()
		end
	end)
end

function Void.Return()
	if v3 or os.clock() < v4 or not module.Data then
		return
	end

	local character = module.Instance.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not humanoid or humanoid.Health <= 0 or not humanoidRootPart then
		return
	end

	if humanoidRootPart.Anchored or character:GetAttribute("Anchored") then
		return
	end

	local v6 = {
		Character = character,
		Humanoid = humanoid,
		HRP = humanoidRootPart,
		MapName = module.Data.Maps.Current,
		Gamemode = module.Data.Gamemode,
		Session = module.Data.GamemodeSession,
		Deadline = os.clock() + 8
	}
	v3 = v6
	character:SetAttribute("VoidRecovering", true)
	humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
	humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
	v6.Thread = task.spawn(function()
		local success, result = pcall(function()
			return module.Signal:Invoke("General", "Void", "Return")
		end)

		if not IsCurrent(v6) then
			Finish(v6)
			return
		end

		if not success or typeof(result) ~= "table" or typeof(result.Destination) ~= "CFrame" or result.Character ~= character or result.MapName ~= v6.MapName or result.Gamemode ~= v6.Gamemode or result.Session ~= v6.Session then
			Finish(v6)
			return
		end

		pcall(function()
			module.Instance:RequestStreamAroundAsync(result.Destination.Position, 3)
		end)

		if not IsCurrent(v6) then
			Finish(v6)
			return
		end

		local function Teleport()
			if not IsCurrent(v6) then
				Finish(v6)
				return
			end

			v6.Thread = coroutine.running()
			v6.Teleporting = true
			humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
			humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
			local success2, result2 = pcall(function()
				module.Signal:InvokeSelf(
					"Player",
					"Character",
					"_Teleport",
					result.Destination,
					result.Destination.Rotation
				)
			end)
			v6.Teleporting = false
			Finish(v6)

			if not success2 then
				warn("[VOID]: Could not return character: " .. tostring(result2))
			end
		end

		if module.Data.Settings["Hide Teleport Transition"] then
			Teleport()
		else
			module.Signal:FireSelf("Interface", "Transition", "Create", "Circular", "In", 2, 1, Teleport)
		end
	end)
end

function Void.Check()
	if v3 then
		if not IsCurrent(v3) or os.clock() >= v3.Deadline then
			Finish(v3)
		end
	else
		local character = module.Instance.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		local oceanHeight = GetOceanHeight()

		if oceanHeight and humanoidRootPart.Position.Y < oceanHeight then
			Void.Return()
		end
	end
end

function Void.Destroy()
	Reset() -- equivalent call inferred; original call site unknown

	for _, connection in v do
		connection:Disconnect()
	end

	table.clear(v)

	for k in v2 do
		Untrack(k) -- equivalent call inferred; original call site unknown
	end
end

function Void.Init()
	if v.Heartbeat then
		return
	end

	v.Added = module.Services.CollectionService:GetInstanceAddedSignal("Void"):Connect(Track)
	v.Removed = module.Services.CollectionService:GetInstanceRemovedSignal("Void"):Connect(Untrack)
	v.CharacterAdded = module.Instance.CharacterAdded:Connect(Reset)
	v.CharacterRemoving = module.Instance.CharacterRemoving:Connect(Reset)

	for _, v6 in module.Services.CollectionService:GetTagged("Void") do
		Track(v6)
	end

	v.Heartbeat = module.Services.RunService.Heartbeat:Connect(function()
		local now = os.clock()

		if now - v5 < 0.1 then
			return
		end

		v5 = now
		Void.Check()
	end)
end

return Void