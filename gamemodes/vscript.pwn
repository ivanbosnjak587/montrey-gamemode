/*
? --
?Informacije
? --
* Montrey Community
* Version 0.0.1
? --
? Zahvale  :
? --
* Southclaws : https://github.com/pawn-lang/compiler
* Y_Less : https://github.com/pawn-lang/YSI-Includes/tree/v5.1
* Maddinat0r : https://github.com/maddinat0r/sscanf/releases
* Awesomdude : https://github.com/Awsomedude/easyDialog
* samp-incognito : https://github.com/samp-incognito/samp-streamer-plugin/releases
? --
? Credits :
? --
* Vostic - Founder, Scripter, Mapper, TextDraw
* Neithan - Developer
? --
? Defined
? --
*	c_server + col_server = Server Color
*	c_yellow + col_yellow = Information Poruke
*	c_red + col_red = Error Massage / Very Important Message
*	c_blue + col_blue = Jobs Info
*	c_green + col_green = Bank Info 
*	c_orange + col_orange = Orgs Info
*	c_ltblue + col_ltblue = Staff Colors
*	c_pink + col_pink =	Anticheat Info
*	c_white + col_white = IC Chat
*	c_greey + col_gteey = OOC Chat

*   Server Tag = | M >>
? --
?Staff Level
? --
* Staff 1 - //! Helper
* Staff 2 - //! Silver Staff
* Staff 3 - //! Gold Staff
* Staff 4 - //! Diamond Staff
* Staff 5 - //! Head Staff //! Podrank (Vodja Helpera, Vodja Lidera)
* Staff 6 - //! Direktor //! Podrank (Mapper, Pomocni Skripter)
* Staff 7 - //! Vlasnik 
? ==
?==
* Imajte u vidu da kada komentariste ovaj mod da ovo nema veze s nasim modom jer je nas mod modularan
* Ovo radimo da pomognemo drugima i bice 2 razlicite verzije na nasem githubu
* Mozete pisati bugove koje nalazite a mi cemo resiti iste.
*/

//! Ne pipaj kolko se ne valja
#define YSI_YES_HEAP_MALLOC

const MAX_PLAYERS = 1000;

#define CGEN_MEMORY 20000

//?=============================== Includes =========================================//
#include <a_samp>
#include <ysilib\YSI_Storage\y_ini>
#include <ysilib\YSI_Coding\y_timers>
#include <ysilib\YSI_Visual\y_commands>
#include <ysilib\YSI_Coding\y_hooks>
#include <ysilib\YSI_Data\y_foreach>
#include <sscanf\sscanf2>
#include <easy-dialog>
#include <streamer>

//?=============================== Externi fajlovi =========================================//
#include "maps.pwn"

//?=============================== Simple Define =========================================//
#define VERZIJA_MODA     		"v0.0.1 by Montrey.pwn"
#define MAP_NAME    			"Balkan"
#define JEZIK_GMA               "Ex-Yu"

//?================================== Colors ============================================//

#define     c_server        "{0099ff}"
#define     c_red           "{ff1100}"
#define     c_blue          "{0099cc}"
#define     c_white         "{ffffff}"
#define     c_yellow        "{f2ff00}"
#define     c_green         "{009933}"
#define     c_pink          "{ff00bb}"
#define     c_ltblue        "{00f2ff}"
#define     c_orange        "{ffa200}"
#define     c_greey         "{787878}"

#define     col_server     0x0099FFAA
#define     col_red        0xFF1100AA
#define     col_blue       0x0099CCAA
#define     col_white      0xffffffAA
#define     col_yellow     0xf2ff00AA
#define     col_green      0x009933AA
#define     col_pink       0xff00bbAA
#define     col_ltblue     0x00f2ffAA
#define     col_orange     0xffa200AA
#define     col_greey      0x787878AA
#define     col_purple      0xC2A2DAAA

//?================================== Static Const ============================================//
const MAX_PASSWORD_DUZINA = 64; //! Max duzina stringa za lozinku
const MIN_PASSWORD_DUZINA = 6; //! Minimalna duzina lozinke
const MAX_LOGIN_POKUSAJA = 3; //! Max broj pokusaja logina

static stock const USER_PATH[64] = "/Korisnici/%s.ini";
//?================================== Enumerations ============================================//
enum
{
 	iRegistrovan = 1, //! Provera dal je registrovan korisnik
	iUlogovan //! Provera dal je ulogovan korisnik
};
//?================================== Static Player Info ============================================//
static  
    iLozinka[MAX_PLAYERS][MAX_PASSWORD_DUZINA], //! Lozinka igraca
    iPol[MAX_PLAYERS][2], //! Pol igraca
    iLevel[MAX_PLAYERS], //! Level igraca
    iNovac[MAX_PLAYERS], //! Novac igraca
	iBankovniRacun[MAX_PLAYERS], //! Bankovni racun igraca
	iNovacuBanci[MAX_PLAYERS], //! Novac u banci
    iGodine[MAX_PLAYERS], //! Godine igraca
    iSkin[MAX_PLAYERS], //! Skin igraca
	iDrzavljanstvo[MAX_PLAYERS], //! Drzavljanstvo igraca
	iPotrebnoRespekata[MAX_PLAYERS], //! Potrebno respekata za level up
	iRespekti[MAX_PLAYERS], //! Broj respekata igraca
    iLoginPokusaja[MAX_PLAYERS], //! Login pokusaja provera
	iStaff[MAX_PLAYERS], //! Staff 
	iStaffDutyTime[MAX_PLAYERS], //! Staff duty vreme
    iKarticaPin[MAX_PLAYERS], //! Pin kartice u banci
	iLicnaKarta[MAX_PLAYERS]; //! Licna karta cuvanje

//?================================== Booliens ============================================//
new bool:StaffDuty[MAX_PLAYERS]; //! Provera dal je admin na duznosti (0, 1)
//?================================== Variables ============================================//
new stfveh[MAX_PLAYERS] = { INVALID_VEHICLE_ID, ... }; //! Staff vozilo provera
//! Chekpointi za banku
new CP_UlazuBanku, CP_IzlazizBanke, CP_3Sprat, CP_15Sprat, CP_19Sprat; 

new AktorPrizemlje, ActorOpenRacuna, AktorHipoteka; //! Aktori

new Text3D:Text_Banka; //! 3D text banka

//?================================== Callbacks ============================================//
//! Ucitavanje naloga
forward Account_Load(const playerid, const string: name[], const string: value[]);
public Account_Load(const playerid, const string: name[], const string: value[])
{
	INI_String("Lozinka", iLozinka[playerid]);
	INI_String("Pol", iPol[playerid]);
	INI_Int("Drzavljanstvo", iDrzavljanstvo[playerid]);
	INI_Int("Level", iLevel[playerid]);
	INI_Int("Novac", iNovac[playerid]);
	INI_Int("Skin", iSkin[playerid]);
	INI_Int("Respekti", iRespekti[playerid]);
	INI_Int("PotrebnoRespekata", iPotrebnoRespekata[playerid]);
	INI_Int("NovacuBanci", iNovacuBanci[playerid]);
	INI_Int("Staff", iStaff[playerid]);
	INI_Int("StaffDuty", iStaffDutyTime[playerid]);
	INI_Int("BankovniRacun", iBankovniRacun[playerid]);
    INI_Int("KarticaPin", iKarticaPin[playerid]);
	INI_Int("NovacuBanci", iNovacuBanci[playerid]);
    INI_Int("Novac", iNovac[playerid]);
	INI_Int("LicnaKarta", iLicnaKarta[playerid]);
	
	return 1;
}
//! Label & Pickup
forward Create3DandP(const text[], Float:vXU, Float:vYU, Float:vZU, vInt, vVW, pickupid, Float:radius);
public Create3DandP(const text[], Float:vXU, Float:vYU, Float:vZU, vInt, vVW, pickupid, Float:radius)
{
	CreateDynamic3DTextLabel(text, 0x0059FFAA, vXU, vYU, vZU, radius, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, vVW, vInt, -1, 20.0);
	CreateDynamicPickup(pickupid, 1, vXU, vYU, vZU, vVW, vInt);
}
//! Payday
forward PayDay(playerid);
public PayDay(playerid)
{
    iRespekti[playerid]++;
    static string[256];
    format(string, sizeof(string), ""c_green"PAYDAY: "c_white"Primili ste platu u iznosu od $500! Ostatak plate vam je isplacen na racun!");
    SendClientMessage(playerid, -1, string);
    GivePlayerMoney(playerid, 500);
    format(string, sizeof(string), ""c_green"PAYDAY: "c_white"Sada imas %d/%d respekata!", iRespekti[playerid], iPotrebnoRespekata[playerid]);
    SendClientMessage(playerid, -1, string);
    if(iRespekti[playerid] >= iPotrebnoRespekata[playerid])
    {
        iRespekti[playerid] = 0;
        iLevel[playerid]++;
        iPotrebnoRespekata[playerid] = iLevel[playerid]*3+4;
        format(string, sizeof(string), ""c_green"PAYDAY: "c_white"Cestitamo sada si level %d! Potrebno ti je %d respekata!", iLevel[playerid], iPotrebnoRespekata[playerid]);
        SendClientMessage(playerid, -1, string);
    }
    new INI:File = INI_Open(Korisnici(playerid));
    INI_SetTag(File,"data");
    INI_WriteInt(File, "Level", GetPlayerScore(playerid));
    INI_WriteInt(File, "Respekti", iRespekti[playerid]);
    INI_WriteInt(File, "PotrebnoRespekata", iPotrebnoRespekata[playerid]);
    INI_WriteInt(File, "Novac", GetPlayerMoney(playerid));
    INI_Close(File);

    SetPlayerScore(playerid, iLevel[playerid]); // Da refresha level u scoreboard kada se levelupuje lik

    return 1;
}
//! Kada je vozilo kreirano
forward OnVehicleCreated(vehicleid);
public OnVehicleCreated(vehicleid)
{
    new engine, lights, alarm, doors, bonnet, boot, objective;
    GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
    if (IsVehicleBicycle(GetVehicleModel(vehicleid))) 
    {
        SetVehicleParamsEx(vehicleid, 1, VEHICLE_PARAMS_OFF, VEHICLE_PARAMS_OFF, doors, bonnet, boot, objective);
    }
    else 
    {
        SetVehicleParamsEx(vehicleid, VEHICLE_PARAMS_OFF, VEHICLE_PARAMS_OFF, VEHICLE_PARAMS_OFF, doors, bonnet, boot, objective);
    }
    
    return 1;
}

