# ROBLOX PROJECT SETUP - NO SECRETS REQUIRED
# Run this from any directory

param(
    [string]$ProjectName = "brain-rot-train67",
    [string]$DestinationRoot,
    [switch]$OpenFolder
)

if ([string]::IsNullOrWhiteSpace($DestinationRoot)) {
    $DestinationRoot = [Environment]::GetFolderPath("MyDocuments")
}

if ([string]::IsNullOrWhiteSpace($DestinationRoot)) {
    Write-Error "Destination root could not be resolved. Provide -DestinationRoot to continue."
    exit 1
}

$projectPath = Join-Path -Path $DestinationRoot -ChildPath $ProjectName

Write-Host "🎮 Setting up Roblox project: $ProjectName" -ForegroundColor Cyan

# Create project structure
Write-Host "`n📁 Creating folder structure..." -ForegroundColor Yellow
$folders = @(
    "src\ReplicatedStorage\Classes",
    "src\ReplicatedStorage\Weapons",
    "src\ReplicatedStorage\Shared",
    "src\ServerScriptService\GameManager",
    "src\ServerScriptService\Bosses",
    "src\ServerScriptService\WaveSystem",
    "src\StarterPlayer\StarterPlayerScripts",
    ".github\workflows"
)

foreach ($folder in $folders) {
    $fullPath = Join-Path -Path $projectPath -ChildPath $folder
    New-Item -ItemType Directory -Force -Path $fullPath | Out-Null
}

# Create default.project.json
Write-Host "📝 Creating Rojo config..." -ForegroundColor Yellow
@'
{
  "name": "BrainRotTrain67",
  "tree": {
    "$className": "DataModel",
    "ReplicatedStorage": {
      "$path": "src/ReplicatedStorage"
    },
    "ServerScriptService": {
      "$path": "src/ServerScriptService"
    },
    "StarterPlayer": {
      "$path": "src/StarterPlayer"
    }
  }
}
'@ | Out-File -FilePath "$projectPath\default.project.json" -Encoding UTF8

# Create Gospel 444 constants
Write-Host "🎨 Creating Gospel 444 constants..." -ForegroundColor Yellow
@'
-- Gospel 444: Immutable Color Law
-- Purple: #a855f7, Gold: #f59e0b, Dark: #0f0f1a
-- BLUE IS FORBIDDEN

local Gospel444 = {}

Gospel444.PURPLE = Color3.fromHex("a855f7")
Gospel444.GOLD = Color3.fromHex("f59e0b")
Gospel444.DARK = Color3.fromHex("0f0f1a")

Gospel444.UI = {
    Background = Gospel444.DARK,
    Primary = Gospel444.PURPLE,
    Accent = Gospel444.GOLD,
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(200, 200, 200)
}

return Gospel444
'@ | Out-File -FilePath "$projectPath\src\ReplicatedStorage\Shared\Gospel444.lua" -Encoding UTF8

# Create Sigma class (Tank)
Write-Host "⚔️ Creating classes..." -ForegroundColor Yellow
@'
-- Sigma Class: Tank
-- High HP, damage mitigation, team protection

local Sigma = {}
Sigma.ClassName = "Sigma"
Sigma.Type = "Tank"

Sigma.Stats = {
    MaxHealth = 200,
    Damage = 15,
    Speed = 12,
    Armor = 30, -- 30% damage reduction
    AbilityCooldown = 8
}

Sigma.Ability = {
    Name = "Shield Wall",
    Description = "Create protective barrier for team",
    Duration = 5,
    Radius = 15
}

function Sigma.new(player)
    local self = setmetatable({}, {__index = Sigma})
    self.Player = player
    self.Health = Sigma.Stats.MaxHealth
    self.IsAlive = true
    return self
end

function Sigma:UseAbility()
    -- Shield Wall: Create protective zone
    print(self.Player.Name .. " used Shield Wall!")
    -- TODO: Implement shield logic
end

return Sigma
'@ | Out-File -FilePath "$projectPath\src\ReplicatedStorage\Classes\Sigma.lua" -Encoding UTF8

# Create Railrunner class (DPS)
@'
-- Railrunner Class: High DPS
-- Fast attacks, mobility, sustained damage

local Railrunner = {}
Railrunner.ClassName = "Railrunner"
Railrunner.Type = "DPS"

Railrunner.Stats = {
    MaxHealth = 100,
    Damage = 30,
    Speed = 18,
    AttackSpeed = 0.5, -- Attacks per second
    AbilityCooldown = 6
}

