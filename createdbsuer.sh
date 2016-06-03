#!/bin/bash

    if [ "$MYSQL_PASS" = "**Random**" ]; then
        unset MYSQL_PASS
    fi

    PASS=${MYSQL_PASS:-$(pwgen -s 12 1)}
    _word=$( [ ${MYSQL_PASS} ] && echo "preset" || echo "random" )
    echo "=> Creating MySQL user ${MYSQL_USER} with ${_word} password"

    mysql -uroot -e "CREATE DATABASE IF NOT EXISTS db_web"
    mysql -uroot -e "CREATE USER '${MYSQL_USER}'@'localhost' IDENTIFIED BY '$PASS'"
    mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO '${MYSQL_USER}'@'localhost' WITH GRANT OPTION"
    echo "=> Done!"
    echo "========================================================================"
    echo "You can now connect to this MySQL Server using:"
    echo ""
    echo "    mysql -u$MYSQL_USER -p$PASS -h<host> -P<port>"
    echo ""
    echo "Please remember to change the above password as soon as possible!"
    echo "MySQL user 'root' has no password but only allows local connections"
    echo "========================================================================"