//?================================== Tajmeri ============================================//
//! Tajmer za Spawn_Player

timer Spawn_Player[100](playerid, type)
{
	if (type == iRegistrovan)
	{
		if(iDrzavljanstvo[playerid] == 0) //sf
		{
			SetSpawnInfo(playerid, 0, iSkin[playerid], 863.2152,-1101.9219,24.1592,272.1179, 0, 0, 0, 0, 0, 0);
		}
		else if(iDrzavljanstvo[playerid] == 1) //ls
		{
			SetSpawnInfo(playerid, 0, iSkin[playerid], 863.2152,-1101.9219,24.1592,272.1179, 0, 0, 0, 0, 0, 0);
		}
		else if(iDrzavljanstvo[playerid] == 2) //lv
		{
			SetSpawnInfo(playerid, 0, iSkin[playerid], 863.2152,-1101.9219,24.1592,272.1179, 0, 0, 0, 0, 0, 0);			
		}
		SpawnPlayer(playerid);

		SetPlayerScore(playerid, iLevel[playerid]);
		GivePlayerMoney(playerid, iNovac[playerid]);
		SetPlayerSkin(playerid, iSkin[playerid]);
	}

	else if (type == iUlogovan)
	{
		new ime[80], level[80], kes[80], kesbanka[80];
		format(ime, sizeof(ime), "| >> "c_white"Dobrodosao nazad na server, "c_server"%s << |", ReturnPlayerName(playerid));
		format(level, sizeof(level), "| >> "c_white"Tvoj trenuti "c_server"level "c_white"je : "c_server"%i << |", iLevel[playerid]);
		format(kes, sizeof(kes), "| >> "c_white"Tvoj "c_server"novac "c_white"u rukama : "c_server"%i$ << |", iNovac[playerid]);
		if(iBankovniRacun[playerid] == 0)
		{
			format(kesbanka, sizeof(kesbanka), "| >> "c_white"Vi nemate "c_server"racun "c_white"u banci! << |");
		}
		else if(iBankovniRacun[playerid] == 1)
		{
			format(kesbanka, sizeof(kesbanka), "| >> "c_white"Tvoj "c_server"novac "c_white"u banci : "c_server"%d$ << |", iNovacuBanci[playerid]);
		}
		
		SendClientMessage(playerid, col_server, "============== Dobrodosao nazad ==============");
		SendClientMessage(playerid, col_server, ime);
		SendClientMessage(playerid, col_server, level);
		SendClientMessage(playerid, col_server, kes);
		SendClientMessage(playerid, col_server, kesbanka);
		SendClientMessage(playerid, col_server, "| >> "c_white"Uzivaj u igri, Vas Montrey "c_white"Staff Tim "c_server"<< |");
		SendClientMessage(playerid, col_server, "============================================");		
		if(iDrzavljanstvo[playerid] == 0) //sf
		{
			SetSpawnInfo(playerid, 0, iSkin[playerid], 863.2152,-1101.9219,24.1592,272.1179, 0, 0, 0, 0, 0, 0);
		}
		else if(iDrzavljanstvo[playerid] == 1) //ls
		{
			SetSpawnInfo(playerid, 0, iSkin[playerid], 863.2152,-1101.9219,24.1592,272.1179, 0, 0, 0, 0, 0, 0);
		}
		else if(iDrzavljanstvo[playerid] == 2) //lv
		{
			SetSpawnInfo(playerid, 0, iSkin[playerid], 863.2152,-1101.9219,24.1592,272.1179, 0, 0, 0, 0, 0, 0);			
		}
		SpawnPlayer(playerid);
		iPotrebnoRespekata[playerid] = iLevel[playerid]*3+4;
		
		SetPlayerScore(playerid, iLevel[playerid]);
		GivePlayerMoney(playerid, iNovac[playerid]);
		SetPlayerSkin(playerid, iSkin[playerid]);

	}
}
//! Tajmer za Duty Staff
timer StaffDutyTimer[60000](playerid)
{
	if(StaffDuty[playerid])
	{
		iStaffDutyTime[playerid]++;
		defer StaffDutyTimer(playerid);
	}
	
    return 1;
}

