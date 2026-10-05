local createVector = vector.create
local BatClient = {}
BatClient.__index = BatClient
BatClient.FlySpeed = 55
BatClient.RotSpeed = 270
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local ContentProvider = game:GetService("ContentProvider")

function BatClient.new(spawnCF: CFrame)
	local self = setmetatable({}, BatClient)
	self.SpawnCF = spawnCF
	self.Animations = {}
	self:Load()
	return self
end

function BatClient:HitWithScream()
	print("you got hit")
	Client.Sound.Play("BatEarRing", {
		Position = localPlayer.Character:GetPivot().Position
	})
	Client.Events.HitByBatScream:FireServer()
	task.spawn(function()
		local blurEffect = Instance.new("BlurEffect")
		blurEffect.Size = 0
		blurEffect.Parent = game.Lighting
		local total = 0

		while total < 4 do
			total += task.wait()
			local v = (math.sin(total * 3.141592653589793 * 2 * 0.5) + 1) / 2 * 0.7 + 0.3

			if total < 1 then
				v *= total / 1
			end

			if total > 3 then
				v *= 1 - (total - 3) / 1
			end

			blurEffect.Size = v * 25
		end

		blurEffect:Destroy()
	end)
end

function BatClient.ShowWarning(p, p2: number)
	local batBillboard = p.Model.BatBillboard

	if p2 then
		Client.TweenModule.new(function(p3)
			if p3 > 0 then
				batBillboard.Frame.RedHolder.Size = UDim2.new(1, 0, p3, 0)
				batBillboard.Frame.RedHolder.RedFill.Size = UDim2.new(1, 0, 1 / p3, 0)
			end
		end, p2):Play()
	end

	batBillboard.Enabled = true
end

function BatClient.HideWarning(p)
	p.Model.BatBillboard.Enabled = false
end

function BatClient:ScreamAttack()
	local cFrame = self.HumanoidRootPart.CFrame - createVector(0, 4, 0)
	local _ = self.HumanoidRootPart
	local part = Instance.new("Part")
	part.Anchored = true
	part.Shape = Enum.PartType.Ball
	part.Size = createVector(0, 0, 0)
	part.Transparency = 0.5
	part.CFrame = cFrame
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Parent = workspace.Particles
	part.Color = Color3.fromRGB(255, 0, 0)
	local v2 = false
	local v3 = false
	local total = 0
	task.spawn(function()
		while total < 10 and part.Parent do
			local v4 = task.wait()
			total += v4
			local v5 = total * 25
			part.Size = Vector3.new(v5 * 2, v5 * 2, v5 * 2)
			local primaryPart = localPlayer.Character and localPlayer.Character.PrimaryPart
			local v6

			if primaryPart then
				v6 = Client.CollisionUtility.HasLineOfSight(primaryPart.Position, cFrame.Position)
				local magnitude = (primaryPart.Position - cFrame.Position).Magnitude

				if not v2 and not v3 and v6 and magnitude < v5 then
					self:HitWithScream()
					v2 = true
				end

				if magnitude < v5 then
					v3 = true
					task.delay(1, function()
						part:Destroy()
					end)
				end
			else
				v6 = false
			end

			local transparency2 = v3 and 1 or v6 and 0.6 or 0.95
			local transparency = part.Transparency
			local v8 = transparency2 - transparency
			local v9 = 5 * v4

			if math.abs(v8) < v9 then
				part.Transparency = transparency2
			else
				part.Transparency = transparency + v9 * (v8 < 0 and -1 or 1)
			end
		end

		if part.Parent then
			part:Destroy()
		end
	end)
end

