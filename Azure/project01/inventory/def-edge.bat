REM 踏み台サーバのIPアドレス
Set FRONTSV=AABBCC
 
REM 踏み台サーバのID
Set FRONT-ID=azureuser
 
REM 踏み台サーバのポート
Set FRONT-PORT=22
 
REM プライベートキーへのフルパス
REM Set KEYPATH=C:\SPEC-SSH-KEYS\spec_id_rsa-m.pem
Set KEYPATH=%userprofile%\Documents\SPEC-SSH-KEYS\spec_id_rsa.pem
 
REM フォワード先のIPアドレス
Set FWDIP=localhost
 
REM ローカルポート（衝突や重複しないように注意）
Set LOCALPORT=443
 
REM RDP接続先
Set SERVER=localhost
 
REM 鍵ファイル確認
if not exist %userprofile%\Documents\SPEC-SSH-KEYS\spec_id_rsa.pem (
    xcopy /e /y C:\SPEC-SSH-KEYS\ %userprofile%\Documents\SPEC-SSH-KEYS\
)
 
start ssh -L %LOCALPORT%:%FWDIP%:8443 %FRONT-ID%@%FRONTSV% -o StrictHostKeyChecking=no -p %FRONT-PORT% -i %KEYPATH%
start "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" https://%SERVER%:%LOCALPORT%