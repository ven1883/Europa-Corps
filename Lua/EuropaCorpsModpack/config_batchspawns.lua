local batchSpawnConfig = {

--[[

	note: job is nil for nonhumans

	batchname = 
	{
		{"SpeciesName","job"},
		{"SpeciesName","job"},
		{"SpeciesName","job"}
	}

]]	

	jimmy = 
	{
		{"human","securityofficer"}
	},

	-- |#########|
	-- |# HUSKS #|
	-- |#########|

	husk_basic = 
	{
		{"humanhuskold"},
		{"humanhuskold"},
		{"humanhuskold"},
		{"humanhuskold"},
		{"humanhuskold"},
		{"humanhuskold"},
		{"humanhuskold"}
	},

	husk_bombs = 
	{
		{"huskbomber"},
		{"huskbomber"},
		{"huskbomber"},
	},

	husk_mutants = 
	{
		{"huskmutanthuman"},
		{"huskmutanthuman"},
		{"huskmutantcocoonhuman"},
		{"huskmutanthumantorso"}
	},

	husk_crabmix = 
	{
		{"huskmutanthumantorso"},
		{"huskmutanthumanhead"},
		{"huskmutanthumanhead"},
		{"huskmutanthumanhead"},
		{"huskmutanthumantorso"},
		{"huskmutanthuman"}
	},

	husk_raptors = 
	{
		{"mudraptorhusk"},
		{"mudraptorhusk"},
		{"mudraptorhusk"},
		{"mudraptor_hatchlinghusk"},
		{"mudraptor_hatchlinghusk"},
		{"mudraptor_hatchlinghusk"},
		{"mudraptor_veteranhusk"}
	},

	husk_raptors_mutant = 
	{
		{"huskmutantmudraptor"},
		{"huskmutantmudraptor"},
		{"huskmutantmudraptor"},
		{"mudraptor_hatchlinghusk"},
		{"mudraptor_hatchlinghusk"},
		{"mudraptor_hatchlinghusk"},
	},

	husk_armour = 
	{
		{"Husk_chimera"},
		{"Husk_chimera"},
		{"huskmutantarmoredpucs"},
		{"huskmutanthuman"},
		{"huskmutanthuman"},
		{"huskmutanthuman"}
	},

	
	-- |###############|
	-- |# SEPARATISTS #|
	-- |###############|

sep_scout = --fodder
	{
		{"human", "seppie_shotgunner"},
		{"human", "seppie_rifleman"},
		{"human", "seppie_rifleman"},
	},

sep_fireteam = --reduced squad
	{
		{"human", "seppie_captain"},
		{"human", "seppie_gunner"},
		{"human", "seppie_medic"},
		{"human", "seppie_rifleman"}
	},

sep_squad = --full squad
	{
		{"human", "seppie_captain"},
		{"human", "seppie_gunner"},
		{"human", "seppie_medic"},
		{"human", "seppie_shotgunner"},
		{"human", "seppie_rifleman"},
		{"human", "seppie_rifleman"}
	},
	
	-- |#############|
	-- |# COALITION #|
	-- |#############|

coal_scout = --cannon fodder
	{
		{"human", "coalition_grunt"},
		{"human", "coalition_marksman"},
		{"human", "coalition_marksman"}
	},

coal_fireteam = --dangerous, but not unstoppable
	{
		{"human", "coalition_heavy"},
		{"human", "coalition_sapper"},
		{"human", "coalition_grunt"},
		{"human", "coalition_grunt"}
	},

coal_squad = --mortis
	{
		{"human", "coalition_heavy"},
		{"human", "coalition_heavy"},
		{"human", "coalition_heavy"},
		{"human", "coalition_demoman"} --this guy got the rocket launcher
	},

	-- |############|
	-- |# CULTISTS #|
	-- |############|

cult_flank = --heavy, tough brutes to draw fire, vipers to strike from the sides and rear
	{
		{"human", "cultist_viper"},
		{"human", "cultist_initiate"},
		{"human", "cultist_initiate"}
	},

cult_siege = --big frontal assault team
{
	{"human", "cultist_leader"},
	{"human", "cultist_initiate"},
	{"human", "cultist_initiate"},
	{"human", "cultist_initiate"}
},

	-- |###########|
	-- |# BANDITS #|
	-- |###########|

bandit_fodder = --the weakest fodder, second only to civilians
	{
		{"human", "bandit_basic"},
		{"human", "bandit_scout"},
		{"human", "bandit_scout"}
	},

bandit_gunnery = --big gun backed up by basic bandits
	{
		{"human", "bandit_basic"},
		{"human", "bandit_gunner"},
		{"human", "bandit_basic"}
	},

bandit_rangers = --marksman duo with a buddy
	{
		{"human", "bandit_marksman"},
		{"human", "bandit_marksman"},
		{"human", "bandit_basic"}
	},

bandit_squad = --proper squad with all roles filled
	{
		{"human", "bandit_leader"},
		{"human", "bandit_gunner"},
		{"human", "bandit_marksman"},
		{"human", "bandit_basic"},
		{"human", "bandit_basic"}
	},

bandit_gaggle = --the horde
	{
		{"human", "bandit_leader"},
		{"human", "bandit_scout"},
		{"human", "bandit_scout"},
		{"human", "bandit_scout"},
		{"human", "bandit_scout"},
	},

	-- |#############|
	-- |# SURVIVORS #|
	-- |#############|

survivor_small = 
	{
		{"human", "survivor"},
		{"human", "survivor"},
		{"human", "survivor"}
	},

survivor_medium = 
	{
		{"human", "survivor_medic"},
		{"human", "survivor"},
		{"human", "survivor"},
		{"human", "survivor"}
	},

survivor_large = 
	{
		{"human", "survivor_medic"},
		{"human", "survivor"},
		{"human", "survivor"},
		{"human", "survivor"},
		{"human", "survivor"},
		{"human", "survivor"}
	},

}

return batchSpawnConfig