Railrunner.Ability = {
    Name = "Blitz Strike",
    Description = "Rapid dash attack dealing bonus damage",
    DashDistance = 20,
    BonusDamage = 50
}

function Railrunner.new(player)
    local self = setmetatable({}, {__index = Railrunner})
    self.Player = player
    self.Health = Railrunner.Stats.MaxHealth
    self.IsAlive = true
    return self
end

function Railrunner:UseAbility()
    print(self.Player.Name .. " used Blitz Strike!")
    -- TODO: Implement dash + damage
end

return Railrunner
'@ | Out-File -FilePath "$projectPath\src\ReplicatedStorage\Classes\Railrunner.lua" -Encoding UTF8

# Create Baron Skibidi boss
Write-Host "👹 Creating Baron Skibidi boss..." -ForegroundColor Yellow
@'
-- Baron Skibidi: Day 2 Boss
-- First major boss fight, meme-themed attacks

local BaronSkibidi = {}
BaronSkibidi.Name = "Baron Skibidi"
BaronSkibidi.Type = "Boss"

BaronSkibidi.Stats = {
    MaxHealth = 5000,
    Damage = 40,
    Speed = 10,
    PhaseThreshold = 0.5 -- Enrage at 50% HP
}

BaronSkibidi.Attacks = {
    {Name = "Skibidi Slam", Damage = 60, Cooldown = 5, AOE = true},
    {Name = "Meme Beam", Damage = 30, Cooldown = 3, Ranged = true},
    {Name = "Cringe Wave", Damage = 25, Cooldown = 8, Stun = 2}
}

function BaronSkibidi.new()
    local self = setmetatable({}, {__index = BaronSkibidi})
    self.Health = BaronSkibidi.Stats.MaxHealth
    self.IsEnraged = false
    return self
end

function BaronSkibidi:TakeDamage(amount)
    self.Health = self.Health - amount
    
    if self.Health <= self.Stats.MaxHealth * self.Stats.PhaseThreshold and not self.IsEnraged then
        self:Enrage()
    end
    
    if self.Health <= 0 then
        self:OnDeath()
    end
end

function BaronSkibidi:Enrage()
    self.IsEnraged = true
    self.Stats.Damage = self.Stats.Damage * 1.5
    self.Stats.Speed = self.Stats.Speed * 1.3
    print("Baron Skibidi ENRAGED!")
end

function BaronSkibidi:OnDeath()
    print("Baron Skibidi defeated!")
    -- TODO: Drop rewards, trigger cutscene
end

return BaronSkibidi
'@ | Out-File -FilePath "$projectPath\src\ServerScriptService\Bosses\BaronSkibidi.lua" -Encoding UTF8

# Create GameManager
Write-Host "🎮 Creating GameManager..." -ForegroundColor Yellow
@'
-- GameManager: Core game loop controller

local GameManager = {}
GameManager.GameState = "Lobby"
GameManager.CurrentDay = 0
GameManager.PlayersAlive = 0

function GameManager:Initialize()
    print("🎮 Game Manager initialized")
    self.GameState = "Lobby"
end

function GameManager:StartDay(dayNumber)
    self.CurrentDay = dayNumber
    self.GameState = "Active"
    print("Starting Day " .. dayNumber)
    
    if dayNumber == 2 then
        self:SpawnBoss("BaronSkibidi")
    end
end

function GameManager:SpawnBoss(bossName)
    print("⚠️ Boss spawning: " .. bossName)
    local bossModule = script.Parent.Parent.Bosses:FindFirstChild(bossName)
    if not bossModule then
        warn("Boss module not found: " .. bossName)
        return
    end
    local BossClass = require(bossModule)
    -- TODO: Spawn boss instance
end

function GameManager:EndDay()
    self.GameState = "DayComplete"
    print("Day " .. self.CurrentDay .. " complete!")
end

return GameManager
'@ | Out-File -FilePath "$projectPath\src\ServerScriptService\GameManager\init.lua" -Encoding UTF8

# Create .gitignore
Write-Host "🚫 Creating .gitignore..." -ForegroundColor Yellow
@'
*.rbxl
*.rbxlx
*.rbxlx.lock
build/
.vscode/
.rojo/
'@ | Out-File -FilePath "$projectPath\.gitignore" -Encoding UTF8

# Create GitHub Actions workflow
Write-Host "⚙️ Creating GitHub Actions workflow..." -ForegroundColor Yellow
@'
name: Deploy to Roblox

