local Debris = game:GetService("Debris")
game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local function Emit(model, value)
	local v = value or 1
	local clone = model:Clone()

	if not clone then
		return
	end

	if clone:IsA("Model") then
		if model:IsA("Model") then
			clone:PivotTo(model:GetPivot())
		end
	elseif clone:IsA("BasePart") then
		clone.CFrame = model.CFrame
		clone.Anchored = true
		clone.CanCollide = false
	end

	clone.Parent = Workspace.Thrown
	local timeLength = 1

	for _, descendant in ipairs(clone:GetDescendants()) do
		if descendant:IsA("ParticleEmitter") then
			local emitCount = descendant:GetAttribute("EmitCount") or 1
			local max = descendant.Lifetime.Max

			if timeLength < max then
				timeLength = max
			end

			if v ~= 1 then
				descendant.Speed = NumberRange.new(descendant.Speed.Min * v, descendant.Speed.Max * v)
			end

			descendant:Emit(emitCount * v)
		elseif descendant:IsA("Beam") then
			descendant.Enabled = true
			local v2 = descendant
			task.delay(0.1, function()
				v2.Enabled = false
			end)
		elseif descendant:IsA("Sound") then
			descendant:Play()

			if timeLength < descendant.TimeLength then
				timeLength = descendant.TimeLength
			end
		elseif descendant:IsA("Trail") then
			descendant.Enabled = true

			if timeLength < descendant.Lifetime then
				timeLength = descendant.Lifetime
			end
		elseif descendant:IsA("BasePart") and descendant.Name == "Start" then
			descendant.Transparency = 1
		end
	end

	Debris:AddItem(clone, timeLength + 2)
end

