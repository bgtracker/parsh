__revision='3.7.0 (22-APR-17)'
#Make me always be executed by BASH.
if [ "$(printf "%s"$BASH_VERSION)" = "" ]; then bash "$0"; fi;
_cur_lang=$LANG
export LANG=C
export TERM=xterm

__col_red='\e[31m'
__col_blue='\e[34m'
__col_orange='\e[33m'
__col_green='\e[32m'
__col_clear='\e[0m'

if [ -d ~/tmp ]; then results_path="$HOME/tmp"; else results_path="/tmp"; fi;

__destruct(){
	export LANG=$current_lang_var
	if [ -f "$0" ]; then rm -f "$0"; fi
	echo; exit 0
}

trap __destruct INT 20 EXIT

__NOTE(){
	echo -ne $__col_orange"$1"$__col_clear
}
__ERROR(){
	echo -ne $__col_red$1$__col_clear
}
__SUCCESS(){
	echo -ne $__col_green"$1"$__col_clear
}
__BLUE(){
	echo -ne $__col_blue$1$__col_clear
}

__prompt(){
	__NOTE "Press Enter to go back to Main menu\n"
	read a
	clear
	__main
}

__spinner(){ 
spin='-\|/'
while ps aux | grep -Eq "[b]eau|[F]unWeb"; do
	i=$(( (i+1) %4 ))
		printf "\r${spin:$i:1}"
		sleep .1
done
}

