local createVector = vector.create
task.wait(0.2)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local pets = require(ReplicatedStorage:WaitForChild("Database"):WaitForChild("Sync")).Pets
local Weld = require(script.Weld)
local _ = game.Workspace:FindFirstChild("TreeBases") == nil
local parts = {}
local pets2 = game.ReplicatedStorage.Pets
local RunService = game:GetService("RunService")
RunService.PreSimulation:connect(function()
	for _, child in game.Workspace:GetChildren() do
		local pet = child:FindFirstChild("Pet")

		if not (pet and pet:IsA("StringValue") and child:FindFirstChild("HumanoidRootPart")) then
			continue
		end

		local value = pet.Value

		if not pets2:FindFirstChild(value) then
			continue
		end

		local body = pet:FindFirstChild("Body")

		if body then
			local position = child.HumanoidRootPart.Position
			local v = body.Position - position
			local vector2 = position + Vector3.new(v.x, 0, v.z).unit * 3 + Vector3.new(0, math.sin((tick())) * 1 + 2, 0)

			if pet:GetAttribute("Walking") then
				local worldSpace = CFrame.new(vector2):toWorldSpace(CFrame.new(createVector(0, -1, 0)))
				local ray = Ray.new(vector2, (worldSpace.p - vector2).unit * 100)
				local part, v2 = game.Workspace:FindPartOnRayWithIgnoreList(ray, { child, unpack(parts) })

				if part and (part.Transparency >= 1 or part.CanCollide == false) then
					table.insert(parts, part)
				end

				if v2 then
					vector2 = Vector3.new(vector2.X, v2.Y + body.Size.Y / 2 + 0.2, vector2.Z)
				end
			end

			body.Float.position = vector2
			body.Rotate.cframe = child.HumanoidRootPart.CFrame

			if game.Players:GetPlayerFromCharacter(child):DistanceFromCharacter(body.Position) >= 50 then
				body.CFrame = child.HumanoidRootPart.CFrame
			end

			if child == game.Players.LocalPlayer.Character and _G.IsFirstPerson == true then
				if body.Transparency ~= 1 then
					body.Transparency = 0.8
				end

				body.NameTag.Enabled = false
				local ScanEffects
				local ScanEffects2 = ScanEffects

				ScanEffects = function(body2)
					for i, child2 in pairs(body2:GetChildren()) do
						if not child2.Name == "NameTag" and (child2:IsA("ParticleEmitter") or child2:IsA("Fire") or child2:IsA("Trail") or child2:IsA("Beam")) then
							child2.Enabled = false
						end

						if child2:IsA("BasePart") and child2.Transparency ~= 1 then
							child2.Transparency = 0.9
						end

						ScanEffects2(child2)
					end
				end

				ScanEffects(body)
			elseif child:FindFirstChild("UpperTorso") then
				if body.Transparency ~= 1 then
					body.Transparency = child.UpperTorso.Transparency
				end

				local enabled = child.UpperTorso.Transparency < 0.5

				if body:FindFirstChild("NameTag") then
					body.NameTag.Enabled = enabled
				end

				local ScanEffects
				local v4 = child
				local ScanEffects2 = ScanEffects

				ScanEffects = function(body2)
					for i, child2 in pairs(body2:GetChildren()) do
						if child2:IsA("ParticleEmitter") or child2:IsA("Fire") or child2:IsA("Trail") or child2:IsA("Beam") then
							child2.Enabled = enabled
						end

						if child2:IsA("Decal") then
							child2.Transparency = v4.UpperTorso.Transparency
						end

						if child2:IsA("BasePart") and child2.Transparency ~= 1 then
							child2.Transparency = v4.UpperTorso.Transparency
						end

						ScanEffects2(child2)
					end
				end

				ScanEffects(body)
			end
		else
			local clone = pets2[value]:Clone()
			clone.Name = "Body"
			Weld(clone)
			local position = child.HumanoidRootPart.Position
			local v = clone.Position - position
			local _ = position + Vector3.new(v.x, 0, v.z).unit * 3 + Vector3.new(0, math.sin((tick())) * 1 + 2, 0)
			clone.CFrame = child.HumanoidRootPart.CFrame
			local bodyPosition = Instance.new("BodyPosition")
			bodyPosition.Name = "Float"
			bodyPosition.Parent = clone
			bodyPosition.position = child.HumanoidRootPart.Position + createVector(1, 1, 1)
			local bodyGyro = Instance.new("BodyGyro")
			bodyGyro.Name = "Rotate"
			bodyGyro.Parent = clone
			bodyGyro.cframe = child.HumanoidRootPart.CFrame
			bodyGyro.maxTorque = createVector(40000, 20000, 40000)
			clone.Anchored = false
			clone.CanCollide = false
			clone.Parent = pet
			local clone2 = script.PetTag:Clone()
			clone2.Name = "NameTag"
			clone2.Enabled = true
			local petName = pet:GetAttribute("PetName") ~= "" and pet:GetAttribute("PetName") or pets[value].Name
			local GuiService = game:GetService("GuiService")

			if GuiService:IsTenFootInterface() then
				petName = pets[value].Name
			end

			clone2.Tag.Text = petName
			clone2.StudsOffset = Vector3.new(0, clone.Size.Y / 2 + 0.5, 0)
			clone2.Enabled = true
			clone2.Parent = clone
		end
	end
end)