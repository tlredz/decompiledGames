local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local WrappedChic = {}
WrappedChic.Name = "Wrapped Chic"
WrappedChic.TowerName = "Glisten"
WrappedChic.Description = "No description yet"
WrappedChic.Mastery = false
WrappedChic.Cost = 600
WrappedChic.Halloween = true
WrappedChic.HolidaySkin = true
WrappedChic.HolidayYear = 2025
WrappedChic.OverwriteAnimations = {
	Walk = "rbxassetid://104571130641665",
	Idle = "rbxassetid://82719473418324",
	Quirk = "rbxassetid://77287678850219",
	Ability = "rbxassetid://131884488856002",
	Decode = "rbxassetid://138374997415979",
	Run = "rbxassetid://106337088953284"
}
WrappedChic.FaceTextures = {
	Normal = "rbxassetid://137649860545018",
	Blink = "rbxassetid://105681164742942",
	Hurt = "rbxassetid://75726660851108"
}
WrappedChic.USE_SKIN_MODEL = true

function WrappedChic.ApplySkin(_) end

function WrappedChic.UseAbility(instance, _, instance2, p, _, p2, p3)
	local glistenPortal = ReplicatedStorage.Parts.RenderModules.GlistenPortal

	local function CreateMirror(p4, _)
		local clone = glistenPortal.GlistenMirror:Clone()
		local head = instance:FindFirstChild("Head")

		if head and head:IsA("MeshPart") then
			clone.TextureID = "rbxassetid://18839177988"
		end

		local particleEmitter = clone:FindFirstChild("ParticleEmitter")

		if particleEmitter then
			particleEmitter.Color = ColorSequence.new(Color3.new(1, 1, 1))
			particleEmitter.LightEmission = 1
			particleEmitter.LightInfluence = 0
			particleEmitter.Brightness = 1
		end

		clone.Transparency = 1
		TweenInfo.new(5, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false)
		local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false)
		local size = clone.Size
		clone.Size = Vector3.new(size.X * 0.8, size.Y * 0.8, size.Z * 0.8)
		clone.Parent = workspace
		clone.Anchored = true
		clone.CanCollide = false
		clone.CanQuery = false
		clone.CastShadow = false
		clone.CanTouch = false
		clone.Position = p4.Position + Vector3.new(0, -p2 + clone.Size.Y / 2 + 0.25, 0)
		task.spawn(function()
			local v = {
				CFrame = clone.CFrame * CFrame.Angles(0, 2.7401669256310974, 0)
			}
			clone.ParticleEmitter:Emit(10)
			TweenService:Create(
				clone,
				TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out, 0, false),
				{
					Size = size,
					Transparency = 0
				}
			):Play()
			local tween = TweenService:Create(
				clone,
				TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, 0),
				v
			)
			tween:Play()
			tween.Completed:Wait()
			local tween2 = TweenService:Create(clone, tweenInfo, {
				Size = createVector(0, 0, 0),
				Transparency = 1
			})
			tween2:Play()
			TweenService:Create(
				clone,
				TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, false, 0),
				{
					CFrame = clone.CFrame * CFrame.Angles(0, 3.12413936106985, 0)
				}
			):Play()
			task.wait(1)
			tween2:Pause()
			tween2:Destroy()
		end)
		Debris:AddItem(clone, 2)
	end

	local clone = glistenPortal.GlistenPoof:Clone()
	TweenInfo.new(5, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false)
	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)
	CreateMirror(p)
	CreateMirror(instance2.CFrame)
	clone.Parent = workspace
	clone.Anchored = true
	clone.CanCollide = false
	clone.CanQuery = false
	clone.CastShadow = false
	clone.CanTouch = false
	clone.Size = createVector(0, 0.25, 0)
	clone.Position = p.Position + Vector3.new(0, -p2 + 0.25, 0)
	Debris:AddItem(clone, 3)
	local clone2 = glistenPortal.GlistenDash:Clone()
	clone2.Parent = workspace
	local _ = instance2.Position
	clone2.Size = Vector3.new(clone2.Size.X, clone2.Size.Y, (instance2.Position - p.Position).Magnitude)
	local cframe = CFrame.new(0, 0, -(instance2.Position - p.Position).Magnitude / 2)
	clone2.CFrame = CFrame.new(p.Position, instance2.Position) * cframe
	clone2.Anchored = true
	clone2.CanCollide = false
	clone2.CanQuery = false
	clone2.CanTouch = false
	TweenService:Create(clone2, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0), {
		Size = Vector3.new(clone2.Size.X, clone2.Size.Y * 1.5, (instance2.Position - p.Position).Magnitude),
		Transparency = 1
	}):Play()
	Debris:AddItem(clone2, 3)
	TweenService:Create(clone, tweenInfo, {
		Size = createVector(25, 0.25, 25),
		Transparency = 1,
		CFrame = clone.CFrame * CFrame.new(0, 0.25, 0) * CFrame.Angles(0, 2.7401669256310974, 0)
	}):Play()
	local clone3 = glistenPortal.GlistenPoof:Clone()
	TweenInfo.new(5, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false)
	local tweenInfo3 = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)
	clone3.Parent = workspace
	clone3.Anchored = true
	clone3.CanCollide = false
	clone3.CanQuery = false
	clone3.CastShadow = false
	clone3.CanTouch = false
	clone3.Size = createVector(0, 0.25, 0)
	clone3.Position = instance2.CFrame.Position + Vector3.new(0, -p3 + 0.25, 0)
	Debris:AddItem(clone3, 3)
	TweenService:Create(clone3, tweenInfo3, {
		Size = createVector(25, 0.25, 25),
		Transparency = 1,
		CFrame = clone3.CFrame * CFrame.new(0, 0.25, 0) * CFrame.Angles(0, 2.7401669256310974, 0)
	}):Play()
end

return WrappedChic