game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local Debris = game:GetService("Debris")
game:GetService("RunService")
require(game.ReplicatedStorage.library)
local FrameMarker = require(game.ReplicatedStorage.Resources.FrameMarker)
local Libraryyyy2 = require(game.ReplicatedStorage.Resources.Libraryyyy2)

local function ShotGun(instance, p)
	local primaryPart = instance.PrimaryPart
	local v = nil
	local fn

	if p then
		fn = nil
	else
		for _, v3 in pairs(instance.Humanoid:GetPlayingAnimationTracks()) do
			if v3.Animation.AnimationId ~= "rbxassetid://113371045983638" then
				continue
			end

			v = v3
			break
		end

		local v3 = false

		fn = function()
			if v3 or not v or v and not v.IsPlaying then
				v3 = true
				return true
			else
				return false
			end
		end

		if fn() then
			return
		end
	end

	local clone = script.ShotGunFX:Clone()
	clone.Parent = workspace.Thrown
	clone:PivotTo(primaryPart.CFrame * CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, 0))
	Debris:AddItem(clone, 10)
	local shotgun = primaryPart.Parent.Shotgun
	local clone2 = script.Smoke:Clone()
	clone2.Parent = shotgun.Handle
	game.Debris:AddItem(clone2, 10)
	local childAddedConnection = nil
	childAddedConnection = instance.ChildAdded:Connect(function(child)
		if child.Name == "RecentDropShotgun" then
			childAddedConnection:Disconnect()
			childAddedConnection = nil
			shotgun = child.Value

			for _, child2 in pairs(shotgun.Handle:GetChildren()) do
				if child2.Name == "Enabled" then
					child2:Destroy()
				end
			end
		end
	end)
	task.delay(3, function()
		if childAddedConnection then
			childAddedConnection:Disconnect()
			childAddedConnection = nil
		end
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function fx()
		if not p then
			Libraryyyy2.MeshEmit:GroupEmit(script.Meshes.Dash, primaryPart)
		end

		local childAddedConnection2 = nil
		childAddedConnection2 = instance.ChildAdded:Connect(function(child)
			if child.Name == "ShotgunFire" then
				childAddedConnection2:Disconnect()
				childAddedConnection2 = nil

				if not p and fn() then
					return
				end

				Libraryyyy2.Particles:Disable(shotgun)
				clone.Shoot:PivotTo(primaryPart.CFrame * CFrame.new(0, 0, 16))
				Libraryyyy2.Particles:Emit(clone.Shoot)
				Libraryyyy2.MeshEmit:GroupEmit(script.Meshes.Shoot, primaryPart)
				Libraryyyy2.Lighting.PointLight({
					Parent = clone.Shoot.Shoot.Impact,
					Color = Color3.fromRGB(255, 119, 41),
					Duration = 0.5,
					EndRange = 18,
					InitialRange = 15,
					InitialBrightness = 35
				})
				Libraryyyy2.Particles:Enable(shotgun.Handle.Smoke)
				task.delay(0.2, function()
					clone.Land:PivotTo(primaryPart.CFrame * CFrame.new(0, -primaryPart.Size.Y * 1.5, 5))
					Libraryyyy2.Particles:Emit(clone.Land)
					Libraryyyy2.Particles:Emit(shotgun)
					Libraryyyy2.MeshEmit:GroupEmit(script.Meshes.Land, primaryPart)
				end)
				task.wait(1)

				for _, emitter in pairs(shotgun:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end
		end)
	end

	if not p then
		return FrameMarker.new({
			Framerate = 60
		}):Chain({
			[14] = function()
				if fn() then
					return
				end

				fx() -- equivalent call inferred; original call site unknown
				task.delay(3, function()
					if childAddedConnection then
						childAddedConnection:Disconnect()
						childAddedConnection = nil
					end
				end)
			end,
			[52] = function() end
		})
	end

	if not p then
		Libraryyyy2.MeshEmit:GroupEmit(script.Meshes.Dash, primaryPart)
	end

	local childAddedConnection2 = nil
	childAddedConnection2 = instance.ChildAdded:Connect(function(child)
		if child.Name == "ShotgunFire" then
			childAddedConnection2:Disconnect()
			childAddedConnection2 = nil

			if not p and fn() then
				return
			end

			Libraryyyy2.Particles:Disable(shotgun)
			clone.Shoot:PivotTo(primaryPart.CFrame * CFrame.new(0, 0, 16))
			Libraryyyy2.Particles:Emit(clone.Shoot)
			Libraryyyy2.MeshEmit:GroupEmit(script.Meshes.Shoot, primaryPart)
			Libraryyyy2.Lighting.PointLight({
				Parent = clone.Shoot.Shoot.Impact,
				Color = Color3.fromRGB(255, 119, 41),
				Duration = 0.5,
				EndRange = 18,
				InitialRange = 15,
				InitialBrightness = 35
			})
			Libraryyyy2.Particles:Enable(shotgun.Handle.Smoke)
			task.delay(0.2, function()
				clone.Land:PivotTo(primaryPart.CFrame * CFrame.new(0, -primaryPart.Size.Y * 1.5, 5))
				Libraryyyy2.Particles:Emit(clone.Land)
				Libraryyyy2.Particles:Emit(shotgun)
				Libraryyyy2.MeshEmit:GroupEmit(script.Meshes.Land, primaryPart)
			end)
			task.wait(1)

			for _, emitter in pairs(shotgun:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end
	end)
end

return ShotGun