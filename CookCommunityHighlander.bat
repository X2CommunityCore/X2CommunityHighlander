".\steamapps\common\XCOM 2 SDK\Binaries\Win64\XComGame.exe" make -final_release -full
".\steamapps\common\XCOM 2 SDK\Binaries\Win64\XComGame.exe" CookPackages -platform=pcconsole -final_release -quickanddirty -modcook -sha -multilanguagecook=INT+FRA+ITA+DEU+RUS+POL+KOR+ESN -singlethread
if not exist ".\steamapps\common\XCOM 2\XComGame\Mods\X2CommunityHighlander\CookedPCConsole" mkdir ".\steamapps\common\XCOM 2\XComGame\Mods\X2CommunityHighlander\CookedPCConsole" 
if not exist ".\steamapps\common\XCOM 2 SDK\XComGame\Mods\X2CommunityHighlander\CookedPCConsole" mkdir ".\steamapps\common\XCOM 2 SDK\XComGame\Mods\X2CommunityHighlander\CookedPCConsole" 
copy /Y ".\steamapps\common\XCOM 2 SDK\XComGame\Published\CookedPCConsole\XComGame.upk" ".\steamapps\common\XCOM 2\XComGame\Mods\X2CommunityHighlander\CookedPCConsole\XComGame.upk"
copy /Y ".\steamapps\common\XCOM 2 SDK\XComGame\Published\CookedPCConsole\XComGame.upk.uncompressed_size" ".\steamapps\common\XCOM 2\XComGame\Mods\X2CommunityHighlander\CookedPCConsole\XComGame.upk.uncompressed_size"
copy /Y ".\steamapps\common\XCOM 2 SDK\XComGame\Published\CookedPCConsole\XComGame.upk" ".\steamapps\common\XCOM 2 SDK\XComGame\Mods\X2CommunityHighlander\CookedPCConsole\XComGame.upk"
copy /Y ".\steamapps\common\XCOM 2 SDK\XComGame\Published\CookedPCConsole\XComGame.upk.uncompressed_size" ".\steamapps\common\XCOM 2 SDK\XComGame\Mods\X2CommunityHighlander\CookedPCConsole\XComGame.upk.uncompressed_size"
del ".\steamapps\common\XCOM 2\XComGame\Mods\X2CommunityHighlander\Script\XComGame.u"
del ".\steamapps\common\XCOM 2 SDK\XComGame\Mods\X2CommunityHighlander\Script\XComGame.u"
pause
