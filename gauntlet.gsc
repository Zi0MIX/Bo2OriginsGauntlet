#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zombies/_zm_stats;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_weapons;
#include maps/mp/animscripts/zm_utility;
#include maps/mp/zm_tomb;
#include maps/mp/zm_tomb_utility;
// New
#include maps/mp/zm_tomb_capture_zones;
#include maps/mp/zm_tomb_tank;
#include maps/mp/zm_tomb_utility;
#include maps/mp/gametypes_zm/_tweakables;
#include maps/mp/gametypes_zm/_shellshock;
#include maps/mp/gametypes_zm/_weapons;
#include maps/mp/zombies/_zm_game_module;
#include maps/mp/zombies/_zm_net;
#include maps/mp/zombies/_zm_ai_mechz;
#include maps/mp/zombies/_zm_perks;
#include maps/mp/zombies/_zm_perk_random;
#include maps/mp/zombies/_zm_laststand;
#include maps/mp/zombies/_zm_magicbox;
#include maps/mp/zombies/_zm_score;
#include maps/mp/zombies/_zm_powerups;
#include maps/mp/zombies/_zm;

main()
{
    // Pluto QoL changes
    replaceFunc(maps/mp/zombies/_zm_powerups::full_ammo_powerup, ::full_ammo_powerup_override);
}

init()
{
	level thread OnPlayerConnect();
    flag_init("env_kill");
    flag_init("out_of_zone");
    flag_init("just_set_weapon");
    flag_init("weapons_cleared");
    flag_init("nuke_taken");
    flag_init("insta_taken");
    flag_init("max_taken");
    flag_init("double_taken");
    flag_init("blood_taken");
    flag_init("sale_taken");
    flag_init("points_taken");
}

OnPlayerConnect()
{
	level waittill("connecting", player );	
    
	player thread OnPlayerSpawned();

	level waittill("initial_players_connected");
    level thread SetDvars();
    level thread DevDebug("raygun_mark2_upgraded_zm", 16);   // For debugging

    flag_wait("initial_blackscreen_passed");

    level thread EndGameWatcher();
    level thread TimerHud();
    level thread ZombieCounterHud();
    level thread BetaHud(7);
    level thread SetupPanzerRound(16);  // To remake/removal?
    level thread DropWatcher();
    
    // For debugging
    if (isdefined(level.wait_for_round))
    {
        iPrintLn("Waiting");
        level waittill ("start_of_round");
    }

    while (1)
    {
        // Activate generator 1
        if (level.round_number == 1)
        {
            level thread CheckForGenerator(1, 1, 1);
        }

        // Only kill with melee (except for shield)
        else if (level.round_number == 2)
        {
            level thread CheckUsedWeapon(2);
        }

        // Stay still
        else if (level.round_number == 3)
        {
            level thread DisableMovement(3);
        }

        // Have one perk at the end of the round
        else if (level.round_number == 4)
        {
            level thread WatchPerks(4, 1);
        }

        // Pull at least one weapon from the box
        else if (level.round_number == 5)
        {
            level thread WatchPlayerStat(5, "grabbed_from_magicbox", 0, 0, undefined, undefined, undefined);
        }

        // Dig 3 piles (1 for each on coop)
        else if (level.round_number == 6)
        {
            level thread WatchPlayerStat(6, "tomb_dig", 2, 0, undefined, undefined, undefined);
        }

        // Knife kill 6 zombies (12 coop)
        else if (level.round_number == 7)
        {
            level thread WatchPlayerStat(7, "melee_kills", 0, 6, 0, 0, 6);
        }

        // Have one jug by the end of the round
        else if (level.round_number == 8)
        {
            level thread WatchPerks(8, 1);
        }

        // Only kill with mp40
        else if (level.round_number == 9)
        {
            level thread CheckUsedWeapon(9);
        }   

        // Crouch only
        else if (level.round_number == 10)
        {
            level thread DisableMovement(10);
        }

        // Don't buy anything
        else if (level.round_number == 11)
        {
            level thread BuyNothing(11);
        }

        // Have at least one upgraded staff at the end of the round
        else if (level.round_number == 12)
        {
            level thread WatchUpgradedStaffs(12, 1);
        }

        // Survive a round with super-sprinters
        else if (level.round_number == 13)
        {
            level thread ZombieSuperSprint(13);
        }

        // No jumping
        else if (level.round_number == 14)
        {
            level thread DisableMovement(14);
        }

        // Activate all generators
        else if (level.round_number == 15)
        {
            level thread CheckForGenerator(15, 0);
        }

        // Survive a round with Panzers
        else if (level.round_number == 16)
        {
            level thread TooManyPanzers(16);
        }

        // Dig 7 piles (2 for each on coop)
        else if (level.round_number == 17)
        {
            level thread WatchPlayerStat(17, "tomb_dig", 6, 1, undefined, undefined, undefined);
        }

        // Timescale
        else if (level.round_number == 18)
        {
            level thread SetDvarForRound(18, "timescale", 1.6, 1);
        }

        // Only kill with mp40
        else if (level.round_number == 19)
        {
            level thread CheckUsedWeapon(19);
        }   

        // Protect church
        else if (level.round_number == 20)
        {
            level thread CheckForZone(20, array("zone_village_2"), 60);
        }

        // Have five perks at the end of the round
        else if (level.round_number == 21)
        {
            level thread WatchPerks(21, 5);
        }

        // All perks are off
        else if (level.round_number == 22)
        {
            level thread ShutDownPerk(22, "all");
        }

        // Only kill with unpacked stg
        else if (level.round_number == 23)
        {
            level thread CheckUsedWeapon(23);
        }   

        // Take damage if not moving
        else if (level.round_number == 24)
        {
            level thread SprintWatcher(24);
        }

        // GunGame
        else if (level.round_number == 25)
        {
            level thread GunGame(25);
        }

        // Only kill with m14
        else if (level.round_number == 26)
        {
            // level thread 
        }  

        // Protect church
        else if (level.round_number == 27)
        {
            level thread CompareKillsWithZones(27);
        }

        // Only kill with mp40
        else if (level.round_number == 28)
        {
            level thread WatchPlayerStat(28, "drops", 0, 0, undefined, undefined, undefined);
        }   

        // Guns eat up twice as much ammo
        else if (level.round_number == 29)
        {
            level thread AmmoController(29);
        }   

        level waittill("start_of_round"); // Careful not to add this inside normal fucntions

        wait 0.05;
    }
}

OnPlayerSpawned()
{
    level endon( "game_ended" );
	self endon( "disconnect" );

	self waittill( "spawned_player" );

	flag_wait( "initial_blackscreen_passed" );
}

SetDvars()
//Function sets and holds level dvars
{
    level endon( "game_ended" );
    
    foreach(player in level.players)
    {
        player.score = 505;
    }
    level.conditions_met = false;
    level.conditions_in_progress = false;
    self thread LevelDvarsWatcher();
    level.player_too_many_weapons_monitor = 0;
    level.callbackactorkilled = ::actor_killed_override; // Pointer
    // level.player_too_many_weapons_monitor_func = ::player_too_many_weapons_monitor_override;

    level.weapon_used = undefined;
    level.killer_class = undefined;

    while (1)
    {
        level.conditions_met = false;
        level.conditions_in_progress = false;
        level.forbidden_weapon_used = false;
        level.active_gen_1 = false;
        level.active_gen_2 = false;
        level.active_gen_3 = false;
        level.active_gen_4 = false;
        level.active_gen_5 = false;
        level.active_gen_6 = false;
        level.players_jug = 0;
        level.players_quick = 0;
        level.players_doubletap = 0;
        level.players_speed = 0;
        level.players_phd = 0;
        level.players_deadshot = 0;
        level.players_stam = 0;
        level.players_cherry = 0;
        level.players_mulekick = 0;
        level.allplayersup = false;

        level.player_too_many_weapons_monitor = 0;

        flag_clear("env_kill");
        flag_clear("nuke_taken");
        flag_clear("insta_taken");
        flag_clear("max_taken");
        flag_clear("double_taken");
        flag_clear("blood_taken");
        flag_clear("sale_taken");
        flag_clear("points_taken");

        level waittill("end_of_round");
        wait 3; // Must be higher than 1 ::EndGameWatcher
    }
}

LevelDvarsWatcher()
// Function switches level dvars depending on other level dvars so it doesn't have to be done manually, also to prevent hud color fuckery
{
    level endon( "game_ended" );

    while (1)
    {
        if (level.conditions_met)
        {
           level.conditions_in_progress = false; 
        }

        if (level.conditions_in_progress)
        {
            level.conditions_met = false;
        }

        wait 0.05;
    }
}


EndGameWatcher()
//Function operates when level is suppose to end
{
    level endon( "game_ended" );


    self thread ForbiddenWeaponWatcher();
    level waittill ("start_of_round");
    while (1)
    {
        level waittill ("end_of_round");
        wait 1;
        if (!level.conditions_met)
        {
            EndGame();
        }

        else if (level.round_number >= 30)
        {
            maps\mp\zombies\_zm_game_module::freeze_players( 1 );
            level notify("game_won"); // Need to code that
        }

        else if (level.round_number >= 28) // For beta only
        {
            wait 5;
            EndGame("you win beta kappa");
        }
        

        wait 1;
    }
}

ForbiddenWeaponWatcher()
// Function will immidiately end the game if forbidden_weapon trigger is enabled
{
    level endon( "game_ended" );
	self endon( "disconnect" );
    while (1)
    {
        if (level.forbidden_weapon_used)
        {
            EndGame();
            break;
        }
        wait 0.05;
    }
}

EndGame(iprint)
// Function ends the game immidiately
{
    if (!isdefined(iprint))
    {
        iprint = "you bad";
    }
    iprintln(iprint);
    ConditionsMet(false);
    ConditionsInProgress(false);
    wait 0.1;
    maps\mp\zombies\_zm_game_module::freeze_players(1);
    level notify("end_game");
}

ConditionsInProgress(bool)
// Function changes the state of conditions_in_progress boolean, as well as conditions_met if necessary
{
    level.conditions_in_progress = bool;
    if (bool)
    {
        level.conditions_met = false;
    }
    return;
}

