local addonName, addon = ...

local BUFF_DEFENSIVE = "buffs_defensive"
local BUFF_OFFENSIVE = "buffs_offensive"
local BUFF_OTHER = "buffs_other"
local BUFF_SPEED_BOOST = "buffs_speed_boost"
local DEBUFF_OFFENSIVE = "debuffs_offensive"
local INTERRUPT = "interrupts"
local CROWD_CONTROL = "cc"
local ROOT = "roots"
local IMMUNITY = "immunities"
local IMMUNITY_SPELL = "immunities_spells"

addon.HiddenDebuffs = {
    80354, -- Temporal Displacement
    371070, -- Rotting From Within
    390435, -- Exhaustion
    57723, -- Exhaustion
    206151, -- Challenger's Burden
    264689, -- Fatigued
}

addon.Units = {
    "player",
    "pet",
    "target",
    "focus",
    "party1",
    "party2",
    "party3",
    "party4",
    "arena1",
    "arena2",
    "arena3",
    "arena4",
    "arena5",
}

-- Show one of these when a big debuff is displayed
addon.WarningDebuffs = {
    212183, -- Smoke Bomb
    81261, -- Solar Beam
    316099, -- Unstable Affliction
    342938, -- Unstable Affliction
    34914, -- Vampiric Touch
    375901, -- Mindgames
	383005, -- Chrono Loop
}

-- Make sure we always see these debuffs, but don't make them bigger
addon.PriorityDebuffs = {
    316099, -- Unstable Affliction
    342938, -- Unstable Affliction
    34914, -- Vampiric Touch
    209749, -- Faerie Swarm
    117405, -- Binding Shot
    122470, -- Touch of Karma
    208997, -- Counterstrike Totem
    343294, -- Soul Reaper (Unholy)
    375901, -- Mindgames
}

