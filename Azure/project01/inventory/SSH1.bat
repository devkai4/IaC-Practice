REM 踏み台サーバのIPアドレス
Set FRONTSV=4.215.202.239
REM 踏み台サーバのID
Set FRONT-ID=azureuser
REM 踏み台サーバのポート
Set FRONT-PORT=22
REM 鍵ファイル確認
if not exist %userprofile%\Documents\SPEC-SSH-KEYS\spec_id_rsa.pem (
  xcopy /e /y C:\SPEC-SSH-KEYS\ %userprofile%\Documents\SPEC-SSH-KEYS\
)
REM プライベートキーへのフルパス
Set KEYPATH=%userprofile%\Documents\SPEC-SSH-KEYS\spec_id_rsa.pem
REM フォワード先のIPアドレス
Set FWDIP=10.100.1.5
REM ローカルポート（衝突や重複しないように注意）
Set LOCALPORT=49111
REM 接続先
Set SERVER=localhost
start ssh -L %LOCALPORT%:%FWDIP%:22 %FRONT-ID%@%FRONTSV% -o StrictHostKeyChecking=no -p %FRONT-PORT% -i %KEYPATH%
start ssh azureuser@localhost -p %LOCALPORT% -i %KEYPATH% -o StrictHostKeyChecking=no