DevDebug(weapon, round)
// Function to set up debugging vars and items
{
    level endon( "game_ended" );
	self endon( "disconnect" );

    level.wait_for_round = true;
    level.debug_weapons = true;     // debug CheckUsedWeapon()

    if (isdefined(round))
    {
        level.round_number = round;
    }

    level waittill ("start_of_round");

    foreach (player in level.players)
    {
        player giveWeapon(weapon);
        player switchtoweapon(weapon);
        player givestartammo(weapon);
        player.score = 50005;
    }

    if( level.player_out_of_playable_area_monitor && IsDefined( level.player_out_of_playable_area_monitor ) )
	{
		self notify( "stop_player_out_of_playable_area_monitor" );
	}
	level.player_out_of_playable_area_monitor = 0;
}

ConditionsMet(bool)
// Function changes the state of conditions_met boolean, as well as conditions_in_progress if necessary
{
    level.conditions_met = bool;
    if (bool)
    {
        level.conditions_in_progress = false;
    }
    return;
}

TimerHud()
// Timer hud displayer throught the game
{
    self endon("disconnect");
    level endon("end_game");

    timer_hud = newHudElem();
	timer_hud.alignx = "left";					
	timer_hud.aligny = "top";
	timer_hud.horzalign = "user_left";			
	timer_hud.vertalign = "user_top";
	timer_hud.x = 7; 							
	timer_hud.y = 50;							
	timer_hud.fontscale = 1.4;
	timer_hud.alpha = 1;
	timer_hud.color = ( 1, 1, 1 );
	timer_hud.hidewheninmenu = 1;

	timer_hud setTimerUp(0); 
}

ZombieCounterHud()
// Timer hud displayer throught the game
{
    self endon("disconnect");
    level endon("end_game");

    counter_hud = newHudElem();
	counter_hud.alignx = "left";					
	counter_hud.aligny = "top";
	counter_hud.horzalign = "user_left";			
	counter_hud.vertalign = "user_top";
	counter_hud.x = 7; 							
	counter_hud.y = 70;							
	counter_hud.fontscale = 1.4;
	counter_hud.alpha = 1;
	counter_hud.color = ( 1, 1, 1 );
	counter_hud.hidewheninmenu = 1;

    while (1)
    {
        counter_hud setText("Remaining: " + (maps/mp/zombies/_zm_utility::get_round_enemy_array().size + level.zombie_total)); 
        wait 0.05;
    }
	
}

GauntletHud(challenge, relative_var)
// Hud for printing challenge goals, function doesn't yet work properly
{
    self endon("disconnect");
    level endon("end_game");

    if (isdefined(gauntlet_hud))
    {
        gauntlet_hud destroy_hud();
    }
    if (!isdefined(relative_var))
    {
        relative_var = 0;
    }

    gauntlet_hud = newHudElem();
    gauntlet_hud.alignx = "right";
    gauntlet_hud.aligny = "middle";
    gauntlet_hud.horzalign = "user_right";
    gauntlet_hud.vertalign = "user_center";
    gauntlet_hud.x -= 3;
    gauntlet_hud.y -= 20;
    gauntlet_hud.fontscale = 1.4;
    gauntlet_hud.alpha = 1;
    gauntlet_hud.hidewheninmenu = 1;
    gauntlet_hud.color = (1, 1, 1);
    gauntlet_hud settext("Origins gauntlet");
    if (challenge == 1)
    {
        gauntlet_hud settext("Activate generator 1");
    }
    else if (challenge == 2)
    {
        gauntlet_hud settext("Kill only with melee attacks");
    }
    else if (challenge == 3)
    {
        gauntlet_hud settext("Stand still");
    }
    else if (challenge == 4)
    {
        gauntlet_hud settext("Own a perk at the end of the round");
    }
    else if (challenge == 5)
    {
        gauntlet_hud settext("Pull a weapon from the mystery box");
    }
    else if (challenge == 6)
    {
        if (level.players.size == 1)
        {
            gauntlet_hud settext("Dig up 3 piles");
        }
        else
        {
            gauntlet_hud settext("Dig up a pile");
        }
    }
    else if (challenge == 7)
    {
        if (level.players.size == 1)
        {
            gauntlet_hud settext("Kill 6 zombies with melee attacks");
        }
        else
        {
            gauntlet_hud settext("Kill 12 zombies total with melee attacks");
        }
    }
    else if (challenge == 8)
    {
        gauntlet_hud settext("Own Jugger-Nog by the end of the round");
    }
    else if (challenge == 9)
    {
        gauntlet_hud settext("Only kill with MP-40");
    }
    else if (challenge == 10)
    {
        gauntlet_hud settext("Crouch only");
    }
    else if (challenge == 11)
    {
        gauntlet_hud settext("Don't buy anything");
    }
    else if (challenge == 12)
    {
        gauntlet_hud settext("Upgrade a staff");
    }
    else if (challenge == 13)
    {
        gauntlet_hud settext("Survive round with super-sprinters");
    }
    else if (challenge == 14)
    {
        gauntlet_hud settext("No jumping");
    }
    else if (challenge == 15)
    {
        gauntlet_hud settext("Activate all generators");
    }
    else if (challenge == 16)
    {
        gauntlet_hud settext("Survive round with panzers");
    }
    else if (challenge == 17)
    {
        if (level.players.size == 1)
        {
            gauntlet_hud settext("Dig up 7 piles");
        }
        else
        {
            gauntlet_hud settext("Dig up 2 piles");
        }
    }
    else if (challenge == 18)
    {
        gauntlet_hud settext("Time is faster");
    }
    else if (challenge == 19)
    {
        gauntlet_hud settext("Only kill with MP-40");
    }
    else if (challenge == 20)
    {
        gauntlet_hud settext("Protect church");
    }
    else if (challenge == 21)
    {
        gauntlet_hud settext("Own " + relative_var + " perks at the end of the round");
    }
    else if (challenge == 22)
    {
        gauntlet_hud settext("All perks are offline");
    }
    else if (challenge == 23)
    {
        gauntlet_hud settext("Only kill with First Room guns");
    }
    else if (challenge == 24)
    {
        gauntlet_hud settext("Move or get hurt");
    }
    else if (challenge == 25)
    {
        gauntlet_hud settext("Weapons shuffle");
    }
    else if (challenge == 26)
    {
        gauntlet_hud settext("Kill " + relative_var + " zombies with tank");
    }
    else if (challenge == 27)
    {
        gauntlet_hud settext("Only kill zombies while indoors");
    }
    else if (challenge == 28)
    {
        gauntlet_hud settext("Don't pick up any drops");
    }
    else if (challenge == 29)
    {
        gauntlet_hud settext("Value your ammo");
    }

    while (level.round_number == challenge)
    {
        if (level.conditions_in_progress)
        {
            gauntlet_hud.color = (0.8, 0.8, 0);
        }
        else if (level.conditions_met)
        {          
            gauntlet_hud.color = (0, 0.8, 0);
        }
        else if (!level.conditions_met && !level.conditions_in_progress)
        {
            gauntlet_hud.color = (0.8, 0, 0);
        }
        else
        {
            gauntlet_hud.color = (1, 1, 1); // failsafe
        }

        wait 0.05;
    }

    wait 1;
    gauntlet_hud.color = GauntletHudAfteraction();

    wait 4;
    gauntlet_hud fadeovertime(1.25);
    gauntlet_hud.alpha = 0;
    wait 2;

    // gauntlet_hud destroy_hud();
}

GauntletHudAfteraction()
// Function changes the color of challenge hud after the round is over
{
    if (level.conditions_met)
    {
        return (0, 0.8, 0);
    }
    else
    {
        return (0.8, 0, 0);
    }
}

BetaHud(beta_version)
// Function for beta overlay
{
    self endon("disconnect");

    if (!isdefined(beta_version))
    {
        beta_version = 0;
    }
    beta_hud = newHudElem();
    beta_hud.alignx = "middle";
    beta_hud.aligny = "top";
    beta_hud.horzalign = "user_center";
    beta_hud.vertalign = "user_top";
    beta_hud.x = 0;
    beta_hud.y = 5;
    beta_hud.fontscale = 1.2;
    beta_hud.alpha = 0.3;
    beta_hud.hidewheninmenu = 1;
    beta_hud.color = (0, 0.4, 0.8);
    beta_hud settext("Beta V" + beta_version);
}

CheckForGenerator(challenge, gen_id, rnd_override)
// Master function for checking generators. Pass 0 as gen_id to verify all gens
{
    level endon("end_game");
    level endon("start_of_round");

    self.current_round = level.round_number;
    if (isdefined(rnd_override))
    {
        self.current_round = rnd_override;
    }
    self.generator_id = gen_id;

    self thread GauntletHud(challenge);
    self thread GeneratorCondition();
    self thread GeneratorWatcher();
}

GeneratorCondition()
// Function will change boolean if defined generator is taken
{
    while (self.current_round == level.round_number)
    {
        if (level.active_gen_1 && self.generator_id == 1)
        {
            ConditionsMet(true);
        }

        else if (level.active_gen_2 && self.generator_id == 2)
        {
            ConditionsMet(true);
        }

        else if (level.active_gen_3 && self.generator_id == 3)
        {
            ConditionsMet(true);
        }

        else if (level.active_gen_4 && self.generator_id == 4)
        {
            ConditionsMet(true);
        }

        else if (level.active_gen_5 && self.generator_id == 5)
        {
            ConditionsMet(true);
        }

        else if (level.active_gen_6 && self.generator_id == 6)
        {
            ConditionsMet(true);
        }

        else if (self.generator_id == 0)
        {
            if (level.active_gen_1 && level.active_gen_2 && level.active_gen_3 && level.active_gen_4 && level.active_gen_5 && level.active_gen_6)
            {
                ConditionsMet(true);
            }

            else if (level.active_gen_1 || level.active_gen_2 || level.active_gen_3 || level.active_gen_4 || level.active_gen_5 || level.active_gen_6)
            {
                ConditionsInProgress(true);
            }

            else
            {
                ConditionsMet(false);
                ConditionsInProgress(false);
            }
        }

        else
        {
            ConditionsMet(false);
            ConditionsInProgress(false);
        }

        if (flag("zone_capture_in_progress"))
        {
            ConditionsInProgress(true);
        }

        wait 0.05;
    }
}

