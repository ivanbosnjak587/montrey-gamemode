/* 
*   __   __             _                    _____                                      _ _         
*  |  \/  |           | |                  / ____|                                    (_) |        
* | \  / | ___  _ __ | |_ _ __ ___ _   _  | |     ___  _ __ ___  _ __ ___  _   _ _ __  _| |_ _   _ 
* | |\/| |/ _ \| '_ \| __| '__/ _ \ | | | | |    / _ \| '_ ` _ \| '_ ` _ \| | | | '_ \| | __| | | |
* | |  | | (_) | | | | |_| | |  __/ |_| | | |___| (_) | | | | | | | | | | | |_| | | | | | |_| |_| |
* |_|  |_|\___/|_| |_|\__|_|  \___|\__, | \_____\___/|_| |_| |_|_| |_| |_|\__,_|_| |_|_|\__|\__, |
*                                   __/ |                                                     __/ |
*                                  |___/                                                     |___/ 
*   @Author         :   Vostic
*   @Version        :   0.0.1
*   @Description    :   Na modu radili svi kojima je dosao u ruke, pravu verziju ima samo Vostic, Ivo je samo ovu prvu verziju prebacio na open multiplayer 
*                       i u mysql, tako da pozdrav od Ive Deva
*   @Message by Ivo :   Ivi ne pada na pamet da se dalje jebe oko moda i pozdravljam
*   @Module         :   reglog
*/

#include <ysilib\YSI_Coding\y_hooks>

const MAX_PASSWORD_LENGTH   =       (65);
const MIN_PASSWORD_LENGTH   =       (6);
const MAX_LOGIN_ATTEMPTS    =       (3);
const MAX_EMAIL_LENGTH      =       (34);

#define ClearChat(%0,%1) for(new x = 0, j = %1; x <= j; x++) SendClientMessage(%0, -1, " ")

enum e_PLAYER_DATA 
{
    pID,
    pUsername[MAX_PLAYER_NAME],
    pPassword[MAX_PASSWORD_LENGTH],
    pEmail[MAX_EMAIL_LENGTH],
    pSex,
    pAges,
    pCountry,
    pScore,
    pMoney,
    pSkin
};

new PlayerInfo[MAX_PLAYERS][e_PLAYER_DATA],
    LoginAttempts[MAX_PLAYERS];

forward Account_CheckData(playerid);
public Account_CheckData(playerid)
{
    new rows = cache_num_rows();
    if(!rows) 
    {
        new msg1[256];
        format(msg1, sizeof(msg1), ""c_server"montrey %c "c_white"Dobrodosli na "c_server"Montrey Community.\n"c_white"Vi nemate napravljen korisnicki racun, da bi pristupili serveru, registrujte se.", 187);
        SendClientMessage(playerid, col_server, msg1);
        Dialog_Show(playerid, "dialog_register", DIALOG_STYLE_INPUT,  ""c_server"Montrey "c_white"Register", ""c_white"Da bi zapoceli proces registracije, prvo unesi zeljenu lozinku.\n"c_white"Lozinka minimalno moze biti 6 znakova, a maksimalno 65.", "Dalje", "Izlaz");
    }
    else
    {
        cache_get_value_name(0, "password", PlayerInfo[playerid][pPassword], MAX_PASSWORD_LENGTH);
        new msg2[256];
        format(msg2, sizeof(msg2), ""c_server"montrey %c "c_white"Dobrodosli na "c_server"Montrey Community.\n"c_white"Vi posjedujete korisnicki racun, ukucajte tocnu lozinku.", 187);
        SendClientMessage(playerid, col_server, msg2);
        Dialog_Show(playerid, "dialog_login", DIALOG_STYLE_PASSWORD, ""c_server"Montrey "c_white"Login", ""c_white"Za nastavak igranja na serveru, ukucajte tocnu lozinku\n"c_white"Ako ste kojim slucajem zaboravili, obratite nam se na nasem forumu", "Login", "Izlaz");
    }
    return (true);
}

