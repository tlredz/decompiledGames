local TweenService = game:GetService("TweenService")
local parent = script.Parent
local parent2 = parent.Parent
local particles = parent2.Particles
local parent3 = parent2.Parent
task.spawn(function()
	while true do
		TweenService:Create(parent, TweenInfo.new(1), {
			Offset = Vector2.new(0.8, 0)
		}):Play()
		task.wait(0.2)
		particles.ParticleEmitter.Enabled = true
		task.wait(0.15)
		particles.ParticleEmitter.Enabled = false
		task.wait(5)
		parent.Offset = Vector2.new(-0.8, 0)
	end
end)
parent3.Changed:Connect(function()
	parent2.Visible = parent3.Text ~= ""
	parent2.Text = parent3.Text
end)