GeneratorWatcher()
// Function watches for current state of gens and changing booleans accordingly
{
    while (self.current_round == level.round_number)
    {
        if (level.zone_capture.zones["generator_start_bunker"]ent_flag("player_controlled"))
        {
            level.active_gen_1 = true;
        }
        else
        {
            level.active_gen_1 = false;
        }

        if (level.zone_capture.zones["generator_tank_trench"]ent_flag("player_controlled"))
        {
            level.active_gen_2 = true;
        }
        else
        {
            level.active_gen_2 = false;
        }

        if (level.zone_capture.zones["generator_mid_trench"]ent_flag("player_controlled"))
        {
            level.active_gen_3 = true;
        }
        else
        {
            level.active_gen_3 = false;
        }

        if (level.zone_capture.zones["generator_nml_right"]ent_flag("player_controlled"))
        {
            level.active_gen_4 = true;
        }
        else
        {
            level.active_gen_4 = false;
        }

        if (level.zone_capture.zones["generator_nml_left"]ent_flag("player_controlled"))
        {
            level.active_gen_5 = true;
        }
        else
        {
            level.active_gen_5 = false;
        }

        if (level.zone_capture.zones["generator_church"]ent_flag("player_controlled"))
        {
            level.active_gen_6 = true;
        }
        else
        {
            level.active_gen_6 = false;
        }

        wait 0.05;
    }
}

WatchPlayerStat(challenge, stat_1, multi_solo, multi_coop, stat_sum, sum_range_down, sum_range_up)
// Function watches for a single provided stat (guns from box)
{
    level endon("end_game");
    level endon("start_of_round");

    self thread GauntletHud(challenge);
    rnd = level.round_number;
    beginning_stat_sum = 0;

    // Grab stats to player variables on round start and sum stats
    foreach (player in level.players)
    {
        player.temp_beginning_stat = player.pers[stat_1];
        player.did_hit_box = 0;
        beginning_stat_sum += player.temp_beginning_stat;
        // player iPrintLn("^1beginning stat: " + player.temp_beginning_stat); // debug
    }

    // Watch stats midround
    proper_boxers = 0;
    piles_in_progress = false;
    temp_melees = 0;
    while (level.round_number == rnd)
    {
        proper_boxers = 0;
        temp_melees = 0;

        // Pull stat from each player to player var during the round
        foreach (player in level.players)
        {
            player.temp_current_stat = player.pers[stat_1];
            // player iPrintLn("stat: " + player.temp_current_stat); // Debug
        }

        // Define if condition is met
        i = 0;
        foreach (player in level.players)
        {
            // Assign passed arguments to variables, important!
            l_stat_sum = stat_sum;
            l_sum_range_down = sum_range_down;
            l_sum_range_up = sum_range_up;

            temp_stat = player.temp_current_stat;
            beg_stat = player.temp_beginning_stat;
            if (temp_stat > beg_stat)
            {
                // Sum the stats if need be
                if (isdefined(l_stat_sum))
                {
                    l_stat_sum += temp_stat;
                }
                // Else analyze difference for each player separately
                else
                {
                    // Don't switch the variable for no reason
                    if (player.did_hit_box != 1)
                    {
                        player.did_hit_box = 2;
                    }

                    // If met requirements for solo
                    if (temp_stat > (beg_stat + multi_solo) && level.players.size == 1)
                    {
                        player.did_hit_box = 1;
                    }

                    // If met requirements for coop
                    else if (temp_stat > (beg_stat + multi_coop) && level.players.size > 1)
                    {
                        player.did_hit_box = 1;
                    }
                }
            }

            // Handle summarized stats
            if (isDefined(l_stat_sum) && l_stat_sum > 0)
            {
                // print("l_stat_sum: " + l_stat_sum);
                // print("l_sum_range_up: " + l_sum_range_up);
                // print("l_sum_range_down: " + l_sum_range_down);
                // Add coop multiplication to upper range for coop
                if (level.players.size > 1)
                {
                    l_sum_range_up += multi_coop;
                }

                // If requirements in progress
                if (l_stat_sum > l_sum_range_down && l_stat_sum < l_sum_range_up)
                {
                    player.did_hit_box = 2;
                }
            
                // If requirements met
                else if (l_stat_sum >= l_sum_range_up)
                {
                    player.did_hit_box = 1;
                }
            }

            // Count players who met requirements
            if (player.did_hit_box == 1)
            {
                proper_boxers++;
            }

            // Notify that one of the players is in progress
            else if (player.did_hit_box == 2 && !piles_in_progress)
            {
                piles_in_progress = true;
            }
        }

        // Define flow of meeting requirements
        if (proper_boxers == 0 && !piles_in_progress)
        {
            ConditionsMet(false);
            ConditionsInProgress(false);            
        }
        else if (proper_boxers == level.players.size)
        {
            ConditionsMet(true);
        }
        else
        {
            ConditionsInProgress(true); 
            }

        wait 0.05;
    }
    wait 0.1;
    if (challenge == 28)
    {
        ConditionsMet(true);
    }
}

EnvironmentKills()
// Function sets "env_kill" flag if one more more environment kills happen in the round (tank, robot etc)
{
    prev_zombie_counter = maps/mp/zombies/_zm_utility::get_round_enemy_array().size + level.zombie_total;
    current_round = level.round_number;
    global_kills = 0;
    foreach (player in level.players)
    {
        global_kills += player.pers["kills"];
    }
    old_global_kills = global_kills;
    kill_difference = 0;
    stat_difference = 0;

    while (level.round_number == current_round)
    {
        global_kills = 0;
        foreach (player in level.players)
        {
            global_kills += player.pers["kills"];
        }
        new_zombie_counter = maps/mp/zombies/_zm_utility::get_round_enemy_array().size + level.zombie_total;

        if (new_zombie_counter < prev_zombie_counter)
        {
            kill_difference = prev_zombie_counter - new_zombie_counter;
            stat_difference = global_kills - old_global_kills;
        }

        if (stat_difference != kill_difference)
        {
            // global_kills += kill_difference; // Maxis drone is crashing the game
            iPrintLn("env_kill");
            level notify ("env_kill");
            flag_set("env_kill");
            kill_difference = stat_difference;
        }

        old_global_kills = global_kills;
        prev_zombie_counter = new_zombie_counter;

        wait 0.05;
    }
}

DisableMovement(challenge)
// Function disable walking and jumping ability until the end of the round 
{
    level endon("end_game");
    level endon("start_of_round");

    ConditionsInProgress(true);

    self thread GauntletHud(challenge);
    self thread WatchDownedPlayers();

    current_round = level.round_number;
  
    while (!level.allplayersup && (current_round == level.round_number))
    {
        foreach (player in level.players)
        {
            if (challenge == 3)
            {
                player setmovespeedscale(0);
                player allowjump(0);
            }
            else if (challenge == 10)
            {
                player allowstand(0);
                player allowprone(0);
                player allowsprint(0);
            }
            else if (challenge == 14)
            {
                player allowjump(0);
            }
        }
        wait 0.05;
    }
    
    if (current_round == level.round_number)
    {
        level waittill ("end_of_round");
    }
    
    ConditionsMet(true);
    foreach (player in level.players)
    {
        player setmovespeedscale(1);
        player allowjump(1);
        if (!player player_is_in_laststand())
        {  
            player allowstand(1);
            player allowprone(1);
            player allowsprint(1);
        }
    }
}

WatchDownedPlayers()
{
    level.allplayersup = false;
    while (!level.allplayersup)
    {
        i = 1;
        foreach (player in level.players)
        {
            if (!player player_is_in_laststand())
            {
                i++;
            }
        }

        if (i == level.players.size)
        {
            level.allplayersup = true;
        }
        i = 1;
        wait 0.05;
    }
}

WatchPerks(challenge, number_of_perks)
// Function checks for the amount of perks per player at the end of the round.
{
    level endon("end_game");
    level endon("start_of_round");

    if (!isdefined(number_of_perks))
    {
        number_of_perks = 1;
    }
    // Pluto compatibility
    else if (number_of_perks > 4 && level.players.size > 4)
    {
        number_of_perks = 4;
    }
    
    self thread GauntletHud(challenge, number_of_perks);
    level.proper_players = 0;

    if (challenge == 8)
    {
        self thread PerkTracker();
        self thread WatchPerkMidRound("jug");
    }
    else
    {
        self thread PerkTracker();
        self thread WatchPerkMidRound("all");
    }
    
    level waittill ("end_of_round");
    if (challenge != 8 && level.proper_players == level.players.size)
    {
        ConditionsMet(true);
    }
    else if (challenge == 8 && level.players_jug >= level.players.size)
    {
        ConditionsMet(true);
    }
}

PerkTracker()
// Function checks which and how many perks players have
{
    current_round = level.round_number;
    foreach (player in level.players)
    {
        player.owned_perks = 0;
    }

    while (current_round == level.round_number)
    {
        hasjug = 0;
        hasquick = 0;
        hasdoubletap = 0;
        hasspeed = 0;
        hasphd = 0;
        hasdeadshot = 0;
        hasstam = 0;
        hascherry = 0;
        hasmule = 0;
        foreach (player in level.players)
        {
            player.temp_owned_perks = 0;

            if (player hasperk("specialty_armorvest"))
            {
                hasjug++;
                player.temp_owned_perks++;
            }

            if (player hasperk("specialty_quickrevive"))
            {
                hasquick++;
                player.temp_owned_perks++;
            }

            if (player hasperk("specialty_rof"))
            {
                hasdoubletap++;
                player.temp_owned_perks++;
            }
            
            if (player hasperk("specialty_fastreload"))
            {
                hasspeed++;
                player.temp_owned_perks++;
            }
            
            if (player hasperk("specialty_flakjacket"))
            {
                hasphd++;
                player.temp_owned_perks++;
            }  
           
            if (player hasperk("specialty_deadshot"))
            {
                hasdeadshot++;
                player.temp_owned_perks++;
            }
            
            if (player hasperk("specialty_longersprint"))
            {
                hasstam++;
                player.temp_owned_perks++;
            }   

            if (player hasperk("specialty_grenadepulldeath"))
            {
                hascherry++;
                player.temp_owned_perks++;
            }


            if (player hasperk("specialty_additionalprimaryweapon"))
            {
                hasmule++;
                player.temp_owned_perks++;
            }

            // Sum the amount of perks player has on him rn
            if (player.owned_perks != player.temp_owned_perks)
            {
                player.owned_perks = player.temp_owned_perks;
            }                                            
        } 
        level.players_jug = hasjug;
        level.players_quick = hasquick;
        level.players_doubletap = hasdoubletap;
        level.players_speed = hasspeed;
        level.players_phd = hasphd;
        level.players_deadshot = hasdeadshot;
        level.players_stam = hasstam;
        level.players_cherry = hascherry;
        level.players_mulekick = hasmule;  
        wait 0.05;
    }
}

