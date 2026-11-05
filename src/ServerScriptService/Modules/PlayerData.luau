--!strict
-- Per-player stats (Strength, Yeast, Cash) shown in the leaderboard, plus the starter weapon.
-- NOTE: nothing is saved between sessions yet. DataStore saving is a later step.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Configurations.GameConfig)
local PlaceholderModels = require(script.Parent.PlaceholderModels)

local UpdateData = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("UpdateData") :: RemoteEvent

local PlayerData = {}

local function getStat(player: Player, name: string): NumberValue?
	local leaderstats = player:FindFirstChild("leaderstats")
	local stat = leaderstats and leaderstats:FindFirstChild(name)
	if stat and stat:IsA("NumberValue") then
		return stat
	end
	return nil
end

local function snapshot(player: Player): { [string]: any }
	return {
		Strength = PlayerData.GetStrength(player),
		Yeast = (getStat(player, "Yeast") or { Value = 0 }).Value,
		Cash = (getStat(player, "Cash") or { Value = 0 }).Value,
	}
end

function PlayerData.GetStrength(player: Player): number
	local strength = getStat(player, "Strength")
	return if strength then strength.Value else GameConfig.Combat.StartingStrength
end

-- Adds a kill reward. `position` is where the client should show the "+10 Yeast" / "+$150" pop-ups.
function PlayerData.AddRewards(player: Player, yeast: number, cash: number, position: Vector3)
	local yeastStat = getStat(player, "Yeast")
	local cashStat = getStat(player, "Cash")
	if yeastStat then
		yeastStat.Value += yeast
	end
	if cashStat then
		cashStat.Value += cash
	end

	local payload = snapshot(player)
	payload.GainedYeast = yeast
	payload.GainedCash = cash
	payload.Position = position
	UpdateData:FireClient(player, payload)
end

function PlayerData.GiveWeapon(player: Player, weaponName: string)
	local stats = GameConfig.Weapons[weaponName]
	assert(stats, `Unknown weapon "{weaponName}"`)

	local backpack = player:WaitForChild("Backpack")
	if backpack:FindFirstChild(weaponName) then
		return
	end

	local tool = PlaceholderModels.GetWeaponTool(stats.ModelName):Clone()
	-- Set on the server so the client can't change its own damage multiplier.
	tool:SetAttribute("DamageMultiplier", stats.DamageMultiplier)
	tool.Parent = backpack

	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid.Health > 0 then
		humanoid:EquipTool(tool)
	end
end

local function onPlayerAdded(player: Player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"

	local function addStat(name: string, value: number)
		local stat = Instance.new("NumberValue")
		stat.Name = name
		stat.Value = value
		stat.Parent = leaderstats
	end
	addStat("Strength", GameConfig.Combat.StartingStrength)
	addStat("Yeast", 0)
	addStat("Cash", 0)
	leaderstats.Parent = player

	local function onCharacterAdded(_character: Model)
		-- The Backpack is rebuilt on every respawn, so hand the weapon out again each time.
		PlayerData.GiveWeapon(player, GameConfig.StarterWeapon)
	end
	player.CharacterAdded:Connect(onCharacterAdded)
	if player.Character then
		task.spawn(onCharacterAdded, player.Character)
	end

	UpdateData:FireClient(player, snapshot(player))
end

function PlayerData.Init()
	PlaceholderModels.EnsureAll()
	Players.PlayerAdded:Connect(onPlayerAdded)
	for _, player in Players:GetPlayers() do
		task.spawn(onPlayerAdded, player)
	end
end

return PlayerData