__wordpress.reset(){
	echo "This will try to determine the WP version, get the vanilla core files, make a TARGZ backup of wp-admin, wp-includes and wp-config.php, then overwrite them. Start? [y/n]"; read a
	if ! ls wp-includes/version.php 2>&1 > /dev/null; then __ERROR "I really can't do this. Either this isn't Wordpress or I can't fetch the version is question from their site.\n"; __prompt; fi
		actual_version=$(grep "^[$]wp_version" wp-includes/version.php  | grep -o "[0-9.]" | tr -d '\n'); 
	if wget -Nq --no-check-certificate http://wordpress.org/wordpress-$actual_version-no-content.zip;then
		tar czvf CORE_FILES_BACKUP$(date +%s).tar.gz wp-includes wp-admin wp-config.php .htaccess;
		rm -rf wp-admin wp-includes;
		unzip wordpress-$actual_version-no-content.zip;
		mv wordpress/* .;
		rm -rf wordpress wordpress-$actual_version-no-content.zip;
		cp -a wp-config.php wp-includes/js/jquery/suggest.txt;chmod 0755 wp-includes/js/jquery/suggest.txt
	else
		__ERROR "I really can't do this. Either this isn't Wordpress or I can't fetch the version is question from their site.\n"
	fi
	__prompt
}

__wordpress.work(){
	my_user=$(egrep "^define.*DB_" wp-config.php | grep USER | awk -F"'" '{print$4}')
	my_name=$(egrep "^define.*DB_" wp-config.php | grep NAME | awk -F"'" '{print$4}')
	my_pass=$(egrep "^define.*DB_" wp-config.php | grep PASS | awk -F"'" '{print$4}')
	my_host=$(egrep "^define.*DB_" wp-config.php | grep HOST | awk -F"'" '{print$4}')
	my_pref=$(egrep "^[$]table" wp-config.php | awk -F"'" '{print$2}')
	my_perms='a:1:{s:13:"administrator";s:1:"1";}'
	my_randpass=$(cat /dev/urandom | tr -dc "[:alnum:]" | head -c 12)
	case $1 in
		a) mysql -h "$my_host" -p"$my_pass" -u "$my_user" "$my_name" -e "INSERT INTO ${my_pref}users (ID, user_login, user_pass, user_nicename, user_email, user_url, user_registered, user_activation_key, user_status, display_name) VALUES ('12312399', 'support@', MD5('${my_randpass}'), 'support', 'test@yourdomain.com', 'http://www.paragon.net.uk/', '2011-06-07 00:00:00', '', '0', 'support'); INSERT INTO ${my_pref}usermeta (umeta_id, user_id, meta_key, meta_value) VALUES (NULL, '12312399', '${my_pref}capabilities', '${my_perms}'); INSERT INTO ${my_pref}usermeta (umeta_id, user_id, meta_key, meta_value) VALUES (NULL, '12312399', '${my_pref}user_level', '10')"
			echo "support@ / $my_randpass"
	;;
		d) mysql -h "$my_host" -p"$my_pass" -u "$my_user" "$my_name" -e "DELETE FROM ${my_pref}users WHERE ${my_pref}users.ID = 12312399; DELETE FROM ${my_pref}usermeta WHERE ${my_pref}usermeta.user_id = 12312399; DELETE FROM ${my_pref}usermeta WHERE ${my_pref}usermeta.user_id = 12312399;"
	;;
		o) mysqlcheck -h "$my_host" -r -p"$my_pass" -u "$my_user" "$my_name"; mysqlcheck -h "$my_host" -o -p"$my_pass" -u "$my_user" "$my_name"
	;;
		*) echo "Bad man, you are."
	;;
	esac
}

__joomla.work(){
	my_user=$(grep \$user configuration.php  | awk -F"'" '{print$2}')
	my_name=$(grep "\$db[^[:alnum:]]" configuration.php  | awk -F"'" '{print$2}')
	my_pass=$(grep \$pass configuration.php  | awk -F"'" '{print$2}')
	my_host=$(grep \$host configuration.php  | awk -F"'" '{print$2}')
	my_pref=$(grep \$dbprefix configuration.php  | awk -F"'" '{print$2}')
	my_randpass=`cat /dev/urandom | tr -dc "[:alnum:]" | head -c 12`
	case $1 in
		a) mysql -h "$my_host" -p"$my_pass" -u "$my_user" "$my_name" -e "INSERT INTO ${my_pref}users (id, name, username, email, password, block, sendEmail, registerDate, lastvisitDate, activation, params, lastResetTime, resetCount, otpKey, otep, requireReset) VALUES ('12312399', 'support@paragon.net.uk', 'support@paragon.net.uk', 'support@paragon.net.uk', MD5('${my_randpass}'), '0', '0', '2011-06-07 00:00:00', '2011-06-07 00:00:00', '', '', '0000-00-00 00:00:00', '0', '', '', '0'); INSERT INTO ${my_pref}user_usergroup_map (user_id, group_id) VALUES ('12312399', '8');"
			echo "support@paragon.net.uk / $my_randpass"
	;;
		d) mysql -h "$my_host" -p"$my_pass" -u "$my_user" "$my_name" -e "DELETE FROM ${my_pref}users WHERE ${my_pref}users.id = 12312399; DELETE FROM ${my_pref}user_usergroup_map WHERE ${my_pref}user_usergroup_map.user_id = 12312399;" 
	;;
		o) mysqlcheck -h "$my_host" -r -p"$my_pass" -u "$my_user" "$my_name"; mysqlcheck -h "$my_host" -o -p"$my_pass" -u "$my_user" "$my_name"
	;;
		*) echo "Bad man, you are."
	;;
	esac
}

__prestashop.work()
{
	my_user=$(grep _USER ./config/settings.inc.php  | awk -F"'" '{print$4}')
	my_name=$(grep _NAME ./config/settings.inc.php  | awk -F"'" '{print$4}')
	my_pass=$(grep _PASSWD ./config/settings.inc.php  | awk -F"'" '{print$4}')
	my_host=$(grep _SERVER ./config/settings.inc.php  | awk -F"'" '{print$4}')
	my_pref=$(grep _PREFIX ./config/settings.inc.php  | awk -F"'" '{print$4}')
	#Prestashop users a Cookie Key prefixed to the password, so $my_cook . newpass
	my_cook=$(grep _COOKIE_KEY ./config/settings.inc.php  | awk -F"'" '{print$4}')
	my_randpass=`cat /dev/urandom | tr -dc "[:alnum:]" | head -c 12`
	#users are kept in _employee
	case $1 in
		a) mysql -h "$my_host" -p"$my_pass" -u "$my_user" "$my_name" -e "INSERT INTO ${my_pref}employee (id_employee, id_profile, id_lang, lastname, firstname, email, passwd, last_passwd_gen, stats_date_from, stats_date_to, stats_compare_from, stats_compare_to, stats_compare_option, preselect_date_range, bo_color, bo_theme, bo_css, bo_width, bo_menu, active, optin, default_tab, id_last_order, id_last_customer_message, id_last_customer, last_connection_date) VALUES ('12312399', '1', '1', 'Support', 'Paragon', 'support@paragon.net.uk', MD5('${my_cook}${my_randpass}'), '2011-06-07 00:00:00', '0000-00-00', '0000-00-00', '0000-00-00', '0000-00-00', '1', '', '#ff586d', 'default', 'admin-theme.css', '0', '1', '1', '1', '3', '0', '0', '0', '0000-00-00'); INSERT INTO ${my_pref}employee_shop (id_employee, id_shop) VALUES ('12312399', '1')"
			echo -e "support@paragon.net.uk / $my_randpass \n\nAdmin URL is one of these:\n\n$(find -maxdepth 2 -name "password.php" 2> /dev/null | awk -F"/" '{print$2}')"
	;;
		d) mysql -h "$my_host" -p"$my_pass" -u "$my_user" "$my_name" -e "DELETE FROM ${my_pref}employee WHERE ${my_pref}employee.id_employee = 12312399; DELETE FROM ${my_pref}employee_shop WHERE ${my_pref}employee_shop.id_employee = 12312399;"
	;;
		o) mysqlcheck -h "$my_host" -r -p"$my_pass" -u "$my_user" "$my_name"; mysqlcheck -h "$my_host" -o -p"$my_pass" -u "$my_user" "$my_name"
	;;
		*) echo "Bad man, you are."
	;;
	esac
}

__detect_cms(){
	if [ -f ./wp-config.php ]; then 
		echo -n '__wordpress'
	elif [ -f ./configuration.php ]; then
		echo -n '__joomla'
	elif [ -f ./config/settings.inc.php ]; then
		echo '__prestashop'
	else
		echo "Don't know what this CMS is."; __prompt; __main
	fi
}

__quarantine(){
	while read line; do
		__ERROR "$line.infected\n"
		mv "$line" "$line.infected"
		chmod 000 "$line.infected"
	done < $results_path/report.tmp
	rm -f $results_path/results.tmp
	cp -a wp-config.php wp-includes/js/jquery/suggest.txt 2> /dev/null
	chmod 0755 wp-includes/js/jquery/suggest.txt 2> /dev/null
}

__quarantine.reverse(){
	echo "Look for quarantined everywhere or just recursively down current folder? [1/2]"
	read w
	case $w in
		1) targetPath=~;;
		2) targetPath=$(pwd);;
		*) __prompt;;
	esac
	find $targetPath -name "*.infected" -print0 | xargs -0 -I%% sh -c 'chmod 644 %%; mv %% "$(echo %% | sed 's/\.infected$//')"'
	cp -a wp-config.php wp-includes/js/jquery/suggest.txt 2> /dev/null
	chmod 0755 wp-includes/js/jquery/suggest.txt 2> /dev/null
	__prompt
}

__quarantine.report(){
	ls ~/*REPORT*
	__NOTE "Copy and paste report file from those above.\n"
	read a
	while read line; do mv $line $line.infected; chmod 000 $line.infected; done < $a
}

__phpscan (){
	rm -f $results_path/report.tmp
	if grep -q a /proc/cpuinfo 2> /dev/null;then _procnum=$(grep -c ^processor /proc/cpuinfo); else _procnum=4; fi
	__phpscan.injected(){
		#Injection scan excludes
		printf '%s\n' "${a_php_run1[@]}" | xargs -d '\n' -n10 -P $_procnum egrep -LZ "mandrill_events|json_decode.*[?].|TCPDF FONT FILE DESCRIPTION|extend.Drupal.settings|REXISTHEDOG4FBI|_fontawesome|fortawesome.github.io|__icl_lang_names|bulletproof-security|WPSEO_BASE|class RevSliderNavigation|SimpleThemeLogger extends SimpleLogger|vc_google_fonts|contact us at addons4prestashop|Adapted from Hyphenator|between you and Presta-Apps|function wp_cache_decr|case 'wc-about'|class ReduxFramework_|dtoken|DUPLICATOR_INIT|pluginbuddy|datastore=plugindata|\"id\":\"hebrew\",\"name\":\"Hebrew\"" | xargs -0 wc -L | awk 'BEGIN {OFS=ORS=""};{if($1>9069){for(i=2;i<NF;i++)print$i " "; print$NF"\n"}}' | sed -e '/total/d' -e '/^$/d' >> $results_path/results.tmp
		cp -a wp-config.php wp-includes/js/jquery/suggest.txt 2> /dev/null
		chmod 0755 wp-includes/js/jquery/suggest.txt 2> /dev/null
		clear
		if [ -f $results_path/results.tmp ] && [ "$(wc -l < $results_path/results.tmp)" -gt 0 ]; then
			sed -e 's/:/   ->   /g' -e 's/\.php$/\.php   ->   VERY LONG LINE/g' $results_path/results.tmp | sort -u -k1,1
			sed -e 's/:/   ->   /g' -e 's/\.php$/\.php   ->   VERY LONG LINE/g' $results_path/results.tmp | sort -u -k1,1 | awk -F'   ->' '{print$1}' >> $results_path/report.tmp
		else
			echo 'No hits' 
			__prompt
		fi
		__BLUE "\nHits: "
		wc -l < $results_path/report.tmp
		__NOTE "\nA lof of agents don't read this. "; __ERROR 'Do not just copy-paste this.\n\n';
		echo -n "Would you like to save the report? [y/n]"
		read a
		case $a in 
			y) TIME=$(stat -c %y $results_path/results.tmp | sed 's/\..*//' | tr " " "-");PWD="$(pwd | sed 's/\/home\///' | sed 's/\/var\/sites\/*.\///' | tr "/" "_")"_;NAME="-REPORT.txt";cp $results_path/report.tmp ~/`echo $PWD$TIME$NAME`;;
		esac
		__main
	}

	if [ -f $results_path/results.tmp ]
		then
			echo -e "Would you like to display your previous results from:\n$(stat -c %y $results_path/results.tmp)\nor start a new scan? [1/2]"
			echo -n "Opt: "
			read k
			case $k in
				1) clear; sed -e 's/:/   ->   /g' -e 's/\.php$/\.php   ->   VERY LONG LINE/g' $results_path/results.tmp | sort -u -k1,1;;
				2) rm -f $results_path/results.tmp; clear;;
				*) __ERROR "Wrong entry\n"; __prompt; __main;;
			esac
	fi

	#IFS set, needed for all arrays
	IFS=$'\n\t'
	__BLUE "Working:\n"
	echo -n "  Applying whitelist on... "
	#__spinner&
	a_source=($(find . -type f -name "*.php"))
	__BLUE "(${#a_source[@]})\n"

	a_php_run1=($(printf '%s\n' "${a_source[@]}" | xargs -n10 -P $_procnum -d '\n' grep -rLE "beau_do_shortcode|\@(since|package) |mozilla.org.MPL|function.ewww_image|michael.d.simpson|header\(...protocol.304|for CSSTidy|sanitize_text_field|TCPDF FONT FILE DESCRIPTION|extend.Drupal.settings|extension_loaded..ionCube Loader|Maintained by David Saez|icl_import_xml|WPML_Disqus_Integration|from script by Valentin Schmidt|cannot be embedded in mPDF|the entire function consists of only|Author:\s*Ian Back|CJKfollowing =|Mage_Core_Model_Resource_Setup|CIDR\sformat:\s*1.2.3|If you like phpThumb|('your_version' => 'Your Version',)|# author Roland Soos|The Original Code is lib_zip.php|language file for GeSHi|WORDPRESS DOWNLOAD MONITOR|Olivier PLATHEY|header\('Content-Type: application/pdf'\)|have no libs|wfConfig::|self::|require_once|public static|public function|duplicator|DUPLICATOR_|dtoken\.php|phpconcept|dUnzip2|class zipfile|Installatron|getID3|podPress|IMPORTBUDDY|[']AolVersion[']| extends "))

	if [ -z ${#a_php_run1[@]} ];then
		echo 'No hits'
		__prompt
	fi

	echo -n "  Collecting malicious functionality on... "
	__BLUE "(${#a_php_run1[@]})\n"

printf '%s\n' "${a_php_run1[@]}" | xargs -n10 -P $_procnum -d '\n' grep -E -m1 -o "hacked by|base64_decode\(.*[?][>]|[A-Z][\x0-9]{4}{2,}[A-Z]{2,}|=[$]\GLOBALS;[$][{].|\;\@assert\([$]\cacheconf\(|=.I_have_problem_with|..chr\(101\)..|=.leafmailer.pw.| FILTER_FLAG_NO_RES_RANGE\)\ !== FALSE\)|php eval\(eval\(.|foreach \([$]\GLOBALS\[[$]\GLOBALS\[|coolin.in|;[$]\GLOBALS\[|sh_decrypt_phase|[$]\www= [$]\_POST|substr\(md5\(strrev|@assert\(base64_decode\([$]\_REQUEST\[.array.]|= .\)..chr\(|[$]\OOO000000=urldecode\(|[$]\O00OO0=urldecode\(.|[$]\_F=__FILE__;[$]|php @?eval\([$]\_POST|script>.*setCookie|=._COOKIE;|ntlm_sasl_client.php|b[^[:alnum:]]*a[^[:alnum:]]*s[^[:alnum:]]*e[^[:alnum:]]*6[^[:alnum:]]*4[^[:alnum:]]*_[^[:alnum:]]*d[^[:alnum:]]*e[^[:alnum:]]*c[^[:alnum:]]*o[^[:alnum:]]*d[^[:alnum:]]*e\s*[^(]|([A-Z][a-z][B-DF-HJ-NP-TV-Z]+([b-df-hj-np-tv-z]|[0-9]+)+\()|[Aa]rmy|[Nn]oo[Bb]|[$][[:alnum:]]* ?= ?([$][[:alnum:]]*\[[0-9]\] ?\. ?){6,}|isset\([$][{][$]...[}]|@ini_set..display_errors.,0.|Array\('.'=[>]'.'[,]|[$][[:alnum:]]=[']|[$]__[+-]|[$][[:print:]]\[\]=|echo perms\(|[$]_=|@php_uname|[[:punct:]][[:alnum:]][\].php|gz(un)?compress|base_convert|SELECT user_login|Texlon-Version|FunWebProducts" /dev/null | awk -F: '{printf"%s:%s\n",$1, substr($2,0,50)}' >> $results_path/results.tmp
	
	__phpscan.injected
}
__main(){
		__BLUE "	PARWP $__revision\n"
echo -ne "$(__BLUE '1)') Run scan $(__BLUE '2)') Quarantine $(__BLUE '3)') Quarantine from report
$(__BLUE '4)') Wordpress reset on Steroids! (Run me in document root)
$(__BLUE '5)') Default File Permissions (Recursive)
$(__BLUE '6)') Add/Remove Admin User (Wordpress/Joomla/Prestashop)
$(__BLUE '7)') Cannot modify header... or Cookies are blocked due to... Fix
$(__BLUE '8)') 
$(__BLUE '9)') Hit Ctrl+C or Ctrl+Z to Exit and Purge
$(__BLUE '10)') Repair and Optimize current database (Run me in document root)
$(__BLUE '20)') Restore .infected files
$(__BLUE '21)') Cure first-line injections (BETA)

Opt: "
		read a
		case $a in
		1) printf "\033c"; __phpscan; __prompt;;
		
		2) __quarantine;__SUCCESS "Done\n"; __prompt;;