WatchPerkMidRound(perk)
// Function checks if players have more than 0 of specified perk and changes condition to in progress
{
    current_round = level.round_number;
    players_inprogress = 0;
    while (current_round == level.round_number)
    {
        // If function should look for all perks
        if (perk == "all")
        {
            temp_players_inprogress = 0;
            
            foreach(player in level.players)
            {
                if (player.owned_perks > 0)
                {
                    temp_players_inprogress++;
                }
            }

            // Update only if perk state changes
            if (players_inprogress != temp_players_inprogress)
            {
                players_inprogress = temp_players_inprogress;
                level.proper_players = players_inprogress;

                if (players_inprogress >= 1)
                {
                    ConditionsInProgress(true);
                }
                else
                {
                    ConditionsInProgress(false);
                }
            }
        }

        else if (perk == "jug")
        {
            ConditionsInProgress(false);
            if (level.players_jug > 0)
            {
                ConditionsInProgress(true);
            }
        }

        else if (perk == "quick")
        {
            if (level.players_quick > 0)
            {
                ConditionsInProgress(true);
            }
        }

        else if (perk == "doubletap")
        {
            if (level.players_doubletap > 0)
            {
                ConditionsInProgress(true);
            }
        }

        else if (perk == "speed")
        {
            if (level.players_speed > 0)
            {
                ConditionsInProgress(true);
            }
        }

        else if (perk == "phd")
        {
            if (level.players_phd > 0)
            {
                ConditionsInProgress(true);
            }
        }

        else if (perk == "deadshot")
        {
            if (level.players_deadshot > 0)
            {
                ConditionsInProgress(true);
            }
        }

        else if (perk == "stam")
        {
            if (level.players_stam > 0)
            {
                ConditionsInProgress(true);
            }
        }

        else if (perk == "cherry")
        {
            if (level.players_cherry > 0)
            {
                ConditionsInProgress(true);
            }
        }

        else if (perk == "mulekick")
        {
            if (level.players_mulekick > 0)
            {
                ConditionsInProgress(true);
            }
        }

        wait 0.05;
    }
}

CheckUsedWeapon(challenge)
// Function verifies if kills are only done with specified weapon(s)
{
    level endon("end_game");
    level endon("start_of_round");

    self thread GauntletHud(challenge);

    if (challenge != 26)
    {
        ConditionsInProgress(true);
    }
    current_round = level.round_number;
    
    gun_mods_array = array("MOD_RIFLE_BULLET", "MOD_PISTOL_BULLET", "MOD_PROJECTILE_SPLASH", "MOD_PROJECTILE", "MOD_MELEE");
    robot_array = array("actor_zm_tomb_giant_robot_0", "actor_zm_tomb_giant_robot_1", "actor_zm_tomb_giant_robot_2");
    lethal_array = array("claymore_zm", "frag_grenade_zm", "sticky_grenade_zm", "cymbal_monkey_zm", "beacon_zm");
    tank_array = array("zombie_markiv_cannon", "zombie_markiv_side_cannon", "zombie_markiv_turret");
    melee_array = array("knife_zm", "one_inch_punch_air_zm", "one_inch_punch_fire_zm", "one_inch_punch_ice_zm", "one_inch_punch_lightning_zm", "one_inch_punch_upgraded_zm", "one_inch_punch_zm", "staff_air_melee_zm", "staff_fire_melee_zm", "staff_lightning_melee_zm", "staff_water_melee_zm");

    mp40_array = array("mp40_zm", "mp40_stalker_zm", "mp40_upgraded_zm", "mp40_stalker_upgraded_zm");
    first_room_array = array("c96_zm", "c96_upgraded_zm", "ballista_zm", "ballista_upgraded_zm", "m14_zm", "m14_upgraded_zm", "galil_zm", "galil_upgraded_zm", "mp44_zm", "mp44_upgraded_zm", "scar_zm", "scar_upgraded_zm");
    // m14_array = array("m14_zm", "m14_upgraded_zm");
    // mp44_unpap_array = array("mp44_zm");

    while (current_round == level.round_number)
    {
        level waittill_any ("zombie_killed", "end_of_round", "nuke_taken");

        proper_gun_used = false;
        
        killed_lethals = false;         // Nades, semtex, clays, monkeys, beacons
        killed_insta = false;           // Insta
        killed_robots = false;          // Robots
        killed_tank = false;            // Tank
        killed_worldspawn = false;      // Bleeds, gens & nukes
        killed_drone = false;           // Maxis drone
        killed_stick = false;           // Staff revive stick
        killed_shield = false;          // Shield
        killed_melee = false;           // Melee weapons
        killed_nuke = false;            // Nukes

        // DEFINE MURDER WEAPON

        // Tank rollover
        if (isinarray(tank_array, level.weapon_used) && level.weapon_mod == "MOD_CRUSH")
        {
            killed_tank = true;
        }
        // Maxis drone
        else if (level.weapon_used == "quadrotorturret_zm" || level.weapon_used == "quadrotorturret_upgraded_zm")
        {
            killed_drone = true;
        }
        // Staff stick
        else if (level.weapon_used == "staff_revive_zm")
        {
            killed_stick = true;
        }
        // Shield
        else if (level.weapon_used == "tomb_shield_zm")
        {
            killed_shield = true;
        }
        // Melee
        else if (level.weapon_mod == "MOD_MELEE" && isinarray(melee_array, level.weapon_used))
        {
            killed_melee = true;
        }
        // Nukes
        else if (flag("nuke_taken"))
        {
            flag_clear("nuke_taken");
            killed_nuke = true;
        }
        // None weapon exceptions
        else if (level.weapon_used == "none")
        {
            // Nades, semtex, clays, monkeys, beacons (headless)
            if (level.weapon_mod == "MOD_GRENADE_SPLASH")
            {
                killed_lethals = true;
            }
            // Robots
            else if (isinarray(robot_array, level.killer_class))
            {
                killed_robots = true;
            }
            // Tank flamethrower
            else if (level.killer_class == "script_vehicle" && level.weapon_mod == "MOD_BURNED")
            {
                killed_tank = true;
            }
            // Bleeds, gens & nukes
            else if (level.killer_class == "worldspawn" && level.weapon_mod == "MOD_UNKNOWN")
            {
                killed_worldspawn = true;
            }
            // Melee
            else if (level.weapon_mod == "MOD_MELEE")
            {
                killed_melee = true;
            }

            // Instakill (if not killshot)
            if (isinarray(gun_mods_array, level.weapon_mod))
            {
                killed_insta = true;
            }
        }

        // COMPARE MEANS OF DEATH AGAINST CHALLENGES
        if (challenge == 2 || challenge == 9 || challenge == 19 || challenge == 23)
        {
            // CASE = MELEE
            if (challenge == 2)
            {
                if ((killed_insta && killed_melee) || killed_melee)
                {
                    proper_gun_used = true;
                }
            }
            if (challenge == 26)
            {
                if (killed_tank)
                {
                    level.killed_with_tank++;
                }
            }
            // CASE = WEAPONS
            else
            {
                // Define weapon list for a challenge
                if (challenge == 9 || challenge == 19)
                {
                    allowed_weapons = array_copy(mp40_array);
                }
                else if (challenge == 23)
                {
                    allowed_weapons = array_copy(first_room_array);
                }

                // Define if proper gun was used
                if (isinarray(allowed_weapons, level.weapon_used))
                {
                    proper_gun_used = true;
                }
                // Watch for instakill
                else if (!killed_lethals && !killed_robots && !killed_tank && !killed_drone && !killed_stick && !killed_shield && !killed_melee && !killed_nuke && killed_insta)
                {
                    pass_insta = true;
                    foreach (player in level.players)
                    {
                        if (player.clientid == level.killer_name)
                        {
                            held_weapon = player getCurrentWeapon();
                            if (!isinarray(allowed_weapons, held_weapon))
                            {
                                pass_insta = false;
                            }
                        }
                    }

                    if (!isdefined(held_weapon))
                    {
                        held_weapon = "undefined";
                    }

                    if (pass_insta)
                    {
                        proper_gun_used = true;
                    }
                }
                // Watch for nukes
                else if (killed_nuke)
                {
                    proper_gun_used = true;
                }
                // Watch for env kills
                else if (killed_robots || killed_tank)
                {
                    proper_gun_used = true;
                }
                // Watch for despawns
                else if (killed_worldspawn && !killed_insta)
                {
                    proper_gun_used = true;
                }
            }
        }

        // DEBUG PRINTS
        if (isdefined(level.debug_weapons) && level.debug_weapons)
        {
            print("proper_gun_used: " + proper_gun_used);
            print("killed_lethals: " + killed_lethals);
            print("killed_insta: " + killed_insta);
            print("killed_robots: " + killed_robots);
            print("killed_tank: " + killed_tank);
            print("killed_worldspawn: " + killed_worldspawn);
            print("killed_drone: " + killed_drone);
            print("killed_stick: " + killed_stick);
            print("killed_shield: " + killed_shield);
            print("killed_melee: " + killed_melee);
            print("killed_nuke: " + killed_nuke);

            if (killed_insta)
            {
                iPrintLn("Kill: Instakill (" + held_weapon + ")");
            } 
            
            if (killed_nuke)
            {
                iPrintLn("Kill: Nuke");
            }
            else if (killed_lethals)
            {
                iPrintLn("Kill: Lethal equipment");
            }
            else if (killed_robots)
            {
                iPrintLn("Kill: Robot");
            }
            else if (killed_tank)
            {
                iPrintLn("Kill: Tank");
            }
            else if (killed_worldspawn)
            {
                iPrintLn("Kill: Worldspawn");
            }
            else if (killed_drone)
            {
                iPrintLn("Kill: Drone");
            }
            else if (killed_stick)
            {
                iPrintLn("Kill: Revive stick");
            }
            else if (killed_shield)
            {
                iPrintLn("Kill: Shield");
            }
            else if (proper_gun_used && !killed_insta)
            {
                iPrintLn("^2Kill: " + level.weapon_used);
            }
            else if (!isdefined(level.weapon_used) || !isdefined(level.killer_class) || !isdefined(level.weapon_mod))
            {
                iPrintLn("^3Arguments undefined");
                print("Killer: " + level.killer_class);
                print("Kill mod: " + level.weapon_mod);
                print("Kill weapon: " + level.weapon_used);
            }
            else
            {
                iPrintLn("^1Kill: " + level.weapon_used);
                print("Killer: " + level.killer_class);
                print("Kill mod: " + level.weapon_mod);
                print("Kill weapon: " + level.weapon_used);
            }
        }

        // END GAME IF CONDITION NOT MET
        if ((!proper_gun_used && current_round == level.round_number) && (challenge != 26))
        {
            level.forbidden_weapon_used = true;
        }

        wait 0.05;
    }
    wait 0.1;
    if (challenge != 26)
    {
        ConditionsMet(true);
    }
}

