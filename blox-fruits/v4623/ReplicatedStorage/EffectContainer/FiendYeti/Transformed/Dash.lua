local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ContentProvider = game:GetService("ContentProvider")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local TweenService = game:GetService("TweenService")
game:GetService("RunService")

local function preloadRetextureImages(folder)
	if not RunService:IsClient() then
		return
	end

	local v = {}
	local v2 = {}

	for _, configuration in folder:GetDescendants() do
		if not (configuration:IsA("Configuration") and configuration.Name == "RetextureForRecolor") then
			continue
		end

		local decal = configuration:FindFirstChildWhichIsA("Decal")
		local texture = decal and decal.Texture

		if not texture or texture == "" or v[texture] then
			continue
		end

		v[texture] = true
		local imageLabel = Instance.new("ImageLabel")
		imageLabel.Image = texture
		table.insert(v2, imageLabel)
	end

	if #v2 > 0 then
		local success, result = pcall(function()
			ContentProvider:PreloadAsync(v2)
		end)

		for _, v3 in v2 do
			v3:Destroy()
		end

		if not success then
			warn("Failed to preload recolor textures:", result)
		end
	end
end

preloadRetextureImages(script.Parent.M1GroundSlamFelku)

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local FX = require(ReplicatedStorage.FX)
local geppoDash = FX:WaitForChild("YetiEffectsRed").GeppoDash

local function emitAll(folder, p)
	for _, effect in folder:GetDescendants() do
		if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam")) then
			continue
		end

		if effect:IsA("Beam") then
			local emitDelay = effect:GetAttribute("EmitDelay")
			local v = effect:GetAttribute("EmitDuration")
			local v2 = effect
			task.delay(tonumber(emitDelay) or 0, function()
				if tonumber(v) and v ~= 0 then
					v2.Enabled = true

					if not v2:GetAttribute("pr3") then
						v2:SetAttribute("pr3", 0)
					end

					local v3 = (v2:GetAttribute("pr3") + 1) % 1000
					v2:SetAttribute("pr3", v3)
					task.wait(v)

					if v3 == v2:GetAttribute("pr3") then
						v2.Enabled = false
					end
				end
			end)
		elseif not p or effect.Parent.Name ~= "Front" then
			local emitCount = effect:GetAttribute("EmitCount")
			local emitDelay = effect:GetAttribute("EmitDelay")
			local v = effect
			local v3 = effect:GetAttribute("EmitDuration")
			task.delay(tonumber(emitDelay) or 0, function()
				v:Emit(emitCount or 0)

				if tonumber(v3) and v3 ~= 0 then
					v.Enabled = true

					if not v:GetAttribute("pr3") then
						v:SetAttribute("pr3", 0)
					end

					local v4 = (v:GetAttribute("pr3") + 1) % 1000
					v:SetAttribute("pr3", v4)
					task.wait(v3)

					if v4 == v:GetAttribute("pr3") then
						v.Enabled = false
					end
				end
			end)
		end
	end
end