on:
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  deploy:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Install Rojo
        shell: pwsh
        run: |
          $rojoUrl = "https://github.com/rojo-rbx/rojo/releases/download/v7.4.1/rojo-7.4.1-windows.zip"
          Invoke-WebRequest -Uri $rojoUrl -OutFile rojo.zip
          Expand-Archive rojo.zip -DestinationPath .
          
      - name: Build place file
        run: .\rojo.exe build -o BrainRotTrain67.rbxl
        
      - name: Deploy to Roblox
        env:
          ROBLOX_API_KEY: ${{ secrets.ROBLOX_API_KEY }}
          UNIVERSE_ID: ${{ secrets.UNIVERSE_ID }}
          PLACE_ID: ${{ secrets.PLACE_ID }}
        run: |
          # TODO: Add Open Cloud API deployment
          # curl -X POST https://apis.roblox.com/universes/v1/${UNIVERSE_ID}/places/${PLACE_ID}/versions
          Write-Host "✅ Build successful - Manual upload required until API configured"
'@ | Out-File -FilePath "$projectPath\.github\workflows\deploy.yml" -Encoding UTF8

# Create README
Write-Host "📖 Creating README..." -ForegroundColor Yellow
@'
# To Survive a Brainrot: Game 1 - Train 67

Gospel 444 compliant Roblox survival game.

## Setup

### Prerequisites
- Roblox Studio
- Git
- Rojo 7.4+

### Local Development

1. Install Rojo:
``````powershell
# Download from: https://github.com/rojo-rbx/rojo/releases
``````

2. Start Rojo server:
``````bash
rojo serve
``````

3. In Roblox Studio:
   - Plugins → Rojo → Connect
   - Connect to localhost:34872

4. Make changes in ``src/`` folder
5. Changes sync automatically to Studio

### Deployment

Push to main branch triggers auto-deploy (after secrets configured).

### Required GitHub Secrets

Add these in repo Settings → Secrets → Actions:
- ``ROBLOX_API_KEY`` - From create.roblox.com
- ``UNIVERSE_ID`` - From Studio → Game Settings
- ``PLACE_ID`` - From Studio → Game Settings

## Project Structure

``````
src/
├── ReplicatedStorage/
│   ├── Classes/          # Player classes (Sigma, Railrunner, etc)
│   ├── Weapons/          # Weapon definitions
│   └── Shared/           # Gospel 444 constants
├── ServerScriptService/
│   ├── GameManager/      # Core game loop
│   ├── Bosses/           # Boss scripts (Baron Skibidi, etc)
│   └── WaveSystem/       # Enemy spawning
└── StarterPlayer/
    └── StarterPlayerScripts/  # Client scripts
``````

## Gospel 444 Compliance

Colors ONLY:
- Purple: #a855f7
- Gold: #f59e0b
- Dark: #0f0f1a
- **BLUE IS FORBIDDEN**
'@ | Out-File -FilePath "$projectPath\README.md" -Encoding UTF8

# Create git init script
Write-Host "🔧 Creating git setup script..." -ForegroundColor Yellow
@'
# Run this after GitHub repo is created
# Usage: .\init-git.ps1 YOUR_GITHUB_USERNAME

param([string]$username)

if (-not $username) {
    Write-Host "❌ Usage: .\init-git.ps1 YOUR_GITHUB_USERNAME" -ForegroundColor Red
    exit 1
}

git init
git add .
git commit -m "feat: initial roblox project setup"
git branch -M main
git remote add origin https://github.com/$username/brain-rot-train67.git
git push -u origin main

Write-Host "✅ Pushed to GitHub!" -ForegroundColor Green
Write-Host "Next: Add secrets to repo → Settings → Secrets → Actions" -ForegroundColor Yellow
'@ | Out-File -FilePath "$projectPath\init-git.ps1" -Encoding UTF8

Write-Host "`n✅ PROJECT SETUP COMPLETE!" -ForegroundColor Green
Write-Host "`n📂 Project location: $projectPath" -ForegroundColor Cyan
Write-Host "`n📋 NEXT STEPS:" -ForegroundColor Yellow
Write-Host "1. cd `"$projectPath`"" -ForegroundColor White
Write-Host "2. Get Roblox API key + Universe/Place IDs" -ForegroundColor White
Write-Host "3. Run: rojo serve" -ForegroundColor White
Write-Host "4. Roblox Studio → Rojo plugin → Connect" -ForegroundColor White
Write-Host "5. When ready: .\init-git.ps1 YOUR_GITHUB_USERNAME" -ForegroundColor White

# Open project folder (optional)
if ($OpenFolder) {
    Start-Process explorer.exe $projectPath
}
