--!strict
-- Builds simple stand-in models in code so the game loop works before the real
-- Waspes meshes exist. Each one is only created if a model with that name is
-- NOT already in ReplicatedStorage/Assets/Models, so dropping in the real
-- model (same name) replaces the placeholder with no code changes.
--
-- Note: the bread is expected to be a Model with a PrimaryPart. The weapon is
-- expected to be a Tool. A real weapon mesh needs wrapping in a Tool (Handle part).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlaceholderModels = {}

local function makeFolder(name: string, parent: Instance): Folder
	local folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = parent
	return folder
end

local function getModelsFolder(): Folder
	local assets = ReplicatedStorage:FindFirstChild("Assets") or makeFolder("Assets", ReplicatedStorage)
	local models = assets:FindFirstChild("Models") or makeFolder("Models", assets)
	return models :: Folder
end

local function newPart(name: string, size: Vector3, color: Color3, parent: Instance): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Color = color
	part.Material = Enum.Material.SmoothPlastic
	part.Anchored = true
	part.CanCollide = false
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

-- A flat UI shape for the face. Positions/sizes are in pixels (50 pixels = 1 stud).
local function faceShape(parent: Instance, name: string, pos: Vector2, size: Vector2, color: Color3, round: boolean): Frame
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.Position = UDim2.fromOffset(pos.X, pos.Y)
	frame.Size = UDim2.fromOffset(size.X, size.Y)
	frame.BackgroundColor3 = color
	frame.BorderSizePixel = 0

	local corner = Instance.new("UICorner")
	corner.CornerRadius = if round then UDim.new(1, 0) else UDim.new(0, 12)
	corner.Parent = frame

	frame.Parent = parent
	return frame
end

local function addOutline(frame: Frame, thickness: number)
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = thickness
	stroke.Color = Color3.fromRGB(30, 20, 20)
	stroke.Parent = frame
end

local function buildFace(body: Part)
	local gui = Instance.new("SurfaceGui")
	gui.Name = "Face"
	gui.Face = Enum.NormalId.Front -- front = -Z, the direction the model "looks"
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 50
	gui.LightInfluence = 0
	gui.Parent = body

	local white = Color3.fromRGB(255, 255, 255)
	local black = Color3.fromRGB(25, 20, 20)

	-- Mismatched googly eyes: the funny part.
	local leftEye = faceShape(gui, "LeftEye", Vector2.new(46, 20), Vector2.new(36, 36), white, true)
	addOutline(leftEye, 3)
	faceShape(leftEye, "Pupil", Vector2.new(14, 16), Vector2.new(14, 14), black, true)

	local rightEye = faceShape(gui, "RightEye", Vector2.new(108, 8), Vector2.new(54, 54), white, true)
	addOutline(rightEye, 3)
	faceShape(rightEye, "Pupil", Vector2.new(24, 8), Vector2.new(20, 20), black, true)

	-- Rosy cheeks
	local pink = Color3.fromRGB(255, 140, 150)
	local leftCheek = faceShape(gui, "LeftCheek", Vector2.new(22, 68), Vector2.new(24, 14), pink, true)
	leftCheek.BackgroundTransparency = 0.3
	local rightCheek = faceShape(gui, "RightCheek", Vector2.new(154, 72), Vector2.new(24, 14), pink, true)
	rightCheek.BackgroundTransparency = 0.3

	-- Wide goofy grin with one tooth and a tongue
	local mouth = faceShape(gui, "Mouth", Vector2.new(50, 80), Vector2.new(100, 32), Color3.fromRGB(120, 30, 40), false)
	addOutline(mouth, 3)
	local tongue = faceShape(mouth, "Tongue", Vector2.new(58, 16), Vector2.new(30, 18), Color3.fromRGB(255, 110, 130), true)
	tongue.ZIndex = 2
	local tooth = faceShape(mouth, "Tooth", Vector2.new(10, 0), Vector2.new(16, 11), white, false)
	tooth.ZIndex = 2
end

