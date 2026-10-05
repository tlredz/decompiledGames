local parent = script.Parent
local animator = parent:WaitForChild("Humanoid"):WaitForChild("Animator")
local FacialExpressions = require(script:WaitForChild("FacialExpressions"))
FacialExpressions:Setup(animator, parent)