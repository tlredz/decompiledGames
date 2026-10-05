game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local Debris = game:GetService("Debris")
game:GetService("RunService")
local FrameMarker = require(game.ReplicatedStorage.Resources.FrameMarker)
local Libraryyyy2 = require(game.ReplicatedStorage.Resources.Libraryyyy2)

local function DuelDeagle(instance, _)
	local primaryPart = instance.PrimaryPart
	local clone = script.DuelDeagleFX:Clone()
	clone.Parent = workspace.Thrown
	clone:PivotTo(primaryPart.CFrame * CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, 0))
	Debris:AddItem(clone, 25)
	local v = nil
	local cFrame = primaryPart.CFrame
	return FrameMarker.new({
		Framerate = 60
	}):Chain({
		[0] = function()
			for _, childName in pairs({ "Deagle" }) do
				local child = instance:FindFirstChild(childName)

				if not child then
					continue
				end

				local clone2 = script.Parent.Deagle.SpinFX:Clone()
				clone2.Parent = child.Weapon
				game.Debris:AddItem(clone2, 5)
				v = child
			end

			Libraryyyy2.Particles:Enable(primaryPart.Parent.Deagle.Weapon.SpinFX)
		end,
		[10] = function()
			if v and v.Parent then
				Libraryyyy2.Particles:Disable(v.Weapon.SpinFX)
			end
		end,
		[39] = function()
			local deagleAnchor = instance:FindFirstChild("DeagleAnchor")

			if not deagleAnchor then
				return
			end

			if deagleAnchor then
				cFrame = deagleAnchor.Value
			end

			clone:PivotTo(cFrame)
			Libraryyyy2.Particles:Emit(clone.Shoot.Shoot1)
			Libraryyyy2.MeshEmit:GroupEmit(script.Meshes.Shoot1, clone.Shoot.CFrame)

			if v and v.Parent then
				Libraryyyy2.Lighting.PointLight({
					Parent = v.Weapon,
					Color = Color3.fromRGB(255, 184, 103),
					Duration = 0.5,
					EndRange = 18,
					InitialRange = 11,
					InitialBrightness = 15
				})
			end
		end
	})
end

return DuelDeagle