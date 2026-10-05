local createVector = vector.create
local Maid = require(game.ReplicatedStorage.Util.Maid)
local localPlayer = game.Players.LocalPlayer
local v = Maid.new()
local v2 = {}
local v3 = nil
local v4 = {}
local v5 = 0
local v6 = 0
local v7 = 0
local v8 = 0

for i = 1, 12 do
	local part = Instance.new("Part", workspace)
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Anchored = true
	part.Material = Enum.Material.Neon
	part.CastShadow = false
	part.Transparency = math.max(i - 6, 0) / 6 * 0.95
	part.Color = Color3.fromRGB(156, 0, 0)
	table.insert(v2, part)
end

local UserInputService = game:GetService("UserInputService")

local function FireCannon(p, p2)
	if not v3 or (p2 or not localPlayer.Character) or localPlayer.Character.Busy.Value then
		return
	end

	if localPlayer.Character.Humanoid.Sit == false then
		return
	end

	if UserInputService.GamepadEnabled then
		if p.KeyCode ~= Enum.KeyCode.ButtonR2 then
			return
		end
	elseif p.UserInputType ~= Enum.UserInputType.MouseButton1 and p.UserInputType ~= Enum.UserInputType.Touch then
		return
	end

	local v9 = v3

	if v4[v9] then
		return
	end

	v4[v9] = true

	if game.ReplicatedStorage.Remotes.CommF_:InvokeServer("FireHarpoon", v5, v6, v9, workspace:GetServerTimeNow()) then
		v9:WaitForChild("Cooldown")

		while v9:FindFirstChild("Cooldown") do
			v9.Cooldown:GetPropertyChangedSignal("Parent"):Wait()
		end
	end

	v4[v9] = nil
end

local function CheckActive()
	if not (v3 and localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid") and localPlayer.Character.Humanoid.Sit) then
		return
	end

	if v4[v3] then
		return
	else
		return true
	end
end

local function RenderStepped(p: number)
	local v9

	if v3 and localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid") and localPlayer.Character.Humanoid.Sit then
		v9 = not v4[v3] or nil
	end

	local workspace2

	if v9 then
		workspace2 = workspace
	end

	for _, v10 in pairs(v2) do
		v10.Parent = workspace2
	end

	if not workspace2 then
		return
	end

	local seat = v3:FindFirstChild("Seat")

	if not seat then
		return
	end

	local steerFloat = seat.SteerFloat
	local throttleFloat = seat.ThrottleFloat
	local v10 = steerFloat < 0.1 and steerFloat > -0.1 and 0 or steerFloat
	local v11 = throttleFloat < 0.1 and throttleFloat > -0.1 and 0 or throttleFloat

	if v10 == 0 then
		v7 = 0
	else
		v7 = math.min(v7 + p * 1.5, 1.5)
	end

	local v12 = v6
	v6 = math.clamp(v6 + math.rad(v7 * v10), -1.1344640137963142, 1.1344640137963142)
	v3.Seat.BoatWeld.C0 = CFrame.Angles(0, v6, 0)
	v3.Seat.BoatWeld.C1 = CFrame.Angles(0, v6 * 2, 0)

	if v11 == 0 then
		v8 = 0
	else
		v8 = math.min(v8 + p * 1.5, 1.5)
	end

	local v13 = v5
	v5 = math.clamp(v5 + math.rad(v8 * v11), -0.17453292519943295, 0.7853981633974483)
	local v14 = math.max(v5 - 0.4363323129985824, 0) / 0.6108652381980153 * 2.5
	v3.Seat.CannonWeld.C0 = CFrame.new(0, v14, 0) * CFrame.Angles(v5, 0, 0) * CFrame.new(
		0,
		0,
		-v14 / 1.4142135623730951
	)

	if v13 == v5 and v12 == v6 then
		if v3.Seat.TurningSound.Playing then
			v3.Seat.TurningSound:Pause()
		end
	elseif not v3.Seat.TurningSound.Playing then
		v3.Seat.TurningSound:Play()
	end

	local v15 = -workspace.Gravity
	local v16 = v3.Seat.TubeWeld.Part1.CFrame.LookVector * 400
	local position = v3.Seat.TubeWeld.Part1.CFrame.Position

	-- equivalent calls inferred from this helper; original call sites unknown
	local function calculateFuturePos(p2: number)
		return position + v16 * p2 + createVector(0, 0.5, 0) * v15 * (p2 * p2)
	end

	local v17 = math.max(2 * v16.y / -v15, 0)
	local v18 = math.max(v17 * 0.05, 0.05)

	while (position + v16 * v17 + createVector(0, 0.5, 0) * v15 * (v17 * v17)).Y > -20 do
		v17 += v18
	end

	local v19 = position

	for i = 1, 12 do
		local futurePos = calculateFuturePos(v17 * (i / 20)) -- equivalent call inferred; original call site unknown
		local magnitude = (futurePos - v19).Magnitude
		v2[i].CFrame = CFrame.new(v19, futurePos) * CFrame.new(0, 0, -magnitude / 2)
		v2[i].Size = Vector3.new(1, 1, magnitude)
		v19 = futurePos
	end
end

return function(p)
	if v3 == p then
		return
	end

	if v3 then
		for _, part in pairs(v3.Parent.MeshParts:GetDescendants()) do
			if not part:IsA("BasePart") then
				continue
			end

			part.Transparency = part:GetAttribute("OriginalTransparency")
			part.CanQuery = part:GetAttribute("CouldQuery")
		end

		if v3.Parent.RealParts:FindFirstChild("Mast") then
			local mast = v3.Parent.RealParts.Mast
			mast.Transparency = mast:GetAttribute("OriginalTransparency")
			mast.CanQuery = mast:GetAttribute("CouldQuery")
		end

		if v3.Seat.TurningSound.Playing then
			v3.Seat.TurningSound:Pause()
		end
	else
		local maid = v
		local UserInputService2 = game:GetService("UserInputService")
		maid:GiveTask(UserInputService2.TouchTapInWorld:Connect(FireCannon))
		local maid2 = v
		local UserInputService3 = game:GetService("UserInputService")
		maid2:GiveTask(UserInputService3.InputBegan:Connect(FireCannon))
		local maid3 = v
		local RunService = game:GetService("RunService")
		maid3:GiveTask(RunService.RenderStepped:Connect(RenderStepped))
	end

	v3 = p
	v6 = 0
	v5 = 0
	v8 = 0
	v7 = 0

	if not v3 then
		v:DoCleaning()
		return
	end

	for _, part in pairs(v3.Parent.MeshParts:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		part:SetAttribute("OriginalTransparency", part:GetAttribute("OriginTransparency") or part.Transparency)
		part.Transparency = (1 - part:GetAttribute("OriginalTransparency")) * 0.6 + part:GetAttribute("OriginalTransparency")
		part:SetAttribute("CouldQuery", part:GetAttribute("CouldQuery") or part.CanQuery)
		part.CanQuery = false
	end

	if v3.Parent.RealParts:FindFirstChild("Mast") then
		local mast = v3.Parent.RealParts.Mast
		mast:SetAttribute("OriginalTransparency", mast:GetAttribute("OriginTransparency") or mast.Transparency)
		mast.Transparency = (1 - mast:GetAttribute("OriginalTransparency")) * 0.6 + mast:GetAttribute("OriginalTransparency")
		mast:SetAttribute("CouldQuery", mast:GetAttribute("CouldQuery") or mast.CanQuery)
		mast.CanQuery = false
	end
end