local AdminPanel = {}
local localPlayer = game.Players.LocalPlayer
local PartUtil = require(game.ReplicatedStorage.Modules.Part.PartUtil)
require(game.ReplicatedStorage.Modules.Util.Trove)
local Flags = require(game.ReplicatedStorage.Modules.Flags)
local HIDDEN_SKILLS_ENABLED = Flags.HIDDEN_SKILLS_ENABLED == true
local v = nil
local v2 = {
	Main = true,
	Backpack = true,
	Notifications = true
}
local v3 = {
	NPCIdle = "rbxassetid://108906185034712",
	NPCOpenLaptop = "rbxassetid://72723699164857",
	NPCOpenLaptopLoop = "rbxassetid://91903070929234",
	OpenLaptop = "rbxassetid://127835559697452"
}

local function cloneNPC(mysteriousScientist)
	local _RealPivot = mysteriousScientist:GetAttribute("_RealPivot") or mysteriousScientist:GetPivot()
	local hideCF = _RealPivot * CFrame.new(0, -(mysteriousScientist:GetExtentsSize().Y + 10), 0)
	local clone = mysteriousScientist:Clone()
	local descendants = clone:GetDescendants()
	table.insert(descendants, clone)

	for _, instance in pairs(descendants) do
		if instance:IsA("BillboardGui") or instance:IsA("Animator") or instance.Name == "SHOP" then
			instance:Destroy()
		end

		for _, tag in pairs(game.CollectionService:GetTags(instance)) do
			game.CollectionService:RemoveTag(instance, tag)
		end
	end

	table.clear(descendants)
	mysteriousScientist:PivotTo(hideCF)
	clone:PivotTo(_RealPivot)
	clone.Name = "AdminCutsceneDummy"
	clone.Parent = workspace
	return {
		Model = clone,
		SpawnCF = _RealPivot,
		HideCF = hideCF
	}
end

local function toggleGuis(items)
	if items then
		for _, item in pairs(items) do
			item.Enabled = true
		end

		return nil
	else
		local screenGuis = {}
		local playerGui = localPlayer:FindFirstChild("PlayerGui")

		if not playerGui then
			return screenGuis
		end

		for childName in v2 do
			local screenGui = playerGui:FindFirstChild(childName)

			if not screenGui then
				continue
			end

			if screenGui:IsA("ScreenGui") then
				table.insert(screenGuis, screenGui)
				screenGui.Enabled = false
			else
				warn((`toHide/{childName} is not a screenGui`))
			end
		end

		return screenGuis
	end
end

local function adminPanelOptionSelected(_)
	return {
		Text = { "Ah... you've heard of my new discovery. I'll show it to you, but don't tell anyone else." },
		Option1 = {
			Label = "Ok",
			JumpTo = function()
				AdminPanel.playCutscene()
				return {
					Text = { "..." }
				}
			end
		}
	}
end

local function loadAnimation(parent, list)
	local humanoid = parent:FindFirstChildOfClass("Humanoid")
	local animationController = parent:FindFirstChildOfClass("AnimationController")
	local parent2 = humanoid or animationController or nil
	assert(parent2, parent.Name)
	local v5 = parent2:FindFirstChild("Animator")

	if not v5 then
		v5 = Instance.new("Animator")
		local assert_2 = assert(v5)
		assert_2.Parent = parent2
	end

	local tracks = {}

	for i = 1, #list do
		local v6 = list[i]
		local animation = Instance.new("Animation")
		animation.Name = v6
		animation.AnimationId = v6
		animation.Parent = parent
		local track = v5:LoadAnimation(animation)

		for k, v7 in pairs(v3) do
			if v7 == v6 then
				tracks[k] = track
			end
		end
	end

	return tracks
end