#		3) cure_files;printf "\033[38;5;82mFiles with injected code cured successfully.\033[0m"; __prompt;;

		3) __quarantine.report;__SUCCESS "Done\n"; __prompt;;

		4) __wordpress.reset;;

		5) find . -type d -exec chmod 755 {} \;; find . -type f -exec chmod 644 {} \;; __SUCCESS "Done\n"; __prompt;;	

#		6) htaccess_prevent_php;__SUCCESS "Done\n"; __prompt;;

		6) echo -n "I must be in site's document root! Wanna add or delete? [a/d] "; read a; case $a in a) $(__detect_cms).work a;; d) $(__detect_cms).work d;; *) echo "I did nothing.";; esac; __SUCCESS "Done\n"; __prompt;;

#		7) makegzip; clear; __SUCCESS "Done\n"; __prompt;;

		7) egrep --include="*.php" -rlZ -m 1 "^ *<\?" . | xargs -0 sed -i -e "s/^ *<?php/<?php/1"; __prompt;;

		8) __SUCCESS "Done\n"; __prompt;;

		9) __destruct;;

		10) $(__detect_cms).work o; __prompt;;

		20) __quarantine.reverse;;

		21) egrep --include="*.php" -m 1 -rlZ "^<\?php..*" | xargs -0 sed -i '1 s/^<?php..*$/<?php/g'; __prompt;;

		*) echo -e $__col_red"Wrong command."$__col_clear; __prompt;;
	esac
}
clear
__main