local function buildWhiteBread(): Model
	local model = Instance.new("Model")
	model.Name = "WhiteBread"

	local cream = Color3.fromRGB(255, 242, 205)
	local crust = Color3.fromRGB(205, 130, 50)
	local lightCrust = Color3.fromRGB(240, 176, 84)

	newPart("Base", Vector3.new(4.2, 0.4, 3.2), crust, model).Position = Vector3.new(0, 0.2, 0)

	local body = newPart("Body", Vector3.new(4, 2.6, 3), cream, model)
	body.Position = Vector3.new(0, 1.7, 0)
	body.CanCollide = true -- the only solid part, so clicks hit it and players can't walk through

	-- Puffy "sandwich loaf" top in two stacked layers
	newPart("Crust", Vector3.new(4.4, 0.8, 3.4), crust, model).Position = Vector3.new(0, 3.4, 0)
	newPart("Puff", Vector3.new(3.6, 0.7, 3), lightCrust, model).Position = Vector3.new(0, 4.15, 0)

	buildFace(body)
	model.PrimaryPart = body
	return model
end

local function buildWoodenSmasher(): Tool
	local tool = Instance.new("Tool")
	tool.Name = "WoodenSmasher"
	tool.ToolTip = "Wooden Smasher"
	tool.CanBeDropped = false
	tool.RequiresHandle = true
	-- Same grip convention as the classic Roblox sword: the +Z end points up/forward from the fist.
	tool.GripForward = Vector3.new(-1, 0, 0)
	tool.GripRight = Vector3.new(0, 1, 0)
	tool.GripUp = Vector3.new(0, 0, 1)
	tool.GripPos = Vector3.new(0, 0, -1.3)

	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(0.5, 0.5, 4)
	handle.Color = Color3.fromRGB(122, 84, 48)
	handle.Material = Enum.Material.Wood
	handle.CanCollide = false
	handle.Parent = tool

	local head = Instance.new("Part")
	head.Name = "Head"
	head.Size = Vector3.new(2.6, 1.6, 1.6)
	head.Color = Color3.fromRGB(168, 120, 70)
	head.Material = Enum.Material.Wood
	head.CanCollide = false
	head.Massless = true
	head.CFrame = handle.CFrame * CFrame.new(0, 0, 2.2)
	head.Parent = tool

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = handle
	weld.Part1 = head
	weld.Parent = head

	-- Two darker hoops on the head
	for _, side in { -0.8, 0.8 } do
		local hoop = Instance.new("Part")
		hoop.Name = "Hoop"
		hoop.Size = Vector3.new(0.3, 1.7, 1.7)
		hoop.Color = Color3.fromRGB(90, 62, 36)
		hoop.Material = Enum.Material.Wood
		hoop.CanCollide = false
		hoop.Massless = true
		hoop.CFrame = head.CFrame * CFrame.new(side, 0, 0)
		hoop.Parent = tool

		local hoopWeld = Instance.new("WeldConstraint")
		hoopWeld.Part0 = handle
		hoopWeld.Part1 = hoop
		hoopWeld.Parent = hoop
	end

	return tool
end

-- Creates any placeholder that is missing. Safe to call repeatedly.
function PlaceholderModels.EnsureAll()
	local models = getModelsFolder()
	if not models:FindFirstChild("WhiteBread") then
		buildWhiteBread().Parent = models
	end
	if not models:FindFirstChild("WoodenSmasher") then
		buildWoodenSmasher().Parent = models
	end
end

function PlaceholderModels.GetBreadModel(name: string): Model
	local found = getModelsFolder():FindFirstChild(name)
	assert(found and found:IsA("Model"), `No Model named "{name}" in ReplicatedStorage/Assets/Models`)
	return found
end

function PlaceholderModels.GetWeaponTool(name: string): Tool
	local found = getModelsFolder():FindFirstChild(name)
	assert(found and found:IsA("Tool"), `No Tool named "{name}" in ReplicatedStorage/Assets/Models`)
	return found
end

return PlaceholderModels
