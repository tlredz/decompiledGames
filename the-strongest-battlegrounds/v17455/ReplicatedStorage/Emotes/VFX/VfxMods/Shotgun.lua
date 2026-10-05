local createVector = vector.create
local Shotgun = {}
local libraryNew = require(script.Parent.libraryNew)
local playAttachment = libraryNew.PlayAttachment
local maid = libraryNew.Maid
local _ = libraryNew.PlayTween
local _ = libraryNew.CamShake
local _ = libraryNew.PlayFlipBook
local dtwait = libraryNew.dtwait
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
local _ = libraryNew.Shake
local Libraryyyy2 = require(game.ReplicatedStorage.Resources.Libraryyyy2)
local vfx = script.vfx
local class = {}
class.__index = class
local random = Random.new()
local TweenService = game:GetService("TweenService")
game:GetService("PhysicsService")
local _ = game.Workspace.Camera
local ShotgunAdditions = require(script.Parent.ShotgunAdditions)

function Shotgun.FirstEvent(p)
	local data = p.Data
	local char = data.Char
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

	task.delay(3, Clean)
	task.spawn(function()
		ShotgunAdditions(char, data.quickfire)
	end)
	wait(3)
	Clean() -- equivalent call inferred; original call site unknown
end

function Shotgun.ChargeEvent(p)
	local data = p.Data
	local char = data.Char
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

	task.delay(5, Clean)
	local v2 = nil

	if not data.quickfire then
		local playingAnimationTracks = char.Humanoid:GetPlayingAnimationTracks()

		for i = 1, #playingAnimationTracks do
			if playingAnimationTracks[i].Animation.AnimationId ~= "rbxassetid://113371045983638" then
				continue
			end

			v2 = playingAnimationTracks[i]
			break
		end

		local v3 = false

		-- equivalent calls inferred from this helper; original call sites unknown
		local function check()
			if v3 or not v2 or v2 and not v2.IsPlaying then
				v3 = true
				return true
			else
				return false
			end
		end

		-- equivalent call inferred; original call site unknown
		if check() then
			return
		end
	end

	task.spawn(function()
		local FX = object._maid:give(script.Enabled:Clone())
		FX.Parent = char.Shotgun.Handle
		able({
			FX = FX,
			On = true
		})

		if not data.quickfire and v2 then
			v2.Stopped:Once(function()
				able({
					FX = FX,
					On = false
				})
			end)
		end

		task.wait(0.3)
		able({
			FX = FX,
			On = false
		})
	end)
	wait(3)
	Clean() -- equivalent call inferred; original call site unknown
end