function AdminPanel.playCutscene()
	local maid = nil
	local success, result = pcall(function()
		if not HIDDEN_SKILLS_ENABLED then
			return false
		end

		v = v or require(game.ReplicatedStorage.Controllers.UI.HiddenAbilitiesWindow)
		v:_prewarm()
		local mysteriousScientist = workspace.NPCs:FindFirstChild("Mysterious Scientist")

		if mysteriousScientist then
			local Trove = require(game.ReplicatedStorage.Modules.Util.Trove)
			maid = Trove.new()
			assert(maid):Add(function()
				maid = nil
			end)
			local NPC = cloneNPC(mysteriousScientist)
			local clone = script.BriefcaseLaptop:Clone()
			clone.Parent = NPC.Model
			local rootPart = clone:WaitForChild("RootPart", 1)
			local rightHand = NPC.Model:WaitForChild("RightHand", 1)
			clone:PivotTo(rightHand.CFrame * CFrame.Angles(1.5707963267948966, 0, -1.5707963267948966))
			local weld = PartUtil.weld(rootPart, rightHand)
			weld.C0 *= CFrame.new(0.5, clone:GetExtentsSize().Y / 1.5, 0)
			local v4 = loadAnimation(NPC.Model, { v3.NPCIdle, v3.NPCOpenLaptop, v3.NPCOpenLaptopLoop })
			local v5 = loadAnimation(clone, { v3.OpenLaptop })
			local v6 = assert((toggleGuis()))
			local fieldOfView = workspace.CurrentCamera.FieldOfView
			local pivot = localPlayer.Character:GetPivot()
			localPlayer.Character:PivotTo(NPC.Model:GetPivot() * CFrame.new(-15, 0, -5))
			maid:Add(function()
				v4.NPCIdle:Stop()
				v4.NPCOpenLaptop:Stop()
				v4.NPCOpenLaptopLoop:Stop()
				v5.OpenLaptop:Stop()
				NPC.Model:Destroy()
				mysteriousScientist:PivotTo(NPC.SpawnCF)
				workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
				workspace.CurrentCamera.FieldOfView = fieldOfView
				toggleGuis(v6)

				if localPlayer.Character then
					localPlayer.Character:PivotTo(pivot)
				end
			end)
			v4.NPCIdle:Play()
			local cFrame = NPC.Model:FindFirstChild("Head").CFrame
			workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
			workspace.CurrentCamera.CFrame = CFrame.new((cFrame * CFrame.new(0, 0, -8)).Position, cFrame.Position)
			local screenGui = Instance.new("ScreenGui")
			screenGui.DisplayOrder = 2
			screenGui.IgnoreGuiInset = true
			screenGui.ResetOnSpawn = false
			screenGui.Enabled = false
			local frame = Instance.new("Frame")
			frame.Size = UDim2.fromScale(1, 1)
			frame.BackgroundColor3 = Color3.new(1, 1, 1)
			frame.Parent = screenGui
			screenGui.Parent = localPlayer.PlayerGui
			local maid2 = maid
			local TweenService = game:GetService("TweenService")
			local v7 = maid2:Add(TweenService:Create(workspace.CurrentCamera, TweenInfo.new(1), {
				FieldOfView = 50,
				CFrame = CFrame.new((cFrame * CFrame.new(0, 0, -12)).Position, cFrame.Position)
			}))
			v7:Play()
			v7.Completed:Wait()
			local maid3 = maid
			local TweenService2 = game:GetService("TweenService")
			local v8 = maid3:Add(TweenService2:Create(workspace.CurrentCamera, TweenInfo.new(0.3), {
				FieldOfView = 120,
				CFrame = CFrame.new((cFrame * CFrame.new(0, 0, -5)).Position, cFrame.Position)
			}))
			v8:Play()
			v8.Completed:Wait()
			v4.NPCIdle:Stop()
			v4.NPCOpenLaptop:Play()
			v5.OpenLaptop:Play()
			local TweenService3 = game:GetService("TweenService")
			TweenService3:Create(weld, TweenInfo.new(0.7), {
				C1 = CFrame.new(0, -0.5, 0)
			}):Play()
			task.delay(1.1, function()
				v5.OpenLaptop:AdjustSpeed(0)
			end)
			v4.NPCOpenLaptop.Stopped:Wait()
			v4.NPCOpenLaptop:Stop()
			v4.NPCOpenLaptopLoop:Play()
			local maid4 = maid
			local TweenService4 = game:GetService("TweenService")
			local v9 = maid4:Add(TweenService4:Create(workspace.CurrentCamera, TweenInfo.new(0.2), {
				FieldOfView = 20,
				CFrame = CFrame.new((cFrame * CFrame.new(0, 0, -2)).Position, cFrame.Position)
			}))
			v9:Play()
			v9.Completed:Wait()
			screenGui.Enabled = true
			local maid5 = maid
			local TweenService5 = game:GetService("TweenService")
			maid5:Add(TweenService5:Create(frame, TweenInfo.new(1), {
				BackgroundTransparency = 1
			})):Play()
			task.delay(1.2, function()
				screenGui.Enabled = false
				screenGui:Destroy()
			end)
		else
			warn("Could not find scientist - if streaming is on, it's because we aren't near it")
		end

		if v then
			v:Open()
		end

		if maid then
			maid:Destroy()
		end

		if v then
			v:WaitForClose()
		end

		return true
	end)

	if not success and result then
		warn(result)
	end

	if maid then
		maid:Destroy()
	end
end

function AdminPanel.option(p)
	if HIDDEN_SKILLS_ENABLED then
		return {
			Label = "Admin Panel",
			JumpTo = function()
				return (adminPanelOptionSelected(p))
			end
		}
	end

	return nil
end

return AdminPanel