DropWatcher()
// Count drops to level variables and send notify each time drop is taken
{
    level.current_drops_nuke = 0;
    level.current_drops_insta = 0;
    level.current_drops_max = 0;
    level.current_drops_double = 0;
    level.current_drops_blood = 0; 
    level.current_drops_point = 0;
    level.current_drops_sale = 0;
    
    x = 0;
    while (1)
    {
        nukes_temp = 0;
        instas_temp = 0;
        maxes_temp = 0;
        double_temp = 0;
        blood_temp = 0;
        points_temp = 0;
        sales_temp = 0;

        foreach(player in level.players)
        {
            nukes_temp += player.pers["nuke_pickedup"];
            instas_temp += player.pers["insta_kill_pickedup"];
            maxes_temp += player.pers["full_ammo_pickedup"];
            double_temp += player.pers["double_points_pickedup"];
            blood_temp += player.pers["zombie_blood_pickedup"];
            sales_temp += player.pers["fire_sale_pickedup"];
            // Bonus points doesn't work
            // points_temp += (player.pers["bonus_points_team_pickedup"] + player.pers["bonus_points_player_pickedup"]);
        }

        if (nukes_temp > level.current_drops_nuke)
        {
            level.current_drops_nuke = nukes_temp;
            level notify("nuke_taken");
            flag_set("nuke_taken");
            if (isdefined(level.debug_weapons) && level.debug_weapons)
            {
                iPrintLn("Nuke taken");
            }
            
        }
        else if (instas_temp > level.current_drops_insta)
        {
            level.current_drops_insta = instas_temp;
            level notify("insta_taken");
            flag_set("insta_taken");
            if (isdefined(level.debug_weapons) && level.debug_weapons)
            {
                iPrintLn("Insta taken");
            }        
        }
        else if (maxes_temp > level.current_drops_max)
        {
            level.current_drops_max = maxes_temp;
            level notify ("max_taken");
            flag_set("max_taken");
            if (isdefined(level.debug_weapons) && level.debug_weapons)
            {
                iPrintLn("Max taken");
            }        
        }
        else if (double_temp > level.current_drops_double)
        {
            level.current_drops_double = double_temp;
            level notify ("double_taken");
            flag_set("double_taken");
            if (isdefined(level.debug_weapons) && level.debug_weapons)
            {
                iPrintLn("X2 taken");
            }        
        }
        else if (blood_temp > level.current_drops_blood)
        {
            level.current_drops_blood = blood_temp;
            level notify ("blood_taken");
            flag_set("blood_taken");
            if (isdefined(level.debug_weapons) && level.debug_weapons)
            {
                iPrintLn("Blood taken");
            }        
        }
        else if (sales_temp > level.current_drops_sale)
        {
            level.current_drops_sale = sales_temp;
            level notify ("sale_taken");
            flag_set("sale_taken");
            if (isdefined(level.debug_weapons) && level.debug_weapons)
            {
                iPrintLn("Firesale taken");
            }       
        }
        else if (points_temp > level.current_drops_point)
        {
            // level.current_drops_point = points_temp;
            // level notify ("points_taken");
            // flag_set("points_taken");
            // if (isdefined(level.debug_weapons) && level.debug_weapons)
            // {
            //     iPrintLn("Points taken");
            // }       
        }

        // Clear flags on readpoint
        wait 0.05;
    }
}

actor_killed_override( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime )
// Override used to pass weapon used to kill zombies to level variable alongside level notify
{
    level.weapon_used = sweapon;
    level.weapon_mod = smeansofdeath;
    level.killer_class = attacker.classname;
    level.killer_name = attacker.clientid;
    level notify ("zombie_killed");
    // print("einflictor: " + einflictor);
    // print("attacker: " + attacker.classname);    
    // print("idamage: " + idamage);
    // print("smeansofdeath: " + smeansofdeath);
    // print("sweapon: " + sweapon);
    // print("vdir: " + vdir);
    // print("shitloc: " + shitloc);
    // print("psoffsettime: " + psoffsettime);

    if ( game["state"] == "postgame" )
        return;

    if ( isai( attacker ) && isdefined( attacker.script_owner ) )
    {
        if ( attacker.script_owner.team != self.aiteam )
            attacker = attacker.script_owner;
    }

    if ( attacker.classname == "script_vehicle" && isdefined( attacker.owner ) )
        attacker = attacker.owner;

    if ( isdefined( attacker ) && isplayer( attacker ) )
    {
        multiplier = 1;

        if ( is_headshot( sweapon, shitloc, smeansofdeath ) )
            multiplier = 1.5;

        type = undefined;

        if ( isdefined( self.animname ) )
        {
            switch ( self.animname )
            {
                case "quad_zombie":
                    type = "quadkill";
                    break;
                case "ape_zombie":
                    type = "apekill";
                    break;
                case "zombie":
                    type = "zombiekill";
                    break;
                case "zombie_dog":
                    type = "dogkill";
                    break;
            }
        }
    }

    if ( isdefined( self.is_ziplining ) && self.is_ziplining )
        self.deathanim = undefined;

    if ( isdefined( self.actor_killed_override ) )
        self [[ self.actor_killed_override ]]( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime );
}

WatchUpgradedStaffs(challenge, number_of_staffs)
// Function tracks progress with staff upgrade
{
    level endon("end_game");
    level endon("start_of_round");

    self thread GauntletHud(challenge);

    current_round = level.round_number;
    upgraded_staffs = 0;
    upgraded_wind = false;
    upgraded_fire = false;
    upgraded_lighting = false;
    upgraded_ice = false;
    if (!isdefined(number_of_staffs))
    {
        number_of_staffs = 4;
    }

    while ((current_round == level.round_number) && (upgraded_staffs < number_of_staffs))
    {
        foreach (staff in level.a_elemental_staffs_upgraded)
        {
            if (staff.charger.is_charged == 1 && staff.weapname == "staff_air_upgraded_zm" && !upgraded_wind)
            {
                // print("wind_upgrade"); // For testing
                upgraded_wind = true;
                upgraded_staffs++;
            }

            else if (staff.charger.is_charged == 1 && staff.weapname == "staff_fire_upgraded_zm" && !upgraded_fire)
            {
                // print("fire_upgrade"); // For testing
                upgraded_fire = true;
                upgraded_staffs++;
            }

            else if (staff.charger.is_charged == 1 && staff.weapname == "staff_lightning_upgraded_zm" && !upgraded_lighting)
            {
                // print("lighting_upgrade"); // For testing
                upgraded_lighting = true;
                upgraded_staffs++;
            }

            else if (staff.charger.is_charged == 1 && staff.weapname == "staff_water_upgraded_zm" && !upgraded_ice)
            {
                // print("ice_upgrade"); // For testing
                upgraded_ice = true;
                upgraded_staffs++;
            }

            if (staff.charger.charges_received > 0 && upgraded_staffs == 0)
            {
                ConditionsInProgress(true);
            }
        }

        if (upgraded_staffs > 0)
        {
            ConditionsInProgress(true);

            if (upgraded_staffs >= number_of_staffs)
            {
                ConditionsMet(true);
            }
        }
        wait 0.05;
    }
}

ZombieSuperSprint(challenge, amount_of_supersprinters)
// Function sets most of the zombies in the round as super-sprinters
{
    level endon("end_game");
    level endon("start_of_round");

    self thread GauntletHud(challenge);

    if (!isdefined(amount_of_supersprinters))
    {
        amount_of_supersprinters = 20;
    }

    current_round = level.round_number;
    ConditionsInProgress(true);

    super_sprinters = 0;
    sprinters = 0;
    force_runners = 0;
    dv = 0;                 // Only for dev prints
    while (current_round == level.round_number)
    {
        super_sprinters = 0;
        sprinters = 0;

        // Count super sprinters on the map
        foreach (zombie in get_round_enemy_array())
        {
            if (isdefined(zombie.is_super_sprinter))
            {
                if (zombie.is_super_sprinter)
                {
                    super_sprinters++;
                }
                else
                {
                    sprinters++;
                }
                
            }
        }
        
        foreach (zombie in get_round_enemy_array())
        {
            // Slow super sprinters down if there is too many
            if ((force_runners > 0) && isdefined(zombie.has_legs) && zombie.has_legs && isDefined(zombie.completed_emerging_into_playable_area) && zombie.completed_emerging_into_playable_area)
            {
                if (isdefined(level.debug_weapons) && level.debug_weapons)
                {
                    iPrintLn("slowing down a zombie");
                }
                
                if (isdefined(zombie.is_super_sprinter) && zombie.is_super_sprinter)
                {
                    super_sprinters--;
                }
                zombie.is_super_sprinter = false;
                zombie set_zombie_run_cycle("run");
                force_runners--;
            }

            // Handle new zombies
            if (isdefined(zombie.has_legs) && zombie.has_legs && isDefined(zombie.completed_emerging_into_playable_area) && zombie.completed_emerging_into_playable_area && !isdefined(zombie.is_super_sprinter))
            {
                if (super_sprinters >= amount_of_supersprinters || randomint(100) > 95)
                {
                    zombie.is_super_sprinter = false;
                    sprinters++;
                    zombie set_zombie_run_cycle("run");
                }
                else
                {
                    zombie.is_super_sprinter = true;
                    super_sprinters++;
                    zombie set_zombie_run_cycle("super_sprint");
                }
            }
        }
        // Queue zombies to slow down
        if (super_sprinters > amount_of_supersprinters)
        {
            force_runners = super_sprinters - amount_of_supersprinters;
            if (force_runners < 0)
            {
                force_runners = 0;
            }
        }

        // Dev prints
        if (isdefined(level.debug_weapons) && level.debug_weapons)
        {
            dv++;
            if (dv >= 60)
            {
                iPrintLn("super_sprinters: " + super_sprinters);
                iPrintLn("sprinters: " + sprinters);
                iPrintLn("force_runners: " + force_runners);
                dv = 0;
            }
        }
  
        wait 0.05;
    }
    wait 0.1;
    ConditionsMet(true);
}