function Shotgun.ShootEvent(p)
	local char = p.Data.Char
	local humanoidRootPart = char.HumanoidRootPart
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

	task.delay(5, Clean)
	task.spawn(function()
		local TweenService2 = game:GetService("TweenService")
		local cFrame = humanoidRootPart.CFrame
		local position = (cFrame * CFrame.new(0, 0.5, 0)).Position
		local lookVector = cFrame.LookVector
		local v2 = quickFX({
			FX = vfx.Shoot,
			Maid = object._maid,
			Anchor = cFrame * CFrame.new(0, 0, -4)
		})
		playAttachment(v2)
		game.Debris:AddItem(v2, 5)
		local children = { workspace.Map }

		for _, child in ipairs(workspace.Live:GetChildren()) do
			if child ~= char then
				children[#children + 1] = child
			end
		end

		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Include
		raycastParams.IgnoreWater = true
		raycastParams.FilterDescendantsInstances = children
		local v3 = shared.OnScreen(humanoidRootPart.Position)

		local function FireShotgun(position2, lookVector2, p2, p3)
			local number = random:NextNumber(20, 30)
			local unit = lookVector2.Unit
			local v4 = math.rad(p3)
			local v5 = v4 / 2
			local cframe = CFrame.lookAt(createVector(0, 0, 0), unit)
			local v6 = 4

			for i = 1, p2 do
				local v7 = math.random() * v4 - v5
				local v8 = math.random() * v4 - v5
				local lookVector3 = (cframe * CFrame.Angles(v8, v7, 0)).LookVector
				local raycastResult = workspace:Raycast(position2, lookVector3 * number, raycastParams)
				local position3 = position2 + lookVector3 * number

				if raycastResult then
					position3 = raycastResult.Position or position3
				end

				local magnitude = (position3 - position2).Magnitude

				if magnitude < 0.05 or not v3 then
					continue
				end

				local part = Instance.new("Part")
				part.Anchored = true
				part.CanCollide = false
				part.CanQuery = false
				part.CanTouch = false
				part.CastShadow = false
				part.Material = Enum.Material.Neon
				part.Color = Color3.fromRGB(255, 220, 150)
				part.Size = Vector3.new(0.9, 0.9, magnitude)
				part.Parent = workspace.Thrown
				game.Debris:AddItem(part, 1)
				local lerped = position2:Lerp(position3, 0.5)
				part.CFrame = CFrame.lookAt(lerped, position3)

				if raycastResult and v6 > 0 then
					local instance = raycastResult.Instance

					if not instance:IsDescendantOf(workspace.Live) then
						local normal = raycastResult.Normal

						if math.abs(normal.Y) < 0.1 then
							v6 -= 1
							local position4 = raycastResult.Position
							local FX = object._maid:give(vfx.BulletHitFX:Clone())
							FX.Parent = workspace.Thrown
							FX:PivotTo(CFrame.new(position4, position4 + normal))
							lifeScale({
								FX = FX,
								Scale = random:NextNumber(0.3, 3)
							})
							game.Debris:AddItem(FX, 5)
							Libraryyyy2.MeshEmit:GroupEmit(script.Meshes.BulletHit, FX.CFrame)
							Libraryyyy2.Particles:Emit(FX)
							local v10 = object._maid:give(Instance.new("Part"))
							v10.Size = createVector(0.1, 0.1, 0.1)
							v10.Anchored = true
							v10.CanCollide = false
							v10.Transparency = 1
							v10.CastShadow = false
							v10.CFrame = CFrame.new(position4 + normal, normal) * CFrame.new(0, -1, 0)
							v10.Parent = workspace.Thrown
							shared.repfire({
								Effect = "Ground Crater",
								Seed = math.random(1, 2000000000),
								start = v10.Position,
								["end"] = v10.CFrame.lookVector * -10,
								amount = 2,
								nosound = true,
								nodebris = true,
								nosmoke = true,
								size = random:NextNumber(0.03, 0.05),
								sizemult = 0.15
							})
							local v11 = object._maid:give(Instance.new("Part"))
							local number2 = random:NextNumber(0.3, 0.6)
							v11.Size = Vector3.new(number2, number2, number2)
							v11.CFrame = CFrame.new(v10.Position) * CFrame.Angles(
								random:NextNumber(-4, 4),
								random:NextNumber(-4, 4),
								random:NextNumber(-4, 4)
							)
							v11.Material = instance.Material
							v11.Color = instance.Color
							v11.CastShadow = false
							v11.Parent = EFP
							v11:ApplyImpulse((humanoidRootPart.Position - v10.Position).Unit * random:NextNumber(20, 40) * v11:GetMass() + Vector3.new(
								0,
								random:NextNumber(3, 9),
								0
							))
							game.Debris:AddItem(v11, 3)
							task.delay(random:NextNumber(1, 1.5), function()
								if v11 and v11.Parent then
									TweenService:Create(
										v11,
										TweenInfo.new(random:NextNumber(1, 2), Enum.EasingStyle.Sine),
										{
											Size = createVector(0, 0, 0)
										}
									):Play()
									game.Debris:AddItem(v11, 2)
								end
							end)
						end
					end
				end

				local v9 = position3 - lookVector3 * 0.5
				local tween = TweenService2:Create(
					part,
					TweenInfo.new(random:NextNumber(0.15, 0.3), Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Size = createVector(0.05, 0.05, 1),
						CFrame = CFrame.lookAt(v9, position3),
						Transparency = 1
					}
				)
				tween:Play()
				tween.Completed:Once(function()
					if part then
						part:Destroy()
					end
				end)

				if i % 2 == 0 then
					dtwait(0.01)
				end
			end
		end

		FireShotgun(position, lookVector, 15, 25)
	end)
	wait(3)
	Clean() -- equivalent call inferred; original call site unknown
end

return Shotgun