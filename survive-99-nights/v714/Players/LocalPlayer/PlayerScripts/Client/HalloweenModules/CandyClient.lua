local createVector = vector.create
local TweenService = game:GetService("TweenService")
local CandyClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local random = Random.new()
local v = {
	Color3.fromRGB(0, 174, 255),
	Color3.fromRGB(255, 0, 212),
	Color3.fromRGB(0, 255, 51),
	Color3.fromRGB(255, 247, 0),
	Color3.fromRGB(255, 102, 0),
	Color3.fromRGB(255, 0, 0)
}

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
		local v2 = math.rad((random:NextInteger(-60, 60)))
		local magnitude = (localPlayer.Character.HumanoidRootPart.Position - position).Magnitude
		local total = 0

		while true do
			total += task.wait()

			if not localPlayer.Character then
				break
			end

			local v3 = math.clamp(total / 0.3, 0, 1)
			local position2 = localPlayer.Character.HumanoidRootPart.Position
			local lerped = pivot.Position:Lerp(position2, v3)
			local v4 = math.sin((position2 - lerped).Magnitude / magnitude * 3.141592653589793) * 3
			local v5 = CFrame.lookAt(lerped, position2) * CFrame.Angles(0, 0, v2) * CFrame.new(0, v4, 0)
			folder:PivotTo(pivot - pivot.Position + v5.Position)

			if total >= 0.3 then
				break
			end
		end

		Client.Sound.Play("CandyPickup", {
			Duplicate = true
		})

		for _, part in pairs(folder:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Transparency = 1
			end
		end

		local pivot2 = folder:GetPivot()
		task.spawn(function()
			local color = folder.PrimaryPart.Trail.Color
			Client.Utility.SpawnParticles("CandyCollected", pivot2, {
				Color = color
			})
		end)
		local candySource = folder:GetAttribute("CandySource")
		AddCandy(1, candySource)
		task.wait(2)
		folder:Destroy()
	end)
end

function AddCandy(p, p2)
	Client.Events.RequestCollectCandy:FireServer(p, p2)
end

function CandyClient.TakeClient(instance)
	print("take", instance)
	instance:RemoveTag("Interaction")
	instance:SetAttribute("Interaction", nil)
	FlyCandy(instance)
end

function SpawnCauldronCandy(instance, p)
	if not instance and instance.Parent then
		AddCandy(p, "Cauldron")
		return
	end

	local cFrame = instance.PrimaryPart.CFrame

	for _ = 1, p do
		local v2 = random:NextNumber() * 3.141592653589793 * 2
		local cframe = CFrame.Angles(
			random:NextNumber() * 3.141592653589793 * 2,
			random:NextNumber() * 3.141592653589793 * 2,
			random:NextNumber() * 3.141592653589793 * 2
		)
		local v3 = cFrame * CFrame.Angles(0, v2, 0) * CFrame.Angles(1.3089969389957472, 0, 0) * CFrame.new(0, 0, -5) * cframe
		local children = game.ReplicatedStorage.Assets.Halloween.Candy:GetChildren()
		local clone = children[random:NextInteger(1, #children)]:Clone()
		clone:PivotTo(v3)
		clone.Parent = workspace.Halloween.Candy
		clone.PrimaryPart:ApplyImpulse(v3.LookVector * 40 + createVector(0, 40, 0))
		clone:SetAttribute("CandySource", "Cauldron")
		task.delay(random:NextInteger(30, 35), function()
			if clone:GetAttribute("Animating") then
				return
			end

			if localPlayer.Parent == game.Players and clone:GetAttribute("Taken") == nil then
				print("timeout candy")

				if localPlayer.Character and clone.Parent and (clone:GetPivot().Position - localPlayer.Character:GetPivot().Position).Magnitude < 30 then
					CandyClient.TakeClient(clone)
				else
					clone:Destroy()
					AddCandy(1, "Cauldron")
				end
			end
		end)
	end
end

Client.Events.SpawnCauldronCandy:Connect(SpawnCauldronCandy)

function SpawnCandy(_, _) end

CandyClient.SpawnCandy = SpawnCandy

function PlayCandyAnimation(value)
	local candyCount = Client.Interface.CandyCount
	local candyBig = candyCount.CandyBig
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
		candyCount.Count.Text = localPlayer:GetAttribute("Candy") or 0
	end)

	for _ = 1, value or 1 do
		local clone = candyCount.SmallCandy:Clone()
		clone.Name = "CandyParticle"
		clone.ImageColor3 = v[math.random(1, #v)]
		clone.Parent = candyCount
		clone.ZIndex = candyBig.ZIndex + 1
		clone.AnchorPoint = Vector2.new(0.5, 0.5)
		clone.Visible = true
		local v2 = math.random() * 3.141592653589793 * 2
		local v3 = math.random(80, 150)
		local v4 = math.cos(v2) * v3
		local v5 = math.sin(v2) * v3 - 50
		local now = tick()
		local absoluteSize = candyCount.AbsoluteSize
		local renderSteppedConnection = nil
		local RunService = game:GetService("RunService")
		renderSteppedConnection = RunService.RenderStepped:Connect(function()
			local v11 = tick() - now

			if v11 >= 1.5 then
				renderSteppedConnection:Disconnect()
				clone:Destroy()
			else
				local v12 = v4 * v11
				local v13 = v5 * v11 + 300 * v11 * v11
				local v14 = candyBig.Position.X.Scale + v12 / absoluteSize.X
				local v15 = 0.5 + v13 / absoluteSize.Y
				clone.Position = UDim2.new(v14, 0, v15, 0)

				if v11 > 1 then
					clone.ImageTransparency = (v11 - 1) / 0.5
				end

				clone.Rotation = v11 * 80
			end
		end)
	end
end

function CandyClient.Init() end

return CandyClient