local createVector = vector.create
local _ = game.Players.LocalPlayer
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local FX = require(ReplicatedStorage.FX)
local Util = require(game.ReplicatedStorage.Util)
local kitsuneTailSpawn = FX:WaitForChild("Kitsune").KitsuneTailSpawn
local tail = FX:WaitForChild("Kitsune").Tail
local _ = workspace._WorldOrigin
local v = {
	Id = "C"
}
local v2 = {
	Id = "A"
}
local v3 = {
	Id = "B"
}

local function areShiftedColorsEqual(playerFromCharacter, childName: string, color: Color3, color2: Color3, color3: Color3)
	local child = playerFromCharacter:FindFirstChild(childName)

	if child == nil then
		return false
	end

	local shifted = child:FindFirstChild("Shifted")

	if shifted == nil then
		return false
	end

	local shifted_Color1 = shifted:GetAttribute("Shifted_Color1")
	local shifted_Color2 = shifted:GetAttribute("Shifted_Color2")
	local shifted_Color3 = shifted:GetAttribute("Shifted_Color3")

	if shifted_Color1 == nil or shifted_Color2 == nil or shifted_Color3 == nil then
		return false
	end

	return color == shifted_Color1 and color2 == shifted_Color2 and color3 == shifted_Color3
end

return function(data)
	local root = data.Root
	local playerFromCharacter = game.Players:GetPlayerFromCharacter(root.Parent) or data.Root.Parent
	local cFrame = root.CFrame

	local function choose(p)
		local v4 = nil

		if p == 1 then
			return v
		elseif p == 2 then
			return v2
		elseif p == 3 then
			return v3
		end

		return v4
	end

	for i = 1, 3 do
		local v4 = nil

		for _, id in pairs(data.Ids) do
			if id == i then
				v4 = true
			end
		end

		if v4 then
			continue
		end

		local child = root.Parent:FindFirstChild("KitsuneTail" .. i)

		if not child then
			continue
		end

		Util.Sound:Play("Passives- Tail Disappear", root)
		local folder = child
		task.spawn(function()
			folder.Name = "DESTROYING"

			for i2, emitter in pairs(folder:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter.Enabled = true

				if emitter:GetAttribute("Funky") then
					local v5 = emitter
					coroutine.wrap(function()
						for i3 = 1, 15 do
							v5.Acceleration = Vector3.new(
								math.random(-50, 50),
								math.random(-50, 50),
								math.random(-50, 50)
							)
							task.wait(math.random(10, 20) / 200)
						end

						v5.Acceleration = Vector3.new(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))
					end)()
				end

				local v5 = emitter
				coroutine.wrap(function()
					task.wait(0.35)
					v5.Enabled = false
				end)()
			end

			task.wait(0.15)

			for i2, part in pairs(folder:GetDescendants()) do
				if part:IsA("MeshPart") then
					TweenService:Create(part, TweenInfo.new(0.15), {
						Transparency = 1
					}):Play()
				end
			end

			task.wait(1.5)
			folder:Destroy()
		end)
	end

	for _, id in pairs(data.Ids) do
		local v4 = nil

		if id == 1 then
			v4 = v
		elseif id == 2 then
			v4 = v2
		elseif id == 3 then
			v4 = v3
		end

		local v5 = "Tail" .. v4.Id
		local child = root.Parent:FindFirstChild("KitsuneTail" .. id)

		if child then
			if not data.ForceRefresh then
				continue
			end

			child.Name = "RefreshingKitsuneTail" .. id
			child:Destroy()
		end

		local clone = kitsuneTailSpawn[v5]:Clone()
		local CollectionService = game:GetService("CollectionService")
		CollectionService:RemoveTag(clone, "SmartBone")
		clone.Name = "KitsuneTail" .. id
		Util.SetParentOverrideWithColor(clone, root.Parent, playerFromCharacter, "KitsuneFruitVFXColor", true)

		if areShiftedColorsEqual(
			playerFromCharacter,
			"KitsuneFruitVFXColor",
			Color3.fromRGB(255, 11, 1),
			Color3.fromRGB(0, 0, 0),
			Color3.fromRGB(255, 68, 5)
		) then
			for _, child2 in ipairs(clone:GetChildren()) do
				if child2:GetAttribute("main") then
					child2.Color = Color3.fromRGB(255, 73, 73)
				end
			end
		end

		if data.Tool and data.Tool:FindFirstChild("IsGalaxy") and data.Tool:FindFirstChild("IsGalaxy").Value == true then
			local body_low001 = clone:FindFirstChild("Body_low.001")

			if body_low001 then
				local clone_2 = tail.SurfaceAppearance:Clone()
				clone_2.Parent = body_low001
			end

			local body_low002 = clone:FindFirstChild("Body_low.002")

			if body_low002 then
				local clone_3 = tail.SurfaceAppearance:Clone()
				clone_3.Parent = body_low002
			end

			local body_low004 = clone:FindFirstChild("Body_low.004")

			if body_low004 then
				local clone_4 = tail.SurfaceAppearance:Clone()
				clone_4.Parent = body_low004
			end
		end

		Util.SyncColorsOnChange(clone, playerFromCharacter, "KitsuneFruitVFXColor")
		clone.RootPart.CFrame = cFrame
		clone.RootPart.Weld.C0 *= CFrame.new(0, 0.75, 0)
		clone.RootPart.Weld.Part0 = root.Parent.LowerTorso
		clone.RootPart:SetAttribute("Force", createVector(0, 1, 0) * (id == 2 and 500 or 333))
		clone.RootPart:SetAttribute("WindInfluence", 5)
		clone.RootPart:SetAttribute("AnchorsRotate", true)
		clone.RootPart:SetAttribute("Damping", 0.1)
		clone.RootPart:SetAttribute("Inertia", 0.55)
		clone.RootPart:SetAttribute("ActivationDistance", 600)
		clone.RootPart:SetAttribute("ThrottleDistance", 200)
		Util.Sound:Play("Passives- 1 Tail", root)
		local folder = clone
		task.spawn(function()
			for i, emitter in pairs(folder:GetDescendants()) do
				if not (emitter:IsA("ParticleEmitter") and emitter:GetAttribute("Start")) then
					continue
				end

				emitter.Enabled = true

				if emitter:GetAttribute("Funky") then
					local v6 = emitter
					coroutine.wrap(function()
						for i2 = 1, 15 do
							v6.Acceleration = Vector3.new(
								math.random(-50, 50),
								math.random(-50, 50),
								math.random(-50, 50)
							)
							task.wait(math.random(10, 20) / 200)
						end

						v6.Acceleration = Vector3.new(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))
					end)()
				end

				local v6 = emitter
				coroutine.wrap(function()
					task.wait(0.25)
					v6.Enabled = false
				end)()
			end

			if folder.Name ~= "DESTROYING" then
				local CollectionService2 = game:GetService("CollectionService")
				CollectionService2:AddTag(folder, "SmartBone")
			end
		end)
	end
end