//?================================== Dialozi ============================================//
//! Register Password dialog
Dialog: dialog_regpassword(const playerid, response, listitem, string: inputtext[])
{
	if (!response) // ovo je ako klikne izlaz (odustane od registracije)
		return Kick(playerid);

	if (!(MIN_PASSWORD_DUZINA <= strlen(inputtext) <= MAX_PASSWORD_DUZINA))
		return Dialog_Show(playerid, "dialog_regpassword", DIALOG_STYLE_INPUT,
			"Registracija",
			"%s, unesite Vasu zeljenu lozinku: ",
			"Potvrdi", "Izlaz", ReturnPlayerName(playerid)
		);

	strcopy(iLozinka[playerid], inputtext);

	Dialog_Show(playerid, "dialog_regages", DIALOG_STYLE_INPUT,
		"Godine",
		"Koliko imate godina: ",
		"Unesi", "Izlaz"
	);

	return 1;
}
//! Register godine dialog
Dialog: dialog_regages(const playerid, response, listitem, string: inputtext[])
{
	if (!response)
		return Kick(playerid);

	if (!(12 <= strval(inputtext) <= 50))
		return SendClientMessage(playerid, -1, "il si mlad il si mator"), Dialog_Show(playerid, "dialog_regages", DIALOG_STYLE_INPUT,
			"Godine",
			"Koliko imate godina: ",
			"Unesi", "Izlaz"
		);

	iGodine[playerid] = strval(inputtext);

	Dialog_Show(playerid, "dialog_drzavljanstvo", DIALOG_STYLE_LIST,
		"Drzavljanstvo",
		"San Fierro\nLos Santos\nLas Venturas",
		"Odaberi", "Izlaz"
	);

	return 1;
}
//! Register drzavljanstvo dialog
Dialog: dialog_drzavljanstvo(const playerid, response, listitem, string: inputtext[])
{
	if (!response)
		return Kick(playerid);
		
	if(response)
	{
		switch(listitem)
		{
			case 0:
			{
			 	iDrzavljanstvo[playerid] = 0;
				SendClientMessage(playerid, col_server, "M >> "c_white"Dobrodosao u Montrey, trebas pomoc, svrati do aktora!" );
			}
			case 1:
			{
			 	iDrzavljanstvo[playerid] = 1;
				SendClientMessage(playerid, col_server, "M >> "c_white"Dobrodosao u Montrey, trebas pomoc, svrati do aktora!" );
			}
			case 2:
			{
			 	iDrzavljanstvo[playerid] = 2;
				SendClientMessage(playerid, col_server, "M >> "c_white"Dobrodosao u Montrey, trebas pomoc, svrati do aktora!" );
			}
		}
	}

	Dialog_Show(playerid, "dialog_regsex", DIALOG_STYLE_LIST,
	"Spol",
	"Musko\nZensko",
	"Odaberi", "Izlaz"
	);
	return 1;
}
//! Register pol dialog
Dialog: dialog_regsex(const playerid, response, listitem, string: inputtext[])
{
	if (!response)
		return Kick(playerid);

	new tmp_int = listitem + 1;

	new INI:File = INI_Open(Korisnici(playerid));
	INI_SetTag(File,"data");
	INI_WriteString(File, "Lozinka", iLozinka[playerid]);
	INI_WriteString(File, "Pol", (tmp_int == 1 ? ("Musko") : ("Zensko")));
	INI_WriteInt(File, "Drzavljanstvo", iDrzavljanstvo[playerid]);
	INI_WriteInt(File, "Godine", iGodine[playerid]);
	INI_WriteInt(File, "Level", 1);
	INI_WriteInt(File, "Skin", 240);
	INI_WriteInt(File, "Novac", 1000);
	INI_WriteInt(File, "Staff", 0);
	INI_WriteInt(File, "StaffDuty", 0);
	INI_WriteInt(File, "LicnaKarta", 0);
	INI_WriteInt(File, "Respekti", 0);
	INI_WriteInt(File, "PotrebnoRespekata", 7);
	INI_WriteInt(File, "BankovniRacun", 0); // Racun dal ima
	INI_WriteInt(File, "NovacuBanci", 0); // Racun dal ima
	INI_WriteInt(File, "KarticaPin", 0);

	INI_Close(File);

	iNovac[playerid] = 1000;
	iSkin[playerid] = 240;
	iLevel[playerid] = 1;
	iPotrebnoRespekata[playerid] = 7;

	defer Spawn_Player(playerid, 1);
	
	return 1;
}
//! Login Dialog
Dialog: dialog_login(const playerid, response, listitem, string: inputtext[])
{
	if (!response)
		return Kick(playerid);

	if (!strcmp(iLozinka[playerid], inputtext, false))
		defer Spawn_Player(playerid, 2);
	else
	{
		if (iLoginPokusaja[playerid] == MAX_LOGIN_POKUSAJA)
			return Kick(playerid);

		++iLoginPokusaja[playerid];
		Dialog_Show(playerid, "dialog_login", DIALOG_STYLE_PASSWORD,
			"Prijavljivanje",
			"%s, unesite Vasu tacnu lozinku: ",
			"Potvrdi", "Izlaz", ReturnPlayerName(playerid)
		);
	}

	return 1;
}
//! Dialog Owner Panel
Dialog: dialog_spanel(const playerid, response, listitem, string: inputtext[])
{
	if(response)
	{
		switch(listitem)
		{
			case 0:
			{
				SendClientMessage(playerid, col_server, "M >> "c_white"Trenuto offline!" );
			}
			case 1:
			{
				SendClientMessage(playerid, col_server, "M >> "c_white"Trenuto offline!" );
			}
			case 2:
			{
				Dialog_Show(playerid, "dialog_vreme", DIALOG_STYLE_LIST,
					""c_server"M >> "c_white"Vreme Panel",
					"Noc\nDan",
					"Odaberi", "Izlaz");
			}
			case 3:
			{
				Dialog_Show(playerid, "dialog_napravi", DIALOG_STYLE_LIST,
					""c_server"M >> "c_white"Napravi Funkcije",
					"Offline",
					"Odaberi", "Izlaz");
			}
			case 4:
			{
				Dialog_Show(playerid, "dialog_izmeni", DIALOG_STYLE_LIST,
					""c_server"M >> "c_white"Izmeni Funkcije",
					"Offline",
					"Odaberi", "Izlaz");
			}
			case 5:
			{
				Dialog_Show(playerid, "dialog_izbrisi", DIALOG_STYLE_LIST,
					""c_server"M >> "c_white"Izbrisi Funkcije",
					"Offline",
					"Odaberi", "Izlaz");
			}
		}
	}
	return 1;
}
//! Owner Panel Vreme
Dialog: dialog_vreme(const playerid, response, listitem, string: inputtext[])
{	
	if(response)
	{
		switch(listitem)
		{
			case 0:
			{
				SetWorldTime(2);
				SendClientMessage(playerid, col_server, "M >> "c_white"Postavili ste vreme na noc!" );
			}
			case 1:
			{
				SetWorldTime(14);
				SendClientMessage(playerid, col_server, "M >> "c_white"Postavili ste vreme na dan!" );
			}
		}
	}
	return 1;
}
//! Owner Panel Napravi
Dialog: dialog_napravi(const playerid, response, listitem, string: inputtext[])
{	
	if(response)
	{
		switch(listitem)
		{
			case 0:
			{
				return SendClientMessage(playerid, col_red, "M >> "c_white"Nema ponudjenih stvari!");
			}
		}
	}
	return 1;
}
//! Owner Panel Izmeni
Dialog: dialog_izmeni(const playerid, response, listitem, string: inputtext[])
{	
	if(response)
	{
		switch(listitem)
		{
			case 0:
			{
				return SendClientMessage(playerid, col_red, "M >> "c_white"Nema ponudjenih stvari!");
			}
		}
	}
	return 1;
}
//! Owner Panel Izbrisi
Dialog: dialog_izbrisi(const playerid, response, listitem, string: inputtext[])
{	
	if(response)
	{
		switch(listitem)
		{
			case 0:
			{
				return SendClientMessage(playerid, col_red, "M >> "c_white"Nema ponudjenih stvari!");
			}
		}
	}
	return 1;
}
//! Banka Lift Dialog
Dialog: dialog_bankalift(const playerid, response, listitem, string: inputtext[])
{		
	if(response)
	{
		switch(listitem)
		{
			case 0:
			{
				if(IsPlayerInRangeOfPoint(playerid, 1.0, 1786.4974,-1304.6136,22.1869)) // Provera sprata po poziciji chekpointa
					return SendClientMessage(playerid, col_red, "M >> "c_white"Vec si na ovom spratu!");
					
			 	SetPlayerPos(playerid, 1786.8237,-1299.6392,22.2109); // Pozicija igraca
				SetPlayerFacingAngle(playerid, 315.01);
				SendClientMessage(playerid, col_green, "BANKA >> "c_white"Na 1 si spratu, ovo je sprat za klijente!");
			}
			case 1:
			{
				if(IsPlayerInRangeOfPoint(playerid, 1.0, 1786.5707,-1304.6349,33.1169)) // Provera sprata po poziciji chekpointa
					return SendClientMessage(playerid, col_red, "M >> "c_white"Vec si na ovom spratu!");
					
			 	SetPlayerPos(playerid, 1786.6571,-1299.0269,33.1250); // Pozicija igraca
				SetPlayerFacingAngle(playerid, 315.01);
				SendClientMessage(playerid, col_green, "BANKA >> "c_white"Na 3 si spratu, ovo je sprat gde su zaposleni!");
			}
			case 2:
			{
				if(IsPlayerInRangeOfPoint(playerid, 1.0, 1786.6957,-1305.0073,98.4870))  // Provera sprata po poziciji chekpointa
					return SendClientMessage(playerid, col_red, "M >> "c_white"Vec si na ovom spratu!");
					
			 	SetPlayerPos(playerid, 1787.1149,-1299.4758,98.5000); // Pozicija igraca
				SetPlayerFacingAngle(playerid, 315.01);
				SendClientMessage(playerid, col_green, "BANKA >> "c_white"Na 15 si spratu, ovo je sprat gde je obezbedjenje!");
			}
			case 3:
			{
				if(IsPlayerInRangeOfPoint(playerid, 1.0, 1786.5061,-1304.5850,120.2471)) // Provera sprata po poziciji chekpointa
					return SendClientMessage(playerid, col_red, "M >> "c_white"Vec si na ovom spratu!");

			 	SetPlayerPos(playerid, 1786.3268,-1299.2252,120.2656); // Pozicija igraca
				SetPlayerFacingAngle(playerid, 315.01);
				SendClientMessage(playerid, col_green, "BANKA >> "c_white"Na 19 si spratu, upao si u sef!");
			}
			case 4:
			{
				SendClientMessage(playerid, col_green, "BANKA >> "c_white"Trenutno nedostupno");
			}
			case 5:
			{
			 	SetPlayerPos(playerid, 1796.9551,-1306.2042,13.6524); // Pozicija igraca
				SetPlayerFacingAngle(playerid, 315.01);
				SetPlayerMapIcon(playerid, 1, 1786.4974,-1304.6136,22.1869, 52, 0, MAPICON_GLOBAL); // Ikonica banke na mapi
			}
		}
	}
	return 1;
}
//! Banka Kartica Dialog
Dialog: dialog_kartica(const playerid, response, listitem, string: inputtext[])
{	
	new ranpin = 1000 + random(9999);
	new stringic[128];
	if(response)
	{
		switch(listitem)
		{
			case 0:
			{
				iKarticaPin[playerid] = ranpin;
			 	iBankovniRacun[playerid] = 1;
                iNovacuBanci[playerid] = 100;
                ApplyAnimation(playerid, "DEALER", "shop_pay", 4.1, 0, 0, 0, 0, 0);
				format(stringic, sizeof(stringic), "BANKA >> "c_white"Uspesno si otvorio racun u banci.\nTvoj pin od kartice je >> %i, zapamti ga dobro!", iKarticaPin[playerid]);
                SendClientMessage(playerid, col_server, stringic);
				SendClientMessage(playerid, col_server, "BANKA >> "c_white"Dobio si 100$ novcane pomoci od predsednika Los Santosa!");

                new INI:File = INI_Open(Korisnici(playerid));
                INI_SetTag( File, "data" );

				INI_WriteInt(File, "BankovniRacun", iBankovniRacun[playerid]);
				INI_WriteInt(File, "NovacuBanci", iNovacuBanci[playerid]);
                INI_WriteInt(File, "Novac", GetPlayerMoney(playerid));
                INI_WriteInt(File, "KarticaPin", iKarticaPin[playerid]);           

                INI_Close( File );
			}
			case 1:
			{
				iKarticaPin[playerid] = ranpin;
			 	iBankovniRacun[playerid] = 1;
                iNovacuBanci[playerid] = 100;
                ApplyAnimation(playerid, "DEALER", "shop_pay", 4.1, 0, 0, 0, 0, 0);
				format(stringic, sizeof(stringic), "BANKA >> "c_white"Uspesno si otvorio racun u banci.\nTvoj pin od kartice je >> %i, zapamti ga dobro!", iKarticaPin[playerid]);
                SendClientMessage(playerid, col_server, stringic);
				SendClientMessage(playerid, col_server, "BANKA >> "c_white"Dobio si 100$ novcane pomoci od predsednika Los Santosa!");

                new INI:File = INI_Open(Korisnici(playerid));
                INI_SetTag( File, "data" );

				INI_WriteInt(File, "BankovniRacun", iBankovniRacun[playerid]);
				INI_WriteInt(File, "NovacuBanci", iNovacuBanci[playerid]);
                INI_WriteInt(File, "Novac", GetPlayerMoney(playerid));
                INI_WriteInt(File, "KarticaPin", iKarticaPin[playerid]);           

                INI_Close( File );
			}
			case 2:
			{
				iKarticaPin[playerid] = ranpin;
			 	iBankovniRacun[playerid] = 1;
                iNovacuBanci[playerid] = 100;
                ApplyAnimation(playerid, "DEALER", "shop_pay", 4.1, 0, 0, 0, 0, 0);
				format(stringic, sizeof(stringic), "BANKA >> "c_white"Uspesno si otvorio racun u banci.\nTvoj pin od kartice je >> %i, zapamti ga dobro!", iKarticaPin[playerid]);
                SendClientMessage(playerid, col_server, stringic);
				SendClientMessage(playerid, col_server, "BANKA >> "c_white"Dobio si 100$ novcane pomoci od predsednika Los Santosa!");

                new INI:File = INI_Open(Korisnici(playerid));
                INI_SetTag( File, "data" );

				INI_WriteInt(File, "BankovniRacun", iBankovniRacun[playerid]);
				INI_WriteInt(File, "NovacuBanci", iNovacuBanci[playerid]);
                INI_WriteInt(File, "Novac", GetPlayerMoney(playerid));
                INI_WriteInt(File, "KarticaPin", iKarticaPin[playerid]);           

                INI_Close( File );
			}
			case 3:
			{
				iKarticaPin[playerid] = ranpin;
			 	iBankovniRacun[playerid] = 1;
                iNovacuBanci[playerid] = 500;
                ApplyAnimation(playerid, "DEALER", "shop_pay", 4.1, 0, 0, 0, 0, 0);
				format(stringic, sizeof(stringic), "BANKA >> "c_white"Uspesno si otvorio racun u banci.\nTvoj pin od kartice je >> %i, zapamti ga dobro!", iKarticaPin[playerid]);
                SendClientMessage(playerid, col_server, stringic);
				SendClientMessage(playerid, col_server, "BANKA >> "c_white"Dobio si 500$ novcane pomoci kao nas premium korisnik!");

                new INI:File = INI_Open(Korisnici(playerid));
                INI_SetTag( File, "data" );

				INI_WriteInt(File, "BankovniRacun", iBankovniRacun[playerid]);
				INI_WriteInt(File, "NovacuBanci", iNovacuBanci[playerid]);
                INI_WriteInt(File, "Novac", GetPlayerMoney(playerid));
                INI_WriteInt(File, "KarticaPin", iKarticaPin[playerid]);           

                INI_Close( File );
			}
		}
	}
    return 1;
}
//! Banka Blagajna Dialog
Dialog: dialog_blagajna(const playerid, response, listitem, string: inputtext[])
{	
	new ranpin = 1000 + random(9999);
	if(response)
	{
		switch(listitem)
		{
			case 0:
			{
				Dialog_Show(playerid, "dialog_deposit", DIALOG_STYLE_INPUT,
				"Montrey Banka",
				"%s, Napisi kolicinu novca koju zelis da ostavis!",
				"Odaberi", "Nazad", ReturnPlayerName(playerid)
			);
			}
			case 1:
			{
				Dialog_Show(playerid, "dialog_withdraw", DIALOG_STYLE_INPUT,
				"Montrey Banka",
				"%s, Napisi kolicinu novca koju zelis da podignes\nTvoj trenutni novac u banci je >> %d $!",
				"Odaberi", "Nazad", ReturnPlayerName(playerid), iNovacuBanci[playerid]
			);
			}
			case 2:
			{
				Dialog_Show(playerid, "dialog_transfer", DIALOG_STYLE_INPUT,
				"Montrey Banka",
				"%s, unesi id igraca i kolicinu novca koju zelis prebaciti!",
				"Odaberi", "Nazad", ReturnPlayerName(playerid)
			);
			}
			case 3:
			{
				SendClientMessage(playerid, col_green, "BANKA >> "c_white"Opcija kredita jos nije moguca!");
			}
			case 4:
			{
				Dialog_Show(playerid, "dialog_balans", DIALOG_STYLE_MSGBOX,
				"Montrey Banka",
				""c_white"%s, Vase treenutno stanje na racunu je >> "c_server"%d $!",
				"U redu", "", ReturnPlayerName(playerid), iNovacuBanci[playerid]
				);
			}
			case 5:
			{
				iKarticaPin[playerid] = ranpin;
				Dialog_Show(playerid, "dialog_balans", DIALOG_STYLE_MSGBOX,
				"Montrey Banka",
				""c_white"%s, Vase novi pin od racuna je >> "c_server"%i, zapamtite ga dobro!",
				"U redu", "", ReturnPlayerName(playerid), iKarticaPin[playerid]
				);

                new INI:File = INI_Open(Korisnici(playerid));
                INI_SetTag( File, "data" );

                INI_WriteInt(File, "KarticaPin", iKarticaPin[playerid]);           

                INI_Close( File );
			}
		}
	}
    return 1;
}