return {
	frameEvents = {
		[45] = function(p)
			task.spawn(function()
				local seq_45 = p.PreloadedImages.Seq_45

				if not seq_45 then
					return
				end

				local backgroundImage = p.backgroundImage
				local count = #seq_45
				local v = {}

				for i, v2 in ipairs(seq_45) do
					v2.Parent = backgroundImage
					v2.BackgroundTransparency = 1
					v2.Position = UDim2.fromScale(0.5, 0.5)
					v2.AnchorPoint = Vector2.new(0.5, 0.5)
					v2.Size = UDim2.fromOffset(1, 1)
					v2.ScaleType = Enum.ScaleType.Crop
					v2.ZIndex = -2
					v2.ImageColor3 = Color3.new(0.513725, 0.105882, 0.105882)
					v[i] = v2
				end

				for i, v2 in ipairs(v) do
					local v3 = v[i - 1]

					if v3 then
						v3:Destroy()
					end

					v2.Size = UDim2.fromScale(1, 1)
					task.wait(5 / count)
				end

				if v[count] then
					v[count]:Destroy()
				end
			end)
		end,
		[57] = function(p)
			local sweat = p.vfx.HeadFx.Sweat

			for _, effect in pairs(sweat:GetDescendants()) do
				if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam") or effect:IsA("Trail")) then
					continue
				end

				effect.Enabled = true
			end

			local M0 = p.cameraRig.CamPart.Beams.M0

			for _, effect in pairs(M0:GetDescendants()) do
				if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam") or effect:IsA("Trail")) then
					continue
				end

				effect.Enabled = true
			end
		end,
		[60] = function(p)
			task.spawn(function()
				local seq_60_1 = p.PreloadedImages.Seq_60_1

				if not seq_60_1 then
					return
				end

				local backgroundImage = p.backgroundImage
				local count = #seq_60_1
				local v = {}

				for i, v2 in ipairs(seq_60_1) do
					v2.Parent = backgroundImage
					v2.BackgroundTransparency = 1
					v2.Position = UDim2.fromScale(0.5, 0.5)
					v2.AnchorPoint = Vector2.new(0.5, 0.5)
					v2.Size = UDim2.fromOffset(1, 1)
					v2.ScaleType = Enum.ScaleType.Crop
					v2.ZIndex = 2
					v[i] = v2
				end

				for i, v2 in ipairs(v) do
					local v3 = v[i - 1]

					if v3 then
						v3:Destroy()
					end

					v2.Size = UDim2.fromScale(1, 1)
					task.wait(4 / count)
				end

				if v[count] then
					v[count]:Destroy()
				end
			end)
			task.spawn(function()
				local seq_60_2 = p.PreloadedImages.Seq_60_2
				local backgroundImage = p.backgroundImage

				if not seq_60_2 then
					return
				end

				local count = #seq_60_2
				local v = {}

				for i, v2 in ipairs(seq_60_2) do
					v2.Parent = backgroundImage
					v2.BackgroundTransparency = 1
					v2.Position = UDim2.fromScale(0.5, 0.5)
					v2.AnchorPoint = Vector2.new(0.5, 0.5)
					v2.Size = UDim2.fromOffset(1, 1)
					v2.ScaleType = Enum.ScaleType.Crop
					v2.ZIndex = 6
					v[i] = v2
				end

				for i, v2 in ipairs(v) do
					local v3 = v[i - 1]

					if v3 then
						v3:Destroy()
					end

					v2.Size = UDim2.fromScale(1, 1)
					task.wait(4 / count)
				end

				if v[count] then
					v[count]:Destroy()
				end
			end)
		end,
		[350] = function(p)
			local starFx = p.vfx.HeadFx.StarFx
			starFx.Parent.Transparency = 1

			for _, effect in pairs(starFx:GetDescendants()) do
				if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam") or effect:IsA("Trail")) then
					continue
				end

				local v = effect
				delay(effect:GetAttribute("EmitDelay"), function()
					v:Emit(v:GetAttribute("EmitCount"))
				end)
			end

			local emit1 = p.cameraRig.CamPart.Fx.Emit1

			for _, effect in pairs(emit1:GetDescendants()) do
				if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam") or effect:IsA("Trail")) then
					continue
				end

				local v = effect
				delay(effect:GetAttribute("EmitDelay"), function()
					v:Emit(v:GetAttribute("EmitCount"))
				end)
			end
		end,
		[372] = function(data)
			local roarFx = data.vfx.RoarFx

			for _, effect in pairs(roarFx:GetDescendants()) do
				if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam") or effect:IsA("Trail")) then
					continue
				end

				effect.Enabled = true
			end

			Emit(data.vfx.RoarFx.Debris)
			local M0 = data.cameraRig.CamPart.Beams.M0

			for _, effect in pairs(M0:GetDescendants()) do
				if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam") or effect:IsA("Trail")) then
					continue
				end

				effect.Enabled = false
			end

			task.spawn(function()
				local seq_372 = data.PreloadedImages.Seq_372

				if not seq_372 then
					return
				end

				local label = data.vfx.Image.screen.label
				local count = #seq_372
				local v = {}

				for i, v2 in ipairs(seq_372) do
					v2.Parent = label
					v2.BackgroundTransparency = 1
					v2.Position = UDim2.fromScale(0.5, 0.5)
					v2.AnchorPoint = Vector2.new(0.5, 0.5)
					v2.Size = UDim2.fromOffset(1, 1)
					v2.ScaleType = Enum.ScaleType.Fit
					v2.ZIndex = 15
					v2.ImageColor3 = Color3.new(1, 0.313725, 0.313725)
					v[i] = v2
				end

				for i, v2 in ipairs(v) do
					local v3 = v[i - 1]

					if v3 then
						v3:Destroy()
					end

					v2.Size = UDim2.fromScale(1, 1)
					task.wait(3 / count)
				end

				if v[count] then
					v[count]:Destroy()
				end
			end)
		end,
		[388] = function(p)
			Emit(p.vfx.Mesh.Roar)
			Emit(p.vfx.RoarFx.Debris)
			local sweat = p.vfx.HeadFx.Sweat

			for _, effect in pairs(sweat:GetDescendants()) do
				if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam") or effect:IsA("Trail")) then
					continue
				end

				effect.Enabled = false
			end
		end,
		[408] = function(p)
			Emit(p.vfx.RoarFx.Debris)
		end,
		[424] = function(p)
			Emit(p.vfx.RoarFx.Debris)
		end,
		[439] = function(p)
			Emit(p.vfx.RoarFx.Debris)
		end,
		[457] = function(p)
			Emit(p.vfx.RoarFx.Debris)
		end,
		[473] = function(p)
			Emit(p.vfx.RoarFx.Debris)
		end,
		[489] = function(p)
			local roarFx = p.vfx.RoarFx

			for _, effect in pairs(roarFx:GetDescendants()) do
				if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam") or effect:IsA("Trail")) then
					continue
				end

				effect.Enabled = false
			end
		end,
		[490] = function(p)
			task.spawn(function()
				local seq_490 = p.PreloadedImages.Seq_490

				if not seq_490 then
					return
				end

				local backgroundImage = p.backgroundImage
				local count = #seq_490
				local v = {}

				for i, v2 in ipairs(seq_490) do
					v2.Parent = backgroundImage
					v2.BackgroundTransparency = 1
					v2.Position = UDim2.fromScale(0.5, 0.5)
					v2.AnchorPoint = Vector2.new(0.5, 0.5)
					v2.Size = UDim2.fromOffset(1, 1)
					v2.ScaleType = Enum.ScaleType.Crop
					v2.ZIndex = 2
					v2.ImageColor3 = Color3.new(1, 0.388235, 0.388235)
					v[i] = v2
				end

				for i, v2 in ipairs(v) do
					local v3 = v[i - 1]

					if v3 then
						v3:Destroy()
					end

					v2.Size = UDim2.fromScale(1, 1)
					task.wait(2.125 / count)
				end

				if v[count] then
					v[count]:Destroy()
				end
			end)
		end,
		[621] = function(p)
			local auraEmitFx = p.vfx.AuraEmitFx

			for _, emitter in pairs(auraEmitFx:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v = emitter
				delay(emitter:GetAttribute("EmitDelay"), function()
					v:Emit(v:GetAttribute("EmitCount"))
				end)
			end
		end
	},
	fovKeyframes = {
		[0] = 70,
		[26] = 36.8276,
		[32] = 33.0732,
		[70] = 34,
		[144] = 34,
		[164] = 50,
		[184] = 41.3043,
		[190] = 40.7826,
		[210] = 46,
		[226] = 30,
		[227] = 26,
		[264] = 37,
		[283] = 22.3182,
		[289] = 18,
		[295] = 16.1519,
		[371] = 20,
		[379] = 30,
		[387] = 14,
		[413] = 40,
		[469] = 58.9831,
		[475] = 61.5789,
		[485] = 66.8421,
		[491] = 72.6721,
		[497] = 83.8462,
		[498] = 86.1538,
		[505] = 93.8462,
		[506] = 70,
		[625] = 70,
		[626] = 15.9483,
		[632] = 16.4615,
		[639] = 17.5385,
		[645] = 17.4375,
		[662] = 12
	},
	brightnessKeyframes = {
		[376] = 0,
		[379] = 15,
		[388] = 2,
		[392] = 4,
		[395] = 0,
		[398] = 15,
		[407] = 2,
		[411] = 4,
		[414] = 0,
		[417] = 15,
		[426] = 2,
		[430] = 4,
		[434] = 0,
		[437] = 15,
		[446] = 2,
		[450] = 4,
		[454] = 0,
		[457] = 15,
		[466] = 2,
		[470] = 4,
		[489] = 4,
		[492] = 55,
		[497] = 0
	},
	colorCorrectionKeyframes = {
		Brightness = {
			[0] = 0,
			[39] = -0.1,
			[352] = 0,
			[354] = 0.1,
			[370] = 0.1,
			[373] = 0.1,
			[494] = -0.3,
			[500] = -1,
			[540] = -1,
			[541] = 0,
			[626] = 0,
			[627] = 0.5,
			[644] = 0
		},
		Contrast = {
			[0] = 0,
			[39] = 0.5,
			[352] = 0,
			[354] = 0.5,
			[370] = 0.5,
			[373] = 0.7,
			[494] = 0.4,
			[496] = 1,
			[527] = 0,
			[626] = 0,
			[627] = -1,
			[640] = 0
		},
		Saturation = {
			[0] = 0,
			[39] = -0.2,
			[352] = 0,
			[354] = -0.2,
			[370] = -0.2,
			[373] = -0.4,
			[494] = -0.25,
			[496] = -0.25,
			[527] = 0,
			[626] = 0,
			[627] = 0
		},
		TintColor = {
			[0] = Color3.new(1, 1, 1),
			[39] = Color3.new(1, 1, 1),
			[352] = Color3.new(1, 1, 1),
			[354] = Color3.new(1, 1, 1),
			[370] = Color3.new(1, 1, 1),
			[373] = Color3.new(1, 1, 1),
			[494] = Color3.new(1, 1, 1),
			[496] = Color3.new(1, 0.305882, 0.305882),
			[512] = Color3.new(1, 0.305882, 0.305882),
			[527] = Color3.new(1, 1, 1),
			[626] = Color3.new(1, 1, 1),
			[627] = Color3.new(1, 0.0117647, 0.0117647),
			[634] = Color3.new(1, 0.0117647, 0.0117647),
			[657] = Color3.new(1, 1, 1)
		}
	},
	transparencyKeyframes = {
		[364] = 1,
		[384] = 0.45,
		[516] = 0.45,
		[528] = 1
	},
	imageTransparencyKeyframes = {
		[365] = 1,
		[384] = 0,
		[516] = 0,
		[528] = 1,
		[650] = 1,
		[657] = 0,
		[700] = 1
	},
	transparencyKeyframes2 = {
		[374] = 1,
		[384] = 0,
		[516] = 0,
		[528] = 1
	},
	ambientKeyframes = {
		Ambient = {
			[321] = Color3.new(0.27451, 0.27451, 0.27451),
			[346] = Color3.new(0.572549, 0.0943022, 0.0943022),
			[512] = Color3.new(0.572549, 0.0943022, 0.0943022),
			[531] = Color3.new(0.27451, 0.27451, 0.27451)
		},
		OutdoorAmbient = {
			[321] = Color3.new(0.27451, 0.27451, 0.27451),
			[346] = Color3.new(0.572549, 0.0943022, 0.0943022),
			[512] = Color3.new(0.572549, 0.0943022, 0.0943022),
			[531] = Color3.new(0.27451, 0.27451, 0.27451)
		}
	},
	highlightKeyframes = {
		user = {
			Enabled = {
				[0] = true,
				[443] = true,
				[448] = true,
				[479] = true,
				[726] = true
			},
			OutlineTransparency = {
				[0] = 1
			},
			OutlineColor = {
				[0] = Color3.new(1, 1, 1)
			},
			FillTransparency = {
				[0] = 1,
				[364] = 1,
				[380] = 0,
				[497] = 0,
				[503] = 1
			},
			FillColor = {
				[0] = Color3.new(0, 0, 0)
			}
		}
	},
	imageKeyframes = {
		imagelabel = {
			ImageColor3 = {
				[0] = Color3.new(1, 1, 1),
				[16] = Color3.new(0, 0, 0),
				[52] = Color3.new(0, 0, 0),
				[62] = Color3.new(0, 0, 0),
				[436] = Color3.new(0, 0, 0),
				[649] = Color3.new(0, 0, 0),
				[659] = Color3.new(0, 0, 0)
			},
			ImageTransparency = {
				[0] = 1,
				[16] = 0,
				[52] = 0,
				[62] = 1,
				[365] = 1,
				[384] = 0,
				[436] = 1,
				[516] = 0,
				[528] = 1,
				[649] = 0,
				[657] = 0,
				[659] = 1,
				[700] = 1
			}
		}
	}
}