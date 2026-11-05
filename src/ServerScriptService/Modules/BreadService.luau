--!strict
-- Spawns White Bread targets in the red zone, tracks their health, shows the
-- name tag + health bar, and handles death and respawn.

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local GameConfig = require(ReplicatedStorage.Configurations.GameConfig)
local PlaceholderModels = require(script.Parent.PlaceholderModels)
local PlayerData = require(script.Parent.PlayerData)

local SpawnParticle = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("SpawnParticle") :: RemoteEvent

local BREAD_TAG = "Bread" -- the client finds breads by this tag

local BreadService = {}

local zone: BasePart? = nil
local breadFolder: Folder? = nil
local slots: { [number]: Model? } = {}
local healthBars: { [Model]: { Fill: Frame, Label: TextLabel } } = setmetatable({}, { __mode = "k" }) :: any

-- Zone ---------------------------------------------------------------------

local function getZone(): BasePart
	local existing = Workspace:FindFirstChild(GameConfig.Zone.Name)
	if existing and existing:IsA("BasePart") then
		return existing
	end

	local part = Instance.new("Part")
	part.Name = GameConfig.Zone.Name
	part.Anchored = true
	part.Size = GameConfig.Zone.Size
	part.Position = GameConfig.Zone.Position
	part.Color = Color3.fromRGB(220, 40, 40)
	part.Material = Enum.Material.SmoothPlastic
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = Workspace

	-- Low neon rim so the boundary reads clearly (low enough to step over)
	local size = part.Size
	local rimColor = Color3.fromRGB(255, 90, 90)
	local rimTop = part.Position.Y + size.Y / 2
	local rims = {
		{ Vector3.new(size.X, 0.6, 0.6), Vector3.new(0, 0, size.Z / 2 - 0.3) },
		{ Vector3.new(size.X, 0.6, 0.6), Vector3.new(0, 0, -size.Z / 2 + 0.3) },
		{ Vector3.new(0.6, 0.6, size.Z), Vector3.new(size.X / 2 - 0.3, 0, 0) },
		{ Vector3.new(0.6, 0.6, size.Z), Vector3.new(-size.X / 2 + 0.3, 0, 0) },
	}
	for _, rim in rims do
		local rimPart = Instance.new("Part")
		rimPart.Name = "Rim"
		rimPart.Anchored = true
		rimPart.Size = rim[1]
		rimPart.Position = Vector3.new(part.Position.X + rim[2].X, rimTop + 0.3, part.Position.Z + rim[2].Z)
		rimPart.Color = rimColor
		rimPart.Material = Enum.Material.Neon
		rimPart.Parent = part
	end

	return part
end

local function pickSpot(): Vector3
	local zonePart = zone :: BasePart
	local halfX = zonePart.Size.X / 2 - GameConfig.Zone.EdgeMargin
	local halfZ = zonePart.Size.Z / 2 - GameConfig.Zone.EdgeMargin

	local taken: { Vector3 } = {}
	for _, bread in slots do
		if bread then
			table.insert(taken, bread:GetPivot().Position)
		end
	end

	local best = zonePart.Position
	for _ = 1, 30 do
		local candidate = zonePart.Position + Vector3.new((math.random() * 2 - 1) * halfX, 0, (math.random() * 2 - 1) * halfZ)
		local clear = true
		for _, other in taken do
			local flat = Vector3.new(other.X - candidate.X, 0, other.Z - candidate.Z)
			if flat.Magnitude < GameConfig.Spawner.MinSpacing then
				clear = false
				break
			end
		end
		best = candidate
		if clear then
			break
		end
	end
	return best
end

-- Health bar + name tag ------------------------------------------------------

local function updateHealthBar(bread: Model)
	local bar = healthBars[bread]
	if not bar then
		return
	end
	local health = bread:GetAttribute("Health") :: number
	local maxHealth = bread:GetAttribute("MaxHealth") :: number
	local ratio = math.clamp(health / maxHealth, 0, 1)
	bar.Fill.Size = UDim2.fromScale(ratio, 1)
	bar.Fill.BackgroundColor3 = Color3.fromHSV(ratio * 0.33, 0.8, 0.95) -- green when full, red when low
	bar.Label.Text = `{math.ceil(health)}/{maxHealth}`
end

