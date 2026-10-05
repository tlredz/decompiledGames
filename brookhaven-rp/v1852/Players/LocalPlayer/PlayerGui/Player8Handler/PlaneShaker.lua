local shaker = script:WaitForChild("Shaker")

while true do
	wait(30)
	shaker.Disabled = false
	wait(5)
	shaker.Disabled = true
	wait(55)
	shaker.Disabled = false
	wait(3)
	shaker.Disabled = true
	wait(45)
	shaker.Disabled = false
	wait(4)
	shaker.Disabled = true
end