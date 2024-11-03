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
*   @Module         :   database
*/

#include <ysilib\YSI_Coding\y_hooks>

new MySQL:SQL;

hook OnGameModeInit() 
{
    
    mysql_log(ALL);

    SQL = mysql_connect_file("mysql.ini");

    if(mysql_errno(SQL) != 0)
    {
        printf("[MYSQL] Database connection failed, check mysql.ini!");
        SendRconCommand("exit");
    }
    else
    {
        printf("[MYSQL] Connected to database successfully");
    }

    return (true);
}

hook OnGameModeExit()
{

    if(SQL) 
    {
        mysql_close(SQL);
    }

    return (true);
}