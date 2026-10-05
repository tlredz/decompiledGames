local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local TweenService = game:GetService("TweenService")
game:GetService("RunService")

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local FX = require(ReplicatedStorage.FX)
local geppoDash = FX:WaitForChild("YetiEffects").GeppoDash

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

return function(data)
	local player = data.player or data.Player or data.plr or game.Players:GetPlayerFromCharacter(data.Root.Parent)
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
		Util.Sound:Play("YETI_TNSFM_Dash_01", root)
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

		if data.Direction:Dot(root.CFrame.LookVector) > 0.75 then
			local yetiRig = root.Parent.YetiRig.YetiRig
			emitAll(yetiRig.DashSmoke)
			emitAll(
				yetiRig.DashParticle.Front1.WindDashFront,
				root.Parent == game.Players.LocalPlayer.Character and (workspace.CurrentCamera.CFrame.p - yetiRig.DashParticle.Front1.WindDashFront.WorldPosition).Magnitude < 120
			)

			for _, descendant in pairs(yetiRig:GetDescendants()) do
				if descendant.Name == "DashBAMP_FrontDash" then
					descendant:Emit(18)
				end
			end

			if data.DemonOgreHeldVariant == true then
				local heartbeatLoopFor = Util.HeartbeatLoopFor.HeartbeatLoopFor

				-- equivalent calls inferred from this helper; original call sites unknown
				local function makeFollowingAfterImage(p: number)
					task.spawn(function()
						local clone = yetiRig:Clone()
						local descendants = {}

						for _, descendant in ipairs(clone:GetDescendants()) do
							if descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("Trail") or descendant:IsA("Sound") or descendant.ClassName == "Part" then
								descendant:Destroy()
							elseif descendant:IsA("BasePart") then
								descendant.Anchored = true
								descendant.CanCollide = false
								descendant.CanTouch = false
								descendant.CanQuery = false
								descendant.CastShadow = false
								table.insert(descendants, descendant)
							end
						end

						clone.Parent = workspace._WorldOrigin
						Util.DestroyAfter(clone, 4)
						local v3 = root
						local unit = data.Direction.Magnitude > 0 and data.Direction.Unit or v3.CFrame.LookVector
						heartbeatLoopFor(0.4, function(_, _, p2)
							local v4 = unit * (p * 25) / (0.2 + 1.5 * p2)
							local v5 = v3.Position - v4 - createVector(0, 5, 0)
							clone:PivotTo(CFrame.lookAt(v5, v5 + unit))

							for _, v6 in ipairs(descendants) do
								v6.Transparency = p2 + p * 0.2 / 4
							end
						end, function()
							for _, v4 in ipairs(descendants) do
								v4.Transparency = 1
							end
						end)
					end)
				end

				task.spawn(function()
					makeFollowingAfterImage(1) -- equivalent call inferred; original call site unknown
					makeFollowingAfterImage(2) -- equivalent call inferred; original call site unknown
					makeFollowingAfterImage(3) -- equivalent call inferred; original call site unknown
					makeFollowingAfterImage(4) -- equivalent call inferred; original call site unknown
				end)
			end
		else
			local clone = geppoDash.dash.DASH:Clone()
			Util.SetParentOverrideWithColor(clone, part, player, "YetiFruitVFXColor")
			emitAll(clone)
		end
	end
end