forward Account_LoadData(playerid);
public Account_LoadData(playerid) 
{
    new rows = cache_num_rows();
    if(!rows) return false;
    else
    {
        cache_get_value_name_int(0, "id", PlayerInfo[playerid][pID]);
        cache_get_value_name(0, "password", PlayerInfo[playerid][pPassword], MAX_PASSWORD_LENGTH);
        cache_get_value_name(0, "email", PlayerInfo[playerid][pEmail], MAX_EMAIL_LENGTH);
        cache_get_value_name_int(0, "sex", PlayerInfo[playerid][pSex]);
        cache_get_value_name_int(0, "ages", PlayerInfo[playerid][pAges]);
        cache_get_value_name_int(0, "country", PlayerInfo[playerid][pCountry]);
        cache_get_value_name_int(0, "score", PlayerInfo[playerid][pScore]);
        cache_get_value_name_int(0, "money", PlayerInfo[playerid][pMoney]);
        cache_get_value_name_int(0, "skin", PlayerInfo[playerid][pSkin]);
        SetSpawnInfo(playerid, 0, PlayerInfo[playerid][pSkin], 1579.1288, -2322.0776, 13.3828, 88.6321, WEAPON_FIST, 0, WEAPON_FIST, 0, WEAPON_FIST, 0);
        SpawnPlayer(playerid);
        SetPlayerScore(playerid, PlayerInfo[playerid][pScore]);
        GivePlayerMoney(playerid, PlayerInfo[playerid][pMoney]);
        SetPlayerSkin(playerid, PlayerInfo[playerid][pSkin]);
        ClearChat(playerid, 20);
        new logstr[128];
        format(logstr, sizeof(logstr), ""c_server"montrey %c "c_white"Uspesno ste se ulogovali", 187);
        SendClientMessage(playerid, col_server, logstr);
    }
    return (true);
}

forward Account_Registered(playerid);
public Account_Registered(playerid)
{
    PlayerInfo[playerid][pUsername] = ReturnPlayerName(playerid);
    PlayerInfo[playerid][pScore] = 1;
    PlayerInfo[playerid][pMoney] = 10000;
    SetSpawnInfo(playerid, 0, PlayerInfo[playerid][pSkin], 1579.1288, -2322.0776, 13.3828, 88.6321, WEAPON_FIST, 0, WEAPON_FIST, 0, WEAPON_FIST, 0);
    SpawnPlayer(playerid);
    SetPlayerScore(playerid, PlayerInfo[playerid][pScore]);
    GivePlayerMoney(playerid, PlayerInfo[playerid][pMoney]);
    SetPlayerSkin(playerid, PlayerInfo[playerid][pSkin]);
    ClearChat(playerid, 20);
    new regstr[128];
    format(regstr, sizeof(regstr), ""c_server"montrey %c "c_white"Uspesno ste se registrovali", 187);
    SendClientMessage(playerid, col_server, regstr);
    return (true);
}

forward OnPasswordHash(playerid);
public OnPasswordHash(playerid) {
    bcrypt_get_hash(PlayerInfo[playerid][pPassword]);
}

forward OnPasswordVerify(playerid, bool:success);
public OnPasswordVerify(playerid, bool:success) 
{
    if(success) 
    {
        new q[256];
        mysql_format(SQL, q, sizeof(q), "SELECT * FROM `users` WHERE `username` = '%e' LIMIT 1", ReturnPlayerName(playerid));
        mysql_tquery(SQL, q, "Account_LoadData", "i", playerid);
    }
    else   
    {
        ++LoginAttempts[playerid];
        if(LoginAttempts[playerid] == MAX_LOGIN_ATTEMPTS) 
        {
            SendClientMessage(playerid, col_red, "Pogresili ste lozinku 3 puta, pa ste zbog toga kickovani sa servera!");
            Kick(playerid);
        }
        Dialog_Show(playerid, "dialog_login", DIALOG_STYLE_PASSWORD, ""c_server"Montrey "c_white"Login", ""c_white"Za nastavak igranja na serveru, ukucajte tocnu lozinku\n"c_white"Ako ste kojim slucajem zaboravili, obratite nam se na nasem forumu", "Login", "Izlaz");
    }
}

stock Account_SaveData(playerid)
{
    new q[256];
    mysql_format(SQL, q, sizeof(q), "UPDATE `users` SET `username` = '%e', `score` = '%d', `money` = '%d', `skin` = '%d' WHERE `id` = '%d'", ReturnPlayerName(playerid), PlayerInfo[playerid][pScore], PlayerInfo[playerid][pMoney], PlayerInfo[playerid][pSkin], PlayerInfo[playerid][pID]);
    mysql_tquery(SQL, q);
    return (true);
}

hook OnPlayerConnect(playerid)
{
    LoginAttempts[playerid] = 0;
    SetPlayerColor(playerid, col_white);
    ClearChat(playerid, 20);
    new q[120];
    mysql_format(SQL, q, sizeof(q), "SELECT * FROM `users` WHERE `username` = '%e'", ReturnPlayerName(playerid));
    mysql_tquery(SQL, q, "Account_CheckData", "i", playerid);
    return (true);
}

hook OnPlayerDisconnect(playerid, reason)
{
    Account_SaveData(playerid);
    return (true);
}

hook OnPlayerSpawn(playerid)
{
    TogglePlayerSpectating(playerid, false);
    SetPlayerColor(playerid, col_white);
    SetPlayerTeam(playerid, NO_TEAM);
    return (true);
}

