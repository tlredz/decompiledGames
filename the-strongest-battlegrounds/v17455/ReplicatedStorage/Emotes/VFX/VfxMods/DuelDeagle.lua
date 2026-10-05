local createVector = vector.create
local DuelDeagle = {}
local libraryNew = require(script.Parent.libraryNew)
local library = require(script.Parent.library)
local playAttachment = libraryNew.PlayAttachment
local maid = libraryNew.Maid
local playTween = libraryNew.PlayTween
local _ = libraryNew.CamShake
local _ = libraryNew.PlayFlipBook
local _ = libraryNew.dtwait
local EFP = libraryNew.EFP
local _ = libraryNew.PlayMesh
local _ = libraryNew.Impact
local _ = libraryNew.GlassLight
local _ = libraryNew.RaiseZIndex
local able = libraryNew.Able
local lifeScale = libraryNew.LifeScale
local quickFX = libraryNew.QuickFX
local _ = libraryNew.QuickWeld
local _ = libraryNew.Yield
local _ = libraryNew.ProcessPart
local _ = libraryNew.WeldObject
local _ = libraryNew.Bezier
local _ = libraryNew.EditableMeshShader
local meshEmit = libraryNew.MeshEmit
local vfx = script.vfx
local class = {}
class.__index = class
local random = Random.new()
local TweenService = game:GetService("TweenService")
game:GetService("PhysicsService")
local _ = game.Workspace.Camera

