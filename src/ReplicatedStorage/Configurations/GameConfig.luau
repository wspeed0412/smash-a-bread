--!strict
-- GameConfig for "Smash A Bread".
--
-- Every entry's ModelName must match the model's name under
-- ReplicatedStorage/Assets/Models. Until the real 3D meshes exist, the server
-- builds placeholder versions of WhiteBread and WoodenSmasher with that name.
-- All numbers below are PLACEHOLDERS: tune them while playtesting.

export type BreadStats = {
	ModelName: string,
	DisplayName: string, -- shown on the name tag, e.g. "Easy Bread [100 HP]"
	Health: number,
	YeastReward: number,
	CashReward: number,
	SpawnPosition: Vector3,
	SpawnRadius: number,
	MaxAlive: number,
}

export type WeaponStats = {
	ModelName: string,
	DamageMultiplier: number, -- damage per hit = player Strength x this
	Cost: number, -- Yeast, bought at the Merchant Cart
}

export type PlacedModel = {
	ModelName: string,
	Position: Vector3,
}

local GameConfig = {}

GameConfig.Models = {
	AssetsPath = "Assets/Models", -- under ReplicatedStorage
}

-- Combat
GameConfig.Combat = {
	StartingStrength = 10,
	SwingCooldown = 0.35, -- seconds between swings
	MaxHitDistance = 16, -- studs, server-side check (player to bread center)
	AutoAimRange = 12, -- studs, client picks the nearest bread in front if the click misses
}

-- The central red zone where White Breads spawn.
-- If a Part with this Name already exists in Workspace it is used instead.
GameConfig.Zone = {
	Name = "RedBoundaryZone",
	Position = Vector3.new(0, 0.5, 0),
	Size = Vector3.new(60, 1, 60),
	EdgeMargin = 5, -- keep breads this far from the zone edge
}

GameConfig.Spawner = {
	WhiteBreadCount = 5,
	RespawnSeconds = 3,
	MinSpacing = 9, -- studs between breads
}

-- Bread targets (cartoon bread meshes with faces)
GameConfig.Breads = {
	WhiteBread = {
		ModelName = "WhiteBread",
		DisplayName = "Easy Bread",
		Health = 100,
		YeastReward = 10,
		CashReward = 150,
		SpawnPosition = Vector3.new(0, 3, 0),
		SpawnRadius = 60,
		MaxAlive = 25,
	} :: BreadStats,

	GarlicBread = {
		ModelName = "GarlicBread",
		DisplayName = "Garlic Bread",
		Health = 300,
		YeastReward = 30,
		CashReward = 450,
		SpawnPosition = Vector3.new(80, 3, 0),
		SpawnRadius = 40,
		MaxAlive = 15,
	} :: BreadStats,

	Sourdough = {
		ModelName = "Sourdough",
		DisplayName = "Tough Bread",
		Health = 800,
		YeastReward = 80,
		CashReward = 1200,
		SpawnPosition = Vector3.new(-80, 3, 0),
		SpawnRadius = 40,
		MaxAlive = 10,
	} :: BreadStats,

	-- Event boss: spawns on the Floating Event Spawner platform
	MegalodonLoaf = {
		ModelName = "MegalodonLoaf",
		DisplayName = "Megalodon Loaf",
		Health = 25000,
		YeastReward = 2500,
		CashReward = 50000,
		SpawnPosition = Vector3.new(0, 125, 0),
		SpawnRadius = 10,
		MaxAlive = 1,
	} :: BreadStats,
}

-- Weapons
GameConfig.Weapons = {
	WoodenSmasher = {
		ModelName = "WoodenSmasher",
		DamageMultiplier = 1,
		Cost = 0, -- starter weapon
	} :: WeaponStats,

	GoldenBaguette = {
		ModelName = "GoldenBaguette",
		DamageMultiplier = 2.5,
		Cost = 500,
	} :: WeaponStats,

	DiamondSmasher = {
		ModelName = "DiamondSmasher",
		DamageMultiplier = 6,
		Cost = 5000,
	} :: WeaponStats,
}

GameConfig.StarterWeapon = "WoodenSmasher"

-- Environment
GameConfig.Environment = {
	MerchantCart = {
		ModelName = "MerchantCart",
		Position = Vector3.new(0, 0, -40),
	} :: PlacedModel,

	FloatingEventSpawner = {
		ModelName = "FloatingEventSpawner",
		Position = Vector3.new(0, 120, 0),
	} :: PlacedModel,

	-- Low-poly trees: one model, many placements
	Trees = {
		ModelName = "LowPolyTree",
		Positions = {
			Vector3.new(-30, 0, -25),
			Vector3.new(35, 0, -30),
			Vector3.new(-55, 0, 30),
			Vector3.new(50, 0, 45),
			Vector3.new(0, 0, 70),
		},
	},
}

return GameConfig