//! Ostavljanje Novca
Dialog: dialog_deposit(const playerid, response, listitem, string: inputtext[])
{
	if(!response) 
		return Dialog_Show(playerid, "dialog_blagajna", DIALOG_STYLE_LIST,
		"Montrey Banka",
		"Ostavi\nPodigni\nTransfer Novca\nKredit\nBalans\nPromena Pin Koda",
		"Odaberi", "Izlaz"
	);
	new stringic[128];
	if(GetPlayerMoney(playerid) < strval(inputtext)) return SendClientMessage(playerid, col_red, "M >> "c_white"Nemas toliko novca kod sebe!");
	new novac1 = strval(inputtext);
	iNovacuBanci[playerid] += strval(inputtext);
	format(stringic, sizeof(stringic), "BANKA >> "c_white"Ostavili ste %d$ na vas racun! Vase novo stanje je %d$!", novac1, iNovacuBanci[playerid]);
    SendClientMessage(playerid, col_green, stringic);
	ApplyAnimation(playerid, "DEALER", "shop_pay", 4.1, 0, 0, 0, 0, 0);
	GivePlayerMoney(playerid, -strval(inputtext));

    new INI:File = INI_Open(Korisnici(playerid));
    INI_SetTag( File, "data" );

	INI_WriteInt(File, "NovacuBanci", iNovacuBanci[playerid]);
    INI_WriteInt(File, "Novac", GetPlayerMoney(playerid));       

    INI_Close( File );

	return 1;
}
//! Dizanje Kesa
Dialog: dialog_withdraw(const playerid, response, listitem, string: inputtext[])
{
	if(!response) 
		return Dialog_Show(playerid, "dialog_blagajna", DIALOG_STYLE_LIST,
		"Montrey Banka",
		"Ostavi\nPodigni\nTransfer Novca\nKredit\nBalans\nPromena Pin Koda",
		"Odaberi", "Izlaz"
	);
	new stringic[128];
	if(iNovacuBanci[playerid] < strval(inputtext)) return SendClientMessage(playerid, col_red, "M >> "c_white"Nemas toliko novca na racunu!");
	new novac1 = strval(inputtext);
	iNovacuBanci[playerid] -= strval(inputtext);
	format(stringic, sizeof(stringic), "BANKA >> "c_white"Uzeli ste %d$ sa vaseg racuna! Vase novo stanje je %d$!", novac1, iNovacuBanci[playerid]);
    SendClientMessage(playerid, col_green, stringic);
	ApplyAnimation(playerid, "DEALER", "shop_pay", 4.1, 0, 0, 0, 0, 0);
	GivePlayerMoney(playerid, strval(inputtext));	

    new INI:File = INI_Open(Korisnici(playerid));
    INI_SetTag( File, "data" );

	INI_WriteInt(File, "NovacuBanci", iNovacuBanci[playerid]);
    INI_WriteInt(File, "Novac", GetPlayerMoney(playerid));

    INI_Close( File );

	return 1;
}

//! Transfer Kesa
Dialog: dialog_transfer(const playerid, response, listitem, string: inputtext[])
{
	if(!response) 
		return Dialog_Show(playerid, "dialog_blagajna", DIALOG_STYLE_LIST,
		"Montrey Banka",
		"Ostavi\nPodigni\nTransfer Novca\nKredit\nBalans\nPromena Pin Koda",
		"Odaberi", "Izlaz"
	);
    new id, cashdeposit;
	if(sscanf(inputtext, "ui", id, cashdeposit)) return Dialog_Show(playerid, "dialog_transfer", DIALOG_STYLE_INPUT,
														"Montrey Banka",
														"%s, unesi id igraca i kolicinu novca koju zelis prebaciti!",
														"Odaberi", "Nazad", ReturnPlayerName(playerid)
														);

	if( cashdeposit > iNovacuBanci[playerid] || cashdeposit < 1 ) return SendClientMessage( playerid, col_red, "M >> "c_white"Nemate toliko novaca");
	if( id == INVALID_PLAYER_ID ) return SendClientMessage(playerid, col_red, "M >> "c_white"Pogresan ID Igraca");
    if(!iBankovniRacun[id]) return SendClientMessage(playerid, col_red, "M >> "c_white"Taj igrac nema racun u banci!");

	iNovacuBanci[playerid] -= cashdeposit;
    iNovacuBanci[id] += cashdeposit;

	new INI:File = INI_Open(Korisnici(playerid));
    INI_SetTag( File, "data" );

	INI_WriteInt(File, "NovacuBanci", iNovacuBanci[playerid]);

    INI_Close( File );

    SavePlayer(playerid); SavePlayer(id);
	PlayerPlaySound( playerid, 1052, 0.0, 0.0, 0.0);

	SendClientMessageEx(playerid, col_green, "TRANSFER: "c_white"Poslao si %d$ na %s-ov racun.", cashdeposit, ReturnPlayerName( id ), id );
	SendClientMessageEx(id, col_green, "TRANSFER: "c_white"Primio si %d$ na svoj racun od %s.", cashdeposit, ReturnPlayerName( playerid ), playerid );

	return 1;
}
//! Opstina Promena Drzave Dialog
Dialog: dialog_promenadrzave(const playerid, response, listitem, string: inputtext[])
{	
	if(response)
	{
		switch(listitem)
		{
			case 0:
			{
                if(iDrzavljanstvo[playerid] == 0) return SendClientMessage(playerid, col_red, "M >> "c_white"Vec si drzavljanin San Fierra!");
			 	iDrzavljanstvo[playerid] = 0;
                GivePlayerMoney(playerid, -200);
                ApplyAnimation(playerid, "DEALER", "shop_pay", 4.1, 0, 0, 0, 0, 0);
                SendClientMessage(playerid, col_server, "M >> "c_white"Uspesno si promenio drzavljanstvo!");

                new INI:File = INI_Open(Korisnici(playerid));
                INI_SetTag( File, "data" );

                INI_WriteInt(File, "Novac", GetPlayerMoney(playerid));
                INI_WriteInt(File, "Drzavljanstvo", iDrzavljanstvo[playerid]);           

                INI_Close( File );
                
				SendClientMessage(playerid, col_server, "Ti si drzavljanin San Fierra!" );
			}
			case 1:
			{
                if(iDrzavljanstvo[playerid] == 1) return SendClientMessage(playerid, col_red, "M >> "c_white"Vec si drzavljanin Los Santosa!");
			 	iDrzavljanstvo[playerid] = 1;
                GivePlayerMoney(playerid, -200);
                ApplyAnimation(playerid, "DEALER", "shop_pay", 4.1, 0, 0, 0, 0, 0);
                SendClientMessage(playerid, col_server, "M >> "c_white"Uspesno si promenio drzavljanstvo!");

                new INI:File = INI_Open(Korisnici(playerid));
                INI_SetTag( File, "data" );

                INI_WriteInt(File, "Novac", GetPlayerMoney(playerid));
                INI_WriteInt(File, "Drzavljanstvo", iDrzavljanstvo[playerid]);           

                INI_Close( File );
                
				SendClientMessage(playerid, col_server, "Ti si drzavljanin Los Santosa!" );
			}
			case 2:
			{
                if(iDrzavljanstvo[playerid] == 2) return SendClientMessage(playerid, col_red, "M >> "c_white"Vec si drzavljanin Las Venturasa!");
			 	iDrzavljanstvo[playerid] = 2;
                GivePlayerMoney(playerid, -200);
                ApplyAnimation(playerid, "DEALER", "shop_pay", 4.1, 0, 0, 0, 0, 0);
                SendClientMessage(playerid, col_server, "M >> "c_white"Uspesno si promenio drzavljanstvo!");

                new INI:File = INI_Open(Korisnici(playerid));
                INI_SetTag( File, "data" );

                INI_WriteInt(File, "Novac", GetPlayerMoney(playerid));
                INI_WriteInt(File, "Drzavljanstvo", iDrzavljanstvo[playerid]);           

                INI_Close( File );

				SendClientMessage(playerid, col_server, "Ti si drzavljanin Las Venturasa!" );
			}
		}
	}
    return 1;
}

