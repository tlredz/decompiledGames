local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Lightning
local _ = Util.Sound
local _ = Util.MasterClock
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local electro2Effects = FX:WaitForChild("Electro2Effects")
local _ = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local random = Random.new()

local function flop(list)
	for i = 1, math.floor(#list / 2) do
		local v = #list - i + 1
		local v2 = list[v]
		local v3 = list[i]
		list[i] = v2
		list[v] = v3
	end

	return list
end

local function Create(className, items)
	local instance = Instance.new(className)

	for k, item in pairs(items) do
		instance[k] = item
	end

	return instance
end

local function CreatePart(items)
	local part = Instance.new("Part")

	for k, v in pairs({
		Size = createVector(1, 1, 1),
		TopSurface = "Smooth",
		BottomSurface = "Smooth",
		CanCollide = false,
		Massless = true,
		Anchored = true
	}) do
		part[k] = v
	end

	for k, item in pairs(items) do
		part[k] = item
	end

	return part
end

local function ClearAllChildren(instance, className)
	for _, child in pairs(instance:GetChildren()) do
		if className then
			if child:IsA(className) then
				child:Destroy()
			end
		else
			child:Destroy()
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function deleteWhenTweenCompletes(tween, instance)
	local completedConnection = nil
	completedConnection = tween.Completed:Connect(function(_)
		instance:Destroy()
		completedConnection:Disconnect()
	end)
end

local function randomSphericalPoint(p, p2, list)
	local v = { -p2, p2 }
	local number = random:NextNumber(-list[1].X, list[1].X)
	local v2

	if list[1].IsPositiveOrNegative then
		v2 = v[random:NextInteger(1, #v)] or p2
	else
		v2 = p2
	end

	local v3 = number * v2
	local number2 = random:NextNumber(-list[2].Y, list[2].Y)
	local v4

	if list[2].IsPositiveOrNegative then
		v4 = v[random:NextInteger(1, #v)] or p2
	else
		v4 = p2
	end

	local v5 = number2 * v4
	local number3 = random:NextNumber(-list[3].Z, list[3].Z)

	if list[3].IsPositiveOrNegative then
		p2 = v[random:NextInteger(1, #v)] or p2
	end

	local v6 = p + Vector3.new(v3, v5, number3 * p2)
	return CFrame.new(v6.p, -(p.p - v6.p) * 999)
end

return function(data)
	local DISTANCE_THRESHOLD = 1100
	local v = { workspace.Characters, workspace.Enemies }

	local function electroJump()
		spawn(function()
			for _ = 1, 2 do
				local clone = electro2Effects:WaitForChild("ElectroJumpWave"):Clone()
				clone.CFrame = data.jumpRef.CFrame * CFrame.new(0, -3, 0)
				clone.Parent = _WorldOrigin
				local tween = TweenService:Create(clone, TweenInfo.new(0.275, Enum.EasingStyle.Quint), {
					Size = clone.Size * 5,
					Transparency = 1
				})
				tween:Play()
				deleteWhenTweenCompletes(tween, clone) -- equivalent call inferred; original call site unknown
				wait(0.075)
			end
		end)
		local clone = electro2Effects:WaitForChild("ElectroJumpShock"):Clone()
		clone.CFrame = data.jumpRef.CFrame * CFrame.new(0, -3, 0)
		clone.Parent = _WorldOrigin
		spawn(function()
			for _ = 1, 19 do
				RunService.RenderStepped:Wait()
				clone.CFrame *= CFrame.Angles(0, random:NextNumber(-3.141592653589793, 3.141592653589793), 0)
			end

			clone:Destroy()
		end)

		for _ = 1, 2 do
			local clone2 = electro2Effects:WaitForChild("ElectroJumpImpact"):Clone()
			clone2.CFrame = data.jumpRef.CFrame * CFrame.new(0, -3, 0) * CFrame.Angles(
				0,
				random:NextNumber(-3.141592653589793, 3.141592653589793),
				0
			)
			clone2.Parent = _WorldOrigin
			local tween = TweenService:Create(clone2, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
				Transparency = 1,
				Size = clone2.Size * 4
			})
			tween:Play()
			deleteWhenTweenCompletes(tween, clone2) -- equivalent call inferred; original call site unknown
			wait(0.165)
		end
	end

	local function ZigZag()
		local clone = electro2Effects:WaitForChild("LightningC_Trail"):Clone()
		clone.Name = "Trail " .. data.tTick
		clone.Parent = _WorldOrigin

		repeat
			RunService.RenderStepped:Wait()
			clone.CFrame = data.TrailRef.CFrame
		until clone.Parent == nil
	end

	local function afterBurst()
		local clone = electro2Effects:WaitForChild("LightningAfterSpark"):Clone()
		clone.CFrame = data.prevPos
		clone.Parent = _WorldOrigin
		local clone2 = electro2Effects:WaitForChild("LightningAfterShock"):Clone()
		clone2.CFrame = data.prevPos
		clone2.Parent = _WorldOrigin
		spawn(function()
			repeat
				RunService.RenderStepped:Wait()
				clone2.CFrame *= CFrame.Angles(
					random:NextNumber(-3.141592653589793, 3.141592653589793),
					random:NextNumber(-3.141592653589793, 3.141592653589793),
					random:NextNumber(-3.141592653589793, 3.141592653589793)
				)
			until clone2.Parent == nil
		end)
		local tween = TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Cubic), {
			Size = clone2.Size * 1.75,
			Color = Color3.new(0.643137, 0.964706, 1),
			Transparency = 1
		})
		local tween2 = TweenService:Create(clone2, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {
			Size = clone2.Size * 1.5,
			Color = Color3.new(0.584314, 1, 0.968627),
			Transparency = 1
		})
		tween2:Play()
		tween:Play()
		deleteWhenTweenCompletes(tween2, clone2) -- equivalent call inferred; original call site unknown
		deleteWhenTweenCompletes(tween, clone) -- equivalent call inferred; original call site unknown
		local clone3 = electro2Effects:WaitForChild("ElectroZag"):Clone()
		clone3.Size = Vector3.new((data.prevPos.p - data.TrailRef.Position).Magnitude, 12, 12)
		clone3.CFrame = CFrame.new(data.prevPos.p, data.TrailRef.Position) * CFrame.new(0, 0, -clone3.Size.X / 2) * CFrame.Angles(
			0,
			1.5707963267948966,
			0
		)
		clone3.Parent = _WorldOrigin
		local tween3 = TweenService:Create(
			clone3,
			TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 2),
			{
				Transparency = 1
			}
		)
		local tween4 = TweenService:Create(clone3, TweenInfo.new(0.6), {
			Size = Vector3.new(clone3.Size.X, 0, 0)
		})
		spawn(function()
			repeat
				RunService.RenderStepped:Wait()
				clone3.CFrame *= CFrame.Angles(1.0471975511965976, 0, 0)
			until clone3.Parent == nil
		end)
		tween4:Play()
		tween3:Play()
		deleteWhenTweenCompletes(tween3, clone3) -- equivalent call inferred; original call site unknown
	end

	local function Strike()
		local child = _WorldOrigin:FindFirstChild("Trail " .. data.tTick)

		if child then
			for _, trail in pairs(child:GetChildren()) do
				if trail:IsA("Trail") then
					trail.Enabled = false
				end
			end

			delay(child.Trail.Lifetime, function()
				child:Destroy()
			end)
		end
	end

	local function Explode()
		local v2 = false

		if (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - data.explosionRef.Position).Magnitude < 75 then
			Util.CameraShaker:ShakeOnce(12, 10.5, 0.2, 0.8)
		end

		local hitCf = data.hitCf

		for i = 1, 2 do
			local clone = electro2Effects:WaitForChild("ElectricRumble"):Clone()
			clone.Size = Vector3.new(i * 6 + 75, i * 5 + 75, i ^ 0.5 * 5 + 45)
			clone.Color = Color3.fromRGB(25, 202, 255)
			clone.CFrame = hitCf * CFrame.Angles(1.5707963267948966, 0, 0) + Vector3.new(0, clone.Size.Z / 3.25, 0)
			clone.Parent = _WorldOrigin
			spawn(function()
				local count = 0

				repeat
					RunService.RenderStepped:Wait()
					count += 1
					clone.CFrame *= CFrame.Angles(0, 0, random:NextNumber(-3.141592653589793, 3.141592653589793))

					if count >= 4 and v2 == false then
						count = 0
						local clone2 = electro2Effects:WaitForChild("ElectroSlice"):Clone()
						clone2.CFrame = hitCf * CFrame.Angles(
							0,
							random:NextNumber(-3.141592653589793, 3.141592653589793),
							0
						)
						clone2.Parent = _WorldOrigin
						local tween = TweenService:Create(clone2, TweenInfo.new(0.225, Enum.EasingStyle.Linear), {
							Size = clone2.Size * 1.75,
							CFrame = clone2.CFrame * CFrame.new(-15, 0, 20),
							Transparency = 1
						})
						tween:Play()
						deleteWhenTweenCompletes(tween, clone2) -- equivalent call inferred; original call site unknown
					end
				until clone.Parent == nil
			end)
			local tween = TweenService:Create(
				clone,
				TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 4),
				{
					Size = Vector3.new(
						clone.Size.X / (i == 1 and 1.25 or 0.75),
						clone.Size.Y * (i == 1 and 1.25 or 0.75),
						clone.Size.Z / (i == 1 and 1.25 or 0.75)
					),
					Color = Color3.fromRGB(120, 255, 255)
				}
			)
			tween:Play()
			local v4 = clone
			tween.Completed:Connect(function(p)
				if p == Enum.PlaybackState.Completed then
					v2 = true
					local tween2 = TweenService:Create(v4, TweenInfo.new(0.15), {
						Size = Vector3.new(0, 0, v4.Size.Z * 1.5),
						CFrame = v4.CFrame + Vector3.new(0, v4.Size.Z / 2 - 10, 0)
					})
					tween2:Play()
					deleteWhenTweenCompletes(tween2, v4) -- equivalent call inferred; original call site unknown

					for i2 = 1, 2 do
						local clone2 = i2 == 1 and electro2Effects:WaitForChild("ElectroRumbleAfterWind"):Clone() or electro2Effects:WaitForChild("ElectroRumbleAfterWind2"):Clone()
						clone2.CFrame = hitCf
						clone2.Parent = _WorldOrigin
						local tween3 = TweenService:Create(
							clone2,
							TweenInfo.new(i2 == 1 and 0.25 or 0.33, Enum.EasingStyle.Sine),
							{
								Size = clone2.Size * (i2 == 1 and 1.5 or 2),
								CFrame = clone2.CFrame * CFrame.Angles(0, 3.141592653589793, 0),
								Transparency = 1
							}
						)
						tween3:Play()
						deleteWhenTweenCompletes(tween3, clone2) -- equivalent call inferred; original call site unknown
					end
				end
			end)
		end

		for i = 1, 17 do
			local part = CreatePart({
				Size = createVector(7, 7, 7),
				CFrame = hitCf * CFrame.Angles(0, math.rad(i * 21.176470588235293), 0) * CFrame.new(0, 0, -46)
			})
			local ray, v4 = Util.Ray(part.Position, part.CFrame.UpVector * -12, v)

			if not ray then
				continue
			end

			part.Color = ray.Color
			part.Material = ray.Material
			part.CFrame = CFrame.new(v4) * CFrame.Angles(
				random:NextNumber(-3.141592653589793, 3.141592653589793),
				random:NextNumber(-3.141592653589793, 3.141592653589793),
				random:NextNumber(-3.141592653589793, 3.141592653589793)
			)
			part.Parent = _WorldOrigin
			local part2 = part
			delay(1, function()
				local tween = TweenService:Create(part2, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
					Size = createVector(0, 0, 0)
				})
				tween:Play()
				deleteWhenTweenCompletes(tween, part2) -- equivalent call inferred; original call site unknown
			end)
		end

		local ray = Util.Ray(hitCf.p, hitCf.UpVector * -10, v)

		if ray then
			for _ = 1, 6 do
				local part = CreatePart({
					Size = createVector(1, 1, 1) * random:NextNumber(4, 6),
					CFrame = hitCf * CFrame.Angles(0, random:NextNumber(-3.141592653589793, 3.141592653589793), 0) * CFrame.Angles(
						math.rad((random:NextNumber(20, 60))),
						0,
						0
					) * CFrame.new(0, 0, -35),
					Anchored = false,
					Material = ray and ray.Material,
					Color = ray and ray.Color,
					Parent = _WorldOrigin
				})
				part.Velocity = part.CFrame.LookVector * 120
				part.RotVelocity = Vector3.new(
					random:NextNumber(5, 25),
					random:NextNumber(5, 25),
					random:NextNumber(5, 25)
				)
				delay(0.33, function()
					local tween = TweenService:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
						Size = createVector(0, 0, 0)
					})
					tween:Play()
					deleteWhenTweenCompletes(tween, part) -- equivalent call inferred; original call site unknown
				end)
			end
		end

		local clone = electro2Effects:WaitForChild("ExplosionCrack3"):Clone()
		Util.Debris:AddItem(clone, 5)
		clone:SetPrimaryPartCFrame(hitCf)
		clone.Parent = _WorldOrigin

		for _, child in pairs(clone:GetChildren()) do
			if child.Name == "c" then
				continue
			end

			local ray2, v3, _ = Util.Ray(child.Position, child.CFrame.UpVector * -12, v)

			if ray2 then
				child.CFrame -= Vector3.new(0, math.abs(v3.Y - child.CFrame.Y), 0)
				local v4 = child
				delay(1.25 - (child.Position - clone.c.Position).Magnitude / 200, function()
					local tween = TweenService:Create(v4, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
						Transparency = 1
					})
					tween:Play()

					if #clone:GetChildren() == 1 then
						Util.Debris:AddItem(clone, 0.25)
					end

					deleteWhenTweenCompletes(tween, v4) -- equivalent call inferred; original call site unknown
				end)
			else
				child:Destroy()
			end
		end

		local clone2 = electro2Effects:WaitForChild("ElectroExplosionShock"):Clone()
		clone2.CFrame = hitCf - createVector(0, 1.5, 0)
		clone2.Size *= 7
		clone2.Parent = _WorldOrigin
		Util.Debris:AddItem(clone2, 0.175)
		spawn(function()
			repeat
				RunService.RenderStepped:Wait()
				clone2.CFrame *= CFrame.Angles(0, random:NextNumber(-3.141592653589793, 3.141592653589793), 0)
			until clone2.Parent == nil
		end)
		local clone3 = electro2Effects:WaitForChild("ElectroJumpShock"):Clone()
		clone3.CFrame = hitCf + createVector(0, 20, 0)
		clone3.Size *= 3.75
		clone3.Parent = _WorldOrigin
		task.delay(0.175, function()
			clone3:Destroy()
		end)
		spawn(function()
			repeat
				RunService.RenderStepped:Wait()
				clone3.CFrame *= CFrame.Angles(0, random:NextNumber(-3.141592653589793, 3.141592653589793), 0)
			until clone3.Parent == nil
		end)
	end

	if data.Arg == "ZigZag" then
		if (data.TrailRef.Position - workspace.CurrentCamera.CFrame.p).Magnitude > DISTANCE_THRESHOLD then
			return
		end

		ZigZag()
	elseif data.Arg == "ElectroJump" then
		if (data.jumpRef.Position - workspace.CurrentCamera.CFrame.p).Magnitude > DISTANCE_THRESHOLD then
			return
		end

		electroJump()
	elseif data.Arg == "afterBurst" then
		if (data.TrailRef.Position - workspace.CurrentCamera.CFrame.p).Magnitude > DISTANCE_THRESHOLD then
			return
		end

		afterBurst()
	elseif data.Arg == "Strike" then
		Strike()
	elseif data.Arg == "Explode" then
		if (data.explosionRef.Position - workspace.CurrentCamera.CFrame.p).Magnitude > DISTANCE_THRESHOLD then
			return
		else
			Explode()
		end
	end
end