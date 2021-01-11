# [Discord link for more scripts](https://discord.gg/U5YDgbh): https://discord.gg/U5YDgbh

# Fivem SQL Dumper

It’s a code to dump/backup your database into a .sql file automatically.
The dump happens on the moment that you starts your server, it took just some seconds.
Very simple installation/ configuration.

# Installation

1. Download [MySQL Async](https://forum.cfx.re/t/release-mysql-async-library-3-3-2/21881)
2. Download Fivem SQL Dumper
3. Start both scripts (MySQL must be first)
4. Configure the Dump
5. Done

# Config File

You must set your Database name and the tables that you wanna dump

# Requirements

It’s standalone, works on any framework

# Bugs

Please, report here if you found any bugs

If you are using an older version of MySQL Async:
Change the first line in sv.lua:
```lua
MySQL.ready(function ()
```

To:
```lua
AddEventHandler(‘onMySQLReady’,function()
```