//?=============================== Some Funkcije =========================================//
//! Korisnici Putanja
stock Korisnici(const playerid)
{
	new tmp_fmt[64];
	format(tmp_fmt, sizeof(tmp_fmt), USER_PATH, ReturnPlayerName(playerid));

	return tmp_fmt;
}
//! ProxDetector
stock ProxDetector(playerid, Float:max_range, color, const string[], Float:max_ratio = 1.6)
{
	new
		Float:pos_x,
		Float:pos_y,
		Float:pos_z,
		Float:range,
		Float:range_ratio,
		Float:range_with_ratio,
		clr_r, clr_g, clr_b,
		Float:color_r, Float:color_g, Float:color_b;

	if (!GetPlayerPos(playerid, pos_x, pos_y, pos_z)) 
	{
		return 0;
	}

	color_r = float(color >> 24 & 0xFF);
	color_g = float(color >> 16 & 0xFF);
	color_b = float(color >> 8 & 0xFF);
	range_with_ratio = max_range * max_ratio;

#if defined foreach
	foreach (new i : Player) 
	{
#else
	for (new i = GetPlayerPoolSize(); i != -1; i--) 
	{
#endif
		if (!IsPlayerStreamedIn(i, playerid)) 
		{
			continue;
		}

		range = GetPlayerDistanceFromPoint(i, pos_x, pos_y, pos_z);
		if (range > max_range) 
		{
			continue;
		}

		range_ratio = (range_with_ratio - range) / range_with_ratio;
		clr_r = floatround(range_ratio * color_r);
		clr_g = floatround(range_ratio * color_g);
		clr_b = floatround(range_ratio * color_b);

		SendClientMessage(i, (color & 0xFF) | (clr_b << 8) | (clr_g << 16) | (clr_r << 24), string);
	}

	SendClientMessage(playerid, color, string);

	return 1;
}

//! SendClientMessageEx
stock SendClientMessageEx(playerid, color, const str[], {Float,_}:...)
{
	static
	    args,
	    start,
	    end,
	    string[144]
	;
	#emit LOAD.S.pri 8
	#emit STOR.pri args

	if(args > 12)
	{
		#emit ADDR.pri str
		#emit STOR.pri start

	    for (end = start + (args - 12); end > start; end -= 4)
		{
	        #emit LREF.pri end
	        #emit PUSH.pri
		}
		#emit PUSH.S str
		#emit PUSH.C 144
		#emit PUSH.C string
		#emit PUSH.C args
		#emit SYSREQ.C format

		SendClientMessage(playerid, color, string);

		#emit LCTRL 5
		#emit SCTRL 4
		#emit RETN
	}
	return SendClientMessage(playerid, color, str);
}
//! Ukoliko je vozilo bicikl
stock IsVehicleBicycle(m)
{
    if (m == 481 || m == 509 || m == 510) return true;
    
    return false;
}

//?=============================== Main Mod =========================================//

main()
{
	print("================== [ MOD UCITAN ] ======================");
	print("	   Montrey Community - www.montrey.xyz				   ");
	print("	     v0.0.1 gamemode - Loading...					   ");
	print("	     v0.0.1 gamemode - Loaded.  					   ");
	print("	     v0.0.1 gamemode by Vostic    		  			   ");
	print("========================================================");
}
//! Labeli 3D
CreatePickupsAnd3Ds()
{
    Create3DandP(""c_server"[ Opstina ]\n"c_white"'ENTER' za ulaz", 1477.0828,-1818.7952,15.3383, -1, -1, 19133, 2.0); // Opstina ulaz
    Create3DandP(""c_server"[ Salter ]\n"c_white"'/izvadilicnu'\n'/promenidrzavljanstvo'", 361.2740,171.0686,1008.3828, -1, -1, 1239, 2.0); //licna
    Create3DandP(""c_server"[ Blagajna ]\n"c_white"'/blagajna'", 1813.6713,-1290.7893,22.2109, -1, -1, 1212, 2.0); //salter1 Banka
    Create3DandP(""c_server"[ Blagajna ]\n"c_white"'/blagajna'", 1813.6687,-1298.4092,22.2109, -1, -1, 1212, 2.0); //salter2 Banka
    Create3DandP(""c_server"[ Racun ]\n"c_white"'/otvoriracun'", 1829.6395,-1274.9326,22.2109, -1, -1, 1212, 2.0); //racun open Banka
    Create3DandP(""c_server"[ Hipoteka ]\n"c_white"'Y' za pogodnosti hipoteke", 1818.0872,-1276.6302,22.2109, -1, -1, 1239, 2.0); //Banka Hipoteka
    Create3DandP(""c_server"[ Cekaonica ]\n"c_white"'Y' da sednes", 1830.1454,-1283.1907,22.7549, -1, -1, 1239, 2.0); //Banka Sedalo1
    Create3DandP(""c_server"[ Cekaonica ]\n"c_white"'Y' da sednes", 1800.4771,-1309.0106,22.7549, -1, -1, 1239, 2.0); //Banka Sedalo2
    Create3DandP(""c_server"[ Radno Vreme ]\n"c_white"'07-23'", 1792.5695,-1300.4518,13.4612, -1, -1, 1239, 2.0); //Banka Radno Vreme
    Create3DandP(""c_server"[ Biro Rada ]\n"c_white"'ENTER' za ulaz", 1467.5178,-1011.0197,26.8438, -1, -1, 19133, 2.0); //Biro Desni Ulaz
    Create3DandP(""c_server"[ Biro Rada ]\n"c_white"'ENTER' za ulaz", 1457.2957,-1011.6390,26.8438, -1, -1, 19133, 2.0); //Biro levi ulaz
    
    return 1;
}
//! SavePlayer za Banku Transfer
SavePlayer(playerid)
{
    new INI:File = INI_Open(Korisnici(playerid));
    INI_SetTag( File, "data" );

	INI_WriteInt(File, "LicnaKarta", iLicnaKarta[playerid]);
	INI_WriteInt(File, "BankovniRacun", iBankovniRacun[playerid]);
	INI_WriteInt(File, "NovacuBanci", iNovacuBanci[playerid]);
    INI_WriteInt(File, "Novac", GetPlayerMoney(playerid));
    INI_WriteInt(File, "KarticaPin", iKarticaPin[playerid]);           

    INI_Close( File );	
	return true;
}

//! Na startu moda
public OnGameModeInit()
{
	//! Default defines
	SetGameModeText( VERZIJA_MODA );
	SendRconCommand( "language "JEZIK_GMA"" );
	SendRconCommand( "mapname "MAP_NAME"" );

	DisableInteriorEnterExits(); 						//! Gasi interijere default
	ManualVehicleEngineAndLights(); 					//! Gasi Manualna Svetla i engine vozila
	ShowPlayerMarkers(PLAYER_MARKERS_MODE_OFF);  		//! Gasi player markere
	SetNameTagDrawDistance(20.0);  						//! Dinstanca prikaza imena igraca
	LimitGlobalChatRadius(20.0); 						//! Limit za razdaljinu global chata
	EnableVehicleFriendlyFire(); 						//! Svako vozilo se moze destroy
	CreatePickupsAnd3Ds(); 								//! Aktivira forward naveden gore

	SetTimer("PayDay", 3600000, true); 						//! Payday tajmer

	//! Aktori 
	AktorPrizemlje = CreateActor(71, 1792.7607,-1302.4524,13.5277,0.1496);
	ActorOpenRacuna = CreateActor(141, 1831.5023,-1272.4097,22.2109,139.4119);
	AktorHipoteka = CreateActor(148, 1816.2584,-1274.6991,22.2109,216.5893);
	ApplyActorAnimation(AktorPrizemlje, "DEALER", "DEALER_IDLE", 4.1, 1, 0, 0, 0, 0);
	ApplyActorAnimation(ActorOpenRacuna, "GANGS", "prtial_gngtlkA", 4.1, 1, 0, 0, 0, 0);
	ApplyActorAnimation(AktorHipoteka, "GANGS", "prtial_gngtlkA", 4.1, 1, 0, 0, 0, 0);
	//!CP
    CP_UlazuBanku = CreateDynamicCP(1792.6542,-1306.0980,13.7764, 1, -1, -1, -1, 200);
    CP_IzlazizBanke = CreateDynamicCP(1786.4974,-1304.6136,22.1869, 1, -1, -1, -1, 200);
	CP_3Sprat = CreateDynamicCP(1786.5707,-1304.6349,33.1169, 1, -1, -1, -1, 200);
	CP_15Sprat = CreateDynamicCP(1786.6957,-1305.0073,98.4870, 1, -1, -1, -1, 200);
	CP_19Sprat = CreateDynamicCP(1786.5061,-1304.5850,120.2471, 1, -1, -1, -1, 200);
    
    Text_Banka = CreateDynamic3DTextLabel("Montrey Banka", col_white, 1792.6542,-1306.0980,13.7764, 30.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 200);

	return 1;
}
//! Na gasenje moda
public OnGameModeExit()
{
    DestroyDynamicCP(CP_UlazuBanku);
    DestroyDynamicCP(CP_IzlazizBanke);
	DestroyDynamicCP(CP_3Sprat);
	DestroyDynamicCP(CP_15Sprat);
	DestroyDynamicCP(CP_19Sprat);
    
    DestroyDynamic3DTextLabel(Text_Banka);

	return 1;
}
//! Opcije prilikom konekcije igraca
public OnPlayerConnect(playerid)
{
	SetPlayerColor(playerid, col_white);

	TogglePlayerSpectating(playerid, 0);
	for(new ocisti1; ocisti1 < 110; ocisti1++)
	{
		SendClientMessageToAll(-1, "");
	}

	if (fexist(Korisnici(playerid)))
	{
		INI_ParseFile(Korisnici(playerid), "Account_Load", true, true, playerid);
		Dialog_Show(playerid, "dialog_login", DIALOG_STYLE_PASSWORD,
			"Prijavljivanje",
			"%s, unesite Vasu tacnu lozinku: ",
			"Potvrdi", "Izlaz", ReturnPlayerName(playerid)
		);
		return 1;
	}

	Dialog_Show(playerid, "dialog_regpassword", DIALOG_STYLE_INPUT,
		"Registracija",
		"%s, unesite Vasu zeljenu lozinku: ",
		"Potvrdi", "Izlaz", ReturnPlayerName(playerid)
	);

	stfveh[playerid] = INVALID_VEHICLE_ID;

	return 1;
}
//! Opcije priliko izlaza sa servera (crash ili normal izlaz)
public OnPlayerDisconnect(playerid, reason)
{
	new INI:File = INI_Open(Korisnici(playerid));
    INI_SetTag(File,"data");
    INI_WriteInt(File, "Level",GetPlayerScore(playerid));
    INI_WriteInt(File, "Skin",GetPlayerSkin(playerid));
    INI_WriteInt(File, "Novac", GetPlayerMoney(playerid));
	INI_WriteInt(File, "Staff", iStaff[playerid]);
	INI_WriteInt(File, "StaffDuty", iStaffDutyTime[playerid]);
    INI_WriteInt(File, "Respekti", iRespekti[playerid]);
    INI_WriteInt(File, "PotrebnoRespekata", iPotrebnoRespekata[playerid]);
    INI_Close(File);
	
    return 1;
}
//! Kada igrac klikne na mapi nesto
public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{
	if(iStaff[playerid] >= 1)
	{
		SetPlayerPosFindZ(playerid, fX, fY, fZ);
	}
	return 1;
}
//! Kada se igrac spawnuje
public OnPlayerSpawn(playerid)
{
	SetPlayerTeam(playerid, NO_TEAM);
	SetPlayerMapIcon(playerid, 1, 1786.6084,-1299.6708,13.4351, 52, 0, MAPICON_GLOBAL); // Ikonica banke na mapi

	return 1;
}
//! Kad igrac umre
public OnPlayerDeath(playerid, killerid, reason)
{

    return 1;
}
//! Kada se spawnuje vozilo
public OnVehicleSpawn(vehicleid)
{
    // Gasenje motora na vozilu, odnosno paljenje ako je u pitanju bicikl + gasenje svetala
    new engine, lights, alarm, doors, bonnet, boot, objective;
    GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
    if (IsVehicleBicycle(GetVehicleModel(vehicleid))) 
    {
        SetVehicleParamsEx(vehicleid, 1, 0, 0, doors, bonnet, boot, objective);
    }
    else 
    {
        SetVehicleParamsEx(vehicleid, 0, 0, 0, doors, bonnet, boot, objective);
    }

    return 1;
}
//! Na unistenje vozila
public OnVehicleDeath(vehicleid, killerid)
{
	DestroyVehicle(stfveh[vehicleid]);
	stfveh[vehicleid] = INVALID_PLAYER_ID;

    return 1;
}
//! Kada igrac udje na chekpoint
public OnPlayerEnterDynamicCP(playerid, checkpointid)
{
    if(checkpointid == CP_UlazuBanku) // Ulaz u banku cp
	{
		new sati, minuti;
		GetPlayerTime(playerid, sati, minuti);
		if(sati < 7) return SendClientMessage(playerid, col_red, "M >> "c_white"Trenutno je noc i glavna filijala ne radi!");
		SetPlayerPos(playerid, 1786.8237,-1299.6392,22.2109); // Pozicija igraca
		SetPlayerFacingAngle(playerid, 270);
		RemovePlayerMapIcon(playerid, 1); // Uklanja ikonicu na mapi.
	}
    if(checkpointid == CP_IzlazizBanke) // Izlaz iz banke cp
	{
		Dialog_Show(playerid, "dialog_bankalift", DIALOG_STYLE_LIST,
		""c_server"M >> "c_white"Lift Banka",
		"Banka\n3 Sprat\n15 Sprat\n19 Sprat\nGaraza\nIzlaz",
		"Odaberi", "Izlaz"
		);
	}
    if(checkpointid == CP_3Sprat) // Izlaz iz banke cp
	{
		Dialog_Show(playerid, "dialog_bankalift", DIALOG_STYLE_LIST,
		""c_server"M >> "c_white"Lift Banka",
		"Banka\n3 Sprat\n15 Sprat\n19 Sprat\nGaraza\nIzlaz",
		"Odaberi", "Izlaz"
		);
	}
    if(checkpointid == CP_15Sprat) // Izlaz iz banke cp
	{
		Dialog_Show(playerid, "dialog_bankalift", DIALOG_STYLE_LIST,
		""c_server"M >> "c_white"Lift Banka",
		"Banka\n3 Sprat\n15 Sprat\n19 Sprat\nGaraza\nIzlaz",
		"Odaberi", "Izlaz"
		);
	}
    if(checkpointid == CP_19Sprat) // Izlaz iz banke cp
	{
		Dialog_Show(playerid, "dialog_bankalift", DIALOG_STYLE_LIST,
		""c_server"M >> "c_white"Lift Banka",
		"Banka\n3 Sprat\n15 Sprat\n19 Sprat\nGaraza\nIzlaz",
		"Odaberi", "Izlaz"
		);
	}
	return 1;
}
//! Sta se desi kad igrac pritisne neko dugme na tastaturi
public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
        if(newkeys & KEY_NO)
        {
            new veh = GetPlayerVehicleID(playerid),
                engine,
                lights,
                alarm,
                doors,
                bonnet,
                boot,
                objective;
            
            if(IsVehicleBicycle(GetVehicleModel(veh)))
            {
                return true;
            }
            
            GetVehicleParamsEx(veh, engine, lights, alarm, doors, bonnet, boot, objective);

            if(engine == VEHICLE_PARAMS_OFF)
            {
                SetVehicleParamsEx(veh, VEHICLE_PARAMS_ON, lights, alarm, doors, bonnet, boot, objective);
            }
            else
            {
                SetVehicleParamsEx(veh, VEHICLE_PARAMS_OFF, lights, alarm, doors, bonnet, boot, objective);
            }
            new str[60];
            format(str, sizeof(str), "%s si motor.", (engine == VEHICLE_PARAMS_OFF) ? "Upalio" : "Ugasio");
            SendClientMessage(playerid, -1, str);

            return true;
        }
    }
	else if(newkeys & KEY_SECONDARY_ATTACK)
    {
        if(IsPlayerInRangeOfPoint(playerid, 3.0, 1477.0828, -1818.7952, 15.3383)) //OpstinaLS
        {
            SetPlayerInterior(playerid, 3);
            SetPlayerPos(playerid, 389.7137, 173.6886, 1008.3828);
            SetCameraBehindPlayer(playerid);
        }
        if(IsPlayerInRangeOfPoint(playerid, 3.0, 389.7137, 173.6886, 1008.3828)) //OpstinaSF Izlaz
        {
            SetPlayerInterior(playerid, 0);
            SetPlayerPos(playerid, 1477.0828, -1818.7952, 15.3383);
            SetCameraBehindPlayer(playerid);
        }
        if(IsPlayerInRangeOfPoint(playerid, 1.0, 1467.5178,-1011.0197,26.8438)) //Biro Rada Ulaz
        {
            SetPlayerPos(playerid, 1467.1675,-1008.0137,26.8850);
            SetCameraBehindPlayer(playerid);     
        }     
        if(IsPlayerInRangeOfPoint(playerid, 1.0, 1457.2957,-1011.6390,26.8438)) //Biro Rada Ulaz 2
        {
            SetPlayerPos(playerid, 1457.1305,-1007.5593,26.8850);
            SetCameraBehindPlayer(playerid);
        }
        if(IsPlayerInRangeOfPoint(playerid, 1.0, 1467.1675,-1008.0137,26.8850)) //Biro Rada Izlaz
        {
            SetPlayerPos(playerid, 1467.5178,-1011.0197,26.8438);
            SetCameraBehindPlayer(playerid);     
        }     
        if(IsPlayerInRangeOfPoint(playerid, 1.0, 1457.1305,-1007.5593,26.8850)) //Biro Rada Izlaz 2
        {
            SetPlayerPos(playerid, 1457.2957,-1011.6390,26.8438);
            SetCameraBehindPlayer(playerid);
        } 
    }
    return 1;
}
//! Sta se desi na promeni state-a (vozilo, pesacenje etc..)
public OnPlayerStateChange(playerid, newstate, oldstate)
{
    if(newstate == PLAYER_STATE_DRIVER)
    {
        SendClientMessage(playerid, -1, "Da upalite motor koristite tipku 'N'");
    }

    return 1;
}
//! Kada igrac napusti vozilo
public OnPlayerExitVehicle(playerid, vehicleid)
{
    new engine,
        lights,
        alarm,
        doors,
        bonnet,
        boot,
        objective;

    GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
    SetVehicleParamsEx(vehicleid, VEHICLE_PARAMS_OFF, lights, alarm, doors, bonnet, boot, objective);

    return 1;
}
//?================================== Komande ============================================//
//! OOC CHAT
YCMD:b(playerid, params[], help)
{
	new string[128], text[100];
	if(sscanf(params, "s[100]", text)) return SendClientMessage(playerid, col_server, "M >> "c_white"Nisi uneo text!");
 	format(string, sizeof(string), "(( "c_white"OOC"c_greey" )) "c_white"%s "c_greey": "c_white"%s", ReturnPlayerName(playerid), text);

	 
	ProxDetector(playerid, Float:30.0, col_greey, string);

	return 1;
}
//! Staff Duty
YCMD:sduty(playerid, params[], help)
{
	if(!iStaff[playerid])
		return SendClientMessage(playerid, col_red, "GRESKA >> "c_white"Niste clan staffa!");

	static string[128];
	if(StaffDuty[playerid] == false )
 	{
		SetPlayerHealth( playerid, 100);
		SetPlayerArmour( playerid, 99);
		
		StaffDuty[ playerid ] = true;
		defer StaffDutyTimer(playerid);
		format(string, sizeof(string), "Staff %s (Duty: %d min) je sada na duznosti /report", ReturnPlayerName(playerid), iStaffDutyTime[playerid]);
	  	SendClientMessageToAll(-1, string);	
	}
	else if(StaffDuty[playerid] == true)
	{
	 	StaffDuty[playerid] = false;
		format(string, sizeof(string), "Staff %s (Duty: %d min) vise nije na duznosti", ReturnPlayerName(playerid), iStaffDutyTime[playerid]);
	 	SendClientMessageToAll(-1, string);
	}
	new INI:File = INI_Open(Korisnici(playerid));
	INI_SetTag( File, "data" );
	INI_WriteInt(File, "StaffDuty", iStaffDutyTime[playerid]);

	INI_Close( File );

    return true;
}
//! STAFF CHAT
YCMD:sc(playerid, const string: params[], help)
{
	if(!iStaff[playerid])
		return SendClientMessage(playerid, col_red, "M >> "c_white"Samo staff moze ovo!");
	if(StaffDuty[playerid] == false)
		return SendClientMessage(playerid, col_red, "M >> "c_white"Morate biti admin na duznosti!");

	if (isnull(params))
		return SendClientMessage(playerid, col_yellow, "KORISCENJE >> "c_white"/sc [text]");

	static tmp_str[128];
	format(tmp_str, sizeof(tmp_str), "Staff - %s(%d): "c_white"%s", ReturnPlayerName(playerid), playerid, params);

	foreach (new i: Player)
		if (iStaff[i])
			SendClientMessage(i, col_ltblue, tmp_str);
	
    return 1;
}
//! STAFF CMD
YCMD:staffcmd(playerid, const string: params[], help)
{
	if(!iStaff[playerid])
		return SendClientMessage(playerid, col_red, "M >> "c_white"Samo staff moze ovo!");

	Dialog_Show(playerid, "dialog_staffcmd", DIALOG_STYLE_MSGBOX,
	""c_server"M >> "c_white"Staff Commands",
	""c_white"%s, Vi ste deo naseg "c_server"staff "c_white"tima!\n\
	"c_server"SLVL1 >> "c_white"/sduty\n\
	"c_server"SLVL1 >> "c_white"/sc\n\
	"c_server"SLVL1 >> "c_white"/staffcmd\n\
	"c_server"SLVL1 >> "c_white"/sveh\n\
	"c_server"SLVL1 >> "c_white"/goto\n\
	"c_server"SLVL1 >> "c_white"/cc\n\
	"c_server"SLVL1 >> "c_white"/fv\n\
	"c_server"SLVL2 >> "c_white"/gethere\n\
	"c_server"SLVL3 >> "c_white"/nitro\n\
	"c_server"SLVL4 >> "c_white"/jetpack\n\
	"c_server"SLVL5 >> "c_white"/setskin\n\
	"c_server"SLVL6 >> "c_white"/xgoto\n\
	"c_server"SLVL7 >> "c_white"/spanel\n\
	"c_server"SLVL7 >> "c_white"/setstaff",
	"U redu", "", ReturnPlayerName(playerid)
	);

    return 1;
}
//! STAFF VOZILO
YCMD:sveh(playerid, params[], help)
{
	if(!iStaff[playerid])
		return SendClientMessage(playerid, col_red, "M >> "c_white"Samo staff moze ovo!");
	if(StaffDuty[playerid] == false)
		return SendClientMessage(playerid, col_red, "M >> "c_white"Morate biti admin na duznosti!");

	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);
	if (stfveh[playerid] == INVALID_VEHICLE_ID) 
	{
		if (isnull(params))
			return SendClientMessage(playerid, col_yellow, "KORISCENJE >> "c_white"/sveh [Model ID]");

		new modelid = strval(params);

		if (400 > modelid > 611)
			return SendClientMessage(playerid, col_yellow, "KORISCENJE >> "c_white"* Validni modeli su od 400 do 611.");

		new vehicleid = stfveh[playerid] = CreateVehicle(modelid, x, y, z, 0.0, 1, 0, -1);
		SetVehicleNumberPlate(vehicleid, "STAFF");
		PutPlayerInVehicle(playerid, vehicleid, 0);

		SendClientMessage(playerid, col_blue, "M >> "c_white"Stvorili ste vozilo, da ga unistite kucajte '/sveh'.");
	}
	else 
	{
		DestroyVehicle(stfveh[playerid]);
		stfveh[playerid] = INVALID_PLAYER_ID;

		SendClientMessage(playerid, col_blue, "M >> "c_white"Unistili ste vozilo, da ga stvorite kucajte '/veh [Model ID]'.");
	}
	
    return 1;
}
//! STAFF GOTO
YCMD:goto(playerid, params[],help)
{
	if(!iStaff[playerid])
		return SendClientMessage(playerid, col_red, "M >> "c_white"Samo staff moze ovo!");
	if(StaffDuty[playerid] == false)
		return SendClientMessage(playerid, col_red, "M >> "c_white"Morate biti admin na duznosti!");

	new giveplayerid, giveplayer[MAX_PLAYER_NAME];
	new Float:plx,Float:ply,Float:plz;
	GetPlayerName(giveplayerid, giveplayer, sizeof(giveplayer));
	if(!sscanf(params, "u", giveplayerid))
	{	
		GetPlayerPos(giveplayerid, plx, ply, plz);
			
		if (GetPlayerState(playerid) == 2)
		{
			new tmpcar = GetPlayerVehicleID(playerid);
			SetVehiclePos(tmpcar, plx, ply+4, plz);
		}
		else
		{
			SetPlayerPos(playerid,plx,ply+2, plz);
		}
		SetPlayerInterior(playerid, GetPlayerInterior(giveplayerid));
	}

    return 1;
}
//! STAFF CLEAR CHAT
YCMD:cc(playerid, params[], help)
{
	if(!iStaff[playerid])
		return SendClientMessage(playerid, col_red, "M >> "c_white"Samo staff moze ovo!");

	static string[72];
	for(new cc; cc < 110; cc++)
	{
		SendClientMessageToAll(-1, "");
	}
	if(iStaff[playerid] == 1)
	{
		format(string, sizeof(string), "M >> "c_white"Helper %s, je ocistio chat.", ReturnPlayerName(playerid));
		SendClientMessageToAll(-1, string);
	}
	if(iStaff[playerid] == 2)
	{
		format(string, sizeof(string), "M >> "c_white"Silver Staff %s, je ocistio chat.", ReturnPlayerName(playerid));
		SendClientMessageToAll(-1, string);
	}
	if(iStaff[playerid] == 3)
	{
		format(string, sizeof(string), "M >> "c_white"Gold Staff %s, je ocistio chat.", ReturnPlayerName(playerid));
		SendClientMessageToAll(-1, string);
	}
	if(iStaff[playerid] == 4)
	{
		format(string, sizeof(string), "M >> "c_white"Diamond Staff %s, je ocistio chat.", ReturnPlayerName(playerid));
		SendClientMessageToAll(-1, string);
	}
	if(iStaff[playerid] == 5)
	{
		format(string, sizeof(string), "M >> "c_white"Head Staff %s, je ocistio chat.", ReturnPlayerName(playerid));
		SendClientMessageToAll(-1, string);
	}
	if(iStaff[playerid] == 6)
	{
		format(string, sizeof(string), "M >> "c_white"Direktor %s, je ocistio chat.", ReturnPlayerName(playerid));
		SendClientMessageToAll(-1, string);
	}
	if(iStaff[playerid] == 7)
	{
		format(string, sizeof(string), "M >> "c_white"Gazda %s, je ocistio chat.", ReturnPlayerName(playerid));
		SendClientMessageToAll(-1, string);
	}
    return 1;
}
//! STAFF FIX VEH
YCMD:fv(playerid, params[], help)
{
	if(!iStaff[playerid])
		return SendClientMessage(playerid, col_red, "M >> "c_white"Samo staff moze ovo!");
	if(StaffDuty[playerid] == false)
		return SendClientMessage(playerid, col_red, "M >> "c_white"Morate biti admin na duznosti!");
	new vehicleid = GetPlayerVehicleID(playerid);
	if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, col_red, "M >> "c_white"Niste u vozilu!");
	RepairVehicle(vehicleid);
	SetVehicleHealth(vehicleid, 999.0);
	return 1;

}
//! STAFF DOVUCI IGRACA DO SEBE
YCMD:gethere(playerid, const params[], help)
{
	if (iStaff[playerid] < 2)
		return SendClientMessage(playerid, col_red, "M >> "c_white"Samo staff moze ovo!");
	if(StaffDuty[playerid] == false)
		return SendClientMessage(playerid, col_red, "M >> "c_white"Morate biti admin na duznosti!");
		
	new targetid = INVALID_PLAYER_ID;
	if(sscanf(params, "u", targetid)) return SendClientMessage(playerid, col_yellow, "KORISCENJE >> "c_white"/gethere [id]");
	if(targetid == INVALID_PLAYER_ID) return SendClientMessage(playerid, col_red, "GRESKA >> "c_white"Taj ID nije konektovan.");

	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);
	SetPlayerPos(targetid, x+1, y, z+1);
	SetPlayerInterior(targetid, GetPlayerInterior(playerid));
	SetPlayerVirtualWorld(targetid, GetPlayerVirtualWorld(playerid));

	new name[MAX_PLAYER_NAME];
	GetPlayerName(targetid, name, sizeof(name));

	new str[60];
	format(str, sizeof(str), "M >> Teleportovali ste igraca %s do sebe.", name);
	SendClientMessage(playerid, -1, str);

	GetPlayerName(playerid, name, sizeof(name));

	format(str, sizeof(str), "M >> Admin %s vas je teleportovao do sebe.", name);
	SendClientMessage(targetid, -1, str);

    return 1;
}
//! STAFF NITRO U VOZILO
YCMD:nitro(playerid, params[], help)
{
	if (iStaff[playerid] < 3)
		return SendClientMessage(playerid, col_red, "M >> "c_white"Samo staff moze ovo!");

	AddVehicleComponent(GetPlayerVehicleID(playerid), 1010);
	SendClientMessage(playerid,-1,"Ugradili ste nitro u vase vozilo.");

	return 1;
}
//! Staff jetpack
YCMD:jetpack(playerid, params[], help)
{
	if (iStaff[playerid] < 4)
		return SendClientMessage(playerid, col_red, "M >> "c_white"Samo staff moze ovo!");

	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USEJETPACK);

	return 1;
}
//! Staff set skin
YCMD:setskin(playerid, const string: params[], help)
{
	if (iStaff[playerid] < 5)
		return SendClientMessage(playerid, col_red, "M >> "c_white"Samo staff moze ovo!");
	if(StaffDuty[playerid] == false)
		return SendClientMessage(playerid, col_red, "M >> "c_white"Morate biti admin na duznosti!");

	static
		targetid,
		skinid;

	if (sscanf(params, "ri", targetid, skinid))
		return SendClientMessage(playerid, col_yellow, "KORISCENJE >> "c_white"/setskin [targetid] [skinid]");

	if (!(1 <= skinid <= 311))
		return SendClientMessage(playerid, col_red, "GRESKA >> "c_white"Pogresan ID skina!");

	if (GetPlayerSkin(targetid) == skinid)
		return SendClientMessage(playerid, col_red, "GRESKA >> "c_white"Taj igrac vec ima taj skin!");

	SetPlayerSkin(targetid, skinid);

	iSkin[targetid] = skinid;

    new INI:File = INI_Open(Korisnici(playerid));
	INI_SetTag( File, "data" );
    INI_WriteInt(File, "Skin", GetPlayerSkin(playerid));

	INI_Close( File );

    return 1;
}
//! Staff port do koordinata
YCMD:xgoto(playerid, params[], help)
{
	if (iStaff[playerid] < 6)
		return SendClientMessage(playerid, col_red, "M >> "c_white"Samo staff moze ovo!");
	if(StaffDuty[playerid] == false)
		return SendClientMessage(playerid, col_red, "M >> "c_white"Morate biti admin na duznosti!");
	new Float:x, Float:y, Float:z;
	new string[100];
	if (sscanf(params, "fff", x, y, z)) SendClientMessage(playerid, col_yellow, "KORISCENJE >> "c_white"xgoto <X Float> <Y Float> <Z Float>");
	else
	{
		if(IsPlayerInAnyVehicle(playerid))
		{
		    SetVehiclePos(GetPlayerVehicleID(playerid), x,y,z);
		}
		else
		{
		    SetPlayerPos(playerid, x, y, z);
		}
		format(string, sizeof(string), "M >> "c_white"Postavili ste koordinate na %f, %f, %f", x, y, z);
		SendClientMessage(playerid, col_ltblue, string);
	}
 	return 1;
}
//! Owner Panel
YCMD:spanel(playerid, params[], help)
{
	if(!IsPlayerAdmin(playerid))
		return SendClientMessage(playerid, col_red, "M >> "c_white"Samo RCON administrator!");
	if (iStaff[playerid] < 7)
		return SendClientMessage(playerid, col_red, "M >> "c_white"Nisi Vlasnik sinovac!");
	
	Dialog_Show(playerid, "dialog_spanel", DIALOG_STYLE_LIST,
		""c_server"M >> "c_white"Owner Panel",
		"Podesavanja\nAdmini\nVreme\nNapravi\nIzmeni\nIzbrisi",
		"Odaberi", "Izlaz"
	);

	return 1;
}
//! Postavi staff
YCMD:setstaff(playerid, const string: params[], help)
{
	if (!IsPlayerAdmin(playerid))
		return SendClientMessage(playerid, col_red, "M >> "c_white"Samo RCON administrator!");
	if (iStaff[playerid] < 7)
		return SendClientMessage(playerid, col_red, "M >> "c_white"Nisi Vlasnik sinovac!");

	static
		targetid,
		level;

	if (sscanf(params, "ri", targetid, level))
		return SendClientMessage(playerid, col_yellow, "KORISCENJE >> "c_white"/setstaff [targetid] [0/1]");

	if (!level && !iStaff[targetid])
		return SendClientMessage(playerid, col_red, "M >> "c_white"Taj igrac nije u staff-u.");

	if (level == iStaff[targetid])
		return SendClientMessage(playerid, col_red, "M >> "c_white"Taj igrac je vec u staff-u.");

	iStaff[targetid] = level;
	
	if (!level)
	{
		static fmt_str[64];
		format(fmt_str, sizeof(fmt_str), ""c_yellow"INFO >> "c_white"%s Vas je izbacio iz staff-a.", ReturnPlayerName(playerid));
		SendClientMessage(targetid, -1, fmt_str);
		format(fmt_str, sizeof(fmt_str), ""c_yellow"INFO >> "c_white"Izbacili ste %s iz staff-a.", ReturnPlayerName(targetid));
		SendClientMessage(playerid, -1, fmt_str);
	}
	else
	{
		static fmt_str[64];
		format(fmt_str, sizeof(fmt_str), ""c_yellow"INFO >> "c_white"%s Vas je ubacio u staff.", ReturnPlayerName(playerid));
		SendClientMessage(targetid, -1, fmt_str);
		format(fmt_str, sizeof(fmt_str), ""c_yellow"INFO >> "c_white"Ubacili ste %s u staff.", ReturnPlayerName(targetid));
		SendClientMessage(playerid, -1, fmt_str);
	}

    new INI:File = INI_Open(Korisnici(playerid));
	INI_SetTag( File, "data" );
    INI_WriteInt(File, "Staff", iStaff[playerid]);

	INI_Close( File );

    return 1;
}
//! Temp komanda za pare
YCMD:vosticbiznis(playerid, params[],help)
{
	if(iStaff[playerid] < 7)
		return SendClientMessage(playerid, col_red, "M >> "c_white"Samo vlasnik moze ovo!");

    GivePlayerMoney(playerid, 10000);
	
	new INI:File = INI_Open(Korisnici(playerid));
	INI_SetTag( File, "data" );
    INI_WriteInt(File, "Novac", GetPlayerMoney(playerid));

	INI_Close( File );

	return 1;
}
//! Banka racun otvaranje
YCMD:otvoriracun(playerid, params[], help)
{
	if(!IsPlayerInRangeOfPoint(playerid, 3.0, 1829.6395,-1274.9326,22.2109)) return SendClientMessage(playerid, col_red, "M >> "c_white"Morate biti u banci!");
    if(iLicnaKarta[playerid] == 0) return SendClientMessage(playerid, col_red, "M >> "c_white"Morate imati licnu kartu!");
	if(iBankovniRacun[playerid] == 1) return SendClientMessage(playerid, col_red, "M >> "c_white"Vec imate racun u nasoj banci!");

	Dialog_Show(playerid, "dialog_kartica", DIALOG_STYLE_LIST,
		"Odaberi Bankovnu Karticu",
		"Master Card\nVisa\nAmerican Express\nMontrey Diamond",
		"Odaberi", "Izlaz"
	);

	return 1;

}