function BatClient.MoveTo(data, vector2: Vector3)
	local position = data.HumanoidRootPart.Position
	local v = ((vector2 - position) * createVector(1, 0, 1)).Magnitude / data.FlySpeed
	local v2 = vector2 - position
	Client.TweenModule.new(function(p, p2)
		if not data.Model then
			return true
		end

		local v3 = position + v2 * p
		local v4 = data.HumanoidRootPart.CFrame - data.HumanoidRootPart.Position + v3
		local lookVector = data.HumanoidRootPart.CFrame.LookVector
		local unit = (vector2 - data.HumanoidRootPart.Position).Unit
		local angleBetweenVectors, v5 = Client.Utility.GetAngleBetweenVectors(lookVector, unit)
		local v6 = math.min(data.RotSpeed * p2, (math.abs((math.deg(angleBetweenVectors)))))

		if v6 > 0.01 then
			v4 *= CFrame.Angles(0, math.rad(v6 * v5), 0)
		end

		data.Model:PivotTo(v4)
	end, v):Play()
	return v
end

function BatClient:Scream(duration, p)
	self:PlayAnimation("Scream")
	task.delay(duration, function()
		self:StopAnimation("Scream", 0.5)
	end)
	task.delay(0.5, function()
		local cFrame = self.HumanoidRootPart.CFrame

		if localPlayer.Character and (localPlayer.Character:GetPivot().Position - cFrame.Position).Magnitude < 150 then
			Client.Sound.Play("BatScream")
		end

		Client.Utility.SpawnParticles("BatScream", cFrame + createVector(0, 4, 0), {
			Duration = 1.5
		})

		if not p then
			self:ScreamAttack()
		end
	end)
end

function BatClient:SetMovement(currentMovement, value)
	if self.CurrentMovement == currentMovement then
		return
	end

	local currentMovement2 = self.CurrentMovement

	if currentMovement2 then
		self:PlayAnimation(currentMovement, value or 0.2)
		self:StopAnimation(currentMovement2, value or 0.2)
	else
		self:PlayAnimation(currentMovement)
	end

	if currentMovement == "Flying" or currentMovement == "Hovering" then
		if not self.PlayingFlyingSound then
			self.HumanoidRootPart.BatFly:Play()
			self.PlayingFlyingSound = true
		end
	elseif self.PlayingFlyingSound then
		self.HumanoidRootPart.BatFly:Stop()
		self.PlayingFlyingSound = false
	end

	self.CurrentMovement = currentMovement
end

local v = {
	Flying = 3,
	Hover = 2,
	IdleToFlying = 1.5,
	Scream = 1.5
}

function BatClient:PlayAnimation(p2, p3)
	if self.Animations[p2] then
		self.Animations[p2]:Play(p3)

		if v[p2] then
			self.Animations[p2]:AdjustSpeed(v[p2])
		end
	else
		print("animation", p2, "doesn't exist")
	end
end

function BatClient:StopAnimation(p2, p3)
	if self.Animations[p2] then
		self.Animations[p2]:Stop(p3)
	end
end

function BatClient:Load()
	local clone = game.ReplicatedStorage.Caves.Bat:Clone()
	self.Model = clone
	self.Model:PivotTo(self.SpawnCF)
	local humanoidRootPart = self.Model:WaitForChild("HumanoidRootPart")
	humanoidRootPart.Anchored = true
	self.HumanoidRootPart = humanoidRootPart
	clone.Parent = workspace.Characters
	local animator = self.Model:WaitForChild("AnimationController"):WaitForChild("Animator")
	local animations = self.Model:WaitForChild("Animations")
	local children = {}

	for _, child in pairs(animations:GetChildren()) do
		table.insert(children, child)
		local track = animator:LoadAnimation(child)

		if child:GetAttribute("AnimationSpeed") then
			track:AdjustSpeed(child:GetAttribute("AnimationSpeed"))
		end

		self.Animations[child.Name] = track
	end

	task.spawn(function()
		ContentProvider:PreloadAsync(children)
	end)
	self.Active = true
end

function BatClient:Destroy()
	self.Model:Destroy()
	self.Model = nil
end

return BatClient