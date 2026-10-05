local createVector = vector.create
sp = script.Parent
fireflies = 7
local Debris = game:GetService("Debris")
check = true
local handle = sp:WaitForChild("Handle")
local handle2 = sp:WaitForChild("Handle2")
local motor = sp:WaitForChild("Motor")
local animation = sp:WaitForChild("Animation")
local sound = handle:WaitForChild("Sound")
local fireflyScript = script:WaitForChild("FireflyScript")
local pointLight = handle:FindFirstChild("PointLight")

function createfirefly()
	local part = Instance.new("Part")
	part.Name = "Firefly"
	part.formFactor = "Custom"
	part.Friction = 0
	part.Elasticity = 0
	part.Size = createVector(0.1, 0.1, 0.1)
	part.CFrame = handle.CFrame * CFrame.new(math.random() - 0.5, 1 + math.random(), math.random() - 0.5)
	part.Transparency = 1
	part.CanCollide = true
	part.TopSurface = "Smooth"
	part.BottomSurface = "Smooth"
	local selectionBox = Instance.new("SelectionBox")
	selectionBox.Color = BrickColor.new("New Yeller")
	selectionBox.Adornee = part
	selectionBox.Parent = part
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.maxForce = createVector(100, 100, 100)
	bodyVelocity.velocity = Vector3.new(math.random() - 0.5, 1, math.random() - 0.5) * 4
	bodyVelocity.Parent = part
	local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
	bodyAngularVelocity.maxTorque = createVector(100, 100, 100)
	bodyAngularVelocity.angularvelocity = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5) * 20
	bodyAngularVelocity.Parent = part
	local pointLight2 = Instance.new("PointLight")
	pointLight2.Color = pointLight.Color
	pointLight2.Range = math.random(4, 8)
	pointLight2.Brightness = 1
	pointLight2.Parent = part
	local clone = fireflyScript:clone()
	clone.Disabled = false
	clone.Parent = part
	Debris:AddItem(part, math.random(20, 30))
	part.Parent = game.Workspace
	return part
end

sp.Equipped:connect(function(p)
	equipped = true

	if p ~= nil then
		p.Icon = "rbxasset://textures\\GunCursor.png"
		p.Button1Down:connect(function()
			local torso = sp.Parent:FindFirstChild("Torso")
			local humanoid = sp.Parent:FindFirstChild("Humanoid")

			if torso and humanoid and humanoid.Health > 0 and equipped and check then
				p.Icon = "rbxasset://textures\\GunWaitCursor.png"
				check = false

				if anim then
					anim:Stop()
				end

				anim = humanoid:LoadAnimation(animation)

				if anim then
					anim:Play()
				end

				wait(1)
				sound:Play()
				wait(1.7)
				handle2.Transparency = 1
				local clone = handle2:clone()
				clone.Transparency = 0
				clone.Parent = game.Workspace
				clone.CanCollide = true
				clone.Velocity += Vector3.new(math.random() - 0.5, 3, math.random() - 0.5) * 10
				Debris:AddItem(clone, 5)
				clone.Parent = game.Workspace
				wait(1)

				for i = 1, fireflies do
					createfirefly()
					pointLight.Brightness = 4 * (1 - i / fireflies)
					wait(math.random())
				end

				wait(5)

				if p ~= nil then
					p.Icon = "rbxasset://textures\\GunCursor.png"
				end

				pointLight.Brightness = 4
				handle2.Transparency = 0
				check = true
			end
		end)
	end

	if motor then
		motor.Parent = sp
	end
end)
sp.Unequipped:connect(function()
	equipped = false

	if motor then
		motor.Parent = sp
	end

	if anim then
		anim:Stop()
	end

	pointLight.Brightness = 4
	handle2.Transparency = 0
end)
pointLight.Brightness = 4
handle2.Transparency = 0