local function SideRocks(data)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.FilterDescendantsInstances = { game.Workspace.Map }
	local angle = data.Angle or 0
	local cframe = data.Anchor * CFrame.Angles(0, math.rad(angle), 0)
	local between = data.Between or 12
	local distance = data.Distance or 8
	local sideInc = data.SideInc or 0
	local inc = data.Inc or 1
	local angle2 = data.Angle or -13.5
	local angleRandomizer = data.AngleRandomizer or 2.5
	local scale = data.Scale or 1
	local itterateInc = data.ItterateInc or 2
	local time = data.Time or 0.3
	local _ = {
		Square = createVector(2, 2, 2),
		New = Vector3.new(Random.new():NextNumber(2, 3.75), 2, 2),
		Rect = Vector3.new(
			Random.new():NextNumber(1.8, 3),
			Random.new():NextNumber(2, 3),
			Random.new():NextNumber(2, 3)
		),
		Rect2 = Vector3.new(
			Random.new():NextNumber(3, 4.7),
			Random.new():NextNumber(1.5, 3),
			Random.new():NextNumber(1.1, 2.7)
		)
	}

	local function Eval2(list)
		if typeof(list) == "table" then
			list = Random.new():NextNumber(list[1], list[2])
		end

		return list
	end

	local function EvalSize(p)
		local v = {
			Square = createVector(2, 2, 2),
			New = Vector3.new(Random.new():NextNumber(2, 3.75), 2, 2),
			Rect = Vector3.new(
				Random.new():NextNumber(1.8, 3),
				Random.new():NextNumber(2, 3),
				Random.new():NextNumber(2, 3)
			)
		}
		local shape = p.Shape or "Random"
		local scale2 = p.Scale or { 1, 1.5 }
		local v2 = v[shape]

		if not v2 and shape == "Random" then
			local count = 0
			local count2 = 0

			for _, _ in pairs(v) do
				count += 1
			end

			local v3 = math.random(1, count)

			for k, v5 in pairs(v) do
				count2 += 1

				if count2 ~= v3 then
					continue
				end

				shape = k
				v2 = v5
				break
			end
		end

		if typeof(scale2) == "table" then
			scale2 = Random.new():NextNumber(scale2[1], scale2[2])
		end

		return v2 * scale2, shape
	end

	local v = {}
	local v2 = {}

	for i = 1, 2 do
		local cframe2 = cframe * CFrame.new(i == 1 and between or between * -1, 0, 0)
		local scale2 = scale
		local v4 = nil

		for i2 = 1, distance do
			for i3 = 1, math.clamp(math.floor(i2 / itterateInc), 1, 2) do
				local v5 = i3 == 1 and 1 or i3 * 5
				local v6 = sideInc * i2 * (i == 1 and 1 or -1) * v5
				local size = v[i2]
				local size2

				if size then
					size2 = size
				else
					size2 = EvalSize({
						Scale = scale2
					})
					v[i2] = size2
				end

				local v9

				if v4 then
					local CF = v4:GetAttribute("CF")
					local orientation, v10, v11 = cframe2:ToOrientation()
					local objectSpace = CF:ToObjectSpace(cframe)
					local _ = v4:GetAttribute("Side") + between
					v9 = CFrame.new((Vector3.new(CF.Position.X, cframe.Y, CF.Position.Z))) * CFrame.Angles(
						orientation,
						v10,
						v11
					) * CFrame.new(
						objectSpace.X + (i == 1 and between or -between) * 0.5 + v6,
						0,
						(size2.Z * 1 - (size2.Z - v4.Size.Z) * 0.5) * -1
					)
				else
					v9 = cframe2 * CFrame.new(v6, 0, -i2 * inc - size2.X * 0.5 - (not v4 and 0 or v4.Size.X * 1 or 0))
				end

				local raycastResult = game.Workspace:Raycast(
					v9.Position + createVector(0, 1, 0),
					createVector(0, -15, 0),
					raycastParams
				)

				if not raycastResult then
					continue
				end

				local part = Instance.new("Part")
				part.Anchored = true

				if size then
					part.Size = size
				else
					part.Size = size2
				end

				part.TopSurface = Enum.SurfaceType.Smooth
				part.Material = raycastResult.Material
				part.Color = raycastResult.Instance.Color

				if raycastResult.Instance:FindFirstChild("Texture") then
					for _, texture in pairs(raycastResult.Instance:GetChildren()) do
						if not texture:IsA("Texture") then
							continue
						end

						local clone = texture:Clone()
						clone.Parent = part
					end
				end

				part.CanCollide = false
				local _, v10, _ = cframe:ToOrientation()
				local v11 = random:NextNumber(-angleRandomizer * scale2, angleRandomizer * scale2) * (i == 1 and -1 or 1)
				part.CFrame = CFrame.new(v9.X, raycastResult.Position.Y, v9.Z) * CFrame.Angles(0, v10, 0) * CFrame.Angles(
					0,
					0,
					math.rad(angle2) * (i == 1 and -1 or 1) + math.rad(v11)
				)
				local cFrame = part.CFrame * CFrame.new(
					0,
					random:NextNumber(-part.Size.Y * 0.35, -part.Size.Y * 0.5),
					0
				)
				part.CFrame = cFrame * CFrame.new(0, -part.Size.Y * 1, 0)
				part:SetAttribute("CF", cFrame)
				part:SetAttribute("Side", v6)
				local part2 = Instance.new("Part")
				part2.Size = part.Size * 1.01
				local weld = Instance.new("Weld")
				weld.Part0 = part2
				weld.Part1 = part
				weld.Parent = part2
				part2.Material = Enum.Material.Neon
				part2.Color = Color3.new(1, 0.368627, 0.0784314)
				part2.Parent = EFP
				game.Debris:AddItem(part2, 3)
				TweenService:Create(part2, TweenInfo.new(random:NextNumber(2, 3), Enum.EasingStyle.Sine), {
					Transparency = 1
				}):Play()
				task.delay(i3 * 0.03, function()
					TweenService:Create(
						part,
						TweenInfo.new(random:NextNumber(0.175, 0.125), Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
						{
							CFrame = cFrame
						}
					):Play()
				end)
				part.Parent = EFP
				game.Debris:AddItem(part, 15)
				table.insert(v2, part)

				if i3 ~= 1 then
					continue
				end

				scale2 = math.clamp(scale2 + 0.4, 0, 4)
				v4 = part
			end
		end
	end

	task.delay(time, function()
		for _, v3 in pairs(v2) do
			local v4 = v3
			task.delay(random:NextNumber(0, 2), function()
				TweenService:Create(v4, TweenInfo.new(2, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {
					Position = Vector3.new(v4.Position.X, -v4.Size.Y, v4.Position.Z)
				}):Play()
			end)
		end
	end)
end

function DuelDeagle.FirstEvent(p)
	local data = p.Data
	local char = data.Char
	local humanoidRootPart = char.HumanoidRootPart
	local _ = char.Humanoid
	local _ = data.Victim
	local bind = data.Bind
	local object = setmetatable({}, class)
	object._maid = maid.new()
	local v = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v then
			v = true
			object._maid:doCleaning()
		end
	end

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function FirstEvent()
		local parent = object._maid:give(Instance.new("Attachment"))
		parent.CFrame = CFrame.new(0, 0, -3)
		parent.Parent = humanoidRootPart
		local v3 = object._maid:give(Instance.new("PointLight"))
		v3.Color = Color3.fromRGB(255, 136, 0)
		v3.Brightness = 0
		v3.Range = 0
		v3.Parent = parent
		local v4 = {}

		for _, childName in pairs({ "Deagle", "Deagle2" }) do
			local child = char:FindFirstChild(childName)

			if not child then
				continue
			end

			local parent2 = object._maid:give(Instance.new("Model"))
			parent2.Parent = EFP
			local v6 = object._maid:give(Instance.new("NumberValue"))
			object._maid:give(v6.Changed:Connect(function()
				parent2:ScaleTo(v6.Value)
			end))
			local v9 = object._maid:give(Instance.new("Part"))
			v9.Transparency = 1
			v9.Size = createVector(0.5, 0.5, 0.5)
			v9.CanCollide = false
			v9.Massless = true
			local weld = Instance.new("Weld")
			weld.Part0 = v9
			weld.Part1 = child:FindFirstChild("Weapon") or child:FindFirstChild("Weapon2")
			weld.Parent = v9
			weld.C0 = CFrame.new(0.021, -0.37, -1.076)
			v9.Parent = parent2
			local highlight = Instance.new("Highlight")
			highlight.FillTransparency = 0
			highlight.Parent = v9
			local v10 = {}
			local v11 = object._maid:give(script["2"]:Clone())
			v11.Parent = v9
			local v12 = object._maid:give(script["22"]:Clone())
			v12.Parent = v9
			v6.Value = 0.1
			TweenService:Create(v6, TweenInfo.new(1, Enum.EasingStyle.Sine), {
				Value = 1
			}):Play()
			table.insert(v4, parent)
			table.insert(v4, v12)
			table.insert(v10, v11)
			table.insert(v10, v12)
			table.insert(v4, parent2)

			for _, folder in pairs(v10) do
				for _, emitter in pairs(folder:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						TweenService:Create(emitter, TweenInfo.new(1.7, Enum.EasingStyle.Sine), {
							TimeScale = 0.01
						}):Play()
					end
				end
			end
		end

		TweenService:Create(v3, TweenInfo.new(3), {
			Brightness = 10
		}):Play()
		TweenService:Create(v3, TweenInfo.new(3), {
			Range = 10
		}):Play()

		for _, FX in pairs(v4) do
			able({
				FX = FX,
				On = true
			})
		end

		bind.Destroying:Wait()
		TweenService:Create(v3, TweenInfo.new(0.3), {
			Brightness = 0
		}):Play()
		TweenService:Create(v3, TweenInfo.new(0.3), {
			Range = 0
		}):Play()
		game.Debris:AddItem(v3, 0.5)

		for _, v5 in pairs(v4) do
			v5:Destroy()
		end
	end

	task.spawn(FirstEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function DuelDeagle.ShootEvent(p)
	local data = p.Data
	local char = data.Char
	local humanoidRootPart = char.HumanoidRootPart
	local _ = char.Humanoid
	local _ = data.Victim
	local maxCharge = data.MaxCharge
	local isCounter = data.IsCounter
	local anchor = data.Anchor
	local object = setmetatable({}, class)
	object._maid = maid.new()
	local v = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v then
			v = true
			object._maid:doCleaning()
		end
	end

	task.delay(25, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function ShootEvent()
		local scale = maxCharge
		local v3

		if isCounter then
			v3 = 0.5
			scale = 0.5
		else
			v3 = math.clamp(maxCharge * 0.9, 1, 1.8)
		end

		local cFrame = humanoidRootPart.CFrame

		if anchor then
			cFrame = anchor
		end

		local folder

		if isCounter then
			folder = quickFX({
				FX = vfx.MiniShoot,
				Maid = object._maid,
				Anchor = cFrame * CFrame.new(0, 4, -5) * CFrame.Angles(-1.5707963267948966, 0, 0)
			})
		else
			folder = quickFX({
				FX = vfx.Shoot,
				Maid = object._maid,
				Anchor = cFrame * CFrame.new(0, 4, -5) * CFrame.Angles(-1.5707963267948966, 0, 0)
			})
		end

		folder:ScaleTo(v3)
		playAttachment(folder, nil, {
			MeshIgnore = true
		})

		if not shared.ismobile then
			meshEmit.Emit(folder)
		end

		for _, objectValue in pairs(folder:GetDescendants()) do
			if not objectValue:IsA("ObjectValue") then
				continue
			end

			local maxSize = objectValue:GetAttribute("MaxSize")

			if maxSize then
				objectValue:SetAttribute("MaxSize", NumberRange.new(maxSize.Min * v3, maxSize.Max * v3))
			end

			objectValue:GetAttribute("Speed")
		end

		if char == game.Players.LocalPlayer.Character then
			shared.repfire({
				Effect = "Camshake",
				Intensity = 15
			})
		end

		lifeScale({
			FX = folder,
			Scale = 1.5
		})
		task.wait(0.05)
		local folder2 = quickFX({
			FX = vfx.Ground,
			Maid = object._maid,
			Anchor = cFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.4, 0) * CFrame.Angles(0, 0, 0)
		})

		if scale > 1 then
			lifeScale({
				FX = folder2,
				Scale = scale * 2
			})
		end

		playAttachment(folder2, nil, {
			MeshIgnore = true
		})

		if not shared.ismobile then
			meshEmit.Emit(folder2)
		end

		if maxCharge >= 2 then
			library.LifeScale({
				FX = folder2,
				Scale = 2
			})
		end

		folder2:ScaleTo(v3)

		for _, objectValue in pairs(folder2:GetDescendants()) do
			if not objectValue:IsA("ObjectValue") then
				continue
			end

			local maxSize = objectValue:GetAttribute("MaxSize")

			if maxSize then
				objectValue:SetAttribute("MaxSize", NumberRange.new(maxSize.Min * v3, maxSize.Max * v3))
			end
		end

		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Include
		raycastParams.FilterDescendantsInstances = { game.Workspace.Map }

		if maxCharge >= 2 then
			local raycastResult = game.Workspace:Raycast(cFrame.Position, createVector(0, -10, 0), raycastParams)
			local v5 = {}

			for _ = 1, random:NextNumber(8, 12) do
				if not raycastResult then
					continue
				end

				local parent = object._maid:give(Instance.new("Part"))
				local v7 = random:NextNumber(1, 3) * v3
				parent.Size = Vector3.new(v7, v7, v7)
				parent.CollisionGroup = "nocol"
				parent.Material = raycastResult.Material
				parent.Color = raycastResult.Instance.Color
				parent:PivotTo(CFrame.new(raycastResult.Position) * CFrame.Angles(
					random:NextNumber(-5, 5),
					random:NextNumber(-5, 5),
					random:NextNumber(-5, 5)
				))
				parent.Parent = EFP
				local bodyVelocity = Instance.new("BodyVelocity")
				bodyVelocity.MaxForce = createVector(1, 1, 1) * 1e999
				bodyVelocity.Velocity = ((cFrame * CFrame.Angles(0, math.rad((random:NextNumber(-35, 35))), 0)).lookVector * -50 + Vector3.new(
					0,
					random:NextNumber(5, 10),
					0
				) * v3 * v7) * random:NextNumber(0.9, 1.3)
				bodyVelocity.Parent = parent
				game.Debris:AddItem(bodyVelocity, 0.1)
				table.insert(v5, parent)
				task.delay(random:NextNumber(0.5, 1) * v3, function()
					TweenService:Create(parent, TweenInfo.new(random:NextNumber(1, 2), Enum.EasingStyle.Sine), {
						Transparency = 1,
						Size = createVector(0, 0, 0)
					}):Play()
					game.Debris:AddItem(parent, 2)
				end)
			end
		end

		local v5 = object._maid:give(Instance.new("PointLight"))
		v5.Color = Color3.fromRGB(255, 136, 0)
		v5.Brightness = 10
		v5.Range = 35
		v5.Parent = humanoidRootPart
		TweenService:Create(v5, TweenInfo.new(0.3), {
			Brightness = 0
		}):Play()
		TweenService:Create(v5, TweenInfo.new(0.3), {
			Range = 0
		}):Play()
		game.Debris:AddItem(v5, 0.5)
		local raycastParams2 = RaycastParams.new()
		raycastParams2.FilterType = Enum.RaycastFilterType.Include
		raycastParams2.FilterDescendantsInstances = { game.Workspace.Map }
		game.Workspace:Raycast(char.Torso.CFrame.Position, createVector(0, -10, 0), raycastParams2)
		local _ = v3 > 1
		local folder3 = quickFX({
			FX = vfx.Shoot2,
			Maid = object._maid,
			Anchor = cFrame * CFrame.new(0, 0, -5)
		})

		if scale > 1 then
			lifeScale({
				FX = folder3,
				Scale = scale
			})
		end

		for _, objectValue in pairs(folder3:GetDescendants()) do
			if not objectValue:IsA("ObjectValue") then
				continue
			end

			local maxSize = objectValue:GetAttribute("MaxSize")

			if maxSize then
				objectValue:SetAttribute("MaxSize", NumberRange.new(maxSize.Min * v3, maxSize.Max * v3))
			end
		end

		for _, objectValue in pairs(folder3:GetDescendants()) do
			if not objectValue:IsA("ObjectValue") then
				continue
			end

			local speed = objectValue:GetAttribute("Speed")
			local v6 = not (scale > 1) and 1 or scale * 0.45 or 1

			if scale > 1 and speed then
				objectValue:SetAttribute("Speed", NumberRange.new(speed.Min / v6, speed.Max / v6))
			end
		end

		if maxCharge >= 2 then
			library.LifeScale({
				FX = folder3,
				Scale = 2
			})
		end

		playAttachment(folder3, nil, {
			MeshIgnore = true
		})

		if not shared.ismobile then
			meshEmit.Emit(folder3)
		end

		if not isCounter then
			SideRocks({
				Anchor = cFrame
			})
		end

		local folder4 = object._maid:give(vfx.WindBeamsGround:Clone())
		folder4:ScaleTo(0.6)
		folder4:PivotTo(cFrame * CFrame.new(0, 0, -5))
		folder4.Parent = EFP

		for _, beam in pairs(folder4:GetDescendants()) do
			if not beam:IsA("Beam") then
				continue
			end

			TweenService:Create(beam, TweenInfo.new(1, Enum.EasingStyle.Sine), {
				TextureSpeed = 0.5
			}):Play()
			playTween(beam, {
				Time = 2,
				Goal = {
					Transparency = NumberSequence.new(1)
				}
			})
			game.Debris:AddItem(beam, 2)
		end
	end

	task.spawn(ShootEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

return DuelDeagle