local localPlayer = game.Players.LocalPlayer
local character = localPlayer.Character
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

repeat
	wait()
until localPlayer:HasAppearanceLoaded() and character:GetAttribute("CustomScaleApplied")

task.wait(0.1)

for _, part in pairs(character:GetChildren()) do
	if not part:IsA("BasePart") then
		continue
	end

	if part.Name == "HumanoidRootPart" then
		part.RootPriority = 126
	end

	part.TopSurface = "Smooth"
	part.BottomSurface = "Smooth"
end

local v = {
	MammothAccessory = true
}
local now = 0

local function patchMassless()
	if tick() - now > 0.1 then
		now = tick()
		humanoidRootPart.Massless = true
		task.defer(function()
			humanoidRootPart.Massless = false
		end)
		local v2 = now

		for _ = 0, 3, 0.5 do
			if v2 ~= now then
				break
			end

			humanoidRootPart.Massless = true
			humanoidRootPart.Massless = false
			task.wait(0.5)
		end
	end
end

local function accessories()
	for _, accessory in pairs(character:GetChildren()) do
		if not accessory:IsA("Accessory") or v[accessory.Name] then
			continue
		end

		for _, part in pairs(accessory:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Massless = true
			end
		end
	end

	patchMassless()
end

accessories()

-- equivalent calls inferred from this helper; original call sites unknown
local function patchInstance(part, p)
	if part:IsA("BasePart") and (not p or part.Name ~= "Handle" and part.Name ~= "RootPart") then
		part.Massless = true
	end

	patchMassless()
end

local function gang(folder)
	local v2 = folder.ClassName == "Tool"
	local v3, RunService, descendantAddedConnection, ancestryChangedConnection, descendantAddedConnection2, ancestryChangedConnection2

	if v2 or folder.ClassName == "Model" then
		v3 = false

		for i = 1, 8 do
			if #folder:GetChildren() == 0 then
				RunService = game:GetService("RunService")
				RunService.RenderStepped:Wait()
			else
				v3 = true
				break
			end
		end

		if v3 and folder.Parent then
			if v2 then
				if not folder:GetAttribute("MassFixConnected") then
					folder:SetAttribute("MassFixConnected", true)
					descendantAddedConnection = folder.DescendantAdded:Connect(function(descendant)
						patchInstance(descendant, true) -- equivalent call inferred; original call site unknown
					end)
					ancestryChangedConnection = nil
					ancestryChangedConnection = folder.AncestryChanged:Connect(function(_, parent)
						if parent ~= character then
							folder:SetAttribute("MassFixConnected", nil)
							descendantAddedConnection:Disconnect()
							ancestryChangedConnection:Disconnect()
							descendantAddedConnection = nil
							ancestryChangedConnection = nil
						end
					end)
				end

				for i, descendant in pairs(folder:GetDescendants()) do
					patchInstance(descendant, true) -- equivalent call inferred; original call site unknown
				end
			else
				if not folder:GetAttribute("MassFixConnected") then
					folder:SetAttribute("MassFixConnected", true)
					descendantAddedConnection2 = folder.DescendantAdded:Connect(function(part)
						if part:IsA("BasePart") then
							part.Massless = true
						end

						patchMassless()
					end)
					ancestryChangedConnection2 = nil
					ancestryChangedConnection2 = folder.AncestryChanged:Connect(function(_, parent)
						if parent ~= character then
							folder:SetAttribute("MassFixConnected", nil)
							descendantAddedConnection2:Disconnect()
							ancestryChangedConnection2:Disconnect()
							descendantAddedConnection2 = nil
							ancestryChangedConnection2 = nil
						end
					end)
				end

				for i, part in pairs(folder:GetDescendants()) do
					if part:IsA("BasePart") then
						part.Massless = true
					end

					patchMassless()
				end
			end

			patchMassless()
		end
	else
		local CollectionService = game:GetService("CollectionService")

		if CollectionService:HasTag(folder, "Weapon") then
			v3 = false

			for i = 1, 8 do
				if #folder:GetChildren() == 0 then
					RunService = game:GetService("RunService")
					RunService.RenderStepped:Wait()
				else
					v3 = true
					break
				end
			end

			if v3 and folder.Parent then
				if v2 then
					if not folder:GetAttribute("MassFixConnected") then
						folder:SetAttribute("MassFixConnected", true)
						descendantAddedConnection = folder.DescendantAdded:Connect(function(descendant)
							patchInstance(descendant, true) -- equivalent call inferred; original call site unknown
						end)
						ancestryChangedConnection = nil
						ancestryChangedConnection = folder.AncestryChanged:Connect(function(_, parent)
							if parent ~= character then
								folder:SetAttribute("MassFixConnected", nil)
								descendantAddedConnection:Disconnect()
								ancestryChangedConnection:Disconnect()
								descendantAddedConnection = nil
								ancestryChangedConnection = nil
							end
						end)
					end

					for i, descendant in pairs(folder:GetDescendants()) do
						patchInstance(descendant, true) -- equivalent call inferred; original call site unknown
					end
				else
					if not folder:GetAttribute("MassFixConnected") then
						folder:SetAttribute("MassFixConnected", true)
						descendantAddedConnection2 = folder.DescendantAdded:Connect(function(part)
							if part:IsA("BasePart") then
								part.Massless = true
							end

							patchMassless()
						end)
						ancestryChangedConnection2 = nil
						ancestryChangedConnection2 = folder.AncestryChanged:Connect(function(_, parent)
							if parent ~= character then
								folder:SetAttribute("MassFixConnected", nil)
								descendantAddedConnection2:Disconnect()
								ancestryChangedConnection2:Disconnect()
								descendantAddedConnection2 = nil
								ancestryChangedConnection2 = nil
							end
						end)
					end

					for i, part in pairs(folder:GetDescendants()) do
						if part:IsA("BasePart") then
							part.Massless = true
						end

						patchMassless()
					end
				end

				patchMassless()
			end
		else
			local CollectionService2 = game:GetService("CollectionService")

			if CollectionService2:HasTag(folder, "WeaponBack") then
				v3 = false

				for i = 1, 8 do
					if #folder:GetChildren() == 0 then
						RunService = game:GetService("RunService")
						RunService.RenderStepped:Wait()
					else
						v3 = true
						break
					end
				end

				if v3 and folder.Parent then
					if v2 then
						if not folder:GetAttribute("MassFixConnected") then
							folder:SetAttribute("MassFixConnected", true)
							descendantAddedConnection = folder.DescendantAdded:Connect(function(descendant)
								patchInstance(descendant, true) -- equivalent call inferred; original call site unknown
							end)
							ancestryChangedConnection = nil
							ancestryChangedConnection = folder.AncestryChanged:Connect(function(_, parent)
								if parent ~= character then
									folder:SetAttribute("MassFixConnected", nil)
									descendantAddedConnection:Disconnect()
									ancestryChangedConnection:Disconnect()
									descendantAddedConnection = nil
									ancestryChangedConnection = nil
								end
							end)
						end

						for i, descendant in pairs(folder:GetDescendants()) do
							patchInstance(descendant, true) -- equivalent call inferred; original call site unknown
						end
					else
						if not folder:GetAttribute("MassFixConnected") then
							folder:SetAttribute("MassFixConnected", true)
							descendantAddedConnection2 = folder.DescendantAdded:Connect(function(part)
								if part:IsA("BasePart") then
									part.Massless = true
								end

								patchMassless()
							end)
							ancestryChangedConnection2 = nil
							ancestryChangedConnection2 = folder.AncestryChanged:Connect(function(_, parent)
								if parent ~= character then
									folder:SetAttribute("MassFixConnected", nil)
									descendantAddedConnection2:Disconnect()
									ancestryChangedConnection2:Disconnect()
									descendantAddedConnection2 = nil
									ancestryChangedConnection2 = nil
								end
							end)
						end

						for i, part in pairs(folder:GetDescendants()) do
							if part:IsA("BasePart") then
								part.Massless = true
							end

							patchMassless()
						end
					end

					patchMassless()
				end
			end
		end
	end
end

local function fix(accessory)
	if accessory:IsA("Accessory") then
		accessories()
	end

	gang(accessory)
end

localPlayer:WaitForChild("Backpack").ChildAdded:Connect(fix)
character.ChildAdded:Connect(fix)
character:WaitForChild("Humanoid").Died:Connect(function()
	for _, part in pairs(character:GetChildren()) do
		if part:IsA("BasePart") then
			part.Massless = false
		end
	end
end)