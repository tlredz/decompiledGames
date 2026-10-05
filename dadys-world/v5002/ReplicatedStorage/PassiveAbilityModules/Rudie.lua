local Workspace = game:GetService("Workspace")
local Rudie = {}

function Rudie.Initialize(instance, p)
	print("Rudie Passive: Initializing Guiding Light for", p.Name)
	local humanoid = instance:FindFirstChild("Humanoid")
	local stats = instance:FindFirstChild("Stats")
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if not (humanoid and stats and humanoidRootPart) then
		warn("Rudie Passive: Missing required character components")
		return function() end
	end

	local info = Workspace:FindFirstChild("Info")

	if not info then
		warn("Rudie Passive: Info folder not found in workspace")
		return function() end
	end

	local blackOut = info:FindFirstChild("BlackOut")

	if not blackOut then
		warn("Rudie Passive: BlackOut value not found in Info")
		return function() end
	end

	local v = {}

	local function update()
		local enabled = blackOut.Value == true
		local currentSkin = instance:GetAttribute("CurrentSkin") or "Default"
		local nose = instance:FindFirstChild("Nose")
		print("Rudie Passive: Update called - Blackout:", enabled, "Skin:", currentSkin)

		if not nose then
			warn("Rudie Passive: Could not find nose!")
			return
		end

		if not nose:GetAttribute("OriginalTransparency") then
			nose:SetAttribute("OriginalTransparency", nose.Transparency)
			nose:SetAttribute("OriginalMaterial", nose.Material.Name)
			nose:SetAttribute("OriginalColor", nose.Color)

			if nose:IsA("MeshPart") and nose.TextureID ~= "" then
				nose:SetAttribute("OGT", nose.TextureID)
			end
		end

		local blackoutColor = nose:GetAttribute("BlackoutColor") or Color3.fromRGB(206, 31, 39)
		nose.Transparency = enabled and 0 or nose:GetAttribute("OriginalTransparency") or 1
		local originalMaterial = nose:GetAttribute("OriginalMaterial")
		local neon = originalMaterial and Enum.Material[originalMaterial] or Enum.Material.Plastic
		nose.Color = enabled and blackoutColor or nose:GetAttribute("OriginalColor") or BrickColor.new("Medium stone grey").Color

		if nose:IsA("MeshPart") then
			nose.TextureID = enabled and "" or nose:GetAttribute("OGT") or ""
		end

		if enabled then
			neon = Enum.Material.Neon or neon
		end

		nose.Material = neon
		print(
			"Rudie Passive: Set nose - transparency:",
			nose.Transparency,
			"material:",
			nose.Material.Name,
			"blackout:",
			enabled
		)
		local toonLight = humanoidRootPart:FindFirstChild("ToonLight")
		local pointLight = toonLight and toonLight:FindFirstChild("PointLight")

		if pointLight then
			pointLight.Enabled = enabled
			print("Rudie Passive: ToonLight set to", enabled)
		end

		local count = 0

		for _, child in pairs(humanoidRootPart:GetChildren()) do
			if child.Name ~= "ExtraLight" then
				continue
			end

			local pointLight2 = child:FindFirstChild("PointLight")

			if not pointLight2 then
				continue
			end

			pointLight2.Enabled = enabled
			count += 1
		end

		if count > 0 then
			print("Rudie Passive: Set", count, "ExtraLights to", enabled)
		end

		local rootPart = instance:FindFirstChild("RootPart")
		local count2 = 0

		local function scan(folder)
			for _, light in pairs(folder:GetDescendants()) do
				if not (light:IsA("PointLight") or light:IsA("SpotLight")) then
					continue
				end

				light.Enabled = enabled
				count2 += 1
			end
		end

		if nose then
			scan(nose)
		end

		if rootPart then
			scan(rootPart)
		end

		if nose or rootPart then
			if count2 > 0 then
				print("Rudie Passive: Set", count2, "nose lights to", enabled)
			else
				print("Rudie Passive: No lights found inside nose")
			end
		end
	end

	v.blackoutConnection = blackOut:GetPropertyChangedSignal("Value"):Connect(update)
	task.spawn(update)
	return function()
		print("Rudie Passive: Cleaning up for", p.Name)

		for _, connection in pairs(v) do
			if connection then
				connection:Disconnect()
			end
		end
	end
end

function Rudie.Activate(_, _, _) end

function Rudie.Deactivate(_, _) end

function Rudie.Cleanup(instance, p)
	print("Rudie Passive: Additional cleanup for", p.Name)
	local nose = instance:FindFirstChild("Nose")

	if nose then
		local OGT = nose:GetAttribute("OGT")

		if OGT and nose:IsA("MeshPart") then
			nose.TextureID = OGT
			nose.Material = Enum.Material.Plastic
		end
	end
end

return Rudie