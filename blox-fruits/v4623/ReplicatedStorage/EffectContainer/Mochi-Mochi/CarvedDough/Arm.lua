local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
game:GetService("ReplicatedStorage")
local FX = require(game.ReplicatedStorage.FX)
local mochiMochi = FX:WaitForChild("Mochi-Mochi")
return function(list)
	local v, v2, v3 = unpack(list)
	local rightLowerArm = v:WaitForChild("RightLowerArm", 1)
	local rightHand = v:WaitForChild("RightHand", 1)
	local clone = mochiMochi.Forearm:Clone()
	clone.Color = rightLowerArm.Color
	clone.Name = v.Name .. "CarveForearm"
	clone.Anchored = false
	clone.CFrame = rightLowerArm.CFrame
	clone.Mesh.Scale = Vector3.new()
	local clone2 = mochiMochi.Spike:Clone()
	clone2.Color = clone.Color
	clone2.Anchored = false
	clone2.CFrame = clone.CFrame
	clone2.Mesh.Scale = Vector3.new()
	local weld = Instance.new("Weld", clone2)
	weld.Part0 = clone2
	weld.Part1 = clone
	clone2.Parent = clone
	local weld2 = Instance.new("Weld", clone)
	weld2.Part0 = clone
	weld2.Part1 = rightLowerArm
	rightHand.Transparency = 1
	clone.Parent = _WorldOrigin
	local tweenInfo = TweenInfo.new(v2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	local tween = TweenService:Create(clone, tweenInfo, {
		Color = Color3.new()
	})
	local tween2 = TweenService:Create(clone.Mesh, tweenInfo, {
		Scale = createVector(5.625, 10.125, 5.625)
	})
	local tween3 = TweenService:Create(weld2, tweenInfo, {
		C0 = CFrame.new(0, 4.95, 0)
	})
	local tween4 = TweenService:Create(clone2.Mesh, tweenInfo, {
		Scale = createVector(7.3124995, 13.162499, 7.3124995)
	})
	local tween5 = TweenService:Create(clone2, tweenInfo, {
		Color = Color3.new()
	})
	tween.Completed:Connect(function()
		wait(v3)
		local tweenInfo2 = TweenInfo.new(2 * v2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		local tween6 = TweenService:Create(clone, tweenInfo2, {
			Color = rightLowerArm.Color
		})
		local tween7 = TweenService:Create(clone.Mesh, tweenInfo2, {
			Scale = rightLowerArm.Size
		})
		local tween8 = TweenService:Create(weld2, tweenInfo2, {
			C0 = CFrame.new(0, 0, 0)
		})
		local tween9 = TweenService:Create(clone2.Mesh, tweenInfo2, {
			Scale = rightLowerArm.Size
		})
		local tween10 = TweenService:Create(clone2, tweenInfo2, {
			Color = rightLowerArm.Color
		})
		tween6.Completed:Connect(function()
			clone:Destroy()
			rightHand.Transparency = 0
		end)
		tween6:Play()
		tween7:Play()
		tween8:Play()
		tween9:Play()
		tween10:Play()
	end)
	tween:Play()
	tween2:Play()
	tween3:Play()
	tween4:Play()
	tween5:Play()
end