local createVector = vector.create
local Shovel = {}
Shovel.__index = Shovel
Shovel.Cooldown = 2
Shovel.ToolHoldAnim = "ShovelIdle"
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
localPlayer:GetMouse()
local random = Random.new()
game:GetService("RunService")

function Shovel.new(model, realModel)
	local self = setmetatable({}, Shovel)
	self.Model = model
	self.RealModel = realModel
	self.LastSwing = 0
	return self
end

function Shovel:Break()
	print("time to break locally")
	self.Broken = true
	Client.InventoryHandler.ClearItemFromInventory(self.RealModel)
end

function SpawnParticle(p, p2, p3, p4, p5)
	local vector2 = Vector3.new()
	local part = Instance.new("Part")
	local number = random:NextNumber()

	if p4 then
		task.delay(2 + number, function()
			part:Destroy()
		end)
	else
		task.delay(25 + number * 10, function()
			part:Destroy()
		end)
	end

	part.Material = Enum.Material.Snow
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	local integer = random:NextInteger(210, 240)
	local color = Color3.fromHSV(0, 0, integer / 255)

	if p5 then
		color = p5
	elseif p4 then
		local integer2 = random:NextInteger(220, 240)
		color = Color3.fromHSV(0, 0.06274509803921569, integer2 / 255)
	end

	part.Color = color
	local v = random:NextInteger(600, 900) / 1000

	if p4 then
		v = random:NextInteger(800, 1200) / 1000
	end

	part.Size = Vector3.new(v, v, v)
	part.CanCollide = true
	part.CanQuery = false
	part.CollisionGroup = "Particles"
	part.CustomPhysicalProperties = PhysicalProperties.new(1, 2, 0.1, 2, 2)
	local integer2 = random:NextInteger(0, 360)
	part.CFrame = p * CFrame.Angles(0, math.rad(integer2), 0) * CFrame.new(0, 0.1, -1)
	part.Parent = workspace.Particles
	part.Velocity = Vector3.new(0, random:NextInteger(p2 * 0.75, p2 * 1.25), 0) + part.CFrame.LookVector * random:NextInteger(
		p3 * 0.15,
		p3 * 1.25
	) + vector2
end

function Shovel:Activate()
	if not localPlayer.Character then
		return
	end

	local humanoidRootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart or time() < self.LastSwing + self.Cooldown then
		return
	end

	self.LastSwing = time()
	Client.Events.PlayAnimation:Fire("Shovel")
	task.delay(1.5, function()
		Client.Events.StopAnimation:Fire("Shovel")
	end)
	task.delay(1, function()
		if not self.Equipped then
			return
		end

		Client.Sound.Play("ShovelDig", {
			Volume = 0.35,
			Replicate = true,
			ReplicationProperties = {
				Instance = localPlayer.Character.Head,
				Volume = 0.4
			}
		})
		local v = humanoidRootPart.CFrame * CFrame.new(0, 0, -4) + createVector(0, 4, 0)
		local v2 = Client.Events.RequestSnowShovelDig:InvokeServer(self.RealModel, v.Position)

		if v2 and v2.Success then
			local position = v2.Position

			if v2.DestroyedBlock then
				for _ = 1, random:NextInteger(4, 8) do
					SpawnParticle(CFrame.new(position), 25, 14, true, v2.SnowColour)
				end
			else
				for _ = 1, random:NextInteger(6, 12) do
					SpawnParticle(CFrame.new(position), 25, 14)
				end
			end
		end
	end)
end

function Shovel.Deactivate(_) end

function Shovel:OnEquip()
	self.Equipped = true
	Client.GuiButtonHandler.ShowButton("Swing")
end

function Shovel:OnUnequip()
	self.Equipped = false
	Client.GuiButtonHandler.HideButton("Swing")
end

return Shovel