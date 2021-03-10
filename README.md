PowerShell script to create and maintain Valheim backups.

Features:

- Independent of user folder name
- Purges screenshot folder before creating backup (ones that made by game, not Steam)
- Creates backup in Documents folder named ValheimBackups, with cozy gear icon
- Names backups in YYYY_MM_DD-HH_MM_SS format
- If there's more than 3 backups already, deletes the oldest
- Includes all necessary integrity checks to not fail at some point
- Minimalistic logging into nearby file inside same Documents folder (and also a console output) with actual prepend (workaround)
