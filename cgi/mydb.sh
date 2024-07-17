#!/bin/bash

echo "Content-type: text/html"
echo ""
echo '<html>'
echo ' <head><meta charset="utf-8" /> </head>'
echo '<body>'

# MySQL Server Connection test
[ ! -f /opt/www/cgi/dagger.ini ] && echo "<h1><center>pls setup first !  <a href="/setup">setup</a></p></center></h1>" && exit 0
source "/opt/www/cgi/dagger.ini"
if ! mysql --connect-timeout=1 -u "$DB_user" -h "$DB_ip" -p"$DB_passwd" -e "show databases;" &>/dev/null; then
  echo '<h1><center>MySQL Cluster connection <font color="red">failed</font> !
  <p>pls Setup again, thx!
  <a href="/setup">setup</a></p></center></h1>' && exit 0
fi

# var
HTML=$(echo ${QUERY_STRING%=*} | cut -d "=" -f 1)
Action=$(echo $QUERY_STRING | cut -d '=' -f3 | cut -d '+' -f1)
ALL_COMMAND=$(echo $REQUEST_URI | cut -d '=' -f3 | sed 's/+/ /g' | sed 's/%28/(/g' | sed 's/%29/)/g' | sed 's/%2C/,/g' | sed 's/%3B/;/g' | sed "s/%27/'/g" | sed 's/%22/"/g' | sed 's/%3D/=/g' | sed 's/%0D%0A/ /g')
ALL_COMMAND_tbl=${ALL_COMMAND%%&*}
Action_tbl=${QUERY_STRING##*=}
tbl=$(mysql -u "$DB_user" -h "$DB_ip" -p"$DB_passwd" -e "use $DB_name;$ALL_COMMAND_tbl")
tbl_name=$(echo ${QUERY_STRING%&*} | cut -d "=" -f 3)

# Debug
#echo "<br>REQUEST_URI=${REQUEST_URI}</br>"
#echo "<br>QUERY_STRING=${QUERY_STRING}</br>"
#echo "<br>DBname=$DB_name</br>"
#echo "<br>HTML=$HTML</br>"
#echo "<br>Action=$Action</br>"
#echo "<br>Action_tbl=$Action_tbl</br>"
#echo "<br>ALL_COMMAND=${ALL_COMMAND}</br>"
#echo "<br>ALL_COMMAND_tbl=${ALL_COMMAND_tbl}</br>"
#echo "<br>tbl_name=$tbl_name</br>"

# function
DB_list() {
  set -f # disable globbing
  saveIFS=$IFS
  IFS=$'\n' # set field separator to NL (only)
  ALL_DB=$(mysql -u "$DB_user" -h "$DB_ip" -p"$DB_passwd" -e "show databases;")
  cat /dev/null >/opt/www/cgi/db.txt
  for i in ${ALL_DB[@]}; do
    if [ "$i" != "Database" ]; then
      echo "        <option>$i</option>" >>/opt/www/cgi/db.txt
    else
      echo "        <option>請選擇資料庫名稱</option>" >>/opt/www/cgi/db.txt
    fi
  done
  IFS=$saveIFS
  set +f
  sed -i "/<option>/d" /opt/www/html/tbl.html
  line=$(cat /opt/www/html/tbl.html | grep -n 'select type' | cut -d ":" -f 1)
  sed -i "${line} r /opt/www/cgi/db.txt" /opt/www/html/tbl.html
}

tbl_action() {
  mysql --show-warnings -u "$DB_user" -h "$DB_ip" -p"$DB_passwd" -e "use $DB_name;$ALL_COMMAND_tbl" >/tmp/out.txt
  if cat /tmp/out.txt | grep 'Error' &>/dev/null; then
    show
  else
    cat /tmp/out.txt && echo -e "<h1 style="color:blue">\nCommand success</h1>"
  fi
}

show() {
  echo "<pre>"
  echo "<font size="6">"
  cat /tmp/out.txt
  echo "</pre>"
  echo "</font>"
}

show_db() {
  echo "<pre>"
  echo "<font size="6">"
  cat /tmp/dbout.txt
  echo "</pre>"
  echo "</font>"
}

DB_list
if [[ "$HTML" == "tblname" ]]; then
  DB_name=$(echo ${QUERY_STRING%%&*} | cut -d "=" -f 2)
  case ${Action_tbl} in
  DROP)
    if ! echo "$ALL_COMMAND_tbl" | grep 'drop'; then
      if mysql -u "$DB_user" -h "$DB_ip" -p"$DB_passwd" -e "use ${DB_name}; DROP TABLE ${tbl_name}"; then
        echo -e "<h1 style="color:blue">\nCommand success</h1>"
      else
        echo -e "<h1 style="color:red">\nCommand fail</h1>"
      fi
    else
      tbl_action && show
    fi
    ;;
  *)
    tbl_action && show
    ;;
  esac
  echo '<h1><center><a href="../html/tbl.html">返回上一頁</a></center></h1>'
else
  if [[ $Action == "SHOW" ]]; then
    mysql -u "$DB_user" -h "$DB_ip" -p"$DB_passwd" -e "SHOW DATABASES" >/tmp/dbout.txt && show_db
  else
    DB_name=$(echo ${QUERY_STRING%%&*} | cut -d "=" -f 2)
    mysql --show-warnings -u "$DB_user" -h "$DB_ip" -p"$DB_passwd" -e "${Action} DATABASE ${DB_name}" >/tmp/dbout.txt
    if ! cat /tmp/dbout.txt | grep 'Error'; then
      mysql -u "$DB_user" -h "$DB_ip" -p"$DB_passwd" -e "SHOW DATABASES" >/tmp/dbout.txt && show_db && DB_list
    else
      show_db && DB_list
    fi
  fi
fi

echo '</body></html>'
exit 0


