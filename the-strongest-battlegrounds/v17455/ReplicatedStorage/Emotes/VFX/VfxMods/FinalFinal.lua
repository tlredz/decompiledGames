local createVector = vector.create
local FinalFinal = {}
local libraryNew = require(script.Parent.libraryNew)
local _ = libraryNew.PlayAttachment
local maid = libraryNew.Maid
local playTween = libraryNew.PlayTween
local _ = libraryNew.CamShake
local _ = libraryNew.PlayFlipBook
local dtwait = libraryNew.dtwait
local EFP = libraryNew.EFP
local _ = libraryNew.PlayMesh
local _ = libraryNew.Impact
local _ = libraryNew.GlassLight
local _ = libraryNew.RaiseZIndex
local _ = libraryNew.Able
local lifeScale = libraryNew.LifeScale
local _ = libraryNew.QuickFX
local _ = libraryNew.QuickWeld
local _ = libraryNew.Yield
local _ = libraryNew.ProcessPart
local _ = libraryNew.WeldObject
local _ = libraryNew.Bezier
local _ = libraryNew.EditableMeshShader
game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local Debris = game:GetService("Debris")
game:GetService("Players")
local Library = require(ReplicatedStorage.Resources.CosmicUtils.Library)
local class = {}
class.__index = class
local random = Random.new()
local TweenService = game:GetService("TweenService")
game:GetService("PhysicsService")
local _ = game.Workspace.Camera
local LightningModule = require(game.ReplicatedStorage.Resources.LightningModule)

local function loopAndStopFlipbook(instance, list, duration: number, flag: boolean, value)
	local flag2 = true
	local v = value or 1
	coroutine.wrap(function()
		while flag2 do
			if not instance then
				continue
			end

			if flag then
				for i = #list, 1, -1 do
					local texture = list[i]

					if instance.Parent and instance.Decal then
						instance.Decal.Texture = texture
						instance:PivotTo(instance:GetPivot() * CFrame.Angles(0, 0.08726646259971647, 0))
						dtwait(0.01 * v)
					else
						break
					end
				end
			else
				for i = 1, #list do
					local texture = list[i]

					if instance.Parent and instance.Decal then
						instance.Decal.Texture = texture
						instance:PivotTo(instance:GetPivot() * CFrame.Angles(0, 0.03490658503988659, 0))
						dtwait(0.01 * v)
					else
						break
					end
				end
			end

			dtwait(0.01)
		end
	end)()
	task.delay(duration, function()
		flag2 = false
	end)
end

