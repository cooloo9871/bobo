#!/bin/bash
echo "Content-type: text/html"
echo ""
echo '<html>'
echo ' <head><meta charset="utf-8" /> </head>'
echo '
  <style>
  <body>
#div {border-style: solid;}
  
#action{  
  width: 200px;
  background-color: #f9e8d3;
  padding: 12px 20px;
  margin: 8px 10;
  display: inline-block;
  border: 2px solid #008CBA;
  border-radius: 4px;
  box-sizing: border-box;
  overflow-x:visible;overflow-y:visible;
}

#b1{
  border: none;
  color: black;
  border: 2px solid #008CBA;
  border-radius: 10px;
  padding: 8px 16px;
  text-align: center;
  text-decoration: none;
  display: inline-block;
  font-size: 22px;
  margin: 4px 2px;
  transition-duration: 0.4s;
  cursor: pointer; 
  margin-left: 30px;
  display: inline-block;
 
}
  #lb{display: inline-block;
  width: 200px}
  
  </style>
  
    <form action="../html/dbhome.html">
        <input type="submit" id=b1 value="返回上一頁" />
    </form>
  
    <form action="/setup">
      <fieldset style="background: #eeeff0; border: 2px solid blue;">
      <label for="action" id="lb"><b>MySQL_Server_IP :</b></label>
      <input required type="text" id="action" rows="4" cols="80" name="MySQL_Server_IP" value="" placeholder="請輸入MySQL Server 的 IP"></input><br><br>
      <label for="action" id="lb"><b>MySQL_Database :</b></label>
      <input required type="text" id="action" rows="4" cols="80" name="MySQL_Database" value="" placeholder="請輸入資料庫名稱"></input><br><br>
      <label for="action" id="lb"><b>MySQL_User :</b></label>
      <input required type="text" id="action" rows="4" cols="80" name="MySQL_User" value="" placeholder="請輸入帳號"></input><br><br>
      <label for="action" id="lb"><b>MySQL_User_Password :</b></label>
      <input required type="password" id="action" rows="4" cols="80" name="MySQL_User_password" value="" placeholder="請輸入密碼"></input><br><br>
      <input type="submit" id=b1 value="SUBMIT">
      </fieldset>
    </form>'


IFS='&'
set -- $QUERY_STRING
#echo ${1#*=},${2#*=},${3#*=},${4#*=}
MySQL_Server_IP=${1#*=}
MySQL_Database=${2#*=}
MySQL_User=${3#*=}
MySQL_User_password=${4#*=}

if [[ $MySQL_Server_IP != "" ]]; then
  tee /opt/www/cgi/dagger.ini<<EOF 1>/dev/null
export DB_ip="${1#*=}"
export DB_name="${2#*=}"
export DB_user="${3#*=}"
export DB_passwd="${4#*=}"
EOF
else
  rm /opt/www/cgi/dagger.ini &>/dev/null
fi

echo '</body></html>'
exit 0 
