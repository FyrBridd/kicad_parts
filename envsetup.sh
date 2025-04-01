# define all of your libs here -- should be a CSV file for each lib
GPLMLIBS="discrete_diodes_rectifiers passives_capacitors_mlccs passives_capacitors_polymer_capacitors passives_resistors_film_resistors pmics_controllers_switching_controllers power_transformers_power_transformers power_transformers_pulse_transformers"

DBFILE=./database/parts.sqlite

parts_db_create() {
	for lib in ${GPLMLIBS}; do
		sqlite3 ${DBFILE} "DROP TABLE IF EXISTS ${lib}" || return 1
		sqlite3 --csv ${DBFILE} ".import ./database/g-${lib}.csv ${lib}" || return 1
	done
}

parts_db_watch() {
	echo "watching csv files for changes ..."
	while true; do
		FILE=$(inotifywait -q -e modify -e close_write --format '%w%f' ./database/)
		echo "csv file changed: $FILE"
		# debounce a bit as things might be moving around when libreofice is saving a file
		sleep 1
		if [[ $FILE == *.csv ]]; then
			#LIB=$(basename "${FILE%.*}")
			LIB=${FILE##*-}
			LIB=${LIB%%.*}
			echo "updating db: $LIB ..."
			sqlite3 ${DBFILE} "DROP TABLE IF EXISTS ${LIB}" || return 1
			sqlite3 --csv ${DBFILE} ".import ./database/g-${LIB}.csv ${LIB}" || return 1
		fi
	done
}

parts_db_edit() {
	sqlitebrowser ${DBFILE}
}
