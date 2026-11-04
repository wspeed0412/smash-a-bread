--!strict
-- GameConfig for "Smash A Bread".
--
-- Every entry's ModelName must match the model's name under
-- ReplicatedStorage/Assets/Models (the Waspes 3D meshes).
-- All numbers and positions below are PLACEHOLDERS: tune them while playtesting.

export type BreadStats = {
	ModelName: string,
	Health: number,
	YeastReward: number,
	SpawnPosition: Vector3,
	SpawnRadius: number,
	MaxAlive: number,
}

export type WeaponStats = {
	ModelName: string,
	Damage: number,
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

-- Bread targets (cartoon bread meshes with faces)
GameConfig.Breads = {
	WhiteBread = {
		ModelName = "WhiteBread",
		Health = 20,
		YeastReward = 5,
		SpawnPosition = Vector3.new(0, 3, 0),
		SpawnRadius = 60,
		MaxAlive = 25,
	} :: BreadStats,

	GarlicBread = {
		ModelName = "GarlicBread",
		Health = 60,
		YeastReward = 18,
		SpawnPosition = Vector3.new(80, 3, 0),
		SpawnRadius = 40,
		MaxAlive = 15,
	} :: BreadStats,

	Sourdough = {
		ModelName = "Sourdough",
		Health = 150,
		YeastReward = 50,
		SpawnPosition = Vector3.new(-80, 3, 0),
		SpawnRadius = 40,
		MaxAlive = 10,
	} :: BreadStats,

	-- Event boss: spawns on the Floating Event Spawner platform
	MegalodonLoaf = {
		ModelName = "MegalodonLoaf",
		Health = 5000,
		YeastReward = 2500,
		SpawnPosition = Vector3.new(0, 125, 0),
		SpawnRadius = 10,
		MaxAlive = 1,
	} :: BreadStats,
}

-- Weapons
GameConfig.Weapons = {
	WoodenSmasher = {
		ModelName = "WoodenSmasher",
		Damage = 5,
		Cost = 0, -- starter weapon
	} :: WeaponStats,

	GoldenBaguette = {
		ModelName = "GoldenBaguette",
		Damage = 20,
		Cost = 500,
	} :: WeaponStats,

	DiamondSmasher = {
		ModelName = "DiamondSmasher",
		Damage = 75,
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
