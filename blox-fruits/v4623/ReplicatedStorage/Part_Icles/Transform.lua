local TypeRegistry = require(script.Parent.TypeRegistry)
require(script.Parent.PartConstants)
return function(p)
	if not p.TransformCompleted then
		p.TransformCompleted = Instance.new("BindableEvent")
	end

	function p:Transform(instance)
		if instance:GetAttribute("Transformed") then
			return
		end

		local typeFor = TypeRegistry.getTypeFor(instance)

		if not typeFor then
			if instance:IsA("BasePart") and instance:GetAttribute("IsLightning") and TypeRegistry.Types.Lightning then
				typeFor = TypeRegistry.Types.Lightning
			elseif instance:IsA("BasePart") and instance:GetAttribute("IsCameraShake") and TypeRegistry.Types.CameraShake then
				typeFor = TypeRegistry.Types.CameraShake
			elseif instance:IsA("BasePart") and instance:GetAttribute("IsRocks") and TypeRegistry.Types.Rocks then
				typeFor = TypeRegistry.Types.Rocks
			elseif instance:IsA("BasePart") and instance:GetAttribute("IsRope") and TypeRegistry.Types.Rope then
				typeFor = TypeRegistry.Types.Rope
			else
				return
			end
		end

		local v = typeFor == TypeRegistry.Types.Lightning
		local v2 = typeFor == TypeRegistry.Types.CameraShake
		local v3 = typeFor == TypeRegistry.Types.Rocks
		local v4 = typeFor == TypeRegistry.Types.Rope

		if typeFor.directAccess then
			if instance:IsA("Trail") and TypeRegistry.Types.TrailEmitter then
				typeFor = TypeRegistry.Types.TrailEmitter
			elseif instance:IsA("Beam") and TypeRegistry.Types.Beam then
				typeFor = TypeRegistry.Types.Beam
			else
				return
			end
		end

		if instance:IsA("Model") then
			return self:TransformModel(instance, typeFor)
		end

		local config = TypeRegistry.createConfig(instance, typeFor)
		local clone = instance:Clone()
		clone.Name = "RenderTemplate"

		for _, child in clone:GetChildren() do
			if child:GetAttribute("Transformed") or child:IsA("Attachment") then
				continue
			end

			if child.Name == TypeRegistry.CONFIG_NAME or child.Name == "EmitParent" or child.Name == "Link" or child.Name == "AccelTarget" or child.Name == "Target" or child.Name == "ImageFlipbooks" then
				child:Destroy()
			elseif instance:IsA("PointLight") or instance:IsA("Highlight") then
				child:Destroy()
			elseif instance:IsA("Attachment") then
				if child.Name == "MeshFlipbooks" or child.Name == "BeamFlipbooks" or child.Name == "GraphBlender" then
					child:Destroy()
				end
			elseif instance:IsA("ImageLabel") then
				if not child:IsA("UIComponent") then
					child:Destroy()
				end
			elseif not (child:IsA("SpecialMesh") or child:IsA("Decal") or child:IsA("Texture") or child:IsA("SurfaceAppearance")) then
				child:Destroy()
			end
		end

		for _, v5 in ipairs({
			"Transformed",
			"Qwinkle",
			"IsEmitter",
			"EmitCount",
			"EmitDuration",
			"EmitDelay",
			"EmissionMode",
			"AnimateLoop",
			"PreloadTexture",
			"LinkMode",
			"LinkSource"
		}) do
			clone:SetAttribute(v5, nil)
		end

		if clone:IsA("BasePart") then
			clone.Anchored = true
			clone.CanCollide = false
			clone.CanQuery = false
			clone.CanTouch = false
			clone.CastShadow = false
			clone.Massless = true
			clone.Locked = true
			clone.Transparency = 1

			for _, child in ipairs(clone:GetChildren()) do
				if child:IsA("Decal") or child:IsA("Texture") then
					child.Transparency = 1
				end
			end
		end

		if clone:IsA("Attachment") then
			clone.CFrame = CFrame.new()
		end

		for _, effect in ipairs(clone:GetDescendants()) do
			if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) or effect:GetAttribute("Transformed") then
				continue
			end

			effect.Enabled = false
		end

		clone.Parent = instance

		if instance:IsA("BasePart") and not (instance:IsA("Terrain") or v2) then
			local size = instance.Size
			local specialMesh = instance:FindFirstChildWhichIsA("SpecialMesh")

			if specialMesh then
				size = specialMesh.Scale
			end

			local color = instance.Color
			local transparency = instance.Transparency

			if instance:FindFirstChildWhichIsA("SurfaceAppearance") == nil then
				local decal = instance:FindFirstChildWhichIsA("Decal")

				if decal then
					color = decal.Color3
					transparency = decal.Transparency
				end
			end

			if v or v4 then
				config:SetAttribute(
					"Thickness",
					NumberSequence.new((math.max(0.05, (math.min(instance.Size.X, instance.Size.Y)))))
				)
			elseif not v3 then
				config:SetAttribute("SizeX", NumberSequence.new(size.X))
				config:SetAttribute("SizeY", NumberSequence.new(size.Y))
				config:SetAttribute("SizeZ", NumberSequence.new(size.Z))
			end

			config:SetAttribute("Color", ColorSequence.new(color))
			config:SetAttribute("Transparency", NumberSequence.new(transparency))
		end

		if instance:IsA("BasePart") then
			for _, child in ipairs(instance:GetChildren()) do
				if not (child ~= clone and (child:IsA("SpecialMesh") or child:IsA("Decal") or child:IsA("Texture"))) then
					continue
				end

				child:Destroy()
			end

			instance.Transparency = 1

			if v3 then
				instance.CanCollide = false
			end
		elseif instance:IsA("PointLight") then
			instance.Enabled = false
		elseif instance:IsA("Highlight") then
			instance.Enabled = false
		elseif instance:IsA("PostProcessEffect") then
			instance.Enabled = false
		elseif instance:IsA("ImageLabel") then
			instance.Visible = false
		end

		if instance:IsA("PointLight") then
			config:SetAttribute("Shadows", instance.Shadows)
		end

		if instance:IsA("BlurEffect") then
			config:SetAttribute("BlurSize", NumberSequence.new(instance.Size))
		elseif instance:IsA("BloomEffect") then
			config:SetAttribute("BloomIntensity", NumberSequence.new(instance.Intensity))
			config:SetAttribute("BloomSize", NumberSequence.new(instance.Size))
			config:SetAttribute("BloomThreshold", NumberSequence.new(instance.Threshold))
		elseif instance:IsA("ColorCorrectionEffect") then
			config:SetAttribute("CCBrightness", NumberSequence.new(instance.Brightness))
			config:SetAttribute("CCContrast", NumberSequence.new(instance.Contrast))
			config:SetAttribute("CCSaturation", NumberSequence.new(instance.Saturation))
			config:SetAttribute("CCTintColor", ColorSequence.new(instance.TintColor))
		elseif instance:IsA("Atmosphere") then
			config:SetAttribute("AtmDensity", NumberSequence.new(instance.Density))
			config:SetAttribute("AtmOffset", NumberSequence.new(instance.Offset))
			config:SetAttribute("AtmGlare", NumberSequence.new(instance.Glare))
			config:SetAttribute("AtmHaze", NumberSequence.new(instance.Haze))
			config:SetAttribute("AtmColor", ColorSequence.new(instance.Color))
			config:SetAttribute("AtmDecay", ColorSequence.new(instance.Decay))
		elseif instance:IsA("Highlight") then
			config:SetAttribute("HLFillColor", ColorSequence.new(instance.FillColor))
			config:SetAttribute("HLFillTransparency", NumberSequence.new(instance.FillTransparency))
			config:SetAttribute("HLOutlineColor", ColorSequence.new(instance.OutlineColor))
			config:SetAttribute("HLOutlineTransparency", NumberSequence.new(instance.OutlineTransparency))
			config:SetAttribute("HLDepthMode", instance.DepthMode.Name)

			if not instance:FindFirstChild("Adornee") then
				local objectValue = Instance.new("ObjectValue")
				objectValue.Name = "Adornee"
				objectValue.Value = nil
				objectValue.Parent = instance
			end
		end

		if clone:IsA("PostProcessEffect") then
			clone.Enabled = false
		end

		if instance:IsA("ImageLabel") then
			if clone:IsA("ImageLabel") then
				clone.Visible = false
			end

			if instance.BackgroundTransparency == 0 then
				instance.BackgroundTransparency = 1
			end

			config:SetAttribute("Image", instance.Image)
			config:SetAttribute("Position", instance.Position)
			config:SetAttribute("ImgSize", instance.Size)
			config:SetAttribute("AnchorPoint", instance.AnchorPoint)
			config:SetAttribute("ZIndex", instance.ZIndex)
			config:SetAttribute("ScaleType", instance.ScaleType.Name)
			config:SetAttribute("ResampleMode", instance.ResampleMode.Name)

			if not instance:FindFirstChild("ImageFlipbooks") then
				local folder = Instance.new("Folder")
				folder.Name = "ImageFlipbooks"
				folder.Parent = instance
			end
		end

		if instance:IsA("BasePart") and not (instance:IsA("Terrain") or v or v2 or v3 or v4 or instance:FindFirstChild("MeshFlipbooks")) then
			local folder = Instance.new("Folder")
			folder.Name = "MeshFlipbooks"
			folder.Parent = instance
		end

		if instance:IsA("Trail") then
			instance.Enabled = false

			if clone:IsA("Trail") then
				clone.Enabled = false
			end

			if not instance:FindFirstChild("GraphBlender") then
				local folder = Instance.new("Folder")
				folder.Name = "GraphBlender"
				local configuration = Instance.new("Configuration")
				configuration.Name = "1"
				configuration:SetAttribute("Time", 0)
				configuration:SetAttribute("Width", instance.WidthScale or NumberSequence.new(1))
				configuration:SetAttribute("Transparency", instance.Transparency or NumberSequence.new(0))
				configuration:SetAttribute("Color", instance.Color or ColorSequence.new(Color3.new(1, 1, 1)))
				configuration:SetAttribute("_AutoTime", true)
				configuration.Parent = folder
				folder.Parent = instance
			end

			if not instance:FindFirstChild("TrailFlipbooks") then
				local folder = Instance.new("Folder")
				folder.Name = "TrailFlipbooks"
				folder.Parent = instance
			end
		end

		if instance:IsA("Beam") then
			instance.Enabled = false
			instance.LightInfluence = 0

			if clone:IsA("Beam") then
				clone.Enabled = false
				clone.LightInfluence = 0
			end

			if not instance:FindFirstChild("BeamFlipbooks") then
				local folder = Instance.new("Folder")
				folder.Name = "BeamFlipbooks"
				folder.Parent = instance
			end

			config:SetAttribute("BeamBrightness", NumberSequence.new(instance.Brightness))
			config:SetAttribute("CurveSize0", NumberSequence.new(instance.CurveSize0))
			config:SetAttribute("CurveSize1", NumberSequence.new(instance.CurveSize1))
			config:SetAttribute("Width0", NumberSequence.new(instance.Width0))
			config:SetAttribute("Width1", NumberSequence.new(instance.Width1))
			config:SetAttribute("LightEmission", NumberSequence.new(instance.LightEmission))
			config:SetAttribute("BeamLightInfluence", NumberSequence.new(0))
			config:SetAttribute("Segments", NumberSequence.new(instance.Segments))
			config:SetAttribute("TextureLength", NumberSequence.new(instance.TextureLength))
			config:SetAttribute("TextureSpeed", NumberSequence.new(instance.TextureSpeed))
			config:SetAttribute("FaceCamera", instance.FaceCamera)
			config:SetAttribute("ZOffset", instance.ZOffset)
			config:SetAttribute("BeamTextureMode", instance.TextureMode.Name)
			local folder = Instance.new("Folder")
			folder.Name = "GraphBlender"
			local configuration = Instance.new("Configuration")
			configuration.Name = "1"
			configuration:SetAttribute("Time", 0)
			configuration:SetAttribute("Transparency", instance.Transparency)
			configuration:SetAttribute("Color", instance.Color)
			configuration:SetAttribute("_AutoTime", true)
			configuration.Parent = folder
			folder.Parent = instance
		end

		if not instance:FindFirstChild("EmitParent") then
			local objectValue = Instance.new("ObjectValue")
			objectValue.Name = "EmitParent"
			objectValue.Value = nil
			objectValue.Parent = instance
		end

		if (instance:IsA("BasePart") or instance:IsA("Attachment")) and not (v or v2 or v3 or v4 or instance:FindFirstChild("Link")) then
			local objectValue = Instance.new("ObjectValue")
			objectValue.Name = "Link"
			objectValue.Parent = instance
		end

		if instance:IsA("BasePart") and not (v or v2 or v3 or v4 or instance:FindFirstChild("AccelTarget")) then
			local objectValue = Instance.new("ObjectValue")
			objectValue.Name = "AccelTarget"
			objectValue.Value = nil
			objectValue.Parent = instance
		end

		if instance:IsA("BasePart") and not (v2 or v3 or v4 or instance:FindFirstChild("ShapePart")) then
			local objectValue = Instance.new("ObjectValue")
			objectValue.Name = "ShapePart"
			objectValue.Value = instance
			objectValue.Parent = instance
		end

		if (v or v4) and not instance:FindFirstChild("Target") then
			local objectValue = Instance.new("ObjectValue")
			objectValue.Name = "Target"
			objectValue.Value = nil
			objectValue.Parent = instance
		end

		instance:SetAttribute("Transformed", true)
		instance:SetAttribute("Qwinkle", true)
		local HttpService = game:GetService("HttpService")
		instance:SetAttribute("_EvenCycleId", HttpService:GenerateGUID(false))
		instance:SetAttribute("EmitCount", (instance:IsA("Beam") or v or v2 or v3 or v4) and 1 or 0)
		instance:SetAttribute("EmitDuration", 0)
		instance:SetAttribute("EmitDelay", 0)
		instance:SetAttribute("IsEmitter", true)

		if instance:IsA("BasePart") or instance:IsA("Beam") or instance:IsA("Trail") or instance:IsA("ImageLabel") then
			instance:SetAttribute("PreloadTexture", false)
		end

		instance:SetAttribute("EmissionMode", instance:IsA("Atmosphere") and "Animate" or "Emit")
		instance:SetAttribute("AnimateLoop", false)

		if instance:IsA("BasePart") and not (v or v2 or v3 or v4) or instance:IsA("Beam") or instance:IsA("Attachment") or instance:IsA("Model") then
			instance:SetAttribute("LinkMode", "Follow")
			instance:SetAttribute("LinkSource", "None")
		end

		pcall(function()
			p.TransformCompleted:Fire(instance)
		end)
	end

	function p:TransformModel(folder, p2)
		if folder:GetAttribute("Transformed") then
			return
		end

		TypeRegistry.createConfig(folder, p2)
		local clone = folder:Clone()
		clone.Name = "RenderTemplate"

		for _, child in clone:GetChildren() do
			if not (child.Name == TypeRegistry.CONFIG_NAME or child.Name == "EmitParent" or child.Name == "Link" or child.Name == "AccelTarget") then
				continue
			end

			child:Destroy()
		end

		for _, v in ipairs({
			"Transformed",
			"Qwinkle",
			"IsEmitter",
			"EmitCount",
			"EmitDuration",
			"EmitDelay",
			"EmissionMode",
			"AnimateLoop"
		}) do
			clone:SetAttribute(v, nil)
		end

		for _, descendant in clone:GetDescendants() do
			if descendant:IsA("BasePart") then
				descendant.Anchored = true
				descendant.CanCollide = false
				descendant.CanQuery = false
				descendant.CanTouch = false
				descendant.CastShadow = false
				descendant.Massless = true
				descendant.Locked = true
			elseif (descendant:IsA("ParticleEmitter") or descendant:IsA("Trail")) and not descendant:GetAttribute("Transformed") then
				descendant.Enabled = false
			end
		end

		clone.Parent = folder

		for _, descendant in ipairs(folder:GetDescendants()) do
			if descendant:IsDescendantOf(clone) then
				continue
			end

			if descendant:IsA("BasePart") then
				descendant.Transparency = 1
			elseif descendant:IsA("SpecialMesh") or descendant:IsA("Decal") or descendant:IsA("Texture") then
				descendant:Destroy()
			end
		end

		if not folder:FindFirstChild("EmitParent") then
			local objectValue = Instance.new("ObjectValue")
			objectValue.Name = "EmitParent"
			objectValue.Value = nil
			objectValue.Parent = folder
		end

		if not folder:FindFirstChild("Link") then
			local objectValue = Instance.new("ObjectValue")
			objectValue.Name = "Link"
			objectValue.Parent = folder
		end

		folder:SetAttribute("Transformed", true)
		folder:SetAttribute("Qwinkle", true)
		folder:SetAttribute("EmitCount", 0)
		folder:SetAttribute("EmitDuration", 0)
		folder:SetAttribute("EmitDelay", 0)
		folder:SetAttribute("IsEmitter", true)
		folder:SetAttribute("PreloadTexture", false)
		folder:SetAttribute("EmissionMode", "Emit")
		folder:SetAttribute("AnimateLoop", false)
		folder:SetAttribute("LinkMode", "Follow")
		folder:SetAttribute("LinkSource", "None")
		pcall(function()
			p.TransformCompleted:Fire(folder)
		end)
	end
end