SetupPanzerRound(round)
{
    while(1)
    {
        level waittill ("start_of_round");
        if (level.round_number == round - 1)
        {
            level waittill ("end_of_round");
            level.next_mechz_round = round;
        }
        wait 0.05;
    }
    // level waittill ("end_of_round");
}

TooManyPanzers(challenge)
// Function spawns panzers during the whole duration of the round
{
    level endon("end_game");
    level endon("start_of_round");

    self thread PanzerDeathWatcher();
    self thread ScanCrazyPlace();
    self thread GauntletHud(challenge);

    // level.next_mechz_round = challenge;  // Debugging

    //level.mechz_spawners = getentarray( "mechz_spawner", "script_noteworthy" );
    level.mech_zombies_alive = 0;
    current_round = level.round_number;
    level.wanted_mechz = 7;
    ConditionsInProgress(true);
    
    while (current_round == level.round_number)
    {
        if (level.mech_zombies_alive < level.wanted_mechz)
        {
            ai = spawn_zombie(level.mechz_spawners[0]);
            ai thread mechz_spawn();
            level.mech_zombies_alive++;
            wait randomintrange(4, 8);
        }
        wait 0.05;
    }
    wait 0.1;
    ConditionsMet(true);
}

PanzerDeathWatcher()
// Function watches for dying panzers and keeps the counter on proper number
{
    while (1)
    {
        level waittill ("mechz_killed");
        level.wanted_mechz = randomintrange(6, 11);
        level.mech_zombies_alive--;
        wait 0.05;
    }
}

SetDvarForRound(challenge, dvar, start_value, end_value)
// Function sets a dvar to one value and changes it to another at the end of round
{
    level endon("end_game");
    level endon("start_of_round");

    self thread GauntletHud(challenge);

    if (!isdefined(start_value))
    {
        start_value = 0;
    }
    if (!isdefined(end_value))
    {
        end_value = 1;
    }

    ConditionsInProgress(true);
    setdvar(dvar, start_value);
    level waittill ("end_of_round");
    setdvar(dvar, end_value);
    ConditionsMet(true);
}

CheckForZone(challenge, zonearray, time)
// dsc
{
    level endon("end_game");
    level endon("start_of_round");

    self thread GauntletHud(challenge);
    
    // Optional arguments handling
    if (!isdefined(time))
    {
        time = 45;
    }

    current_round = level.round_number;

    // Define player variables
    foreach (player in level.players)
    {
        player.threaded_already = false;
    }

    // Control if players get to the zone
    tick = time * 2;
    while (tick > 0)
    {
        in_zone = 0;
        modulo = tick % 10;
        foreach (player in level.players)
        {
            right_zone = false;
            current_zone = player get_current_zone();
            // Count up players in the right zone
            if (isinarray(zonearray, current_zone))
            {
                right_zone = true;
                in_zone++;
            }

            // Print a reminder every 5 seconds if not in zone
            if (modulo == 0 && !right_zone)
            {
                player iprintln("^1GET TO THE ZONE");
            }
        }

        // Start the challenge if all players are in zone early
        if (in_zone == level.players.size)
        {
            ConditionsInProgress(true);
            break;
        }

        // Print warnings at the end of the countdown
        if (tick == 20 && !level.conditions_in_progress)
        {
            iprintln("^310 SECONDS LEFT");
        }
        else if (tick == 10 && !level.conditions_in_progress)
        {
            iprintln("^15 SECONDS LEFT");
        }

        tick--;
        wait 0.5;
    }

    // End game if not all players in zone
    if (!level.conditions_in_progress)
    {
        level.forbidden_weapon_used = true;
    }
    else
    {
        iprintln("^2REMAIN IN THE ZONE");
    }
    
    // Watch if players remain in zone
    while (current_round == level.round_number && !level.forbidden_weapon_used)
    {
        in_zone = 0;
        foreach (player in level.players)
        {
            current_zone = player get_current_zone();
            // Count up players in the right zone
            if (isinarray(zonearray, current_zone))
            {
                in_zone++;
            }  
        }
        // Clear trigger if players back in zone
        if (in_zone == level.players.size)
        {
            ConditionsInProgress(true);
            flag_clear("out_of_zone");
            if (player.threaded_already)
            {
                player.threaded_already = false;
            }
        }
        // Trigger an event if player left zone
        else
        {
            ConditionsInProgress(false);
            flag_set("out_of_zone");
            if (!player.threaded_already)
            {
                player thread PlayerInZone();
                player.threaded_already = true;
            }
        }
        wait 0.05;
    }
    wait 0.1;
    // For hud formatting
    if (!level.forbidden_weapon_used)
    {
        ConditionsMet(true);
    }
}

PlayerInZone()
// dsc
{
    while (1)
    {
        self iprintln("^5GET TO THE ZONE");
        self iprintln("YOU got 5 SECONDS");
        wait 1;
        if (flag("out_of_zone"))
        {
            self iprintln("4");
        }
        else
        {
            break;
        }
        wait 0.5;
        if (!flag("out_of_zone"))
        {
            break;
        }
        wait 0.5;

        if (flag("out_of_zone"))
        {
            self iprintln("^33");
        }
        else
        {
            break;
        }
        wait 0.5;
        if (!flag("out_of_zone"))
        {
            break;
        }
        wait 0.5;

        if (flag("out_of_zone"))
        {
            self iprintln("^32");
        }
        else
        {
            break;
        }
        wait 0.5;
        if (!flag("out_of_zone"))
        {
            break;
        }
        wait 0.5;

        if (flag("out_of_zone"))
        {
            self iprintln("^21");
        }
        else
        {
            break;
        }
        wait 0.5;
        if (!flag("out_of_zone"))
        {
            break;
        }
        wait 0.5;

        if (flag("out_of_zone"))
        {
            self iprintln("^20");
            level.forbidden_weapon_used = true;
            break;
        }
        break;
    }
}

ScanCrazyPlace(time)
// Function serves as a safety for panzer rounds, player will be punished for staying in crazy place
{
    level endon("end_game");
    level endon("end_of_round");

    crazy_place_array = array("zone_chamber_0", "zone_chamber_1", "zone_chamber_2", "zone_chamber_3", "zone_chamber_4", "zone_chamber_5", "zone_chamber_6", "zone_chamber_7", "zone_chamber_8");
    if (!isdefined(time))
    {
        time = 30;
    }

    ticks = (time * (level.players.size * 0.75));
    while (1)
    {
        foreach (player in level.players)
        {
            if (!isdefined(player.imm))
            {
                player.imm = 0;
            }

            current_zone = player get_current_zone();
            if (isinarray(crazy_place_array, current_zone) && !player player_is_in_laststand())
            {
                if (ticks > 0 || player.imm > 0)
                {
                    if (isdefined(level.debug_weapons) && level.debug_weapons)
                    {
                        iPrintLn("Ticks: " + ticks);
                        player iPrintLn("Imm: " + player.imm);
                        print(player.name + " downed: " + player player_is_in_laststand());
                    }

                    ticks -= 1;     // -- doesn't work?
                    player.imm -= 1;
                    player iPrintLn("Leave immediately");
                    player dodamage(player.maxhealth / 30, player.origin);
                }
                else
                {
                    player dodamage(player.maxhealth, player.origin);
                    player iPrintLn("You've been warned");
                    player.imm = 10;
                }

                if (player.imm < 0)
                {
                    player.imm = 0;
                }
            }
        }
        if (ticks < 0)
        {
            ticks = 0;
        }
        wait 1;
    }
}

BuyNothing(challenge)
// Function sets up watching for spending points
{
    level endon("end_game");
    level endon("start_of_round");
    self endon("disconnect");

    ConditionsInProgress(true);
    self thread GauntletHud(challenge);

    init_score = 0;
    init_downs = 0;
    init_deaths = 0;

    foreach (player in level.players)
    {
        init_score += player.score;
        init_downs += player.downs;
        init_deaths += player.pers["deaths"];
    }

    self thread WatchPointsLoss(init_score, init_downs, init_deaths);

    level waittill ("end_of_round");
    wait 0.1;
    ConditionsMet(true);
}

WatchPointsLoss(init_score, init_downs, init_deaths)
// Function controls spending points, will end game if points are spent (will not end if points are lost to downs or bleeds)
{
    prev_score = init_score;
    prev_downs = init_downs;
    prev_deaths = init_deaths;
    current_score = 0;
    current_downs = 0;
    current_deaths = 0;
    current_round = level.round_number;

    while (current_round == level.round_number)
    {
        current_score = 0;
        current_downs = 0;
        current_deaths = 0;

        // Get current points and downs
        foreach (player in level.players)
        {
            current_score += player.score;
            current_downs += player.downs;
            current_deaths += player.pers["deaths"];
        }

        // Scan for downs and bleeds
        if ((current_downs > prev_downs) || current_deaths > prev_deaths)
        {
            prev_score = current_score;
        }

        // Scan for points
        if (current_score < prev_score)
        {
            level.forbidden_weapon_used = true;
            break;
        }

        prev_score = current_score;
        prev_downs = current_downs;
        prev_deaths = current_deaths;
        wait 0.05;
    }
}