function FinalFinal.FirstEvent(p)
	local data = p.Data
	local anchor = data.Anchor
	local char = data.Char
	local _ = data.Victim
	local v = game.Players.LocalPlayer.Character == data.Char or game.Players.LocalPlayer.Character == data.Victim
	local object = setmetatable({}, class)
	object._maid = maid.new()
	local v2 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v2 then
			v2 = true
			object._maid:doCleaning()
		end
	end

	task.delay(7, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.FilterDescendantsInstances = { game.Workspace.Map }
	local _ = {
		"rbxassetid://84245338887808",
		"rbxassetid://85803246245430",
		"rbxassetid://116787423956449",
		"rbxassetid://73121255683240",
		"rbxassetid://80122331461916",
		"rbxassetid://132141797278697",
		"rbxassetid://131792300141897",
		"rbxassetid://104741185619341",
		"rbxassetid://115765846937363",
		"rbxassetid://95740809025867",
		"rbxassetid://123758882460225",
		"rbxassetid://129133882287404",
		"rbxassetid://131453852362109",
		"rbxassetid://113380524891696",
		"rbxassetid://129804692509997",
		"rbxassetid://115560969075623"
	}
	local _ = {
		"rbxassetid://124398011319031",
		"rbxassetid://79597820738718",
		"rbxassetid://88369806615647",
		"rbxassetid://118743638508540",
		"rbxassetid://103298072423261",
		"rbxassetid://119290585012871",
		"rbxassetid://72871625269551",
		"rbxassetid://130874748912793",
		"rbxassetid://125082133142812",
		"rbxassetid://80528489342062",
		"rbxassetid://72340500147700",
		"rbxassetid://97429791493003"
	}

	local function FirstEvent()
		local localPlayer = game.Players.LocalPlayer
		local s_FastMode = localPlayer:GetAttribute("S_FastMode") == true
		local s_PotatoMode = localPlayer:GetAttribute("S_PotatoMode") == true
		local clone = nil
		task.spawn(function()
			local clone2 = script.WindUpFX:Clone()
			clone2:PivotTo(anchor * CFrame.new(0, 30, 0))
			clone2.Parent = EFP
			clone2:ScaleTo(11)
			Debris:AddItem(clone2, 10)
			task.wait(0.3)
			Library.Particles.disableParticles(clone2)
			clone = script.ExplosionFX:Clone()
			clone:PivotTo(anchor)
			clone.Parent = EFP
			Debris:AddItem(clone, 15)
			clone:ScaleTo(1.5)

			if v then
				Library.Lighting.colorCorrectionFlash(0, -3, -3, Color3.fromRGB(255, 255, 255), 0.2)
				Library.Lighting.colorCorrectionFlash(0.3, 0.56, 0.87, Color3.fromRGB(255, 144, 144), 0.3)
				Library.Lighting.colorCorrectionFlash(0.1, 0.32, 0.5, Color3.fromRGB(255, 143, 143), 0.6)
			end

			task.wait(0.3)
			clone:ScaleTo(2)
			lifeScale({
				FX = clone.ExplosionFX.Explosion,
				Scale = 3
			})

			if v then
				Library.Lighting.colorCorrectionFlash(0.3, 0.56, 1, Color3.fromRGB(255, 110, 110), 0.3)
			end

			Library.Particles.disableParticles(clone.ExplosionFX.Enabled)
			Library.Particles.emitParticles(clone.ExplosionFX.Explosion)
		end)
		task.wait(0.6)
		local child = game.Workspace.Thrown:FindFirstChild("EFPNUCLEAR_" .. char.Name)

		if child then
			child:Destroy()
		end

		local v3 = object._maid:give(Instance.new("NumberValue"))
		local folder = object._maid:give(script.TestModel:Clone())
		folder.Parent = EFP
		local beams = {}
		local beams2 = {}

		for _, beam in pairs(folder:GetDescendants()) do
			if beam:HasTag("MeshEmitter") then
				beam:SetAttribute("ogs", beam:GetAttribute("MaxSize"))
				beam:SetAttribute("ogsp", beam:GetAttribute("Speed"))
				table.insert(beams, beam)
			end

			if not beam:IsA("Beam") then
				continue
			end

			beam:SetAttribute("ogs", beam.TextureSpeed)
			table.insert(beams2, beam)
		end

		tick()
		local v4 = {}

		for i = 1, #beams do
			local v5 = beams[i]
			local ogs = v5:GetAttribute("ogs")
			local ogsp = v5:GetAttribute("ogsp")
			table.insert(v4, {
				v = v5,
				ogsMin = ogs.Min,
				ogsMax = ogs.Max,
				ogspMin = ogsp.Min,
				ogspMax = ogsp.Max
			})
		end

		object._maid:giveTask(v3.Changed:Connect(function()
			local value = v3.Value
			folder:ScaleTo(value)

			for i = 1, #v4 do
				local v5 = v4[i]
				v5.v:SetAttribute("MaxSize", NumberRange.new(v5.ogsMin * value, v5.ogsMax * value))
				v5.v:SetAttribute("Speed", NumberRange.new(v5.ogspMin * value, v5.ogspMax * value))
			end

			folder:PivotTo(anchor * CFrame.new(0, 35 * value, 0))
			folder.Others:PivotTo(anchor * CFrame.new(0, 235 * value, 0))
		end))
		folder:ScaleTo(0.01)
		TweenService:Create(v3, TweenInfo.new(5, Enum.EasingStyle.Exponential), {
			Value = 1.35
		}):Play()
		v3.Value = folder:GetScale()
		local v5 = object._maid:give(Instance.new("NumberValue"))
		v5.Value = 18
		TweenService:Create(v5, TweenInfo.new(5, Enum.EasingStyle.Exponential), {
			Value = 1
		}):Play()
		object._maid:giveTask(function()
			for _, v6 in pairs(beams2) do
				v6.TextureSpeed = v6:GetAttribute("ogs") * v3.Value
			end
		end)
		task.delay(4, function()
			folder.Main.Attachment.Glow.Lifetime = NumberRange.new(0.3, 0.3)
		end)
		task.delay(3, function()
			folder.Floor.Attachment.RealFloor.Enabled = false
			folder.Floor.Attachment.GlowFloor.Enabled = false
			folder.Floor.Attachment.DefinedFloor.Enabled = false
		end)
		task.delay(3, function()
			for _, descendant in pairs(folder:GetDescendants()) do
				if descendant:IsA("ParticleEmitter") then
					descendant.Enabled = false
				elseif descendant:HasTag("MeshEmitter") then
					descendant:SetAttribute("Enabled", false)
				elseif descendant:IsA("BasePart") or descendant:IsA("Decal") then
					if descendant.Transparency < 1 then
						TweenService:Create(descendant, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
							Transparency = 1
						}):Play()

						if descendant:IsA("BasePart") then
							TweenService:Create(descendant, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
								Size = createVector(0, 0, 0)
							}):Play()
						end
					elseif descendant.Transparency > 1 then
						TweenService:Create(descendant, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
							Transparency = 1,
							Size = createVector(0, 0, 0)
						}):Play()
					end
				elseif descendant:IsA("Beam") then
					playTween(descendant, {
						Time = 0.6,
						EasingStyle = "Sine",
						Goal = {
							Transparency = NumberSequence.new(1)
						}
					})
					game.Debris:AddItem(descendant, 0.6)
				end
			end

			clone.ExplosionFX.Explosion.Main.ParticleEmitter:Destroy()

			for _, descendant in pairs(clone.ExplosionFX:GetDescendants()) do
				if descendant.Name == "Maybe" then
					descendant:Destroy()
				end
			end

			local raycastParams2 = RaycastParams.new()
			raycastParams2.FilterType = Enum.RaycastFilterType.Include
			raycastParams2.FilterDescendantsInstances = { game.Workspace.Built, game.Workspace.Map }
			local raycastResult = game.Workspace:Raycast(
				clone.ExplosionFX:GetPivot().Position,
				createVector(0, -100, 0),
				raycastParams2
			)

			if raycastResult then
				clone.ExplosionFX:PivotTo(CFrame.new(raycastResult.Position + createVector(0, 0.1, 0)))
			end
		end)
		task.spawn(function()
			if not game.Workspace:FindFirstChild("Test2") then
				local v6 = object._maid:give(Instance.new("BoolValue"))
				v6.Name = "Test2"
				v6.Parent = EFP

				if v and not (s_FastMode or s_PotatoMode) then
					task.spawn(function()
						local lastTime = tick()

						while v6.Parent do
							if tick() - lastTime > 1 and tick() - lastTime < 4.5 then
								for _ = 1, math.random(1, 2) do
									local color = Color3.fromRGB(96, 218, 255)
									local v7 = 700 * v3.Value
									LightningModule.Cast(
										folder:GetPivot().Position,
										folder:GetPivot() * CFrame.new(
											random:NextNumber(-v7, v7),
											random:NextNumber(v7, v7 * 2),
											random:NextNumber(-v7, v7)
										).Position,
										{
											JitterScale = 1,
											Duration = random:NextNumber(0.3, 0.6),
											Thickness = random:NextNumber(5, 11.05) * 2,
											Color = Color3.new(color.R * 1.3, color.G * 1.3, color.B * 1.3)
										}
									)
								end
							end

							task.wait(0.3)
						end
					end)
				end

				task.spawn(function()
					local v7 = {}

					for _, part in folder.Clouds:GetChildren() do
						if part:IsA("BasePart") then
							table.insert(v7, {
								part = part,
								mult = tonumber(part.Name) or 0
							})
						end
					end

					local children = {}
					local children2 = {}

					for _, child2 in folder:GetChildren() do
						if child2.Name == "color" then
							table.insert(children2, child2)
						elseif child2.Name == "color2" then
							table.insert(children, child2)
						end
					end

					local lastTime = tick()
					local count = 0

					while v6.Parent do
						count += 1
						local value = v5.Value

						for i = 1, #v7 do
							local v8 = v7[i]
							v8.part:PivotTo(v8.part:GetPivot() * CFrame.Angles(math.rad(v8.mult * value), 0, 0))
						end

						local v8 = math.rad(2 * value)
						local v9 = math.rad(-4 * value)

						for i = 1, #children2 do
							children2[i]:PivotTo(children2[i]:GetPivot() * CFrame.Angles(0, v8, 0))
						end

						for i = 1, #children do
							children[i]:PivotTo(children[i]:GetPivot() * CFrame.Angles(0, v9, 0))
						end

						if v and not s_FastMode and not s_PotatoMode and count % 3 == 0 and tick() - lastTime < 1.5 then
							local color = Color3.fromRGB(255, 115, 80)
							local pivot = folder:GetPivot()
							local position = pivot.Position
							local position2 = (pivot * CFrame.new(
								random:NextNumber(-1, 1),
								1000,
								random:NextNumber(-1, 1)
							)).Position
							LightningModule.Cast(position, position2, {
								JitterScale = 10,
								Duration = random:NextNumber(0.3, 0.6),
								Thickness = random:NextNumber(5, 11.05),
								Color = Color3.new(color.R * 1.3, color.G * 1.3, color.B * 1.3)
							})
						end

						task.wait(0.03)
					end
				end)
			end
		end)
	end

	task.spawn(FirstEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

return FinalFinal