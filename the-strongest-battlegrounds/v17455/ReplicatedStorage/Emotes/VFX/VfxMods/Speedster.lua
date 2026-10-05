local FrameEvents = require(script:WaitForChild("FrameEvents"))
return {
	FirstEvent = function(data)
		local char = data.Char
		local cleanupTable = data.CleanupTable
		local realAnim = data.RealAnim
		local bind = data.Bind
		local Players = game:GetService("Players")
		local RunService = game:GetService("RunService")
		local Workspace = game:GetService("Workspace")
		local Lighting = game:GetService("Lighting")
		local TweenService = game:GetService("TweenService")
		local localPlayer = Players.LocalPlayer
		local currentCamera = Workspace.CurrentCamera
		local S_FOV = localPlayer and localPlayer:GetAttribute("S_FOV") or not currentCamera and 70 or currentCamera.FieldOfView or 70
		local v = {
			Brightness = Lighting.Brightness,
			Ambient = Lighting.Ambient,
			OutdoorAmbient = Lighting.OutdoorAmbient,
			ColorShift_Top = Lighting.ColorShift_Top,
			ColorShift_Bottom = Lighting.ColorShift_Bottom,
			ClockTime = Lighting.ClockTime
		}
		local v2 = {
			Back = Enum.EasingStyle.Back,
			Bounce = Enum.EasingStyle.Bounce,
			Circular = Enum.EasingStyle.Circular,
			Circ = Enum.EasingStyle.Circular,
			Cubic = Enum.EasingStyle.Cubic,
			Elastic = Enum.EasingStyle.Elastic,
			Exponential = Enum.EasingStyle.Exponential,
			Expo = Enum.EasingStyle.Exponential,
			Quad = Enum.EasingStyle.Quad,
			Quart = Enum.EasingStyle.Quart,
			Quint = Enum.EasingStyle.Quint,
			Sine = Enum.EasingStyle.Sine
		}
		local v3 = {
			In = Enum.EasingDirection.In,
			Out = Enum.EasingDirection.Out,
			InOut = Enum.EasingDirection.InOut
		}
		local isme = localPlayer and char == localPlayer.Character

		if isme then
			local v5 = {
				connections = {},
				objects = {},
				tweens = {},
				particles = {},
				beams = {},
				trails = {},
				lights = {},
				tasks = {}
			}
			local run_context = {
				running = true
			}
			local parentChangedConnection = nil
			local flag = false
			local flag2 = false
			local flag3 = false
			local v7 = 0
			local v8 = -1
			local v9 = nil
			local v10 = nil

			-- equivalent calls inferred from this helper; original call sites unknown
			local function cancontinue()
				return not (flag or not (realAnim and realAnim.IsPlaying and bind and bind.Parent))
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function mark(instance)
				if instance then
					pcall(function()
						instance:SetAttribute("EmoteEffect", true)
					end)
				end
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function markTree(folder)
				if folder then
					mark(true) -- equivalent call inferred; original call site unknown
				end

				for _, descendant in pairs(folder:GetDescendants()) do
					if not descendant then
						continue
					end

					mark(true) -- equivalent call inferred; original call site unknown
				end
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function destroyLater(instance)
				task.delay(15, function()
					if instance then
						pcall(function()
							instance:Destroy()
						end)
					end
				end)
			end

			local function trackParticleEffect(instance)
				if instance:IsA("ParticleEmitter") then
					table.insert(v5.particles, instance)
				elseif instance:IsA("Beam") then
					table.insert(v5.beams, instance)
				elseif instance:IsA("Trail") then
					table.insert(v5.trails, instance)
				elseif instance:IsA("PointLight") then
					table.insert(v5.lights, instance)
				end
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function trackTreeEffects(folder)
				trackParticleEffect(folder)

				for _, descendant in pairs(folder:GetDescendants()) do
					trackParticleEffect(descendant)
				end
			end

			local function trackInstance(p, p2, p3)
				if not p then
					return p
				end

				markTree(p) -- equivalent call inferred; original call site unknown
				table.insert(v5.objects, p)

				if cleanupTable and not p3 then
					table.insert(cleanupTable, p)
				end

				if not p2 then
					destroyLater(p) -- equivalent call inferred; original call site unknown
				end

				return p
			end

			local function trackExternal(instance)
				if not instance then
					return instance
				end

				if instance then
					mark(true) -- equivalent call inferred; original call site unknown
				end

				table.insert(v5.objects, instance)

				if cleanupTable then
					table.insert(cleanupTable, instance)
				end

				destroyLater(instance) -- equivalent call inferred; original call site unknown
				return instance
			end

			local function addTask(p)
				if p then
					table.insert(v5.tasks, p)
				end

				return p
			end

			local function setModelVisible(folder, p)
				if not folder then
					return
				end

				for _, descendant in pairs(folder:GetDescendants()) do
					if not (descendant:IsA("BasePart") or descendant:IsA("Decal") or descendant:IsA("Texture")) then
						continue
					end

					if p then
						local cutsceneOriginalTransparency = descendant:GetAttribute("CutsceneOriginalTransparency")
						descendant.Transparency = typeof(cutsceneOriginalTransparency) == "number" and cutsceneOriginalTransparency or 0
					else
						if descendant:GetAttribute("CutsceneOriginalTransparency") == nil then
							descendant:SetAttribute("CutsceneOriginalTransparency", descendant.Transparency)
						end

						descendant.Transparency = 1
					end
				end
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function pivotModelToPositionPreservingRotation(clone, position)
				local pivot = clone:GetPivot()
				clone:PivotTo(CFrame.fromMatrix(position, pivot.XVector, pivot.YVector, pivot.ZVector))
			end

			local function applyEasing(p, data2)
				if type(data2) ~= "table" then
					return p
				end

				local type2 = data2.Type or data2.type or data2.Style or data2.style or "Linear"
				local direction = data2.Direction or data2.direction or "Out"

				if type2 == "Constant" then
					if p >= 1 then
						return 1
					end

					return 0
				else
					if type2 == "Linear" then
						return p
					elseif type2 == "Smoother" then
						return p * p * p * (p * (p * 6 - 15) + 10)
					end

					local v11 = v2[type2]
					local v12 = v3[direction]

					if v11 and v12 then
						return TweenService:GetValue(p, v11, v12)
					end

					return p
				end
			end

			local function interpolateValue(items, p, p2, p3)
				if type(items) ~= "table" or not next(items) then
					return nil
				end

				local v11 = nil
				local v12 = nil
				local v13 = nil
				local v14 = nil

				for k, item in pairs(items) do
					local v15 = tonumber(k)

					if not v15 then
						continue
					end

					if v15 <= p and (not v11 or v11 < v15) then
						v13 = item
						v11 = v15
					end

					if not (p <= v15 and (not v12 or v15 < v12)) then
						continue
					end

					v14 = item
					v12 = v15
				end

				if v11 == v12 or not (v11 and v12) then
					return v13 or v14
				end

				local v16 = applyEasing((p - v11) / (v12 - v11), p3 and p3[v11])

				if p2 == "Color3" then
					return v13:lerp(v14, v16)
				elseif p2 == "number" then
					return v13 + (v14 - v13) * v16
				end

				if p2 == "boolean" then
				end

				return v14
			end

			local function executeFrameEvents(p, p2)
				local frame_events = FrameEvents.frame_events or FrameEvents.frameEvents

				if not frame_events then
					return
				end

				local v11 = math.floor(p + 0.5)

				if v11 <= v8 then
					return
				end

				for i = math.max(0, v8 + 1), v11 do
					local frame_event = frame_events[i]

					if not frame_event then
						continue
					end

					local thread = nil
					local v12 = frame_event
					local v13 = i
					thread = task.spawn(function()
						local success, result = pcall(v12, p2)

						if not (success or flag) then
							warn("Frame event error at frame", v13, ":", result)
						end

						local index = table.find(v5.tasks, thread)

						if index then
							table.remove(v5.tasks, index)
						end
					end)
					local v14 = thread

					if v14 then
						table.insert(v5.tasks, v14)
					end
				end

				v8 = v11
			end

			local function getCurrentFrame(p)
				return p * 60
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function updateFov(p)
				local fov_keyframes = FrameEvents.fov_keyframes or FrameEvents.fovKeyframes
				local fov_eases = FrameEvents.fov_eases or FrameEvents.fovEases

				if not fov_keyframes then
					return
				end

				local fieldOfView = interpolateValue(fov_keyframes, p, "number", fov_eases)

				if fieldOfView and currentCamera then
					currentCamera.FieldOfView = fieldOfView
				end
			end

			local function updateBrightness(p)
				local brightness_keyframes = FrameEvents.brightness_keyframes or FrameEvents.brightnessKeyframes

				if not brightness_keyframes then
					return
				end

				local brightness = interpolateValue(brightness_keyframes, p, "number")

				if brightness ~= nil then
					if not (v10 and v10.Parent) then
						local colorCorrectionEffect, v12, v13 = Instance.new("ColorCorrectionEffect")

						if colorCorrectionEffect then
							markTree(colorCorrectionEffect) -- equivalent call inferred; original call site unknown
							table.insert(v5.objects, colorCorrectionEffect)

							if cleanupTable and not v13 then
								table.insert(cleanupTable, colorCorrectionEffect)
							end

							if not v12 then
								destroyLater(colorCorrectionEffect) -- equivalent call inferred; original call site unknown
							end
						end

						v10 = colorCorrectionEffect
						v10.Name = "CutsceneBrightnessCorrection"
						v10.Parent = Lighting
					end

					v10.Brightness = brightness
				end
			end

			local function updateColorCorrection(p)
				local color_correction_keyframes = FrameEvents.color_correction_keyframes or FrameEvents.colorCorrectionKeyframes

				if not color_correction_keyframes then
					return
				end

				if not (v9 and v9.Parent) then
					local colorCorrectionEffect, v11, v12 = Instance.new("ColorCorrectionEffect")

					if colorCorrectionEffect then
						markTree(colorCorrectionEffect) -- equivalent call inferred; original call site unknown
						table.insert(v5.objects, colorCorrectionEffect)

						if cleanupTable and not v12 then
							table.insert(cleanupTable, colorCorrectionEffect)
						end

						if not v11 then
							destroyLater(colorCorrectionEffect) -- equivalent call inferred; original call site unknown
						end
					end

					v9 = colorCorrectionEffect
					v9.Name = "CutsceneColorCorrection"
					v9.Parent = Lighting
				end

				local brightness = color_correction_keyframes.Brightness and interpolateValue(
					color_correction_keyframes.Brightness,
					p,
					"number"
				)
				local contrast = color_correction_keyframes.Contrast and interpolateValue(
					color_correction_keyframes.Contrast,
					p,
					"number"
				)
				local saturation = color_correction_keyframes.Saturation and interpolateValue(
					color_correction_keyframes.Saturation,
					p,
					"number"
				)
				local tintColor = color_correction_keyframes.TintColor and interpolateValue(
					color_correction_keyframes.TintColor,
					p,
					"Color3"
				)

				if brightness ~= nil then
					v9.Brightness = brightness
				end

				if contrast ~= nil then
					v9.Contrast = contrast
				end

				if saturation ~= nil then
					v9.Saturation = saturation
				end

				if tintColor ~= nil then
					v9.TintColor = tintColor
				end
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function updateAmbient(p)
				local ambient_keyframes = FrameEvents.ambient_keyframes or FrameEvents.ambientKeyframes

				if not ambient_keyframes then
					return
				end

				local ambient = ambient_keyframes.Ambient and interpolateValue(ambient_keyframes.Ambient, p, "Color3")

				if ambient then
					Lighting.Ambient = ambient
				end

				local outdoorAmbient = ambient_keyframes.OutdoorAmbient and interpolateValue(
					ambient_keyframes.OutdoorAmbient,
					p,
					"Color3"
				)

				if outdoorAmbient then
					Lighting.OutdoorAmbient = outdoorAmbient
				end
			end

			local function updateHighlights(highlight, p)
				local highlight_keyframes = FrameEvents.highlight_keyframes or FrameEvents.highlightKeyframes

				if not (highlight and highlight_keyframes and highlight_keyframes.user) then
					return
				end

				local user = highlight_keyframes.user
				local enabled = user.Enabled and interpolateValue(user.Enabled, p, "boolean")
				local outlineTransparency = user.OutlineTransparency and interpolateValue(
					user.OutlineTransparency,
					p,
					"number"
				)
				local outlineColor = user.OutlineColor and interpolateValue(user.OutlineColor, p, "Color3")
				local fillTransparency = user.FillTransparency and interpolateValue(user.FillTransparency, p, "number")
				local fillColor = user.FillColor and interpolateValue(user.FillColor, p, "Color3")

				if enabled ~= nil then
					highlight.Enabled = enabled
				end

				if outlineTransparency ~= nil then
					highlight.OutlineTransparency = outlineTransparency
				end

				if outlineColor ~= nil then
					highlight.OutlineColor = outlineColor
				end

				if fillTransparency ~= nil then
					highlight.FillTransparency = fillTransparency
				end

				if fillColor ~= nil then
					highlight.FillColor = fillColor
				end
			end

			local function updateImageLabel(imageLabel, p)
				local image_keyframes = FrameEvents.image_keyframes or FrameEvents.imageKeyframes

				if not (imageLabel and image_keyframes and image_keyframes.imagelabel) then
					return
				end

				local imagelabel = image_keyframes.imagelabel
				local imageColor = imagelabel.ImageColor3 and interpolateValue(imagelabel.ImageColor3, p, "Color3")

				if imageColor then
					imageLabel.ImageColor3 = imageColor
				end

				if imagelabel.ImageTransparency then
					local imageTransparency = interpolateValue(imagelabel.ImageTransparency, p, "number")

					if imageTransparency ~= nil then
						imageLabel.ImageTransparency = imageTransparency
					end
				end
			end

			local function fn()
				if flag2 then
					return
				end

				flag2 = true
				flag3 = false
				run_context.running = false

				for _, connection in pairs(v5.connections) do
					if not connection then
						continue
					end

					local connection2 = connection
					pcall(function()
						connection2:Disconnect()
					end)
				end

				local thread = coroutine.running()

				for _, task2 in pairs(v5.tasks) do
					if not (task2 and task2 ~= thread) then
						continue
					end

					local v11 = task2
					pcall(function()
						task.cancel(v11)
					end)
				end

				for _, tween in pairs(v5.tweens) do
					if not tween then
						continue
					end

					local v11 = tween
					pcall(function()
						v11:Cancel()
					end)
				end

				for _, particle in pairs(v5.particles) do
					if not particle then
						continue
					end

					local v11 = particle
					pcall(function()
						v11.Enabled = false
					end)
				end

				for _, beam in pairs(v5.beams) do
					if not beam then
						continue
					end

					local v11 = beam
					pcall(function()
						v11.Enabled = false
					end)
				end

				for _, trail in pairs(v5.trails) do
					if not trail then
						continue
					end

					local v11 = trail
					pcall(function()
						v11.Enabled = false
					end)
				end

				for _, light in pairs(v5.lights) do
					if not light then
						continue
					end

					local v11 = light
					pcall(function()
						v11.Enabled = false
					end)
				end

				if isme and currentCamera then
					currentCamera.CameraType = Enum.CameraType.Custom
					currentCamera.FieldOfView = S_FOV

					for k, v11 in pairs(v) do
						Lighting[k] = v11
					end
				end

				for _, object in pairs(v5.objects) do
					if not object then
						continue
					end

					local v11 = object
					pcall(function()
						v11:Destroy()
					end)
				end

				v9 = nil
				v10 = nil
				v5.connections = {}
				v5.objects = {}
				v5.tweens = {}
				v5.particles = {}
				v5.beams = {}
				v5.trails = {}
				v5.lights = {}
				v5.tasks = {}
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function Clean()
				if flag then
					return
				end

				flag = true

				if parentChangedConnection then
					parentChangedConnection:Disconnect()
					parentChangedConnection = nil
				end

				if fn then
					fn()
				end
			end

			if bind then
				parentChangedConnection = bind:GetPropertyChangedSignal("Parent"):Connect(function()
					if not (bind and bind.Parent) then
						Clean() -- equivalent call inferred; original call site unknown
					end
				end)
			end

			task.delay(15, function()
				if flag then
					return
				end

				flag = true

				if parentChangedConnection then
					parentChangedConnection:Disconnect()
					parentChangedConnection = nil
				end

				if fn then
					fn()
				end
			end)

			if cancontinue() then
				local function runCutscene()
					if flag3 then
						return
					end

					local humanoidRootPart = char and char:FindFirstChild("HumanoidRootPart")

					if not humanoidRootPart then
						return
					end

					local misc = script:FindFirstChild("Misc")
					local VFX = script:FindFirstChild("VFX")

					if not (misc and VFX) then
						return
					end

					local thrown = Workspace:FindFirstChild("Thrown") or Workspace
					local v11 = humanoidRootPart.CFrame * CFrame.new(0, -3, 0)
					local cameraRigbasic

					if isme then
						cameraRigbasic = char:WaitForChild("CameraRigbasic", 2)

						if cameraRigbasic then
							if cameraRigbasic then
								mark(true) -- equivalent call inferred; original call site unknown
							end

							table.insert(v5.objects, cameraRigbasic)

							if cleanupTable then
								table.insert(cleanupTable, cameraRigbasic)
							end

							destroyLater(cameraRigbasic) -- equivalent call inferred; original call site unknown
						end
					end

					local highlight

					if FrameEvents.highlight_keyframes or FrameEvents.highlightKeyframes then
						local v12, v13
						highlight, v12, v13 = Instance.new("Highlight")

						if highlight then
							markTree(highlight) -- equivalent call inferred; original call site unknown
							table.insert(v5.objects, highlight)

							if cleanupTable and not v13 then
								table.insert(cleanupTable, highlight)
							end

							if not v12 then
								destroyLater(highlight) -- equivalent call inferred; original call site unknown
							end
						end

						highlight.OutlineTransparency = 1
						highlight.FillTransparency = 1
						highlight.Parent = char
					else
						highlight = nil
					end

					local mask = misc:FindFirstChild("Mask")
					local clone

					if mask then
						local v12, v13
						clone, v12, v13 = mask:Clone()

						if clone then
							markTree(clone) -- equivalent call inferred; original call site unknown
							table.insert(v5.objects, clone)

							if cleanupTable and not v13 then
								table.insert(cleanupTable, clone)
							end

							if not v12 then
								destroyLater(clone) -- equivalent call inferred; original call site unknown
							end
						end

						clone:PivotTo(v11)
						setModelVisible(clone, false)
						local rootPart = clone:FindFirstChild("RootPart")
						local torso = rootPart and rootPart:FindFirstChild("Torso")
						local head = char:FindFirstChild("Head")

						if torso and head then
							pcall(function()
								torso.Part0 = head
							end)
						end

						trackTreeEffects(clone) -- equivalent call inferred; original call site unknown
						clone.Parent = thrown
					end

					local clone2, v12, v13 = VFX:Clone()

					if clone2 then
						markTree(clone2) -- equivalent call inferred; original call site unknown
						table.insert(v5.objects, clone2)

						if cleanupTable and not v13 then
							table.insert(cleanupTable, clone2)
						end

						if not v12 then
							destroyLater(clone2) -- equivalent call inferred; original call site unknown
						end
					end

					clone2.Name = "VFX"
					pivotModelToPositionPreservingRotation(clone2, humanoidRootPart.Position) -- equivalent call inferred; original call site unknown
					trackTreeEffects(clone2) -- equivalent call inferred; original call site unknown
					clone2.Parent = thrown
					local v14 = {}
					local characterVFX = misc:FindFirstChild("characterVFX")

					if characterVFX then
						local children = characterVFX:GetChildren()

						for _, part in pairs(char:GetChildren()) do
							if not (part:IsA("BasePart") and part.Name ~= "HumanoidRootPart") then
								continue
							end

							local v15 = {
								all = {},
								byName = {}
							}
							v14[part.Name] = v15

							for _, v16 in pairs(children) do
								local clone3, v17, v18 = v16:Clone()

								if clone3 then
									markTree(clone3) -- equivalent call inferred; original call site unknown
									table.insert(v5.objects, clone3)

									if cleanupTable and not v18 then
										table.insert(cleanupTable, clone3)
									end

									if not v17 then
										destroyLater(clone3) -- equivalent call inferred; original call site unknown
									end
								end

								trackTreeEffects(clone3) -- equivalent call inferred; original call site unknown
								clone3.Parent = part
								table.insert(v15.all, clone3)
								local clones = v15.byName[clone3.Name]

								if not clones then
									clones = {}
									v15.byName[clone3.Name] = clones
								end

								table.insert(clones, clone3)
							end
						end
					end

					local imageLabel

					if isme and misc:FindFirstChild("BackgroundUI") and localPlayer then
						local clone3, v15, v16 = misc.BackgroundUI:Clone()

						if clone3 then
							markTree(clone3) -- equivalent call inferred; original call site unknown
							table.insert(v5.objects, clone3)

							if cleanupTable and not v16 then
								table.insert(cleanupTable, clone3)
							end

							if not v15 then
								destroyLater(clone3) -- equivalent call inferred; original call site unknown
							end
						end

						clone3.Parent = localPlayer.PlayerGui
						imageLabel = clone3:FindFirstChild("ImageLabel")
					else
						imageLabel = nil
					end

					local v15 = {
						user = realAnim
					}

					if cameraRigbasic and cameraRigbasic:FindFirstChild("AnimationController") then
						for _, cutscene in pairs(cameraRigbasic.AnimationController:GetPlayingAnimationTracks()) do
							v15.cutscene = cutscene
						end
					end

					local v16 = {
						character = char,
						cameraRig = cameraRigbasic,
						camera_rig = cameraRigbasic,
						Mask = clone,
						mask = clone,
						vfx = clone2,
						backgroundImage = imageLabel,
						background_image = imageLabel,
						characterVFX = v14,
						character_vfx = v14,
						run_context = run_context,
						cleanup_objects = v5.objects,
						cleanup_connections = v5.connections,
						cleanup_tasks = v5.tasks,
						isme = isme
					}
					flag3 = true
					v5.connections.renderStepped = RunService.RenderStepped:Connect(function()
						if flag2 then
							return
						end

						if cancontinue() then
							v7 = v15.user.TimePosition * 60

							if isme then
								updateFov(v7) -- equivalent call inferred; original call site unknown
								updateBrightness(v7)
								updateColorCorrection(v7)
								updateAmbient(v7) -- equivalent call inferred; original call site unknown
								updateHighlights(highlight, v7)
								updateImageLabel(imageLabel, v7)
							end

							executeFrameEvents(v7, v16)
						else
							Clean() -- equivalent call inferred; original call site unknown
						end
					end)
				end

				v5.connections.playerRemoving = Players.PlayerRemoving:Connect(function(player)
					if player == localPlayer then
						Clean() -- equivalent call inferred; original call site unknown
					end
				end)
				local success, result = pcall(runCutscene)

				if not success then
					warn("Speedster cutscene error:", result)
					Clean() -- equivalent call inferred; original call site unknown
				end
			else
				Clean() -- equivalent call inferred; original call site unknown
			end
		else
			local SpeedsterOutside = require(script.Parent.SpeedsterOutside)
			SpeedsterOutside.FirstEvent(data)
		end
	end
}