--!strict
-- Handles clicking/tapping with the held tool: picks the bread, plays a fast swing,
-- and tells the server which bread was hit. The server decides the actual damage.

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local GameConfig = require(ReplicatedStorage.Configurations.GameConfig)
local SmashHit = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("SmashHit") :: RemoteEvent

local player = Players.LocalPlayer
local mouse = player:GetMouse()

local lastSwing = 0
local swinging = false
local connectedTools: { [Tool]: boolean } = {}

local function isAliveBread(instance: Instance?): boolean
	if not instance or not instance:IsA("Model") or not CollectionService:HasTag(instance, "Bread") then
		return false
	end
	local health = instance:GetAttribute("Health")
	return typeof(health) == "number" and health > 0
end

local function distanceTo(root: BasePart, bread: Model): number
	return (bread:GetPivot().Position - root.Position).Magnitude
end

-- The bread under the cursor, or (so taps on mobile are forgiving) the nearest one in front of the player.
local function findTarget(root: BasePart): Model?
	local hit: Instance? = mouse.Target
	while hit and hit ~= workspace do
		if isAliveBread(hit) then
			local bread = hit :: Model
			if distanceTo(root, bread) <= GameConfig.Combat.MaxHitDistance - 2 then
				return bread
			end
			break
		end
		hit = hit.Parent
	end

	local best: Model? = nil
	local bestDistance = GameConfig.Combat.AutoAimRange
	for _, tagged in CollectionService:GetTagged("Bread") do
		if isAliveBread(tagged) then
			local bread = tagged :: Model
			local offset = bread:GetPivot().Position - root.Position
			local infront = offset.Unit:Dot(root.CFrame.LookVector) > 0
			if infront and offset.Magnitude < bestDistance then
				best = bread
				bestDistance = offset.Magnitude
			end
		end
	end
	return best
end

local function getShoulder(character: Model): (Motor6D?, boolean)
	local upperArm = character:FindFirstChild("RightUpperArm") -- R15
	local r15Shoulder = upperArm and upperArm:FindFirstChild("RightShoulder")
	if r15Shoulder and r15Shoulder:IsA("Motor6D") then
		return r15Shoulder, true
	end

	local torso = character:FindFirstChild("Torso") -- R6
	local r6Shoulder = torso and torso:FindFirstChild("Right Shoulder")
	if r6Shoulder and r6Shoulder:IsA("Motor6D") then
		return r6Shoulder, false
	end
	return nil, false
end

-- Fast overhead smash: wind up, slam down, recover (about 0.23s total).
-- `onStrike` runs at the moment of impact so the hit lines up with the animation.
local function playSwing(character: Model, onStrike: () -> ())
	local motor, isR15 = getShoulder(character)
	if not motor then
		onStrike()
		return
	end

	swinging = true
	task.spawn(function()
		local baseC0 = motor.C0
		local function pose(degrees: number): CFrame
			local angle = math.rad(degrees)
			return baseC0 * (if isR15 then CFrame.Angles(angle, 0, 0) else CFrame.Angles(0, 0, -angle))
		end

		local ok = pcall(function()
			local windup = TweenService:Create(motor, TweenInfo.new(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { C0 = pose(70) })
			windup:Play()
			windup.Completed:Wait()

			local strike = TweenService:Create(motor, TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { C0 = pose(-45) })
			strike:Play()
			onStrike()
			strike.Completed:Wait()

			local recover = TweenService:Create(motor, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { C0 = baseC0 })
			recover:Play()
			recover.Completed:Wait()
		end)
		if not ok then
			onStrike()
		end
		if motor.Parent then
			motor.C0 = baseC0
		end
		swinging = false
	end)
end

local function onActivated()
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not (character and humanoid and root and root:IsA("BasePart")) or humanoid.Health <= 0 then
		return
	end

	local now = os.clock()
	if swinging or now - lastSwing < GameConfig.Combat.SwingCooldown then
		return
	end
	lastSwing = now

	local target = findTarget(root)
	playSwing(character, function()
		-- Always swing, but only tell the server when there's something to hit.
		if target and target.Parent then
			SmashHit:FireServer(target)
		end
	end)
end

local function watchTool(tool: Instance)
	if tool:IsA("Tool") and not connectedTools[tool] then
		connectedTools[tool] = true
		tool.Activated:Connect(onActivated)
		tool.Destroying:Connect(function()
			connectedTools[tool] = nil
		end)
	end
end

local function onCharacterAdded(character: Model)
	swinging = false
	for _, child in character:GetChildren() do
		watchTool(child)
	end
	character.ChildAdded:Connect(watchTool)
end

player.CharacterAdded:Connect(onCharacterAdded)
if player.Character then
	onCharacterAdded(player.Character)
end