//! Salter u banci komande
YCMD:blagajna(playerid, params[], help)
{
	if(!IsPlayerInRangeOfPoint(playerid, 3.0, 1813.6713,-1290.7893,22.2109) && !IsPlayerInRangeOfPoint(playerid, 3.0, 1813.6687,-1298.4092,22.2109)) 
		return SendClientMessage(playerid, col_red, "M >> "c_white"Morate biti na blagajni u banci!");
	if(iBankovniRacun[playerid] == 0) return SendClientMessage(playerid, col_red, "M >> "c_white"Nemate racun u nasoj banci!");

	Dialog_Show(playerid, "dialog_blagajna", DIALOG_STYLE_LIST,
		"Montrey Banka",
		"Ostavi\nPodigni\nTransfer Novca\nKredit\nBalans\nPromena Pin Koda",
		"Odaberi", "Izlaz"
	);

	return 1;

}
//! Promena drzavljastva opstina
YCMD:promenidrzavljanstvo(playerid, params[], help)
{
    if(!IsPlayerInRangeOfPoint(playerid, 3.0, 361.2740, 171.0686, 1008.3828)) return SendClientMessage(playerid, col_red, "M >> "c_white"Morate biti na salteru u opstini!");
    if(iLicnaKarta[playerid] == 0) return SendClientMessage(playerid, col_red, "M >> "c_white"Morate imati licnu kartu (/izvadilicnu)!");
    if(GetPlayerMoney(playerid) < 200) return SendClientMessage(playerid, col_red, "M >> "c_white"Nemate dovoljno novca!");

    
	Dialog_Show(playerid, "dialog_promenadrzave", DIALOG_STYLE_LIST,
		"Promena Drzavljanstva",
		"San Fierro\nLos Santos\nLas Venturas",
		"Odaberi", "Izlaz"
	);

    return 1;
}