local v = {}
local ObjectCache = require(script:WaitForChild("ObjectCache"))
local Players = game:GetService("Players")
Players.PlayerRemoving:Connect(function(player)
	local v2 = v[player]

	if v2 then
		v[player] = nil
		v2:Destroy()
	end
end)
return function(data)
	local player = data.player or game.Players:GetPlayerFromCharacter(data.Root.Parent)

	if typeof(player) ~= "Instance" and type(player) == "table" then
		local character = player.Character

		if typeof(character) == "Instance" and character:IsA("Model") then
			player = game.Players:GetPlayerFromCharacter(character) or player
		end
	end

	local root = data.Root
	local folder = Instance.new("Folder")
	Util.SetParentOverrideWithColor(folder, _WorldOrigin, player, "YetiFruitVFXColor")
	Util.Debris:AddItem(folder, 3)

	if data.Stage == 1 then
		Util.Sound:Play("YETI_TNSFM_Jump_01", root)
		local clone = geppoDash.gepporing.ring1_1:Clone()
		local clone2 = geppoDash.gepporing.ring1_2:Clone()
		clone.CFrame = root.CFrame * CFrame.new(0, -8, 0) * CFrame.Angles(0, -1.5707963267948966, 0)
		clone2.CFrame = root.CFrame * CFrame.new(0, -8, 0) * CFrame.Angles(0, 1.5707963267948966, 3.141592653589793)
		Util.SetParentOverrideWithColor(clone, folder, player, "YetiFruitVFXColor")
		Util.SetParentOverrideWithColor(clone2, folder, player, "YetiFruitVFXColor")
		Util.Debris:AddItem(clone, 2)
		Util.Debris:AddItem(clone2, 2)
		TweenService:Create(clone, TweenInfo.new(0.35, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut), {
			CFrame = root.CFrame * CFrame.new(0, -17, 0)
		}):Play()
		TweenService:Create(clone2, TweenInfo.new(0.35, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut), {
			CFrame = root.CFrame * CFrame.new(0, -17, 0)
		}):Play()
		TweenService:Create(clone.ring1_1, TweenInfo.new(0.35, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut), {
			Scale = createVector(-12.612, 0, -12.612)
		}):Play()
		TweenService:Create(clone2.ring1_2, TweenInfo.new(0.35, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut), {
			Scale = createVector(12.612, 0, 12.612)
		}):Play()
		TweenService:Create(clone.Decal1_2, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
			Transparency = 1
		}):Play()
		TweenService:Create(clone2.Decal1_2, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
			Transparency = 1
		}):Play()
		local clone3 = geppoDash.pregeppo:Clone()
		clone3.CFrame = root.CFrame * CFrame.new(0, -5.5, 0)
		Util.SetParentOverrideWithColor(clone3, folder, player, "YetiFruitVFXColor")
		emitAll(clone3)
		Util.Debris:AddItem(clone3, 0.5)
		task.wait(-0.012999999999999984)
		local clone4 = geppoDash.geppoemit:Clone()
		clone4.CFrame = root.CFrame * CFrame.new(0, -8.75, 0)
		Util.SetParentOverrideWithColor(clone4, folder, player, "YetiFruitVFXColor")
		emitAll(clone4)
		Util.Debris:AddItem(clone4, 1)
	elseif data.Stage == 2 then
		if not data.DemonOgreHeldVariant then
			Util.Sound:Play("YETI_TNSFM_Dash_01", root)
		end

		local part = Instance.new("Part")
		part.Size = createVector(2, 2, 1)
		part.CFrame = data.Direction == createVector(0, 0, 0) and root.CFrame or CFrame.new(
			root.Position,
			root.Position + data.Direction
		)
		part.Transparency = 1
		part.Anchored = true
		part.CanCollide = false
		Util.SetParentOverrideWithColor(part, folder, player, "YetiFruitVFXColor")
		local yetiRig = root.Parent.YetiRig.YetiRig

		if data.DemonOgreHeldVariant == true and yetiRig then
			local heartbeatLoopFor = Util.HeartbeatLoopFor.HeartbeatLoopFor
			Util.Sound:Play("AkumaYeti_SuperDash_Dash_0" .. tostring(math.random(1, 3)), root)

			-- equivalent calls inferred from this helper; original call sites unknown
			local function makeFollowingAfterImage(p: number, p2)
				task.spawn(function()
					local v2 = player or data.Root.Parent
					local v3 = v[v2]

					if v3 and v3._AfterImageSourceRig ~= yetiRig then
						v[v2] = nil
						v3:Destroy()
					end

					if v[v2] == nil then
						local clone = yetiRig:Clone()
						clone:FindFirstChildOfClass("AnimationController").Animator:Destroy()

						for _, descendant in ipairs(clone:GetDescendants()) do
							if descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("Trail") or descendant:IsA("Sound") or descendant:IsA("Folder") then
								descendant:Destroy()
							elseif descendant:IsA("Part") and descendant:FindFirstChildOfClass("Bone") == nil then
								descendant:Destroy()
							elseif descendant:IsA("BasePart") then
								descendant.Anchored = true
								descendant.CanCollide = false
								descendant.CanTouch = false
								descendant.CanQuery = false
								descendant.CastShadow = false
							end
						end

						local v4 = ObjectCache.new(clone, 1, workspace._WorldOrigin)
						v4._AfterImageSourceRig = yetiRig
						v[v2] = v4
					end

					local v4 = v[v2]
					local v5 = root
					local unit = data.Direction.Magnitude > 0 and data.Direction.Unit or v5.CFrame.LookVector
					local part2 = v4:GetPart(CFrame.lookAt(v5.Position, v5.Position + unit))
					task.delay(4, function()
						v4:ReturnPart(part2)
					end)
					local transformsByName = {}

					for _, bone in ipairs(yetiRig:GetDescendants()) do
						if bone:IsA("Bone") then
							transformsByName[bone.Name] = bone.Transform
						end
					end

					local descendants = {}

					for _, descendant in ipairs(part2:GetDescendants()) do
						if descendant:IsA("BasePart") then
							table.insert(descendants, descendant)
						elseif descendant:IsA("Bone") then
							local transform = transformsByName[descendant.Name]

							if transform then
								descendant.Transform = transform
							end
						end
					end

					for _, v6 in ipairs(descendants) do
						v6.Transparency = 0
					end

					game:GetService("RunService")
					local v6 = {}

					local function pushHistory(position: Vector3)
						local count = #v6

						if count == 0 then
							v6[1] = position
							return
						end

						if (position - v6[count]).Magnitude >= 0.1 then
							v6[count + 1] = position
							count += 1
						end

						if count > 720 then
							local v7 = count - 720

							for i = 1, count - v7 do
								v6[i] = v6[i + v7]
							end

							for i = count - v7 + 1, count do
								v6[i] = nil
							end
						end
					end

					local function getPointBackAlongHistory(list, p3: number, unit2: Vector3)
						local count = #list

						if count == 0 then
							return createVector(0, 0, 0), unit2
						elseif count == 1 then
							return list[1] - unit2.Unit * p3, unit2.Unit
						end

						local v7 = math.max(p3, 0)

						for i = count, 2, -1 do
							local v8 = list[i]
							local v9 = list[i - 1] - v8
							local magnitude = v9.Magnitude

							if not (magnitude > 1e-6) then
								continue
							end

							if v7 <= magnitude then
								local v10 = v9 / magnitude
								return v8 + v10 * v7, -v10
							else
								v7 -= magnitude
							end
						end

						local v8 = list[1]
						local unit3 = unit2.Magnitude > 0 and unit2.Unit or createVector(0, 0, 1)
						return v8 - unit3 * v7, unit3
					end

					for _, v7 in ipairs(descendants) do
						v7.Transparency = math.clamp(0.3 + (p - 1) * 0.8 / (p2 - 1), 0, 0.8)
					end

					heartbeatLoopFor(0.5, function(_, _, p3)
						if root then
							pushHistory(root.Position)
						end

						local v7 = math.sin(p3 * 3.141592653589793)
						local v8 = (p - 1) * 0.35 + 1
						local pointBackAlongHistory, v10 = getPointBackAlongHistory(v6, p * 12 * v8 * v7, unit)
						local v11 = pointBackAlongHistory - createVector(0, 5, 0)
						local unit2 = v10.Magnitude > 0 and v10.Unit or unit
						part2:PivotTo(CFrame.lookAt(v11, v11 + unit2))
					end, function()
						for _, v7 in ipairs(descendants) do
							v7.Transparency = 1
						end
					end)
				end)
			end

			task.spawn(function()
				makeFollowingAfterImage(1, 4) -- equivalent call inferred; original call site unknown
				makeFollowingAfterImage(2, 4) -- equivalent call inferred; original call site unknown
				makeFollowingAfterImage(3, 4) -- equivalent call inferred; original call site unknown
				makeFollowingAfterImage(4, 4) -- equivalent call inferred; original call site unknown
			end)

			-- equivalent calls inferred from this helper; original call sites unknown
			local function PlayFlipbook(part2)
				task.spawn(function()
					if not part2 then
						return
					end

					local folder2 = part2:FindFirstChildOfClass("Folder")
					local decal = part2:FindFirstChildOfClass("Decal")

					if not (folder2 and decal) then
						return
					end

					local texturesByName = {}
					local v2 = 0

					for _, decal2 in ipairs(folder2:GetChildren()) do
						if not decal2:IsA("Decal") then
							continue
						end

						local name = tonumber(decal2.Name)

						if not name then
							continue
						end

						texturesByName[name] = decal2.Texture

						if v2 < name then
							v2 = name
						end
					end

					if v2 == 0 then
						return
					end

					part2:SetAttribute("PlayFlipbook", true)
					local v3 = 1

					while part2 and part2:IsDescendantOf(workspace) and part2:GetAttribute("PlayFlipbook") == true do
						task.wait(0.016666666666666666)
						local texture = texturesByName[v3]

						if texture then
							decal.Texture = texture
						end

						v3 = v3 % v2 + 1
					end
				end)
			end

			local clone = script.Parent.M1GroundSlamFelku.SpiralBeams2:Clone()
			clone:ScaleTo(0.3)
			Util.SetParentOverrideWithColor(clone, workspace._WorldOrigin, player, "YetiFruitVFXColor")
			task.delay(4, function()
				if clone and clone.Parent then
					clone:Destroy()
				end
			end)

			for _, child in ipairs(clone:GetChildren()) do
				if child.Name ~= "Paraboloid" then
					continue
				end

				PlayFlipbook(child.Part) -- equivalent call inferred; original call site unknown
			end

			heartbeatLoopFor(0.5, function(_, _, _)
				local unit = (root.AssemblyLinearVelocity * createVector(1, 0, 1)).Magnitude > 0.001 and (root.AssemblyLinearVelocity * createVector(
					1,
					0,
					1
				)).Unit or (root.CFrame.LookVector * createVector(1, 0, 1)).Unit
				clone:PivotTo(CFrame.lookAt(createVector(0, 0, 0), unit) * CFrame.lookAt(
					createVector(0, 0, 0),
					createVector(-0, -1, -0)
				):Inverse() + root.Position + unit * 14)
			end, function()
				if clone and clone.Parent then
					clone:Destroy()
				end
			end)
		end

		if data.Direction:Dot(root.CFrame.LookVector) > 0.75 then
			local yetiRig2 = root.Parent.YetiRig.YetiRig
			emitAll(yetiRig2.DashSmoke)
			emitAll(
				yetiRig2.DashParticle.Front1.WindDashFront,
				root.Parent == game.Players.LocalPlayer.Character and (workspace.CurrentCamera.CFrame.p - yetiRig2.DashParticle.Front1.WindDashFront.WorldPosition).Magnitude < 120
			)

			for _, descendant in pairs(yetiRig2:GetDescendants()) do
				if descendant.Name == "DashBAMP_FrontDash" then
					descendant:Emit(18)
				end
			end
		else
			local clone = geppoDash.dash.DASH:Clone()
			Util.SetParentOverrideWithColor(clone, part, player, "YetiFruitVFXColor")
			emitAll(clone)
		end
	end
end