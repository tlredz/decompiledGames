local Headcam = {
	Btn = 1,
	SortOrder = 10,
	Desc = "yo clip this chat"
}
local renderSteppedConnection = nil
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
game:GetService("ContextActionService")
game.Players.LocalPlayer:GetMouse()
local v = 0

function Headcam.Callback(p)
	if p == true and not renderSteppedConnection then
		renderSteppedConnection = RunService.RenderStepped:Connect(function()
			local character = game.Players.LocalPlayer.Character

			if character and character:FindFirstChild("Head") then
				workspace.CurrentCamera.CFrame = character.Head.CFrame
				workspace.CurrentCamera.CameraSubject = character.Head
				workspace.CurrentCamera.FieldOfView = 90

				for _, descendant in character:GetDescendants() do
					if descendant:IsA("BasePart") then
						if descendant.Name == "Head" then
							descendant.LocalTransparencyModifier = 1
						elseif descendant.Parent.Parent:IsA("Accessory") and (descendant:FindFirstChild("HatAttachment") or descendant:FindFirstChild("HairAttachment") or descendant:FindFirstChild("FaceFrontAttachment") or descendant:FindFirstChild("FaceCenterAttachment") or descendant:FindFirstChild("NeckAttachment")) then
							descendant.LocalTransparencyModifier = 1
						else
							descendant.LocalTransparencyModifier = 0
						end
					elseif descendant:IsA("ParticleEmitter") and (descendant:IsDescendantOf(character.Head) or descendant.Parent.Name == "Head") then
						descendant.Enabled = false
					end
				end

				local mouseDelta = UserInputService:GetMouseDelta()

				if character:GetAttribute("Ragdoll") <= 0 and character.Humanoid.AutoRotate and not (character:GetAttribute("Stun") or character:GetAttribute("Emote")) then
					character.HumanoidRootPart.CFrame = character.HumanoidRootPart.CFrame * CFrame.Angles(
						0,
						math.rad(-mouseDelta.X),
						0
					)
				end

				v = math.clamp(v - mouseDelta.Y, -90, 90)
				workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame * CFrame.Angles(math.rad(v), 0, 0)
			end
		end)
	elseif renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
		workspace.CurrentCamera.FieldOfView = 70
		local character = game.Players.LocalPlayer.Character

		if character then
			workspace.CurrentCamera.CameraSubject = character.Humanoid
		end
	end
end

return Headcam