REM 踏み台サーバのIPアドレス
Set FRONTSV=4.215.202.239

REM 踏み台サーバのID
Set FRONT-ID=azureuser

REM 踏み台サーバのポート
Set FRONT-PORT=22

REM プライベートキーへのフルパス
REM Set KEYPATH=C:\SPEC-SSH-KEYS\spec_id_rsa-m.pem
Set KEYPATH=%userprofile%\Documents\SPEC-SSH-KEYS\spec_id_rsa.pem

REM フォワード先のIPアドレス
Set FWDIP=10.100.1.6

REM ローカルポート（衝突や重複しないように注意）
Set LOCALPORT=39112

REM RDP接続先
Set SERVER=localhost

REM フォワード先のログインID
Set USERNAME=azureadmin
Set PASSWORD=#Password01!

REM 鍵ファイル確認
if not exist %userprofile%\Documents\SPEC-SSH-KEYS\spec_id_rsa.pem (
    xcopy /e /y C:\SPEC-SSH-KEYS\ %userprofile%\Documents\SPEC-SSH-KEYS\
)

start ssh -L %LOCALPORT%:%FWDIP%:3389 %FRONT-ID%@%FRONTSV% -o StrictHostKeyChecking=no -p %FRONT-PORT% -i %KEYPATH%

REM Timeout 5
REM ############################
REM #このリモートコンピュータの
REM #IDを識別できません。を回避
REM #レジストリ追加
REM ############################
reg add "HKEY_CURRENT_USER\Software\Microsoft\Terminal Server Client" /v AuthenticationLevelOverride /t REG_DWORD /d 0 /f
Cmdkey /generic:TERMSRV/%SERVER% /user:%USERNAME% /pass:%PASSWORD%
Timeout 2
start mstsc /w:1024 /h:768 /v:%SERVER%:%LOCALPORT%
Timeout 5
Cmdkey /delete:TERMSRV/%SERVER%
REM ############################
REM #このリモートコンピュータの
REM #IDを識別できません。を回避
REM #レジストリ削除
REM ############################
reg delete "HKEY_CURRENT_USER\Software\Microsoft\Terminal Server Client" /v AuthenticationLevelOverride /f