ShutDownPerk(challenge, perk, fizz_off)
// Function turns selected or all perks off for the entire round and turns them on afterwards
{
    level endon("end_game");
    self endon("disconnect");
    
    self thread GauntletHud(challenge);
    ConditionsInProgress(true);
    
    fizz_array = getentarray("random_perk_machine", "targetname");
    current_round = level.round_number;

    if (!isdefined(fizz_off))
    {
        fizz_off = true;
    }

    if (fizz_off)
    {
        i = 0;
        foreach (fizz in fizz_array)
        {
            if (fizz.is_current_ball_location == 1)
            {
                fizz.is_current_ball_location = 0;
                fizz conditional_power_indicators();
                fizz hidepart("j_ball");
                reenable_fizz_id = i;
            }
            i++;
        }
    }

    while (current_round == level.round_number)
    {
        if (perk == "all")
        {
            perk_pause_all_perks();
            perk_pause("specialty_rof");
            perk_pause("specialty_flakjacket");
            perk_pause("specialty_grenadepulldeath");
        }
        else
        {
            perk_pause(perk);
        }
        wait 0.05;
    }

    wait 0.1;

    if (fizz_off)
    {
        i = 0;
        foreach (fizz in fizz_array)
        {
            if (i == reenable_fizz_id)
            {
                fizz.is_current_ball_location = 1;
                fizz conditional_power_indicators();
                fizz showpart("j_ball");
            }
            i++;
        }
    }
    perk_unpause_all_perks();
    perk_unpause("specialty_rof");
    perk_unpause("specialty_flakjacket");
    perk_unpause("specialty_grenadepulldeath");
    ConditionsMet(true);
}

SprintWatcher(challenge)
// Function deals damage to players if they don't move
{
    level endon("end_game");
    level endon("start_of_round");  // useful here :)
    self endon("disconnect");
    
    self thread GauntletHud(challenge);
    ConditionsInProgress(true);
    
    current_round = level.round_number;

    // Define player vars
    foreach (player in level.players)
    {
        player.isnt_moving = 0;
    }

    while (current_round == level.round_number)
    {
        foreach (player in level.players)
        {
            // Observe if players move or not
            if (player.player_is_moving == 0)
            {
                player.isnt_moving++;
            }
            else if (player.player_is_moving == 1)
            {
                player.isnt_moving = 0;
            }

            // Do damage if players don't move, kill if they don't move for too long
            if (player.isnt_moving > 20 && !player player_is_in_laststand())
            {
                player dodamage(player.maxhealth, player.origin);
                player.isnt_moving = 0;
            }
            else if (player.isnt_moving > 4 && !player player_is_in_laststand())
            {
                player iPrintLn("^1Move!!!");
                player dodamage(player.maxhealth / 25, player.origin);
            }
            // iPrintLn(player.health);    // For debugging

            // Reset the value if it's too small or too big
            if (player.isnt_moving < 0 || player.isnt_moving > 20)
            {
                player.isnt_moving = 0;
            }
            // print(player.isnt_moving);   // For debugging
        }
        wait 0.25;
    }
    wait 0.1;
    ConditionsMet(true);
}

GunGame(challenge)
// Function handling randomizing guns throught the round and later returnig actual weapons
{
    level endon("end_game");
    level endon("start_of_round"); 
    self endon("disconnect");
    
    self thread GauntletHud(challenge);
    ConditionsInProgress(true);
    
    current_round = level.round_number;
    chest_key = randomint(level.chests.size);

    foreach (player in level.players)
    {
        // Failsafe for robot
        if (player getCurrentWeapon() == "falling_hands_tomb_zm")
        {
            wait 4;
        }

        // Disable offhand weapons and pull weapons player has
        player disableoffhandweapons();
        weapon_array = player getweaponslistprimaries();

        // Keep info how many guns player had at the beginning
        player.stolen_weapons = weapon_array.size;
        player.last_gungame_weapon = "none";

        // Handle mulekick
        if (player.stolen_weapons == 3 && player hasperk("specialty_additionalprimaryweapon"))
        {
            player.stolen_mule_weapon = weapon_array[2];
            player.stolen_mule_ammo = player getAmmoCount(player.stolen_mule_weapon);
            player.stolen_mule_clip = player getWeaponAmmoClip(player.stolen_mule_weapon);
            player takeweapon(player.stolen_mule_weapon);
            wait 0.05;
        }

        // Handle 2nd gun
        if (player.stolen_weapons == 2)
        {
            player.stolen_weapon_2 = weapon_array[1];
            player.stolen_ammo_2 = player getAmmoCount(player.stolen_weapon_2);
            player.stolen_clip_2 = player getWeaponAmmoClip(player.stolen_weapon_2);
            player takeweapon(player.stolen_weapon_2);
            wait 0.05;
        }

        // Handle 1st gun
        player.stolen_weapon_1 = player getCurrentWeapon();
        player.stolen_ammo_1 = player getAmmoCount(player.stolen_weapon_1);
        player.stolen_clip_1 = player getWeaponAmmoClip(player.stolen_weapon_1);
        player takeweapon(player.stolen_weapon_1);
        wait 0.05;
    }

    // Disable boxes
    foreach (chest in level.chests)
    {
        chest hide_chest();
        //chest set_magic_box_zbarrier_state( "away" );
    }
    wait 0.1;

    // level.get_player_weapon_limit = 1;
    // level.additionalprimaryweapon_limit = 1;

    // Thread weapon randomizer and watchers
    self thread RandomizeGuns();
    self thread NukeExtraWeapon();
    self thread WallbuysWatcher();
    self thread FillStolenGuns();   // Works?

    level waittill ("end_of_round");

    wait 0.1;
    ConditionsMet(true);

    level.chests[chest_key] show_chest(); // Give box back in random spot
    // level.get_player_weapon_limit = 2;
    // level.additionalprimaryweapon_limit = 3;
    if (flag("just_set_weapon"))
    {
        wait 2;
    }

    foreach (player in level.players)
    {
        // Take away given weapon and enable offhand
        player takeweapon(player.last_gungame_weapon);
        player enableoffhandweapons();

        // Return 1st weapon
        if (isdefined(player.stolen_weapon_1))
        {
            player giveweapon(player.stolen_weapon_1);
            player switchtoweapon(player.stolen_weapon_1);
            player setweaponammostock(player.stolen_weapon_1, player.stolen_ammo_1);
            player setweaponammoclip(player.stolen_weapon_1, player.stolen_clip_1);
            skip_other = false;
        }
        // Otherwise give mauser
        else
        {
            player giveweapon("c96_zm");
            skip_other = true;
        }
        wait 0.05;

        // Return 2nd wepaon
        if (!skip_other && player.stolen_weapons >= 2)
        {
            player giveweapon(player.stolen_weapon_2);
            player setweaponammostock(player.stolen_weapon_2, player.stolen_ammo_2);
            player setweaponammoclip(player.stolen_weapon_2, player.stolen_clip_2);

            // Return 3rd weapon if player has mulekick
            if (player.stolen_weapons == 3 && isdefined(player.stolen_mule_weapon) && player hasperk("specialty_additionalprimaryweapon"))
            {
                player giveweapon(player.stolen_mule_weapon);
                player setweaponammostock(player.stolen_mule_weapon, player.stolen_mule_ammo);
                player setweaponammoclip(player.stolen_mule_weapon, player.stolen_mule_clip);
            }
        }
    }
}

RandomizeGuns()
// Thread for randomizing guns throught the round and giving them
{
    level endon ("end_of_round");

    // Establish data
    forbidden_weapons_array = array("staff_air_zm", "staff_fire_zm", "staff_lightning_zm", "staff_water_zm", "staff_revive_zm", "staff_air_upgraded_zm", "staff_fire_upgraded_zm", "staff_lightning_upgraded_zm", "staff_water_upgraded_zm", "staff_water_zm_cheap");
    shit_weapon_array = array("c96_zm", "ballista_zm", "beretta93r_extclip_zm", "m14_zm", "870mcs_zm");
    players = get_players();
    weapons = getarraykeys(level.zombie_weapons);
    max_key = level.zombie_weapons.size;
    while (1)
    {
        // Iterate using while loop as nested fors ain't allowed
        i = 0;
        while (i <= (players.size - 1))
        {
            w = randomInt(max_key); // Radomize weapon key

            // Compare against list of disalloed weapons
            if (isinarray(forbidden_weapons_array, weapons[w]))
            {
                // iPrintLn(weapons[w] + " is not allowed");
                w = randomInt(max_key);
                wait 0.05;
                continue;
            }

            // Compare against having weapon (weapons with attachments get bypassed for now)
            if (players[i] has_weapon_or_upgrade(weapons[w]))
            {
                // iPrintLn("already have " + weapons[w]);
                w = randomInt(max_key);
                wait 0.05;
                continue;
            }

            // Verify if incoming weapon is equipment
            if (is_lethal_grenade(weapons[w]) || is_tactical_grenade(weapons[w]) || is_placeable_mine(weapons[w]) || is_melee_weapon(weapons[w]))
            {
                // iPrintLn(weapons[w] + " is equipment");
                w = randomInt(max_key);
                wait 0.05;
                continue;
            }

            // Failsafe if weapon key is too high
            if (w > max_key)
            {
                // iPrintLn("key " + w + " is too big");
                w /= 2;
                wait 0.05;
                continue;
            }

            // Give chance of normal weapons become with attachments
            if (randomInt(100) > 10)
            {
                if (weapons[w] == "ak74u_zm")
                {
                    weapon[w] = "ak74u_extclip_zm";
                }
                else if (weapons[w] == "beretta93r_zm")
                {
                    weapon[w] = "beretta93r_extclip_zm";
                }
                else if (weapons[w] == "mp40_zm")
                {
                    weapon[w] = "mp40_stalker_zm";
                }
            }
            
            weapon = weapons[w];    // Put weapon to the variable

            // Define if weapon will be upgraded
            lucky_roll = false;
            if ((randomInt(100) > 20 && isinarray(shit_weapon_array, weapon)) || randomInt(100) > 66)
            {
                // iPrintLn(weapon + " upgraded");
                lucky_roll = true;
                temp_wpn = weapons[w];
                weapon = level.zombie_weapons[temp_wpn].upgrade_name;
            }

            // Take away previous weapon before giving new one
            if (players[i].last_gungame_weapon != "none")
            {
                players[i] takeweapon(players[i].last_gungame_weapon);
            }
            // iPrintLn("weapon: " + weapon);  // For debugging
            
            // Give upgraded weapon
            if (lucky_roll)
            {
                players[i] giveweapon(weapon, 0, players[i] get_pack_a_punch_weapon_options(weapon));
            }
            // Give unupgraded weapon
            else
            {
                players[i] weapon_give(weapon);
            }
            players[i] play_sound_on_ent("purchase");
            players[i] givestartammo(weapon);
	        players[i] switchtoweapon(weapon);
            players[i].last_gungame_weapon = weapon;
            flag_set("just_set_weapon");
            // iPrintLn("has weapons after assigning: " + players[i] getweaponslistprimaries().size);

            i++;
            wait 0.05;
        }
        wait 3;
        flag_clear("just_set_weapon");
        wait randomIntRange(10, 15);
    }
}