Dialog:dialog_register(playerid, response, listitem, inputtext[])
{
    if(!response) return Kick(playerid);
    if(!(MIN_PASSWORD_LENGTH <= strlen(inputtext) <= MAX_PASSWORD_LENGTH)) return Dialog_Show(playerid, "dialog_register", DIALOG_STYLE_INPUT,  ""c_server"Montrey "c_white"Register", ""c_white"Da bi zapoceli proces registracije, prvo unesi zeljenu lozinku.\n"c_white"Lozinka minimalno moze biti 6 znakova, a maksimalno 65.", "Dalje", "Izlaz");
    bcrypt_hash(playerid, "OnPasswordHash", inputtext, BCRYPT_COST);
    Dialog_Show(playerid, "dialog_email", DIALOG_STYLE_INPUT,  ""c_server"Montrey "c_white"Register", ""c_white"Unesite vasu email adresu", "Dalje", "Izlaz");
    return (true);
}

Dialog:dialog_email(playerid, response, listitem, inputtext[])
{
    if(!response) return Kick(playerid);
    new mailstr = strfind(inputtext, "@", true), tacstr = strfind(inputtext, ".", true);
    if(mailstr == -1 || tacstr == -1)
    {
        Dialog_Show(playerid, "dialog_email", DIALOG_STYLE_INPUT,  ""c_server"Montrey "c_white"Register", ""c_white"Unesite vasu email adresu", "Dalje", "Izlaz");
    }
    else 
    {
        strmid(PlayerInfo[playerid][pEmail], inputtext, 0, strlen(inputtext), MAX_EMAIL_LENGTH);
        Dialog_Show(playerid, "dialog_sex", DIALOG_STYLE_LIST,  ""c_server"Montrey "c_white"Register - Izaberi spol", "Musko\nZensko", "Dalje", "Izlaz");
    }
    return (true);
}

Dialog:dialog_sex(playerid, response, listitem, inputtext[])
{
    if(!response) return Kick(playerid);
    switch(listitem)
    {
        case 0:
        {
            PlayerInfo[playerid][pSex] = 1;
            PlayerInfo[playerid][pSkin] = 240;
            Dialog_Show(playerid, "dialog_ages", DIALOG_STYLE_INPUT,  ""c_server"Montrey "c_white"Register", ""c_white"Upisite koliko vam je godina", "Dalje", "Izlaz");
        }
        case 1:
        {
            PlayerInfo[playerid][pSex] = 2;
            PlayerInfo[playerid][pSkin] = 9;
            Dialog_Show(playerid, "dialog_ages", DIALOG_STYLE_INPUT,  ""c_server"Montrey "c_white"Register", ""c_white"Upisite koliko vam je godina", "Dalje", "Izlaz");
        }
    }
    return (true);
}

Dialog:dialog_ages(playerid, response, listitem, inputtext[])
{
    if(!response) return Kick(playerid);
    new age = strval(inputtext);
    if(age < 12 || age > 65) return Dialog_Show(playerid, "dialog_ages", DIALOG_STYLE_INPUT,  ""c_server"Montrey "c_white"Register", ""c_white"Upisite koliko vam je godina", "Dalje", "Izlaz");
    PlayerInfo[playerid][pAges] = age;
    Dialog_Show(playerid, "dialog_country", DIALOG_STYLE_LIST,  ""c_server"Montrey "c_white"Register - Izaberi drzavu", ""c_white"Hrvatska\nSrbija\nBosna i Hercegovina\nCrna Gora\nMakedonija", "Register", "Izlaz");
    return (true);
}

Dialog:dialog_country(playerid, response, listitem, inputtext[])
{
    if(!response) return Kick(playerid);
    PlayerInfo[playerid][pCountry] = listitem + 1;
    new q[500];
    mysql_format(SQL, q, sizeof(q), "INSERT INTO `users` (`username`, `password`, `email`, `sex`, `ages`, `country`, `score`, `money`, `skin`) \
    VALUES ('%e', '%e', '%e', '%d', '%d', '%d', 1, 10000, '%d')", ReturnPlayerName(playerid), PlayerInfo[playerid][pPassword], PlayerInfo[playerid][pEmail], PlayerInfo[playerid][pSex], PlayerInfo[playerid][pAges], PlayerInfo[playerid][pCountry], PlayerInfo[playerid][pSkin]);
    mysql_tquery(SQL, q, "Account_Registered", "i", playerid);
    return (true);
}

Dialog:dialog_login(playerid, response, listitem, inputtext[])
{
    if(!response) return Kick(playerid);
    bcrypt_verify(playerid, "OnPasswordVerify", inputtext, PlayerInfo[playerid][pPassword]);
    return (true);
}