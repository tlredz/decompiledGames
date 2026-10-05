local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Sound = require(ReplicatedStorage:WaitForChild("Util"):WaitForChild("Sound"))

function CameraCutscene(p, p2)
	local currentCamera = workspace.CurrentCamera
	currentCamera.CameraType = Enum.CameraType.Scriptable

	local function cam(p3, p4, p5, p6, p7)
		return CFrame.new(p3, p4, p5) * CFrame.Angles(0, math.rad(p7), 0) * CFrame.Angles(math.rad(p6), 0, 0)
	end

	local cFrame = currentCamera.CFrame
	local v = ({
		Blue = 247.8,
		Yellow = -66.5,
		Red = 360,
		Platform = 138.238
	})[p]
	local v2 = 138.238 - v
	task.delay(5, function()
		local blurEffect = Instance.new("BlurEffect", game.Lighting)
		blurEffect.Size = 0
		local colorCorrectionEffect = Instance.new("ColorCorrectionEffect", game.Lighting)
		TweenService:Create(blurEffect, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, true), {
			Size = 50
		}):Play()
		TweenService:Create(
			colorCorrectionEffect,
			TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.In, 0, true),
			{
				Brightness = -1
			}
		):Play()
		game.Debris:AddItem(blurEffect, 2)
		game.Debris:AddItem(colorCorrectionEffect, 2)
	end)
	local total = 0

	while total < 6 do
		total += task.wait()
		local v3 = math.sin(math.min(total / 1, 1) * 3.141592653589793 / 2)
		local v4 = math.sin(math.clamp((6 - total) / 2.5, 0, 1) * 3.141592653589793 / 2)
		currentCamera.CFrame = cFrame:Lerp(
			p2.Center.CFrame * CFrame.Angles(0, math.rad(v + total / 6 * v2), 0) * CFrame.new(
				0,
				total * 1600 / 6 + -50 + math.clamp((1 - v4) ^ 2, 0, 1) * -150,
				v4 * 230 + -80
			) * CFrame.Angles(math.rad(v4 * 55), 0, 0),
			v3
		)
	end

	currentCamera.CameraType = Enum.CameraType.Custom
	currentCamera.CFrame = cFrame
end

function CreateChain(instance, p)
	local v = {}
	local v2 = nil
	local v3 = {}
	local v4 = nil

	for _, model in pairs(instance:GetChildren()) do
		if not model:IsA("Model") then
			continue
		end

		local meshesimpel_Torus003 = model:FindFirstChild("Meshes/impel_Torus.003")

		if meshesimpel_Torus003 then
			local attachment = meshesimpel_Torus003.Attachment

			for _, part in pairs(model:GetChildren()) do
				if not part:IsA("BasePart") then
					continue
				end

				part.Anchored = part == model.PrimaryPart
				part.Transparency = 1
				local color = part.Color
				part.Color = Color3.fromRGB(255, 255, 255)
				table.insert(v, TweenService:Create(part, TweenInfo.new(0.7, Enum.EasingStyle.Sine), {
					Color = color,
					Transparency = 0
				}))

				if part == model.PrimaryPart then
					continue
				end

				local weldConstraint = Instance.new("WeldConstraint", model.PrimaryPart)
				weldConstraint.Part0 = model.PrimaryPart
				weldConstraint.Part1 = part
			end

			local cFrame = model.PrimaryPart.CFrame
			model.PrimaryPart.CFrame *= CFrame.new(150, -60, 0)

			if v2 then
				v4 = attachment
			else
				v2 = attachment
			end

			table.insert(v, TweenService:Create(model.PrimaryPart, TweenInfo.new(0.7, Enum.EasingStyle.Sine), {
				CFrame = cFrame * CFrame.new(15, 0, 0)
			}))
			table.insert(v3, TweenService:Create(model.PrimaryPart, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
				CFrame = cFrame
			}))
		else
			model:Destroy()
		end
	end

	local Chain = require(script.Chain)
	local chain = Chain.new(v2, v4)
	instance.AncestryChanged:Once(function(_, parent)
		if not parent then
			chain:Destroy(true)
		end
	end)

	for _, particle in pairs(chain.Particles) do
		particle.Transparency = 1
		local color = particle.Color
		particle.Color = Color3.fromRGB(255, 255, 255)
		table.insert(v, TweenService:Create(particle, TweenInfo.new(0.7, Enum.EasingStyle.Sine), {
			Color = color,
			Transparency = 0
		}))
	end

	return {
		Appear = function()
			for _, v6 in pairs(v) do
				v6:Play()
			end

			task.delay(0.7, function()
				for _, v6 in pairs(v3) do
					v6:Play()
				end

				chain:Earthquake(0.01, false, 100, 6)
			end)
			task.delay(5, function()
				chain:Destroy()
			end)
		end,
		Position = v2.WorldCFrame.Position.Y - p.Center.Position.Y,
		Chain = chain
	}
end

return function(instance, p)
	local chains = {}

	for _, child in pairs(instance:GetChildren()) do
		if child.Name == "Chain" and child:IsA("Model") then
			local v = CreateChain(child, instance)
			local v2 = child
			task.delay(v.Position / 1850 * 5.5 - 1, function()
				Sound:Play("TrialSounds.BF_Trial_Chain_Spawn_0" .. tostring(math.random(1, 6)), v2.PrimaryPart.Position)
				v.Appear()
			end)
			table.insert(chains, v.Chain)
		elseif child.Name == "Platform" and child:IsA("BasePart") then
			local cFrame = child.CFrame
			child.CFrame *= CFrame.new(0, -40, -40)
			local v = child
			task.delay((child.Position.Y - instance.Center.Position.Y) / 1350 * 5 - 0.5, function()
				Sound:Play("TrialSounds.BF_Trial_Rock_Spawn_0" .. tostring(math.random(1, 4)), v.Position)
				TweenService:Create(v, TweenInfo.new(0.6, Enum.EasingStyle.Back), {
					CFrame = cFrame
				}):Play()
			end)
		elseif child.Name == "Brazier" and child:IsA("Model") then
			child:GetPivot()

			for _, model in pairs(child:GetChildren()) do
				if not (model:IsA("Model") and #model:GetChildren() == 3) then
					continue
				end

				local pivot = child:GetPivot()
				local v = pivot * CFrame.new(-50, -50, 0)
				child:PivotTo(v)
				local children = {}
				local folder = nil

				for _, folder2 in pairs(child:GetChildren()) do
					if folder2 == model then
						continue
					end

					children = folder2.Model.Model:GetChildren()
					table.sort(children, function(a, b)
						return a.Position.Y > b.Position.Y
					end)

					for _, part in pairs(folder2:GetDescendants()) do
						if part:IsA("BasePart") then
							part.Transparency = 1
						end
					end

					folder = folder2
				end

				local v2 = child
				task.delay((model:GetPivot().Position.Y - instance.Center.Position.Y) / 1350 * 5 - 2.5, function()
					local v5 = 0

					while v5 < 0.6 do
						v5 = math.min(v5 + task.wait(), 0.6)
						v2:PivotTo(v:Lerp(
							pivot,
							(TweenService:GetValue(v5 / 0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out))
						))
					end

					for k, v6 in pairs(children) do
						v6.Transparency = 0
						task.wait()
					end

					for i, part in pairs(folder:GetDescendants()) do
						if part:IsA("BasePart") then
							TweenService:Create(part, TweenInfo.new(1), {
								Transparency = 0
							}):Play()
						end
					end
				end)
			end
		end
	end

	CameraCutscene(p, instance)
	return function(...)
		for _, v in pairs(chains) do
			v:Earthquake(...)
		end
	end
end