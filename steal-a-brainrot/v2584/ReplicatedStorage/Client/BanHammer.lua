local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ContentProvider = game:GetService("ContentProvider")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ActionController = require(ReplicatedStorage.Controllers.ActionController)
local Janitor = require(ReplicatedStorage.UserGenerated.Lang.Janitor)
require(ReplicatedStorage.UserGenerated.Lang.WCall)
local Net = require(ReplicatedStorage.Packages.Net)
local CharacterUtils = require(ReplicatedStorage.Utils.CharacterUtils)
local Bindable = require(ReplicatedStorage.UserGenerated.Concurrency.Bindable)
local NightVisionController = require(ReplicatedStorage.Controllers.ItemController.NightVisionController)
local remoteFunction = Net:RemoteFunction("Tools/BanHammer/Charge")
local remoteEvent = Net:RemoteEvent("Tools/BanHammer/Release")
local banHammer = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Tools"):WaitForChild("Ban Hammer")
local Flags = require(banHammer.Flags)
local indicator = banHammer:WaitForChild("Indicator")
local runningAnimation = banHammer:WaitForChild("RunningAnimation")
local idleAnimation = banHammer:WaitForChild("IdleAnimation")
task.spawn(ContentProvider.PreloadAsync, ContentProvider, banHammer:GetDescendants())
script:WaitForChild("Equipped").Event:Connect(function(instance)
	local playerFromCharacter

	if instance.Parent:IsA("Model") then
		playerFromCharacter = Players:GetPlayerFromCharacter(instance.Parent)
	else
		playerFromCharacter = instance.Parent.Parent
	end

	assert(playerFromCharacter and playerFromCharacter:IsA("Player"))
	local character = playerFromCharacter.Character and playerFromCharacter.Character.Parent == workspace and playerFromCharacter.Character or playerFromCharacter.CharacterAdded:Wait()
	local v = assert(character:WaitForChild("HumanoidRootPart", 15))
	local v2 = assert(character:WaitForChild("Humanoid", 15))
	assert(v2:WaitForChild("Animator", 15))
	local maid = Janitor.new()
	CharacterUtils:SetAnimations(character, "walk", { runningAnimation })
	CharacterUtils:SetAnimations(character, "run", { runningAnimation })
	CharacterUtils:SetAnimations(character, "idle", { idleAnimation })
	maid:Add(function()
		CharacterUtils:RevertAllAnimations(character)
	end)
	NightVisionController.Enable()
	maid:Add(function()
		NightVisionController.Disable()
	end)

	local function IsValid()
		return not not v.Parent and not (v2.Health <= 0) and not playerFromCharacter:GetAttribute("Stealing")
	end

	local flag = false
	maid:Add(ActionController.Pressed:Connect(function(_, _)
		local v3

		if v.Parent and not (v2.Health <= 0) then
			v3 = not playerFromCharacter:GetAttribute("Stealing")
		else
			v3 = false
		end

		if not v3 or flag then
			return
		end

		flag = true
		local maid2 = Janitor.new()
		local clone = indicator:Clone()
		local main = clone.Main
		maid2:Add(function()
			if clone.Parent then
				local tween = TweenService:Create(
					main,
					TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Transparency = 1
					}
				)
				tween:Play()
				tween.Completed:Wait()
			end

			clone:Destroy()
		end)
		local v4 = false
		maid2:Add(RunService.RenderStepped:Connect(function(_)
			local chargeRadius = instance:GetAttribute("ChargeRadius")
			local chargePercent = instance:GetAttribute("ChargePercent") or 0
			local v5 = v2.HipHeight + 0.5 * v.Size.Y
			clone:PivotTo(v.CFrame * CFrame.new(0, -v5, 0) * Flags.SlamOffset)

			if chargeRadius then
				main.Size = Vector3.new(main.Size.X, chargeRadius * 2, chargeRadius * 2)
				clone.Parent = workspace

				if chargePercent >= 1 and not v4 then
					v4 = true
					TweenService:Create(main, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Transparency = 0.5,
						Color = Color3.fromRGB(97, 173, 255)
					}):Play()
				end
			end
		end))
		local thread = coroutine.running()
		maid2:Add(ActionController.Released:Connect(function()
			task.spawn(thread, false)
		end))
		maid2:Add(maid.Destroying:Connect(function()
			task.spawn(thread, true)
		end))
		local v5 = Bindable.new()
		local v6 = false
		task.spawn(function()
			local success, result = pcall(remoteFunction.InvokeServer, remoteFunction)

			if not (success and result or maid2:IsDestroyed()) then
				task.spawn(thread, nil)
			end

			v6 = true
			v5:Fire()
		end)
		local v7 = coroutine.yield()
		maid2:Destroy()

		if v7 ~= nil then
			remoteEvent:FireServer(v7)
		end

		if not v6 then
			v5:Wait()
		end

		flag = false
	end))
	instance.Unequipped:Connect(function()
		maid:Destroy()
	end)
	v2.Died:Once(function()
		maid:Destroy()
	end)
	instance.AncestryChanged:Connect(function(p)
		if p ~= character then
			maid:Destroy()
		end
	end)
end)