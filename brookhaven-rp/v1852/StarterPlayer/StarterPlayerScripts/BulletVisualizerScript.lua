local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
wait(5)
local game8Settings = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Player8Handler"):WaitForChild("Game8Settings")
local module = require(game8Settings)
local gunSounds = module.GunSounds
local gun = module.Gun
local visualize = script:WaitForChild("Visualize")
local gunSounds2 = script:WaitForChild("GunSounds")
local muzzleEffect = script:WaitForChild("MuzzleEffect")
local canMuzzleEffect = script:WaitForChild("CanMuzzleEffect")
local can = script:WaitForChild("Can")
local BulletVisualizerFuncs = require(script:WaitForChild("BulletVisualizerFuncs"))
local new = CFrame.new
local _ = Vector3.new

function CreateBulletHole(p, instance, instance2)
	local tagged = CollectionService:GetTagged("PreventBulletHoles")

	for _, ancestor in tagged do
		if instance:IsDescendantOf(ancestor) then
			return
		end
	end

	if p ~= nil and instance ~= nil and not instance.Parent:FindFirstChild("Humanoid") and instance.Anchored == true and instance.Name ~= "water" and instance.Transparency < 1 then
		local hitSurfaceCFrame = BulletVisualizerFuncs.GetHitSurfaceCFrame(p, instance)
		local cframe = new(instance.CFrame.p, hitSurfaceCFrame.p)
		local v = cframe.lookVector * (instance.CFrame.p - hitSurfaceCFrame.p).magnitude / 2
		local v2 = p - hitSurfaceCFrame.p + v
		local cFrame = cframe + v + v2

		if instance2:FindFirstChild("Shotgun") == nil then
			local part = Instance.new("Part")
			part.Transparency = 1
			part.Anchored = true
			part.CanCollide = false
			part.FormFactor = "Custom"
			part.Size = createVector(1, 1, 0.05)
			part.TopSurface = 0
			part.BottomSurface = 0
			local decal = Instance.new("Decal")
			decal.Face = Enum.NormalId.Front
			decal.Texture = "rbxassetid://4520072594"
			decal.Parent = part
			part.Parent = workspace.CurrentCamera
			part.CFrame = cFrame
			game.Debris:AddItem(part, 10)
		else
			local part = Instance.new("Part")
			part.Transparency = 1
			part.Anchored = true
			part.CanCollide = false
			part.FormFactor = "Custom"
			part.Size = createVector(1, 1, 0.05)
			part.TopSurface = 0
			part.BottomSurface = 0
			local decal = Instance.new("Decal")
			decal.Face = Enum.NormalId.Front
			decal.Texture = "rbxassetid://5470828808"
			decal.Parent = part
			part.Parent = workspace.CurrentCamera
			part.CFrame = cFrame
			game.Debris:AddItem(part, 10)
		end
	end
end

function VisualizeBullet(p, p2, part, data, p3, _, _, p4, _, list, _, _, _)
	if typeof(data) ~= "Vector3" or typeof(part) ~= "Instance" or (data.Magnitude > 100 or data.Magnitude < -100) then
		return
	end

	if p ~= game.Players.LocalPlayer and part then
		can.Value = list[1]
		local position = (part.CFrame * CFrame.new(data.X, data.Y, data.Z)).p
		local _ = (position - p3).magnitude / 2
		local sound = Instance.new("Sound", part)
		sound.SoundId = "rbxassetid://" .. p4

		if can.Value == false then
			sound.Volume = 0.5
			sound.EmitterSize = 1
			sound.MaxDistance = 65
			spawn(function()
				sound:Play()
			end)
			game.Debris:AddItem(sound, 2)
			local part2 = Instance.new("Part")
			part2.Name = "water"
			part2.Size = createVector(0.01, 0.01, 0.01)
			part2.Transparency = 1
			part2.Anchored = false
			part2.CanCollide = false
			part2.TopSurface = Enum.SurfaceType.SmoothNoOutlines
			part2.BottomSurface = Enum.SurfaceType.SmoothNoOutlines
			local clone = muzzleEffect:Clone()
			clone.Parent = part2
			local weld = Instance.new("Weld", part2)
			weld.Part0 = part
			weld.Part1 = part2
			weld.C0 = CFrame.new(data.X, data.Y, data.Z)
			part2.Position = position
			part2.Parent = workspace.CurrentCamera
			spawn(function()
				clone:Emit(5)
			end)
			game.Debris:AddItem(part2, 0.2)
		else
			sound.Volume = 1
			sound.EmitterSize = 1
			sound.MaxDistance = 100
			spawn(function()
				sound:Play()
			end)
			game.Debris:AddItem(sound, 2)
			local part2 = Instance.new("Part")
			part2.Name = "water"
			part2.Size = createVector(0.01, 0.01, 0.01)
			part2.Transparency = 1
			part2.Anchored = false
			part2.CanCollide = false
			part2.TopSurface = Enum.SurfaceType.SmoothNoOutlines
			part2.BottomSurface = Enum.SurfaceType.SmoothNoOutlines
			local clone = canMuzzleEffect:Clone()
			clone.Parent = part2
			local weld = Instance.new("Weld", part2)
			weld.Part0 = part
			weld.Part1 = part2
			weld.C0 = CFrame.new(data.X, data.Y, data.Z)
			part2.Position = position
			part2.Parent = workspace.CurrentCamera
			spawn(function()
				clone:Emit(5)
			end)
			game.Debris:AddItem(part2, 0.2)
		end

		CreateBulletHole(p3, p2, part)
	end
end

function GunSounds(p, parent, p2, playbackSpeed)
	if p ~= game.Players.LocalPlayer and parent then
		local sound = Instance.new("Sound", parent)
		sound.SoundId = "rbxassetid://" .. p2
		sound.PlaybackSpeed = playbackSpeed
		sound.Volume = 0.5
		sound.EmitterSize = 1
		sound.MaxDistance = 40
		spawn(function()
			sound:Play()
		end)
		game.Debris:AddItem(sound, 3)
	end
end

visualize.Event:connect(VisualizeBullet)
gunSounds2.Event:connect(GunSounds)
gun.OnClientEvent:connect(VisualizeBullet)
gunSounds.OnClientEvent:connect(GunSounds)