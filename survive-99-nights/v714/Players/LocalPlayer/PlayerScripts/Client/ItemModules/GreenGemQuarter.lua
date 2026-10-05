local GreenGemQuarter = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local TweenService = game:GetService("TweenService")
local v = {}
local v2 = {}
Client.Events.AnimateGemMerge:Connect(function(p)
	AnimateGemMerge(p)
end)

function AnimateGemMerge(instance)
	if v2[instance] then
		return
	end

	v2[instance] = true
	task.delay(10, function()
		v2[instance] = nil
	end)
	task.spawn(function()
		local draggingAttachment = instance.PrimaryPart.DraggingAttachment

		for _, child in pairs(draggingAttachment:GetChildren()) do
			local v3 = child
			task.spawn(function()
				if v3:GetAttribute("EmitDelay") then
					task.wait(v3:GetAttribute("EmitDelay"))
				end

				v3:Emit(v3:GetAttribute("EmitCount") or 10)
			end)
		end
	end)
end

function FlashHighlight(p)
	task.spawn(function()
		local highlight = Instance.new("Highlight")
		highlight.FillColor = Color3.fromRGB(255, 255, 255)
		highlight.FillTransparency = 1
		highlight.Adornee = p
		highlight.Parent = p
		TweenService:Create(highlight, TweenInfo.new(0.06), {
			FillTransparency = 0.3
		}):Play()
		task.wait(0.1)
		TweenService:Create(highlight, TweenInfo.new(0.12), {
			FillTransparency = 1
		}):Play()
		task.wait(0.2)
		highlight.Adornee = nil
		highlight:Destroy()
	end)
end

function AttemptCombineGems(instance, instance2)
	if instance:GetAttribute("Destroyed") or instance2:GetAttribute("Destroyed") then
		print("already destroyed")
		return
	end

	if not (instance:HasTag("GreenGemPiece") and instance2:HasTag("GreenGemPiece")) then
		print("not gem piece")
		return
	end

	if instance:GetAttribute("NumberPieces") == nil or instance2:GetAttribute("NumberPieces") == nil then
		return
	end

	if instance:GetAttribute("NumberPieces") >= 4 or instance2:GetAttribute("NumberPieces") >= 4 then
		print("already full pieces")
		return
	end

	if instance:GetAttribute("Owner") == localPlayer.UserId and instance2:GetAttribute("Owner") == nil then
		instance, instance2 = instance2, instance
	end

	if instance2:GetAttribute("NumberPieces") > instance:GetAttribute("NumberPieces") then
		instance, instance2 = instance2, instance
	end

	v[instance2] = true
	v[instance] = true
	local v3 = instance:GetAttribute("NumberPieces") + instance2:GetAttribute("NumberPieces")
	local v4 = math.clamp(v3, 1, 4)
	local v5 = v3 - v4
	instance:SetAttribute("LocalPieces", v4)

	if v5 == 0 then
		instance2.Parent = game.ReplicatedStorage.TempStorage
	else
		instance2:SetAttribute("LocalPieces", v5)
	end

	if v4 == 4 then
		AnimateGemMerge(instance)
	end

	FlashHighlight(instance)
	Client.Sound.Play("GemClink", {
		Position = instance:GetPivot().Position,
		Volume = 0.4,
		VarySpeed = 0.05
	})
	local v6 = Client.Events.RequestMergeGems:InvokeServer(instance, instance2)

	if not (v6 and v6.Success) then
		instance:SetAttribute("LocalPieces", nil)
		instance2:SetAttribute("LocalPieces", nil)
		task.delay(1, function()
			instance2.Parent = workspace.Items
		end)
	end

	v[instance2] = nil
	v[instance] = nil
end

function LoadTouchZone(instance)
	instance:WaitForChild("TouchZone").Touched:Connect(function(otherPart)
		if not otherPart.Parent or instance:HasTag("IceBlock") then
			return
		end

		local parent = otherPart.Parent.Name == "Gem of the Forest Fragment" and otherPart.Parent or otherPart.Parent.Parent

		if parent.Name ~= "Gem of the Forest Fragment" or parent == instance or (v[parent] or v[instance]) then
			return
		end

		print("two gems collide")
		AttemptCombineGems(parent, instance)
	end)
end

function LoadGemPieces(instance)
	local function update()
		local localPieces = instance:GetAttribute("LocalPieces") or instance:GetAttribute("NumberPieces") or 1

		for i = 1, 4 do
			local v3 = instance["Quarter" .. i]

			for _, part in pairs(v3:GetChildren()) do
				if not part:IsA("BasePart") then
					continue
				end

				if i <= localPieces then
					if part.Name == "MetalPiece" then
						part.Transparency = 0
						part.Material = Enum.Material.Metal
					elseif part.Name == "GlassPiece" then
						part.Transparency = 0
						part.Material = Enum.Material.Glass
					elseif part.Name == "Main" then
						part.Transparency = 0.2
						part.Material = Enum.Material.Glass
					end
				else
					part.Transparency = 1
					part.Material = Enum.Material.SmoothPlastic
				end
			end
		end
	end

	update()
	instance:GetAttributeChangedSignal("NumberPieces"):Connect(update)
	instance:GetAttributeChangedSignal("LocalPieces"):Connect(update)
end

function GemPieceAdded(p)
	LoadTouchZone(p)
	LoadGemPieces(p)
end

function GreenGemQuarter.Init()
	Client.Utility.ForAllTagged("GreenGemPiece", GemPieceAdded)
end

return GreenGemQuarter