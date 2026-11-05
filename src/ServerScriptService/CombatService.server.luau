--!strict
-- Validates swings from clients. The client only says WHICH bread it swung at;
-- distance, cooldown, held weapon and damage are all decided here.

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Configurations.GameConfig)
local BreadService = require(script.Parent.Modules.BreadService)
local PlayerData = require(script.Parent.Modules.PlayerData)

local SmashHit = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("SmashHit") :: RemoteEvent

local lastSwing: { [Player]: number } = {}

SmashHit.OnServerEvent:Connect(function(player: Player, bread: unknown)
	if typeof(bread) ~= "Instance" or not bread:IsA("Model") or not CollectionService:HasTag(bread, "Bread") then
		return
	end

	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not (character and humanoid and root and root:IsA("BasePart")) or humanoid.Health <= 0 then
		return
	end

	-- Must be holding a weapon (the multiplier is set by the server when the tool is given)
	local tool = character:FindFirstChildOfClass("Tool")
	local multiplier = tool and tool:GetAttribute("DamageMultiplier")
	if typeof(multiplier) ~= "number" then
		return
	end

	-- Cooldown (a little forgiving to allow for network jitter)
	local now = os.clock()
	if now - (lastSwing[player] or 0) < GameConfig.Combat.SwingCooldown * 0.8 then
		return
	end

	-- Range
	if (bread:GetPivot().Position - root.Position).Magnitude > GameConfig.Combat.MaxHitDistance then
		return
	end

	lastSwing[player] = now

	local damage = math.max(1, math.floor(PlayerData.GetStrength(player) * multiplier))
	BreadService.Damage(bread, damage, player)
end)

Players.PlayerRemoving:Connect(function(player: Player)
	lastSwing[player] = nil
end)