local function addBillboard(bread: Model, stats: GameConfig.BreadStats)
	local primary = bread.PrimaryPart :: BasePart
	local boxCFrame, boxSize = bread:GetBoundingBox()
	local height = (boxCFrame.Position.Y + boxSize.Y / 2) - primary.Position.Y

	local gui = Instance.new("BillboardGui")
	gui.Name = "HealthBillboard"
	gui.Adornee = primary
	gui.Size = UDim2.fromOffset(200, 56)
	gui.StudsOffsetWorldSpace = Vector3.new(0, height + 1.6, 0)
	gui.MaxDistance = 120
	gui.LightInfluence = 0
	gui.ResetOnSpawn = false

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "NameTag"
	nameLabel.BackgroundTransparency = 1
	nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
	nameLabel.Font = Enum.Font.GothamBlack
	nameLabel.TextSize = 20
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextStrokeTransparency = 0
	nameLabel.Text = `{stats.DisplayName} [{stats.Health} HP]`
	nameLabel.Parent = gui

	local background = Instance.new("Frame")
	background.Name = "BarBackground"
	background.AnchorPoint = Vector2.new(0.5, 0)
	background.Position = UDim2.fromScale(0.5, 0.56)
	background.Size = UDim2.new(0.9, 0, 0.36, 0)
	background.BackgroundColor3 = Color3.fromRGB(35, 25, 25)
	background.BorderSizePixel = 0
	background.Parent = gui

	local backgroundCorner = Instance.new("UICorner")
	backgroundCorner.CornerRadius = UDim.new(0, 8)
	backgroundCorner.Parent = background

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 2
	stroke.Color = Color3.fromRGB(0, 0, 0)
	stroke.Parent = background

	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.Size = UDim2.fromScale(1, 1)
	fill.BackgroundColor3 = Color3.fromHSV(0.33, 0.8, 0.95)
	fill.BorderSizePixel = 0
	fill.Parent = background

	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(0, 8)
	fillCorner.Parent = fill

	local hpLabel = Instance.new("TextLabel")
	hpLabel.Name = "HP"
	hpLabel.BackgroundTransparency = 1
	hpLabel.Size = UDim2.fromScale(1, 1)
	hpLabel.Font = Enum.Font.GothamBold
	hpLabel.TextSize = 14
	hpLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	hpLabel.TextStrokeTransparency = 0.3
	hpLabel.ZIndex = 2
	hpLabel.Parent = background

	gui.Parent = primary
	healthBars[bread] = { Fill = fill, Label = hpLabel }
	updateHealthBar(bread)
end

-- Spawning --------------------------------------------------------------------

local function spawnBread(slot: number)
	local stats = GameConfig.Breads.WhiteBread
	local zonePart = zone :: BasePart

	local bread = PlaceholderModels.GetBreadModel(stats.ModelName):Clone()
	bread.Name = stats.ModelName

	-- Place it on the zone, facing the center so its face looks inward
	local spot = pickSpot()
	local center = Vector3.new(zonePart.Position.X, 0, zonePart.Position.Z)
	local flatSpot = Vector3.new(spot.X, 0, spot.Z)
	local facing = if (center - flatSpot).Magnitude > 0.1 then CFrame.lookAt(flatSpot, center) else CFrame.new(flatSpot)
	bread:PivotTo(facing)

	-- Drop the bottom of the model onto the zone's top surface
	local boxCFrame, boxSize = bread:GetBoundingBox()
	local bottom = boxCFrame.Position.Y - boxSize.Y / 2
	local zoneTop = zonePart.Position.Y + zonePart.Size.Y / 2
	bread:PivotTo(bread:GetPivot() + Vector3.new(0, zoneTop - bottom, 0))

	bread:SetAttribute("BreadType", stats.ModelName)
	bread:SetAttribute("MaxHealth", stats.Health)
	bread:SetAttribute("Health", stats.Health)
	bread:SetAttribute("Slot", slot)
	CollectionService:AddTag(bread, BREAD_TAG)

	addBillboard(bread, stats)
	bread.Parent = breadFolder
	slots[slot] = bread
end

local function killBread(bread: Model, attacker: Player)
	local stats = GameConfig.Breads[bread:GetAttribute("BreadType") :: string]
	local slot = bread:GetAttribute("Slot") :: number
	local position = bread:GetPivot().Position

	-- Crumb burst for everyone nearby
	SpawnParticle:FireAllClients("Break", position, {})

	if attacker.Parent == Players then
		local boxCFrame, boxSize = bread:GetBoundingBox()
		local above = Vector3.new(position.X, boxCFrame.Position.Y + boxSize.Y / 2 + 1, position.Z)
		PlayerData.AddRewards(attacker, stats.YeastReward, stats.CashReward, above)
	end

	slots[slot] = nil
	bread:Destroy()

	task.delay(GameConfig.Spawner.RespawnSeconds, spawnBread, slot)
end

-- Public API ------------------------------------------------------------------------

-- Applies damage from `attacker`. Returns true if the hit landed.
function BreadService.Damage(bread: Model, amount: number, attacker: Player): boolean
	local health = bread:GetAttribute("Health")
	if typeof(health) ~= "number" or health <= 0 then
		return false
	end

	local newHealth = math.max(0, health - amount)
	bread:SetAttribute("Health", newHealth)
	updateHealthBar(bread)

	local boxCFrame, boxSize = bread:GetBoundingBox()
	local top = Vector3.new(boxCFrame.Position.X, boxCFrame.Position.Y + boxSize.Y / 2, boxCFrame.Position.Z)
	SpawnParticle:FireAllClients("Damage", top, { Amount = amount, Bread = bread })

	if newHealth <= 0 then
		killBread(bread, attacker)
	end
	return true
end

function BreadService.Start()
	PlaceholderModels.EnsureAll()
	zone = getZone()

	local folder = Instance.new("Folder")
	folder.Name = "Breads"
	folder.Parent = Workspace
	breadFolder = folder

	for slot = 1, GameConfig.Spawner.WhiteBreadCount do
		spawnBread(slot)
	end
end

return BreadService
