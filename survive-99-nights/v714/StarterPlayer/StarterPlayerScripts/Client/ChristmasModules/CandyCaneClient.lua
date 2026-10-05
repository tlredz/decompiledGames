local CandyCaneClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local TweenService = game:GetService("TweenService")
local random = Random.new()

function FlyCandy(folder)
	if folder:GetAttribute("Animating") then
		return
	end

	folder:SetAttribute("Animating", true)
	folder:SetAttribute("Taken", true)
	task.spawn(function()
		for _, part in pairs(folder:GetDescendants()) do
			if not part:IsA("BasePart") then
				continue
			end

			part.Anchored = true
			part.CanCollide = false
			part.CanQuery = false
		end

		local pivot = folder:GetPivot()
		local position = pivot.Position
		local v = math.rad((random:NextInteger(-60, 60)))
		local magnitude = (localPlayer.Character.HumanoidRootPart.Position - position).Magnitude
		local total = 0

		while true do
			total += task.wait()

			if not localPlayer.Character then
				break
			end

			local v2 = math.clamp(total / 0.3, 0, 1)
			local position2 = localPlayer.Character.HumanoidRootPart.Position
			local lerped = pivot.Position:Lerp(position2, v2)
			local v3 = math.sin((position2 - lerped).Magnitude / magnitude * 3.141592653589793) * 3
			local v4 = CFrame.lookAt(lerped, position2) * CFrame.Angles(0, 0, v) * CFrame.new(0, v3, 0)
			folder:PivotTo(pivot - pivot.Position + v4.Position)

			if total >= 0.3 then
				break
			end
		end

		for _, part in pairs(folder:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Transparency = 1
			end
		end

		folder:GetPivot()
		task.spawn(function()
			local _ = folder.PrimaryPart.Trail.Color
		end)
		local candyCaneSource = folder:GetAttribute("CandyCaneSource")
		AddCandy(1, candyCaneSource)
		task.wait(2)
		folder:Destroy()
	end)
end

function AddCandy(p, p2)
	Client.Events.RequestCollectCandyCane:FireServer(p, p2)
end

function CandyCaneClient.TakeClient(instance)
	print("take", instance)
	instance:RemoveTag("Interaction")
	instance:SetAttribute("Interaction", nil)
	FlyCandy(instance)
end

function SpawnCandyCane(_: CFrame, _: string, _: Vector3) end

CandyCaneClient.SpawnCandyCane = SpawnCandyCane
Client.Events.SpawnTurretCandyCanes:Connect(function(p)
	local candyCane = game.ReplicatedStorage.Assets.Christmas["Candy Cane"]

	for _ = 1, 3 do
		local v = p * CFrame.Angles(0, 0, random:NextNumber() * 3.141592653589793 * 2) * CFrame.Angles(
			0.5235987755982988,
			0,
			0
		)
		local v2 = v.LookVector * 20 * candyCane.PrimaryPart.AssemblyMass
		SpawnCandyCane(v, "Turret", v2)
	end
end)
Client.Events.SpawnSantaCandyCanes:Connect(function(p)
	local candyCane = game.ReplicatedStorage.Assets.Christmas["Candy Cane"]

	for _ = 1, 10 do
		local v = p * CFrame.Angles(0, 0, random:NextNumber() * 3.141592653589793 * 2) * CFrame.Angles(
			0.5235987755982988,
			0,
			0
		)
		local v2 = v.LookVector * 20 * candyCane.PrimaryPart.AssemblyMass
		SpawnCandyCane(v, "Santa", v2)
	end
end)

function PlayCandyAnimation(value)
	local candyCaneCount = Client.Interface.CandyCaneCount
	local candyBig = candyCaneCount.CandyBig
	TweenService:Create(candyBig, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
		Size = UDim2.new(1.7, 0, 1.7, 0)
	}):Play()
	task.spawn(function()
		wait(0.15)
		TweenService:Create(candyBig, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			Size = UDim2.new(1.3, 0, 1.3, 0)
		}):Play()
	end)
	task.spawn(function()
		wait(0.075)
		candyCaneCount.Count.Text = localPlayer:GetAttribute("CandyCanes") or 0
	end)

	for _ = 1, value or 1 do
		local clone = candyCaneCount.SmallCandy:Clone()
		clone.Name = "CandyParticle"
		clone.ImageColor3 = Color3.fromRGB(255, 0, 0)
		clone.Parent = candyCaneCount
		clone.ZIndex = candyBig.ZIndex + 1
		clone.AnchorPoint = Vector2.new(0.5, 0.5)
		clone.Visible = true
		local v = math.random() * 3.141592653589793 * 2
		local v2 = math.random(80, 150)
		local v3 = math.cos(v) * v2
		local v4 = math.sin(v) * v2 - 50
		local now = tick()
		local absoluteSize = candyCaneCount.AbsoluteSize
		local renderSteppedConnection = nil
		local RunService = game:GetService("RunService")
		renderSteppedConnection = RunService.RenderStepped:Connect(function()
			local v10 = tick() - now

			if v10 >= 1.5 then
				renderSteppedConnection:Disconnect()
				clone:Destroy()
			else
				local v11 = v3 * v10
				local v12 = v4 * v10 + 300 * v10 * v10
				local v13 = candyBig.Position.X.Scale + v11 / absoluteSize.X
				local v14 = 0.5 + v12 / absoluteSize.Y
				clone.Position = UDim2.new(v13, 0, v14, 0)

				if v10 > 1 then
					clone.ImageTransparency = (v10 - 1) / 0.5
				end

				clone.Rotation = v10 * 80
			end
		end)
	end
end

local thread = nil

function CandyCaneClient.Init()
	local candyCaneCount = Client.Interface.CandyCaneCount
	local candyCanes = localPlayer:GetAttribute("CandyCanes") or 0
	candyCaneCount.Visible = false
	candyCaneCount.Count.Text = candyCanes

	-- equivalent calls inferred from this helper; original call sites unknown
	local function scheduleHide()
		if thread then
			task.cancel(thread)
		end

		thread = task.delay(25, function()
			candyCaneCount.Visible = false
			thread = nil
		end)
	end

	localPlayer:GetAttributeChangedSignal("CandyCanes"):Connect(function()
		local candyCanes2 = localPlayer:GetAttribute("CandyCanes") or 0
		local v = candyCanes2 - candyCanes

		if candyCanes < candyCanes2 then
			PlayCandyAnimation((math.clamp(v, 1, 3)))
		end

		if candyCanes ~= candyCanes2 or candyCanes ~= 0 then
			candyCaneCount.Visible = true
		end

		candyCanes = candyCanes2
		scheduleHide() -- equivalent call inferred; original call site unknown
	end)
end

return CandyCaneClient