addon.Spells = {

    -- Interrupts

    [1766] = { type = INTERRUPT, duration = 3 }, -- Kick (Rogue)
    [2139] = { type = INTERRUPT, duration = 5 }, -- Counterspell (Mage)
    [6552] = { type = INTERRUPT, duration = 3 }, -- Pummel (Warrior)
    [19647] = { type = INTERRUPT, duration = 5 }, -- Spell Lock (Warlock)
        [132409] = { type = INTERRUPT, duration = 5, parent = 19647 }, -- Spell Lock (Warlock)
    [47528] = { type = INTERRUPT, duration = 3 }, -- Mind Freeze (Death Knight)
    [57994] = { type = INTERRUPT, duration = 2 }, -- Wind Shear (Shaman)
    [91807] = { type = INTERRUPT, duration = 2 }, -- Shambling Rush (Death Knight)
    [96231] = { type = INTERRUPT, duration = 3 }, -- Rebuke (Paladin)
    [93985] = { type = INTERRUPT, duration = 3 }, -- Skull Bash (Feral/Guardian)
    [116705] = { type = INTERRUPT, duration = 3 }, -- Spear Hand Strike (Monk)
    [147362] = { type = INTERRUPT, duration = 3 }, -- Counter Shot (Hunter)
    [183752] = { type = INTERRUPT, duration = 3 }, -- Disrupt (Demon Hunter)
    [187707] = { type = INTERRUPT, duration = 3 }, -- Muzzle (Hunter)
    [212619] = { type = INTERRUPT, duration = 5 }, -- Call Felhunter (Warlock)
    [31935] = { type = INTERRUPT, duration = 3 }, -- Avenger's Shield (Paladin)
    [217824] = { type = INTERRUPT, duration = 4 }, -- Shield of Virtue (Protection PvP Talent)
    [351338] = { type = INTERRUPT, duration = 4 }, -- Quell (Evoker)

    -- Death Knight

    [47476] = { type = CROWD_CONTROL }, -- Strangulate
    [374776] = { type = CROWD_CONTROL }, -- Tightening Grasp (Silence)
    [48707] = { type = IMMUNITY_SPELL }, -- Anti-Magic Shell
	[410358] = { type = IMMUNITY_SPELL, parent = 48707 }, -- Anti-Magic Shell (Spellwarden)
	[444741] = { type = IMMUNITY_SPELL, parent = 48707 }, -- Anti-Magic Shell (Horsemen's Aid)
    [145629] = { type = BUFF_DEFENSIVE }, -- Anti-Magic Zone
    [454863] = { type = BUFF_DEFENSIVE }, -- Lesser Anti-Magic Shell
    [48265] = { type = BUFF_SPEED_BOOST }, -- Death's Advance
	[444347] = { type = BUFF_SPEED_BOOST, parent = 48265 }, -- Death Charge
    [48792] = { type = BUFF_DEFENSIVE }, -- Icebound Fortitude
    [49039] = { type = BUFF_OTHER }, -- Lichborne
    [81256] = { type = BUFF_DEFENSIVE }, -- Dancing Rune Weapon
    [51271] = { type = BUFF_OFFENSIVE }, -- Pillar of Frost
    [55233] = { type = BUFF_DEFENSIVE }, -- Vampiric Blood
    [77606] = { type = DEBUFF_OFFENSIVE }, -- Dark Simulacrum
    [63560] = { type = BUFF_OFFENSIVE }, -- Dark Transformation
    [91800] = { type = CROWD_CONTROL }, -- Gnaw
        [91797] = { type = CROWD_CONTROL, parent = 91800 }, -- Monstrous Blow
    [221562] = { type = CROWD_CONTROL }, -- Asphyxiate
    [152279] = { type = BUFF_OFFENSIVE }, -- Breath of Sindragosa
    [194679] = { type = BUFF_DEFENSIVE }, -- Rune Tap
    [194844] = { type = BUFF_DEFENSIVE }, -- Bonestorm
    [454787] = { type = ROOT }, -- Ice Prison
    [204080] = { type = ROOT }, -- Deathchill
        [233395] = { type = ROOT, parent = 204080 }, -- when applied by Remorseless Winter
        [204085] = { type = ROOT, parent = 204080 }, -- when applied by Chains of Ice
    [47568] = { type = BUFF_OFFENSIVE }, -- Empower Rune Weapon
    [207167] = { type = CROWD_CONTROL }, -- Blinding Sleet
    [207289] = { type = BUFF_OFFENSIVE }, -- Unholy Assault
    [212552] = { type = BUFF_SPEED_BOOST }, -- Wraith Walk
    [219809] = { type = BUFF_DEFENSIVE }, -- Tombstone
    [356528] = { type = DEBUFF_OFFENSIVE, nounitFrames = true, nonameplates = true }, -- Necrotic Wound
    [343294] = { type = DEBUFF_OFFENSIVE, nounitFrames = true, nonameplates = true }, -- Soul Reaper
    [377048] = { type = CROWD_CONTROL }, -- Absolute Zero
    -- [91807] = { type = ROOT }, -- Shambling Rush (defined as Interrupt)
    [210141] = { type = CROWD_CONTROL}, -- Zombie Explosion (Reanimation Unholy PvP Talent)
    [288849] = { type = DEBUFF_OFFENSIVE, nounitFrames = true, nonameplates = true }, -- Crypt Fever (Necromancer's Bargain Unholy PvP Talent)
    [3714] = { type = BUFF_OTHER }, -- Path of Frost
    [383269] = { type = BUFF_OFFENSIVE }, -- Abomination Limb

    -- Demon Hunter

    [179057] = { type = CROWD_CONTROL }, -- Chaos Nova
    [187827] = { type = BUFF_DEFENSIVE }, -- Metamorphosis - Vengeance
    [162264] = { type = BUFF_OFFENSIVE }, -- Metamorphosis - Havoc
    [188501] = { type = BUFF_OFFENSIVE }, -- Spectral Sight
    [204490] = { type = CROWD_CONTROL }, -- Sigil of Silence
    [205629] = { type = BUFF_DEFENSIVE }, -- Demonic Trample
    [213491] = { type = CROWD_CONTROL }, -- Demonic Trample (short stun on targets)
    [205630] = { type = CROWD_CONTROL }, -- Illidan's Grasp - Grab
        [208618] = { type = CROWD_CONTROL, parent = 205630 }, -- Illidan's Grasp - Stun
    [206804] = { type = BUFF_OFFENSIVE }, -- Rain from Above (down)
        [206803] = { type = IMMUNITY, parent = 206804 }, -- Rain from Above (up)
    [207685] = { type = CROWD_CONTROL }, -- Sigil of Misery
    [209426] = { type = BUFF_DEFENSIVE }, -- Darkness
    [211881] = { type = CROWD_CONTROL }, -- Fel Eruption
    [212800] = { type = BUFF_DEFENSIVE }, -- Blur
    [196555] = { type = IMMUNITY }, -- Netherwalk
    [217832] = { type = CROWD_CONTROL }, -- Imprison
        [221527] = { type = CROWD_CONTROL, parent = 217832 }, -- Imprison (PvP Talent)
    [390195] = { type = BUFF_OFFENSIVE }, -- Chaos Theory
    [370970] = { type = ROOT }, -- The Hunt (Root)
    [320338] = { type = DEBUFF_OFFENSIVE, nounitFrames = true, nonameplates = true }, -- Essence Break
    [354610] = { type = IMMUNITY }, -- Glimpse

    -- Druid

    [99] = { type = CROWD_CONTROL }, -- Incapacitating Roar
    [339] = { type = ROOT }, -- Entangling Roots
        [170855] = { type = ROOT, parent = 339 }, -- Entangling Roots (Nature's Grasp)
    [1850] = { type = BUFF_SPEED_BOOST }, -- Dash
        [252216] = { type = BUFF_SPEED_BOOST, parent = 1850 }, -- Tiger Dash
    [2637] = { type = CROWD_CONTROL }, -- Hibernate
    [5211] = { type = CROWD_CONTROL }, -- Mighty Bash
    [5217] = { type = BUFF_OFFENSIVE }, -- Tiger's Fury
    [22812] = { type = BUFF_DEFENSIVE }, -- Barkskin
    [22842] = { type = BUFF_DEFENSIVE }, -- Frenzied Regeneration
    [29166] = { type = BUFF_OFFENSIVE }, -- Innervate
    [33786] = { type = CROWD_CONTROL }, -- Cyclone
    [145152] = { type = BUFF_OFFENSIVE }, -- Bloodtalons
    [33891] = { type = BUFF_OFFENSIVE }, -- Incarnation: Tree of Life (for the menu entry - "Incarnation" tooltip isn't informative)
        [117679] = { type = BUFF_OFFENSIVE, parent = 33891 }, -- Incarnation (grants access to Tree of Life form)
    [45334] = { type = ROOT }, -- Immobilized (Wild Charge in Bear Form)
    [61336] = { type = BUFF_DEFENSIVE }, -- Survival Instincts
    [81261] = { type = CROWD_CONTROL }, -- Solar Beam
    [197721] = { type = BUFF_DEFENSIVE }, -- Flourish
    [102342] = { type = BUFF_DEFENSIVE }, -- Ironbark
    [102359] = { type = ROOT }, -- Mass Entanglement
    [102543] = { type = BUFF_OFFENSIVE }, -- Incarnation: King of the Jungle
    [102558] = { type = BUFF_OFFENSIVE }, -- Incarnation: Guardian of Ursoc
    [102560] = { type = BUFF_OFFENSIVE }, -- Incarnation: Chosen of Elune
	[390414] = { type = BUFF_OFFENSIVE, parent = 102560 }, -- Incarnation: Chosen of Elune (Orbital Strike)
    [106951] = { type = BUFF_OFFENSIVE }, -- Berserk (Feral)
    [132158] = { type = BUFF_OFFENSIVE }, -- Nature's Swiftness
    [155835] = { type = BUFF_DEFENSIVE }, -- Bristling Fur
    [163505] = { type = CROWD_CONTROL }, -- Rake
    [194223] = { type = BUFF_OFFENSIVE }, -- Celestial Alignment
	[383410] = { type = BUFF_OFFENSIVE, parent = 194223 }, -- Celestial Alignment (Orbital Strike)
    [202425] = { type = BUFF_OFFENSIVE }, -- Warrior of Elune
    [209749] = { type = CROWD_CONTROL }, -- Faerie Swarm
    [203123] = { type = CROWD_CONTROL }, -- Maim
    [305497] = { type = BUFF_DEFENSIVE }, -- Thorns (PvP Talent)
    [50334] = { type = BUFF_DEFENSIVE }, -- Berserk (Guardian)
    [127797] = { type = CROWD_CONTROL, nounitFrames = true, nonameplates = true }, -- Ursol's Vortex
    [202244] = { type = CROWD_CONTROL }, -- Overrun (Guardian PvP Talent)
    [247563] = { type = BUFF_DEFENSIVE }, -- Nature's Grasp (Resto Entangling Bark PvP Talent)
    [106898] = { type = BUFF_SPEED_BOOST }, -- Stampeding Roar (from Human Form)
        [77764] = { type = BUFF_SPEED_BOOST, parent = 106898 }, -- from Cat Form
        [77761] = { type = BUFF_SPEED_BOOST, parent = 106898 }, -- from Bear Form
    [319454] = { type = BUFF_OFFENSIVE }, -- Heart of the Wild
        [108291] = { type = BUFF_OFFENSIVE, parent = 319454 }, -- with Balance Affinity
        [108292] = { type = BUFF_OFFENSIVE, parent = 319454 }, -- with Feral Affinity
        [108293] = { type = BUFF_OFFENSIVE, parent = 319454 }, -- with Guardian Affinity
        [108294] = { type = BUFF_OFFENSIVE, parent = 319454 }, -- with Resto Affinity
    [5215] = { type = BUFF_OTHER }, -- Prowl
    [391528] = { type = BUFF_OFFENSIVE }, -- Convoke the Spirits
    [473909] = { type = IMMUNITY }, -- Ancient of Lore
    [274838] = { type = DEBUFF_OFFENSIVE, nounitFrames = true, nonameplates = true }, -- Feral Frenzy
    [58180] = { type = DEBUFF_OFFENSIVE, nounitFrames = true, nonameplates = true }, -- Infected Wounds
    [200851] = { type = BUFF_DEFENSIVE }, -- Rage of the Sleeper
    [202347] = { type = DEBUFF_OFFENSIVE, nounitFrames = true, nonameplates = true }, -- Stellar Flare

    -- Evoker

    [363916] = { type = BUFF_DEFENSIVE }, -- Obsidian Scales
    [370960] = { type = BUFF_DEFENSIVE }, -- Emerald Communion
    [374348] = { type = BUFF_DEFENSIVE }, -- Renewing Blaze
    [357170] = { type = BUFF_DEFENSIVE }, -- Time Dilation
    [406732] = { type = BUFF_DEFENSIVE }, -- Spatial Paradox
    [404977] = { type = BUFF_DEFENSIVE }, -- Time Skip
    [375087] = { type = BUFF_OFFENSIVE }, -- Dragonrage
    [383005] = { type = DEBUFF_OFFENSIVE }, -- Chrono Loop
    [372048] = { type = DEBUFF_OFFENSIVE }, -- Oppressing Roar
    [360806] = { type = CROWD_CONTROL }, -- Sleep Walk
    [372245] = { type = CROWD_CONTROL }, -- Terror of the Skies
    [408544] = { type = CROWD_CONTROL }, -- Seismic Slam
    [355689] = { type = ROOT }, -- Landslide
    [378464] = { type = IMMUNITY }, -- Nullifying Shroud
    [378441] = { type = IMMUNITY }, -- Time Stop
    [357210] = { type = IMMUNITY, nonameplates = true }, -- Deep Breath (Immune to CC)
	[433874] = { type = IMMUNITY, nonameplates = true, parent = 357210 }, -- (Maneuverability)
    [359816] = { type = IMMUNITY, nonameplates = true }, -- Dream Flight (Immune to CC)
    [403631] = { type = IMMUNITY, nonameplates = true }, -- Breath of Eons (Immune to CC)
	[442204] = { type = IMMUNITY, nonameplates = true, parent = 403631 }, -- (Maneuverability)
    [445134] = { type = DEBUFF_OFFENSIVE }, -- Shape of Flame
    [368970] = { type = BUFF_OTHER }, -- Tail Swipe (Snare)
    [357214] = { type = BUFF_OTHER }, -- Wing Buffet (Snare)
    [358267] = { type = BUFF_SPEED_BOOST }, -- Hover

    -- Hunter

    [136] = { type = BUFF_DEFENSIVE }, -- Mend Pet
    [1513] = { type = CROWD_CONTROL }, -- Scare Beast
    [3355] = { type = CROWD_CONTROL }, -- Freezing Trap
	[203337] = { type = CROWD_CONTROL, parent = 3355 }, -- Diamond Ice (Survival PvP Talent)
    [356723] = { type = CROWD_CONTROL }, -- Scorpid Venom
    [356727] = { type = CROWD_CONTROL }, -- Spider Venom
    [5384] = { type = BUFF_DEFENSIVE }, -- Feign Death
    [19574] = { type = BUFF_OFFENSIVE }, -- Bestial Wrath
        [186254] = { type = BUFF_OFFENSIVE, parent = 19574 }, -- Bestial Wrath buff on the pet
    [24394] = { type = CROWD_CONTROL }, -- Intimidation
    [53480] = { type = BUFF_DEFENSIVE }, -- Roar of Sacrifice (PvP Talent)
    [54216] = { type = BUFF_DEFENSIVE }, -- Master's Call
    [117526] = { type = CROWD_CONTROL }, -- Binding Shot
    [117405] = { type = ROOT, nounitFrames = true, nonameplates = true }, -- Binding Shot - aura when you're in the area
    [118922] = { type = BUFF_SPEED_BOOST }, -- Posthaste
    [131894] = { type = DEBUFF_OFFENSIVE, nounitFrames = true, nonameplates = true }, -- A Murder of Crows
    [321538] = { type = DEBUFF_OFFENSIVE, nounitFrames = true, nonameplates = true }, -- Bloodshed
    [186257] = { type = BUFF_SPEED_BOOST }, -- Aspect of the Cheetah
        [203233] = { type = BUFF_SPEED_BOOST, parent = 186257 }, -- Hunting Pack (PvP Talent)
    [186265] = { type = IMMUNITY }, -- Aspect of the Turtle
    [264735] = { type = BUFF_DEFENSIVE }, -- Survival of the Fittest
    [186289] = { type = BUFF_OFFENSIVE }, -- Aspect of the Eagle
    [199483] = { type = BUFF_OTHER }, -- Camouflage
    [209997] = { type = BUFF_DEFENSIVE }, -- Play Dead
    [212638] = { type = ROOT }, -- Tracker's Net
    [213691] = { type = CROWD_CONTROL }, -- Scatter Shot
    [357021] = { type = CROWD_CONTROL }, -- Consecutive Concussion
    [400456] = { type = BUFF_OFFENSIVE }, -- Salvo
    [360952] = { type = BUFF_OFFENSIVE }, -- Coordinated Assault
    [360966] = { type = BUFF_OFFENSIVE }, -- Spearhead
    [288613] = { type = BUFF_OFFENSIVE }, -- Trueshot
    [260402] = { type = BUFF_OFFENSIVE }, -- Double Tap
    [359844] = { type = BUFF_OFFENSIVE }, -- Call of the Wild
    [190925] = { type = ROOT }, -- Harpoon
    [202748] = { type = BUFF_DEFENSIVE }, -- Survival Tactics (PvP Talent)
    [248519] = { type = IMMUNITY_SPELL }, -- Interlope (BM PvP Talent)
    [212431] = { type = DEBUFF_OFFENSIVE }, -- Explosive Shot
    [393456] = { type = ROOT }, -- Entrapment
    [451517] = { type = ROOT }, -- Catch Out
    [407032] = { type = CROWD_CONTROL }, -- Sticky Tar Bomb
	[407031] = { type = CROWD_CONTROL, parent = 407032 }, -- Sticky Tar Bomb (AoE)

    -- Mage

    [66] = { type = BUFF_OFFENSIVE }, -- Invisibility (Countdown)
        [32612] = { type = BUFF_OFFENSIVE, parent = 66 }, -- Invisibility
    [110960] = { type = BUFF_DEFENSIVE }, -- Greater Invisibility (Countdown)
	[113862] = { type = BUFF_DEFENSIVE, parent = 110960 }, -- Greater Invisibility
    [118] = { type = CROWD_CONTROL }, -- Polymorph
        [28271] = { type = CROWD_CONTROL, parent = 118 }, -- Polymorph Turtle
        [28272] = { type = CROWD_CONTROL, parent = 118 }, -- Polymorph Pig
        [61025] = { type = CROWD_CONTROL, parent = 118 }, -- Polymorph Serpent
        [61305] = { type = CROWD_CONTROL, parent = 118 }, -- Polymorph Black Cat
        [61721] = { type = CROWD_CONTROL, parent = 118 }, -- Polymorph Rabbit
        [61780] = { type = CROWD_CONTROL, parent = 118 }, -- Polymorph Turkey
        [126819] = { type = CROWD_CONTROL, parent = 118 }, -- Polymorph Porcupine
        [161353] = { type = CROWD_CONTROL, parent = 118 }, -- Polymorph Polar Bear Cub
        [161354] = { type = CROWD_CONTROL, parent = 118 }, -- Polymorph Monkey
        [161355] = { type = CROWD_CONTROL, parent = 118 }, -- Polymorph Penguin
        [161372] = { type = CROWD_CONTROL, parent = 118 }, -- Polymorph Peacock
        [277787] = { type = CROWD_CONTROL, parent = 118 }, -- Polymorph Direhorn
        [277792] = { type = CROWD_CONTROL, parent = 118 }, -- Polymorph Bumblebee
	[391622] = { type = CROWD_CONTROL, parent = 118 }, -- Polymorph Duck
	[460392] = { type = CROWD_CONTROL, parent = 118 }, -- Polymorph Mosswool
	[461489] = { type = CROWD_CONTROL, parent = 118 }, -- Polymorph Moss
    [383121] = { type = CROWD_CONTROL }, -- Mass Polymorph
    [122] = { type = ROOT }, -- Frost Nova
    [33395] = { type = ROOT }, -- Freeze
    [449700] = { type = ROOT }, -- Gravity Lapse (Wowhead labels it as a root mechanic)
    [365362] = { type = BUFF_OFFENSIVE }, -- Arcane Surge
    [12051] = { type = BUFF_OFFENSIVE }, -- Evocation
    [12472] = { type = BUFF_OFFENSIVE }, -- Icy Veins
    [198144] = { type = BUFF_OFFENSIVE }, -- Ice Form
    [31661] = { type = CROWD_CONTROL }, -- Dragon's Breath
    [45438] = { type = IMMUNITY }, -- Ice Block
	[414658] = { type = BUFF_DEFENSIVE, parent = 45438 }, -- Ice Cold
    [41425] = { type = BUFF_OTHER }, -- Hypothermia
    [342242] = { type = BUFF_OFFENSIVE }, -- Time Warp procced by Time Anomality (Arcane Talent)
    [82691] = { type = CROWD_CONTROL }, -- Ring of Frost
    [353084] = { type = CROWD_CONTROL }, -- Ring of Fire
    [87023] = { type = BUFF_OTHER }, -- Cauterize
    [108839] = { type = BUFF_OTHER }, -- Ice Floes
    [342246] = { type = BUFF_DEFENSIVE }, -- Alter Time (Arcane)
        [110909] = { type = BUFF_DEFENSIVE, parent = 342246 }, -- Alter Time (Fire/Frost)
    [157997] = { type = ROOT }, -- Ice Nova
    [190319] = { type = BUFF_OFFENSIVE }, -- Combustion
    [414664] = { type = BUFF_OFFENSIVE }, -- Mass Invisibility
    [205025] = { type = BUFF_OFFENSIVE }, -- Presence of Mind
    [228600] = { type = ROOT }, -- Glacial Spike Root
    [378760] = { type = ROOT }, -- Frostbite
    [130] = { type = BUFF_OTHER }, -- Slow Fall
    [383874] = { type = BUFF_OFFENSIVE }, -- Hyperthermia
    [228358] = { type = DEBUFF_OFFENSIVE }, -- Winter's Chill
    [389831] = { type = CROWD_CONTROL }, -- Snowdrift
    [210824] = { type = DEBUFF_OFFENSIVE, nounitFrames = true, nonameplates = true }, -- Touch of the Magi
    [12654] = { type = DEBUFF_OFFENSIVE, nounitFrames = true, nonameplates = true }, -- Ignite
    [390612] = { type = DEBUFF_OFFENSIVE, nounitFrames = true, nonameplates = true }, -- Frost Bomb
    [1221107] = { type = IMMUNITY }, -- Overpowered Barrier
    [217694] = { type = DEBUFF_OFFENSIVE, nounitFrames = true, nonameplates = true }, -- Living Bomb
        [244813] = { type = DEBUFF_OFFENSIVE, nounitFrames = true, nonameplates = true, parent = 217694 }, -- Living Bomb (spread effect)

    -- Monk

    [115078] = { type = CROWD_CONTROL }, -- Paralysis
    [115176] = { type = BUFF_DEFENSIVE }, -- Zen Meditation
    [120954] = { type = BUFF_DEFENSIVE }, -- Fortifying Brew (Brewmaster)
    [116706] = { type = ROOT }, -- Disable
    [116841] = { type = BUFF_SPEED_BOOST }, -- Tiger's Lust
    [116849] = { type = BUFF_DEFENSIVE }, -- Life Cocoon
    [119381] = { type = CROWD_CONTROL }, -- Leg Sweep
    [324382] = { type = ROOT }, -- Clash
    [122278] = { type = BUFF_DEFENSIVE }, -- Dampen Harm
    [125174] = { type = BUFF_DEFENSIVE }, -- Touch of Karma (Buff)
    [122470] = { type = DEBUFF_OFFENSIVE, nounitFrames = true, nonameplates = true }, -- Touch of Karma (Debuff)
    [122783] = { type = BUFF_DEFENSIVE }, -- Diffuse Magic
    [137639] = { type = BUFF_OFFENSIVE }, -- Storm, Earth, and Fire
    [443028] = { type = BUFF_OFFENSIVE }, -- Celestial Conduit
    [198909] = { type = CROWD_CONTROL }, -- Song of Chi-Ji
    [202162] = { type = BUFF_DEFENSIVE }, -- Avert Harm (Brew PvP Talent)
    [202274] = { type = CROWD_CONTROL }, -- Incendiary Brew (Brew PvP Talent)
    [209584] = { type = BUFF_DEFENSIVE }, -- Zen Focus Tea (MW PvP Talent)
    [233759] = { type = CROWD_CONTROL }, -- Grapple Weapon (MW/WW PvP Talent)
    [394112] = { type = BUFF_DEFENSIVE }, -- Escape from Reality
    [387184] = { type = BUFF_OFFENSIVE }, -- Weapons of Order (Brewmaster)
    [202335] = { type = BUFF_OFFENSIVE }, -- Double Barrel (Brew PvP Talent) - "next cast will..." buff
    [202346] = { type = CROWD_CONTROL }, -- Double Barrel (Brew PvP Talent)
    [202248] = { type = IMMUNITY_SPELL }, -- Guided Meditation (Brew PvP Talent)
    [213664] = { type = BUFF_DEFENSIVE }, -- Nimble Brew (Brew PvP Talent)
    [132578] = { type = BUFF_DEFENSIVE }, -- Invoke Niuzao, the Black Ox
    [353319] = { type = IMMUNITY_SPELL }, -- Peaceweaver
    [456499] = { type = IMMUNITY }, -- Absolute Serenity
    [432180] = { type = BUFF_DEFENSIVE }, -- Dance of the Wind

    -- Paladin

    [498] = { type = BUFF_DEFENSIVE }, -- Divine Protection
        [403876] = { type = BUFF_DEFENSIVE, parent = 498 }, -- Divine Protection (Retribution)
    [642] = { type = IMMUNITY }, -- Divine Shield
    [853] = { type = CROWD_CONTROL }, -- Hammer of Justice
    [1022] = { type = IMMUNITY }, -- Blessing of Protection
    [204018] = { type = IMMUNITY_SPELL }, -- Blessing of Spellwarding
    [1044] = { type = BUFF_DEFENSIVE }, -- Blessing of Freedom
        [305395] = { type = BUFF_DEFENSIVE, parent = 1044 }, -- Blessing of Freedom with Unbound Freedom (PvP Talent)
    [6940] = { type = BUFF_DEFENSIVE }, -- Blessing of Sacrifice
    [199448] = { type = BUFF_DEFENSIVE }, -- Blessing of Sacrifice (Ultimate Sacrifice Holy PvP Talent)
        [199450] = { type = BUFF_DEFENSIVE, parent = 199448 }, -- Ultimate Sacrifice (Holy PvP Talent) - debuff on the paladin
    [20066] = { type = CROWD_CONTROL }, -- Repentance
    [10326] = { type = CROWD_CONTROL }, -- Turn Evil
    [25771] = { type = BUFF_OTHER }, -- Forbearance
    [317929] = { type = BUFF_DEFENSIVE }, -- Aura Mastery (Concentration Aura)
    [31850] = { type = BUFF_DEFENSIVE }, -- Ardent Defender
    [31884] = { type = BUFF_OFFENSIVE }, -- Avenging Wrath
        [216331] = { type = BUFF_OFFENSIVE, parent = 31884 }, -- Avenging Crusader (Holy Talent)
	[454351] = { type = BUFF_OFFENSIVE, parent = 31884 }, -- Avenging Wrath (Radiant Glory)
        [231895] = { type = BUFF_OFFENSIVE, parent = 31884 }, -- Crusade (Retribution Talent)
	[454373] = { type = BUFF_OFFENSIVE, parent = 31884 }, -- Crusade (Radiant Glory)
	[389539] = { type = BUFF_OFFENSIVE, parent = 31884 }, -- Sentinel (Protection Talent)
    -- [31935] = { type = CROWD_CONTROL }, -- Avenger's Shield (defined as Interrupt)
    [86659] = { type = BUFF_DEFENSIVE }, -- Guardian of Ancient Kings
        [212641] = { type = BUFF_DEFENSIVE, parent = 86659 }, -- Guardian of Ancient Kings (Glyphed)
    [228050] = { type = IMMUNITY }, -- Guardian of the Forgotten Queen (Protection PvP Talent)
    [414273] = { type = BUFF_DEFENSIVE }, -- Hand of Divinity
    [105421] = { type = CROWD_CONTROL }, -- Blinding Light
    [184662] = { type = BUFF_DEFENSIVE }, -- Shield of Vengeance
    [199545] = { type = BUFF_DEFENSIVE }, -- Steed of Glory (Protection PvP Talent)
    [210256] = { type = BUFF_DEFENSIVE }, -- Blessing of Sanctuary (Ret PvP Talent)
    [210294] = { type = BUFF_DEFENSIVE }, -- Divine Favor
    [415246] = { type = BUFF_DEFENSIVE }, -- Divine Plea (Holy PvP Talent)
    [215652] = { type = BUFF_OFFENSIVE }, -- Shield of Virtue (Protection PvP Talent) - "next cast will..." buff
    -- [217824] = { type = CROWD_CONTROL }, -- Shield of Virtue (Protection PvP Talent) (defined as Interrupt)
    [221883] = { type = BUFF_SPEED_BOOST }, -- Divine Steed (Human?) (Each race has its own buff, pulled from wowhead - some might be incorrect)
        [221885] = { type = BUFF_SPEED_BOOST, parent =  221883 }, -- Divine Steed (Tauren?)
        [221886] = { type = BUFF_SPEED_BOOST, parent =  221883 }, -- Divine Steed (Blood Elf?)
        [221887] = { type = BUFF_SPEED_BOOST, parent =  221883 }, -- Divine Steed (Lightforged Draenei)
        [254471] = { type = BUFF_SPEED_BOOST, parent =  221883 }, -- Divine Steed (?)
        [254472] = { type = BUFF_SPEED_BOOST, parent =  221883 }, -- Divine Steed (?)
        [254473] = { type = BUFF_SPEED_BOOST, parent =  221883 }, -- Divine Steed (?)
        [254474] = { type = BUFF_SPEED_BOOST, parent =  221883 }, -- Divine Steed (?)
        [276111] = { type = BUFF_SPEED_BOOST, parent =  221883 }, -- Divine Steed (Dwarf?)
        [276112] = { type = BUFF_SPEED_BOOST, parent =  221883 }, -- Divine Steed (Dark Iron Dwarf?)
    [343721] = { type = DEBUFF_OFFENSIVE, nounitFrames = true, nonameplates = true }, -- Final Reckoning
    [343527] = { type = DEBUFF_OFFENSIVE }, -- Execution Sentence
    [255941] = { type = CROWD_CONTROL }, -- Wake of Ashes stun
    [385149] = { type = CROWD_CONTROL }, -- Exorcism stun
    [157128] = { type = BUFF_DEFENSIVE }, -- Saved by the Light
    [410201] = { type = DEBUFF_OFFENSIVE, nonameplates = true }, -- Searing Glare
    [403695] = { type = DEBUFF_OFFENSIVE, nonameplates = true }, -- Wake of Ashes (Truth's Wake)
    [2812] = { type = DEBUFF_OFFENSIVE, nonameplates = true }, -- Denounce

    -- Priest

    [373447] = { type = BUFF_DEFENSIVE }, -- Translucent Image (Fade)
    [605] = { type = CROWD_CONTROL, priority = true }, -- Mind Control
    [8122] = { type = CROWD_CONTROL }, -- Psychic Scream
    [9484] = { type = CROWD_CONTROL }, -- Shackle Undead
    [10060] = { type = BUFF_OFFENSIVE }, -- Power Infusion
    [15487] = { type = CROWD_CONTROL }, -- Silence
    [33206] = { type = BUFF_DEFENSIVE }, -- Pain Suppression
    [472433] = { type = BUFF_DEFENSIVE }, -- Evangelism
    [47585] = { type = BUFF_DEFENSIVE }, -- Dispersion
    [47788] = { type = BUFF_DEFENSIVE }, -- Guardian Spirit
    [64044] = { type = CROWD_CONTROL }, -- Psychic Horror
    [64843] = { type = BUFF_DEFENSIVE }, -- Divine Hymn
    [81782] = { type = BUFF_DEFENSIVE }, -- Power Word: Barrier
	[271466] = { type = BUFF_DEFENSIVE, parent = 81782 }, -- Luminous Barrier
    [87204] = { type = CROWD_CONTROL }, -- Sin and Punishment
    [194249] = { type = BUFF_OFFENSIVE }, -- Voidform
    [391109] = { type = BUFF_OFFENSIVE }, -- Dark Ascension
    [232707] = { type = BUFF_DEFENSIVE }, -- Ray of Hope (Holy PvP Talent)
    [197871] = { type = BUFF_OFFENSIVE }, -- Dark Archangel (Disc PvP Talent) - on the priest
        [197874] = { type = BUFF_OFFENSIVE, parent = 197871 }, -- Dark Archangel (Disc PvP Talent) - on others
    [200183] = { type = BUFF_DEFENSIVE }, -- Apotheosis
    [200196] = { type = CROWD_CONTROL }, -- Holy Word: Chastise
        [200200] = { type = CROWD_CONTROL, parent = 200196 }, -- Holy Word: Chastise (Stun)
    [213610] = { type = IMMUNITY_SPELL }, -- Holy Ward
    --[27827] = { type = BUFF_DEFENSIVE }, -- Spirit of Redemption
    [215769] = { type = BUFF_DEFENSIVE }, -- Spirit of Redemption (Spirit of the Redeemer Holy PvP Talent)
    [211336] = { type = BUFF_DEFENSIVE }, -- Archbishop Benedictus' Restitution (Resurrection Buff)
    [211319] = { type = BUFF_OTHER }, -- Archbishop Benedictus' Restitution (Debuff)
    [289655] = { type = BUFF_DEFENSIVE }, -- Holy Word: Concentration
    [322431] = { type = BUFF_OFFENSIVE, nounitFrames = true, nonameplates = true }, -- Thoughtsteal (Buff)
    [322459] = { type = DEBUFF_OFFENSIVE }, -- Thoughtstolen (Shaman)
        [322464] = { type = DEBUFF_OFFENSIVE, parent = 322459 }, -- Thoughtstolen (Mage)
        [322442] = { type = DEBUFF_OFFENSIVE, parent = 322459 }, -- Thoughtstolen (Druid)
        [322462] = { type = DEBUFF_OFFENSIVE, parent = 322459 }, -- Thoughtstolen (Priest - Holy)
        [322457] = { type = DEBUFF_OFFENSIVE, parent = 322459 }, -- Thoughtstolen (Paladin)
        [322463] = { type = DEBUFF_OFFENSIVE, parent = 322459 }, -- Thoughtstolen (Warlock)
        [322461] = { type = DEBUFF_OFFENSIVE, parent = 322459 }, -- Thoughtstolen (Priest - Discipline)
        [322458] = { type = DEBUFF_OFFENSIVE, parent = 322459 }, -- Thoughtstolen (Monk)
        [322460] = { type = DEBUFF_OFFENSIVE, parent = 322459 }, -- Thoughtstolen (Priest - Shadow)
        [394902] = { type = DEBUFF_OFFENSIVE, parent = 322459 }, -- Thoughtstolen (Evoker)
    [375901] = { type = DEBUFF_OFFENSIVE }, -- Mindgames
    [329543] = { type = BUFF_DEFENSIVE }, -- Divine Ascension (down)
        [328530] = { type = IMMUNITY, parent = 329543 }, -- Divine Ascension (up)
    [335467] = { type = DEBUFF_OFFENSIVE, nounitFrames = true, nonameplates = true }, -- Devouring Plague
    [34914] = { type = DEBUFF_OFFENSIVE, nounitFrames = true, nonameplates = true }, -- Vampiric Touch
    [453] = { type = BUFF_OTHER, noraidFrames = true }, -- Mind Soothe
    [15286] = { type = BUFF_DEFENSIVE }, -- Vampiric Embrace
    [19236] = { type = BUFF_DEFENSIVE }, -- Desperate Prayer
    [111759] = { type = BUFF_OTHER }, -- Levitate
    [322105] = { type = BUFF_OFFENSIVE }, -- Shadow Covenant
    [65081] = { type = BUFF_SPEED_BOOST }, -- Body and Soul
    [121557] = { type = BUFF_SPEED_BOOST }, -- Angelic Feather
    [199845] = { type = DEBUFF_OFFENSIVE, nounitFrames = true, nonameplates = true }, -- Psyflay (Psyfiend) debuff
    [214621] = { type = DEBUFF_OFFENSIVE, nonameplates = true }, -- Schism
    [358861] = { type = CROWD_CONTROL }, -- Void Volley: Horrify (Shadow PvP Talent)
    [114404] = { type = ROOT }, -- Void Tendrils
    [408558] = { type = IMMUNITY }, -- Phase Shift
    [421453] = { type = IMMUNITY }, -- Ultimate Penitence

    -- Rogue

    [408] = { type = CROWD_CONTROL }, -- Kidney Shot
    [1330] = { type = CROWD_CONTROL }, -- Garrote - Silence
    [1776] = { type = CROWD_CONTROL }, -- Gouge
    [1833] = { type = CROWD_CONTROL }, -- Cheap Shot
    [1966] = { type = BUFF_DEFENSIVE }, -- Feint
    [2094] = { type = CROWD_CONTROL }, -- Blind
    [2983] = { type = BUFF_SPEED_BOOST }, -- Sprint
    [36554] = { type = BUFF_SPEED_BOOST }, -- Shadowstep
    [5277] = { type = BUFF_DEFENSIVE }, -- Evasion
    [6770] = { type = CROWD_CONTROL }, -- Sap
    [11327] = { type = BUFF_DEFENSIVE }, -- Vanish
    [13750] = { type = BUFF_OFFENSIVE }, -- Adrenaline Rush
    [31224] = { type = IMMUNITY_SPELL }, -- Cloak of Shadows
    [45182] = { type = BUFF_DEFENSIVE }, -- Cheating Death
    [51690] = { type = BUFF_OFFENSIVE }, -- Killing Spree
    [121471] = { type = BUFF_OFFENSIVE }, -- Shadow Blades
    [185422] = { type = BUFF_OFFENSIVE }, -- Shadow Dance
    [212283] = { type = BUFF_OFFENSIVE, nounitFrames = true, nonameplates = true }, -- Symbols of Death
    [207777] = { type = CROWD_CONTROL }, -- Dismantle
    [212183] = { type = CROWD_CONTROL }, -- Smoke Bomb (PvP Talent)
    [1784] = { type = BUFF_OTHER }, -- Stealth
        [115191] = { type = BUFF_OTHER, parent = 1784 }, -- Stealth (with Subterfuge talented)
    [115192] = { type = BUFF_OFFENSIVE }, -- Subterfuge
    [256735] = { type = BUFF_OFFENSIVE }, -- Master Assassin
    [394758] = { type = BUFF_OFFENSIVE }, -- Flagellation
    [360194] = { type = DEBUFF_OFFENSIVE, priority = true, nonameplates = true }, -- Deathmark
    [193359] = { type = BUFF_OFFENSIVE }, -- True Bearing
    [193357] = { type = BUFF_OFFENSIVE }, -- Ruthless Precision
    [319504] = { type = DEBUFF_OFFENSIVE, nounitFrames = true, nonameplates = true }, -- Shiv
    [196937] = { type = DEBUFF_OFFENSIVE, nounitFrames = true, nonameplates = true }, -- Ghostly Strike
    [385627] = { type = DEBUFF_OFFENSIVE }, -- Kingsbane

    -- Shaman

    [2645] = { type = BUFF_SPEED_BOOST, nounitFrames = true, nonameplates = true }, -- Ghost Wolf
    [8178] = { type = IMMUNITY_SPELL }, -- Grounding Totem Effect (PvP Talent)
    [208997] = { type = DEBUFF_OFFENSIVE, nounitFrames = true, nonameplates = true }, -- Counterstrike Totem (PvP Talent)
    [51514] = { type = CROWD_CONTROL }, -- Hex
        [210873] = { type = CROWD_CONTROL, parent = 51514 }, -- Hex (Compy)
        [211004] = { type = CROWD_CONTROL, parent = 51514 }, -- Hex (Spider)
        [211010] = { type = CROWD_CONTROL, parent = 51514 }, -- Hex (Snake)
        [211015] = { type = CROWD_CONTROL, parent = 51514 }, -- Hex (Cockroach)
        [269352] = { type = CROWD_CONTROL, parent = 51514 }, -- Hex (Skeletal Hatchling)
        [277778] = { type = CROWD_CONTROL, parent = 51514 }, -- Hex (Zandalari Tendonripper)
        [277784] = { type = CROWD_CONTROL, parent = 51514 }, -- Hex (Wicker Mongrel)
        [309328] = { type = CROWD_CONTROL, parent = 51514 }, -- Hex (Living Honey)
    [58875] = { type = BUFF_SPEED_BOOST }, -- Spirit Walk
    [79206] = { type = BUFF_OTHER }, -- Spiritwalker's Grace
    [64695] = { type = ROOT }, -- Earthgrab Totem
    [77505] = { type = CROWD_CONTROL }, -- Earthquake (Stun)
    [325174] = { type = BUFF_DEFENSIVE }, -- Spirit Link Totem
    [108271] = { type = BUFF_DEFENSIVE }, -- Astral Shift
    [114049] = { type = BUFF_OFFENSIVE }, -- Ascendance
        [114050] = { type = BUFF_OFFENSIVE, parent = 114049 }, -- Ascendance (Elemental)
        [114051] = { type = BUFF_OFFENSIVE, parent = 114049 }, -- Ascendance (Enhancement)
        [114052] = { type = BUFF_DEFENSIVE, parent = 114049 }, -- Ascendance (Restoration)
    [118345] = { type = CROWD_CONTROL }, -- Pulverize
    [118337] = { type = BUFF_DEFENSIVE }, -- Harden Skin
    [118905] = { type = CROWD_CONTROL }, -- Static Charge
    [191634] = { type = BUFF_OFFENSIVE }, -- Stormkeeper (Ele)
    [197214] = { type = CROWD_CONTROL }, -- Sundering
    [201633] = { type = BUFF_DEFENSIVE }, -- Earthen Wall Totem
    [384352] = { type = BUFF_OFFENSIVE }, -- Doom Winds
    [260881] = { type = BUFF_DEFENSIVE }, -- Spirit Wolf
    [378078] = { type = BUFF_DEFENSIVE }, -- Spiritwalker's Aegis
    [305485] = { type = CROWD_CONTROL }, -- Lightning Lasso (PvP Talent)
    [546] = { type = BUFF_OTHER }, -- Water Walking
    [333957] = { type = BUFF_OFFENSIVE }, -- Feral Spirit
    [204361] = { type = BUFF_OFFENSIVE }, -- Bloodlust (Enhancement/Elemental PvP Talent)
        [204362] = { type = BUFF_OFFENSIVE, parent = 204361 }, -- Heroism (Enhancement/Elemental PvP Talent)
    [192082] = { type = BUFF_SPEED_BOOST }, -- Windrush Totem
    [378076] = { type = BUFF_SPEED_BOOST }, -- Thunderous Paws
    [375986] = { type = BUFF_OFFENSIVE }, -- Primordial Wave
    [207495] = { type = BUFF_DEFENSIVE }, -- Ancestral Protection (Totem)
        [207498] = { type = BUFF_DEFENSIVE, parent = 207495 }, -- Ancestral Protection (Player)
    [356738] = { type = ROOT }, -- Earth Unleashed
    [285515] = { type = ROOT }, -- Surge of Power (Root)
    [356824] = { type = DEBUFF_OFFENSIVE }, -- Water Unleashed
    [188389] = { type = DEBUFF_OFFENSIVE, nounitFrames = true, nonameplates = true }, -- Flame Shock
    [378081] = { type = BUFF_OFFENSIVE }, -- Nature's Swiftness (Shaman)
        [443454] = { type = BUFF_OFFENSIVE, parent = 378081 }, -- Ancestral Swiftness
    [1218125] = { type = BUFF_OFFENSIVE }, -- Primordial Storm
    [409293] = { type = IMMUNITY }, -- Burrow

    -- Warlock

    [113942] = { type = BUFF_OTHER }, -- Demonic Gateway
    [386997] = { type = DEBUFF_OFFENSIVE }, -- Soul Rot
    [710] = { type = CROWD_CONTROL }, -- Banish
    [5484] = { type = CROWD_CONTROL }, -- Howl of Terror
    [6358] = { type = CROWD_CONTROL }, -- Seduction
    [6789] = { type = CROWD_CONTROL }, -- Mortal Coil
    [20707] = { type = BUFF_OTHER }, -- Soulstone
    [22703] = { type = CROWD_CONTROL }, -- Infernal Awakening
    [30283] = { type = CROWD_CONTROL }, -- Shadowfury
    [89766] = { type = CROWD_CONTROL }, -- Axe Toss
    [104773] = { type = BUFF_DEFENSIVE }, -- Unending Resolve
    [108416] = { type = BUFF_DEFENSIVE }, -- Dark Pact
    [111400] = { type = BUFF_SPEED_BOOST }, -- Burning Rush
    [265273] = { type = BUFF_OFFENSIVE }, -- Demonic Power (Demonic Tyrant)
    [118699] = { type = CROWD_CONTROL }, -- Fear
	[130616] = { type = CROWD_CONTROL, parent = 118699 }, -- Fear (Horrify)
    [196364] = { type = CROWD_CONTROL }, -- Unstable Affliction (Silence)
    [212295] = { type = IMMUNITY_SPELL }, -- Nether Ward (PvP Talent)
    [1098] = { type = CROWD_CONTROL }, -- Subjugate Demon
    [316099] = { type = DEBUFF_OFFENSIVE, nounitFrames = true, nonameplates = true }, -- Unstable Affliction
        [342938] = { type = DEBUFF_OFFENSIVE, parent = 316099 }, -- Unstable Affliction (Affliction PvP Talent)
    [30213] = { type = DEBUFF_OFFENSIVE, nounitFrames = true, nonameplates = true }, -- Legion Strike
    [200587] = { type = DEBUFF_OFFENSIVE, nounitFrames = true, nonameplates = true }, -- Fel Fissure (PvP Talent)
    [333889] = { type = BUFF_DEFENSIVE }, -- Fel Domination
    [267171] = { type = BUFF_OFFENSIVE }, -- Demonic Strength
    [80240] = { type = DEBUFF_OFFENSIVE, nounitFrames = true, nonameplates = true }, -- Havoc
        [200548] = { type = DEBUFF_OFFENSIVE, parent = 80240 }, -- Bane of Havoc (Destro PvP Talent)
    [213688] = { type = CROWD_CONTROL }, -- Fel Cleave - Fel Lord stun (Demo PvP Talent)
    [387633] = { type = BUFF_SPEED_BOOST }, -- Demonic Momentum (Soulburn)
    [1714] = { type = DEBUFF_OFFENSIVE, nounitFrames = true, nonameplates = true }, -- Curse of Tongues
    [702] = { type = DEBUFF_OFFENSIVE, nounitFrames = true, nonameplates = true }, -- Curse of Weakness
    [410598] = { type = DEBUFF_OFFENSIVE, nonameplates = true }, -- Soul Rip
    [442726] = { type = BUFF_OFFENSIVE }, -- Malevolence
    [48181] = { type = DEBUFF_OFFENSIVE, nonameplates = true }, -- Haunt
    [417537] = { type = DEBUFF_OFFENSIVE, nonameplates = true }, -- Oblivion

    -- Warrior

    [871] = { type = BUFF_DEFENSIVE }, -- Shield Wall
    [198817] = { type = DEBUFF_OFFENSIVE }, -- Sharpen Blade
    [1719] = { type = BUFF_OFFENSIVE }, -- Recklessness
    [52437] = {type = BUFF_OFFENSIVE }, -- Sudden Death
    [5246] = { type = CROWD_CONTROL }, -- Intimidating Shout
        [316593] = { type = CROWD_CONTROL, parent = 5246 }, -- Menace (Main target)
        [316595] = { type = CROWD_CONTROL, parent = 5246 }, -- Menace (Other targets)
    [12975] = { type = BUFF_DEFENSIVE }, -- Last Stand
    [18499] = { type = BUFF_OTHER }, -- Berserker Rage
	[384100] = { type = BUFF_OTHER, parent = 18499 }, -- Berserker Shout
	[1219201] = { type = BUFF_OTHER, parent = 18499 }, -- Berserker Roar
    [23920] = { type = IMMUNITY_SPELL }, -- Spell Reflection
    [132168] = { type = CROWD_CONTROL }, -- Shockwave
    [97463] = { type = BUFF_DEFENSIVE }, -- Rallying Cry
    [105771] = { type = ROOT }, -- Charge
    [356356] = { type = ROOT }, -- Warbringer
    [107574] = { type = BUFF_OFFENSIVE }, -- Avatar
    [118038] = { type = BUFF_DEFENSIVE }, -- Die by the Sword
    [132169] = { type = CROWD_CONTROL }, -- Storm Bolt
    [385954] = { type = CROWD_CONTROL }, -- Shield Charge
    [147833] = { type = BUFF_DEFENSIVE }, -- Intervene
    [184364] = { type = BUFF_DEFENSIVE }, -- Enraged Regeneration
    [386208] = { type = BUFF_DEFENSIVE }, -- Defensive Stance
    [208086] = { type = DEBUFF_OFFENSIVE, nounitFrames = true, nonameplates = true }, -- Colossus Smash
    [213871] = { type = BUFF_DEFENSIVE }, -- Bodyguard (Prot PvP Talent)
    [227847] = { type = IMMUNITY }, -- Bladestorm
	[446035] = { type = IMMUNITY, parent = 227847 }, -- Bladestorm
    [236077] = { type = CROWD_CONTROL }, -- Disarm (PvP Talent)
    [199042] = { type = ROOT }, -- Thunderstruck (Prot PvP Talent)
    [236273] = { type = CROWD_CONTROL }, -- Duel (Arms PvP Talent)
    [1219209] = { type = BUFF_DEFENSIVE }, -- Berserker Roar (PvP Talent)
    [198819] = { type = DEBUFF_OFFENSIVE, nounitFrames = true, nonameplates = true }, -- Mortal Strike when applied with Sharpen Blade (50% healing reduc)
    [202164] = { type = BUFF_SPEED_BOOST }, -- Bounding Stride
    [376080] = { type = CROWD_CONTROL, nounitFrames = true, nonameplates = true }, -- Champion's Spear
    [354788] = { type = DEBUFF_OFFENSIVE, nounitFrames = true, nonameplates = true }, -- Slaughterhouse
    [397364] = { type = DEBUFF_OFFENSIVE, nounitFrames = true, nonameplates = true }, -- Thunderous Roar
    [199261] = { type = BUFF_OFFENSIVE }, -- Death Wish

    -- Other

    [115804] = { type = DEBUFF_OFFENSIVE, nounitFrames = true, nonameplates = true }, -- Mortal Wounds
    [1217789] = { type = DEBUFF_OFFENSIVE, nounitFrames = true, nonameplates = true }, -- Grevious Injury (Marksmanship Hunter MS)
    [34709] = { type = BUFF_OTHER }, -- Shadow Sight
    [345231] = { type = BUFF_DEFENSIVE }, -- Gladiator's Emblem
    [314646] = { type = BUFF_OTHER }, -- Drink (40k mana vendor item)
        [348436] = { type = BUFF_OTHER, parent = 314646 }, -- (20k mana vendor item)
        [167152] = { type = BUFF_OTHER, parent = 314646 }, -- Refreshment (mage food)
    [377362] = { type = IMMUNITY }, -- Precognition
    [240559] = { type = DEBUFF_OFFENSIVE, nonameplates = true }, -- Grievous Wound (Mythic Plus Affix)

    -- Racials

    [20549] = { type = CROWD_CONTROL }, -- War Stomp
    [107079] = { type = CROWD_CONTROL }, -- Quaking Palm
    [255723] = { type = CROWD_CONTROL }, -- Bull Rush
    [287712] = { type = CROWD_CONTROL }, -- Haymaker
    [256948] = { type = BUFF_OTHER }, -- Spatial Rift
    [65116] = { type = BUFF_DEFENSIVE }, -- Stoneform
    [273104] = { type = BUFF_DEFENSIVE }, -- Fireblood
    [58984] = { type = BUFF_DEFENSIVE }, -- Shadowmeld

    -- Dragonflight: Dragonriding

    [388673] = { type = CROWD_CONTROL }, -- Dragonrider's Initiative
    [388380] = { type = BUFF_SPEED_BOOST }, -- Dragonrider's Compassion

    -- Shadowlands: Covenant/Soulbind

    [310143] = { type = BUFF_SPEED_BOOST }, -- Soulshape
    [320224] = { type = BUFF_DEFENSIVE }, -- Podtender (Night Fae - Dreamweaver Trait)
    [323524] = { type = IMMUNITY }, -- Ultimate Form (Necrolord - Marileth Trait)
    [324263] = { type = CROWD_CONTROL }, -- Sulfuric Emission (Necrolord - Emeni Trait)
    [327140] = { type = BUFF_OTHER }, -- Forgeborne Reveries (Necrolord - Bonesmith Heirmir Trait)
    [330752] = { type = BUFF_DEFENSIVE }, -- Ascendant Phial (Kyrian - Kleia Trait)
    [331866] = { type = CROWD_CONTROL }, -- Agent of Chaos (Venthyr - Nadjia Trait)
    [332505] = { type = BUFF_OTHER }, -- Soulsteel Clamps (Kyrian - Mikanikos Trait)
        [332506] = { type = BUFF_OTHER, parent = 332505 }, -- Soulsteel Clamps (Kyrian - Mikanikos Trait) - when moving
    [332423] = { type = CROWD_CONTROL }, -- Sparkling Driftglobe Core (Kyrian - Mikanikos Trait)
    [354051] = { type = ROOT }, -- Nimble Steps

    -- Trinkets
    [356567] = { type = CROWD_CONTROL }, -- Shackles of Malediction
    [358259] = { type = CROWD_CONTROL }, -- Gladiator's Maledict
    [362699] = { type = IMMUNITY_SPELL }, -- Gladiator's Resolve
    [363522] = { type = BUFF_DEFENSIVE }, -- Gladiator's Eternal Aegis

    -- Legacy (may be deprecated)

    --[305252] = { type = CROWD_CONTROL }, -- Gladiator's Maledict
    --[313148] = { type = CROWD_CONTROL }, -- Forbidden Obsidian Claw

    -- Special
    --[6788] = { type = "special", nounitFrames = true, noraidFrames = true }, -- Weakened Soul

    -- Dragonflight Dungeons - Season 2
    [266107] = { type = DEBUFF_OFFENSIVE }, -- Thirst for Blood
    [368091] = { type = DEBUFF_OFFENSIVE }, -- Infected Bite

    -- The War Within World Buffs
    [443026] = {type = IMMUNITY}, -- General's Phalanx (The General Tier 4 Benefit)
    [462823] = {type = IMMUNITY}, -- General's Bulwark (The General Tier 6 Benefit)

}
