--!strict
-- Visual feedback: floating damage numbers, "+10 Yeast" / "+$150" pop-ups,
-- a hit flash, and the crumb burst when a bread breaks.

local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local SpawnParticle = RemoteEvents:WaitForChild("SpawnParticle") :: RemoteEvent
local UpdateData = RemoteEvents:WaitForChild("UpdateData") :: RemoteEvent

local rng = Random.new()

-- Floating text that pops in, drifts up, and fades out.
local function popup(position: Vector3, text: string, color: Color3, textSize: number, rise: number)
	local anchor = Instance.new("Part")
	anchor.Name = "PopupAnchor"
	anchor.Anchored = true
	anchor.CanCollide = false
	anchor.CanQuery = false
	anchor.CanTouch = false
	anchor.Transparency = 1
	anchor.Size = Vector3.new(0.2, 0.2, 0.2)
	anchor.Position = position
	anchor.Parent = workspace

	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.fromOffset(240, 60)
	gui.AlwaysOnTop = true
	gui.LightInfluence = 0
	gui.Adornee = anchor
	gui.Parent = anchor

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.Font = Enum.Font.GothamBlack
	label.TextSize = textSize
	label.TextColor3 = color
	label.TextStrokeColor3 = Color3.fromRGB(20, 10, 10)
	label.TextStrokeTransparency = 0
	label.Text = text
	label.Parent = gui

	local scale = Instance.new("UIScale")
	scale.Scale = 0.4
	scale.Parent = label

	TweenService:Create(scale, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
	TweenService:Create(gui, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		StudsOffsetWorldSpace = Vector3.new(0, rise, 0),
	}):Play()

	task.delay(0.55, function()
		local fade = TweenInfo.new(0.35)
		TweenService:Create(label, fade, { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
	end)
	Debris:AddItem(anchor, 1.1)
end

local function flash(bread: Instance?)
	if not bread or not bread:IsA("Model") then
		return
	end
	local highlight = Instance.new("Highlight")
	highlight.Adornee = bread
	highlight.FillColor = Color3.fromRGB(255, 255, 255)
	highlight.FillTransparency = 0.35
	highlight.OutlineTransparency = 1
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.Parent = bread
	TweenService:Create(highlight, TweenInfo.new(0.15), { FillTransparency = 1 }):Play()
	Debris:AddItem(highlight, 0.2)
end

-- Bread crumbs bursting outward.
local crumbColors = {
	Color3.fromRGB(255, 242, 205),
	Color3.fromRGB(240, 176, 84),
	Color3.fromRGB(205, 130, 50),
}

local function crumbBurst(position: Vector3)
	for _ = 1, 18 do
		local size = rng:NextNumber(0.25, 0.6)
		local crumb = Instance.new("Part")
		crumb.Name = "Crumb"
		crumb.Size = Vector3.new(size, size * rng:NextNumber(0.5, 1), size)
		crumb.Color = crumbColors[rng:NextInteger(1, #crumbColors)]
		crumb.Material = Enum.Material.SmoothPlastic
		crumb.CanTouch = false
		crumb.CanQuery = false
		crumb.CFrame = CFrame.new(position + Vector3.new(rng:NextNumber(-1.5, 1.5), rng:NextNumber(0, 2), rng:NextNumber(-1.5, 1.5)))
			* CFrame.Angles(rng:NextNumber(0, 6), rng:NextNumber(0, 6), 0)
		crumb.Parent = workspace

		local direction = Vector3.new(rng:NextNumber(-1, 1), rng:NextNumber(0.6, 1.4), rng:NextNumber(-1, 1)).Unit
		crumb.AssemblyLinearVelocity = direction * rng:NextNumber(18, 34)
		crumb.AssemblyAngularVelocity = Vector3.new(rng:NextNumber(-12, 12), rng:NextNumber(-12, 12), rng:NextNumber(-12, 12))

		task.delay(1.1, function()
			TweenService:Create(crumb, TweenInfo.new(0.4), { Transparency = 1 }):Play()
		end)
		Debris:AddItem(crumb, 1.6)
	end
end

SpawnParticle.OnClientEvent:Connect(function(kind: string, position: Vector3, data: { [string]: any }?)
	if kind == "Damage" and data then
		flash(data.Bread)
		local jitter = Vector3.new(rng:NextNumber(-1.2, 1.2), rng:NextNumber(0, 0.8), rng:NextNumber(-1.2, 1.2))
		popup(position + jitter, `-{data.Amount}`, Color3.fromRGB(255, 120, 70), 30, 3.5)
	elseif kind == "Break" then
		crumbBurst(position)
	end
end)

-- Personal pop-ups for the player who got the kill.
UpdateData.OnClientEvent:Connect(function(data: { [string]: any })
	local position = data.Position
	if typeof(position) ~= "Vector3" then
		return
	end
	if (data.GainedYeast or 0) > 0 then
		popup(position, `+{data.GainedYeast} Yeast`, Color3.fromRGB(255, 220, 90), 34, 5)
	end
	if (data.GainedCash or 0) > 0 then
		popup(position + Vector3.new(0, 1.8, 0), `+${data.GainedCash}`, Color3.fromRGB(110, 235, 120), 34, 5)
	end
end)