WallbuysWatcher()
// Watch for wallbuys, remove the gun and give points back
{
    level endon ("end_of_round");
    while (1)
    {
        level waittill ("weapon_bought", player, gun);
        return_points = get_weapon_cost(gun);
        player add_to_player_score(return_points);
        player takeweapon(gun);
        wait 0.05;
    }
}

NukeExtraWeapon()
// Remove any extra weapons from player equipment (mainly piles)
{
    level endon ("end_of_round");
    while (1)
    {
        foreach (player in level.players)
        {
            if (player.last_gungame_weapon == "none")
            {
                break;
            }

            gun_list = player getweaponslistprimaries();
            gungame_gun = player.last_gungame_weapon;

            if (gun_list.size > 1 && isdefined(gun_list[1]) && gun_list [1] != gungame_gun)
            {
                player takeweapon(gun_list[1]);
            }

            else if (gun_list [0] != gungame_gun)
            {
                player takeweapon(gun_list[0]);
            }
        }
        wait 0.05;
    }
}

FillStolenGuns()
// Function will fill player guns during gungame, relies on replacefunc
{
    level endon ("end_of_round");

    level waittill ("got_a_max");
    foreach (player in level.players)
    {
        if (isdefined(player.stolen_ammo_1))
        {
            player.stolen_ammo_1 = weaponmaxammo(player.stolen_weapon_1);
        }
        if (isdefined(player.stolen_ammo_2))
        {
            player.stolen_ammo_2 = weaponmaxammo(player.stolen_weapon_2);
        }
        if (isdefined(player.stolen_mule_ammo))
        {
            player.stolen_mule_ammo = weaponmaxammo(player.stolen_mule_weapon);
        }
    }
}

CompareKillsWithZones(challenge, allowed_zones)
// Function takes the position of a player (or all players if it's environment kill) and compares it against a list of allowed zones
{
    level endon("end_game");
    level endon("start_of_round"); 
    self endon("disconnect");

    self thread GauntletHud(challenge);
    ConditionsInProgress(true);

    if (!isdefined(allowed_zones))
    {
        // Air tunnel workbench is considered outside :(
        allowed_zones = array("zone_start", "zone_start_a", "zone_start_b", "zone_fire_stairs", "zone_bunker_5a", "zone_bunker_5b", "zone_bunker_4c", "zone_nml_celllar", "zone_bolt_stairs", "zone_nml_19", "ug_bottom_zone", "zone_air_stairs", "zone_village_1", "zone_village_2", "zone_ice_stairs", "zone_chamber_0", "zone_chamber_1", "zone_chamber_2", "zone_chamber_3", "zone_chamber_4", "zone_chamber_5", "zone_chamber_6", "zone_chamber_7", "zone_chamber_8", "zone_robot_head");
    }

    players = level.players;
    current_round = level.round_number;

    self thread BreakLoopOnRoundEnd();
    self thread EnvironmentKills();

    while (current_round == level.round_number)
    {
        level waittill_any ("zombie_killed", "end_of_round", "env_kill");
        if (isdefined(level.breakearly) && level.breakearly)
        {
            break;
        }

        i = 0;
        foreach(player in level.players)
        {
            current_zone = player get_current_zone();
            // Scan all players if it's env kill
            if (flag("env_kill"))
            {
                if (!isinarray(allowed_zones, current_zone))
                {
                    level.forbidden_weapon_used = true;
                }
            }
            // Pull id of player who kills
            else if (player.name == level.killer_class)
            {
                matched_player = i;
                break;
            }
            i++;
        }

        current_zone = players[matched_player] get_current_zone();
        flag_clear("env_kill");

        if (!flag("env_kill"))
        {
            // Compare the position of killer against allowed zones
            if (!isinarray(allowed_zones, current_zone) && level.weapon_used != "none")
            {
                level.forbidden_weapon_used = true;
            }
        }
        wait 0.05;
    }
    wait 0.1;
    ConditionsMet(true);
}

BreakLoopOnRoundEnd()
// Change level variable on round end
{
    level.breakearly = false;
    level waittill ("end_of_round");
    level.breakearly = true;
}

TankEm(challenge)
// Function checks if enough zombies were killed by the tank
{
    level endon("end_game");
    level endon("start_of_round"); 
    self endon("disconnect");

    // Define amount of zombies to kill with tank
    tank_multiplier = 0;
    if (level.players.size > 1)
    {
        tank_multiplier = 24 * (level.players.size - 1);
    }
    zombies_to_tank = 48 + tank_multiplier;

    self thread GauntletHud(challenge, zombies_to_tank);
    self thread CheckUsedWeapon(challenge);
    current_round = level.round_number;
    level.killed_with_tank = 0;
    while (current_round == level.round_number)
    {
        if (level.killed_with_tank > 0 && level.killed_with_tank < zombies_to_tank && !level.conditions_in_progress)
        {
            ConditionsInProgress(true);
        }

        else if (level.killed_with_tank >= zombies_to_tank && !level.conditions_met)
        {
            ConditionsMet(true);
        }
        wait 0.05;
    }
}

AmmoController(challenge)
// Function that threads ammo controllers to each player
{
    level endon("end_game");
    level endon("start_of_round"); 
    self endon("disconnect");

    self thread GauntletHud(challenge);
    ConditionsInProgress(true);
    foreach (player in level.players)
    {
        player thread ValueAmmo();
    }

    level waittill ("end_of_round");
    wait 0.1;
    ConditionsMet(true);
}

ValueAmmo(challenge)
// Function causes player to lose twice as much ammo for shooting
{
    current_round = level.round_number;
    prev_weapon = "";
    burst_weapons = array("beretta93r_zm", "beretta93r_extclip_zm", "fnfal_upgraded_zm", "m16_zm", "raygun_mark2_zm", "raygun_mark2_upgraded_zm", "srm1216_zm", "srm1216_upgraded_zm", "staff_air_upgraded_zm", "staff_fire_upgraded_zm", "staff_lightning_upgraded_zm", "staff_water_upgraded_zm");

    while (current_round == level.round_number)
    {
        // Get currently used weapon, zero saved vars if weapon is changed
        weapon = self getCurrentWeapon();
        if (weapon != prev_weapon)
        {
            saved_clip = undefined;
            saved_stock = undefined;
        }

        // Grab current ammo count for both stock and clip
        current_stock = self getAmmoCount(weapon);
        current_clip = self getWeaponAmmoClip(weapon);
        if (!isdefined(saved_clip))
        {
            saved_clip = current_clip;
        }
        if (!isdefined(saved_stock))
        {
            saved_stock = current_stock;
        }

        // Calculate and take away ammo on shoot
        if (current_clip < saved_clip)
        {
            get_diff_clip = (saved_clip - current_clip);
            get_diff_stock = (saved_stock - current_stock);

            new_clip = (current_clip - get_diff_clip);
            new_stock = (current_stock - get_diff_stock);

            take_from_reserve = false;
            while (new_clip < 0)
            {
                take_from_reserve = true;
                new_clip++;
                new_stock--;
                wait 0.05;
            }

            self setweaponammoclip(weapon, new_clip);
            if (take_from_reserve)
            {
                self setweaponammostock(weapon, new_stock);
            }

            saved_clip = new_clip;
            saved_stock = new_stock;
        }
        // Else keep current ammo count
        else
        {
            saved_clip = self getWeaponAmmoClip(weapon);
            saved_stock = self getAmmoCount(weapon);
        }

        // Zero ammo for burst weapons on low ammo
        if (isinarray(burst_weapons, weapon))
        {
            ammo_total = current_clip + current_stock;
            burst = 3;
            if (weapon == "srm1216_upgraded_zm")
            {
                burst = 4;
            }
            else if (weapon == "staff_air_upgraded_zm" || weapon == "staff_fire_upgraded_zm" || weapon == "staff_lightning_upgraded_zm" || weapon == "staff_water_upgraded_zm")
            {
                burst = 6;
            }

            if ((ammo_total < (burst * 2)) && ammo_total != 0)
            {
                if (isdefined(level.debug_weapons) && level.debug_weapons)
                {    
                    self iPrintLn("reduce burst");
                }            
                self setweaponammoclip(weapon, 0);
                self setweaponammostock(weapon, 0);
                prev_weapon = weapon;
                saved_clip = undefined;
                saved_stock = undefined;
                wait 0.05;
                continue;
            }
        }

        prev_weapon = weapon;
        wait 0.05;
    }
}

full_ammo_powerup_override(drop_item, player)
// Override - notify level if max is obtained
{
    level notify ("got_a_max");
    players = get_players( player.team );

    if ( isdefined( level._get_game_module_players ) )
        players = [[ level._get_game_module_players ]]( player );

    for ( i = 0; i < players.size; i++ )
    {
        if ( !players[i] player_is_in_laststand() )
        {
            primary_weapons = players[i] getweaponslist( 1 );
            players[i] notify( "zmb_max_ammo" );
            players[i] notify( "zmb_lost_knife" );
            players[i] notify( "zmb_disable_claymore_prompt" );
            players[i] notify( "zmb_disable_spikemore_prompt" );

            for ( x = 0; x < primary_weapons.size; x++ )
            {
                pulled_weapon = primary_weapons[x];

                // Reversed if statement to avoid continues
                if ( (!level.headshots_only && !is_lethal_grenade( pulled_weapon )) || ( !isdefined( level.zombie_include_equipment ) && !isdefined( level.zombie_include_equipment[pulled_weapon] )) || ( !isdefined( level.zombie_weapons_no_max_ammo ) && !isdefined( level.zombie_weapons_no_max_ammo[pulled_weapon] )) )
                {
                    if ( players[i] hasweapon( pulled_weapon ) )
                    {
                        players[i] givemaxammo( pulled_weapon );
                    }
                }
            }
        }
    }

    level thread full_ammo_on_hud( drop_item, player.team );
}