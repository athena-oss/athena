#!/bin/bash

# script to index cli function
source ../bin/lib/shared/functions.color.sh

if [ $# -lt 1 ] ; then
	echo
	cat << EOF
usage: $0 <option>	Option can be either 1 for MarkDown or 0 for cli.

EOF
	exit 1
fi
md=${1:-0}
md_buffer=()

function list()
{
	for file in `find $1 -type f -name "functions.*.sh" -d 1`
	do
		if [ "$md" == "0" ]; then 
			athena.color.print_color "green" "$file"
	else
		ctx=$(echo "$file" | sed -n -e "s#.*functions\.\(.*\)\.sh#\1#p")
		md_buffer+=(" ")
		md_buffer+=("### Handling *$ctx*")
	fi
		list_functions $file		
	done
}

function list_description()
{
        reverse=$(tail -r $1)
        func_name="$2"
        IFSOLD=$IFS
        IFS=$'\n'
        found=0
        desc=()
        for l in ${reverse[@]}; do
                if [ "$func_name" == "$l" ] ;then
                        found=1
                elif [ "$found" -eq "1" ]; then
                        if [ "$(echo $l | cut -c1-1)" == "#" ]; then
                                desc+=($l)
                        else
                                found=0
                        fi
                fi
        done
        if [ ! -z "$desc" ]; then
		desc_str=""
                for ((i=${#desc[@]}-1; i>=0; i--)); do
			if [ "$md" == "0" ]; then 
				athena.color.print_color "red" "    $3     ${desc[$i]}"
			else # generate markdown output
				mk_desc=$(echo "${desc[$i]}" | cut -c 3-)
				if $(echo $mk_desc | grep -q "USAGE:"); then
					# search for `athena.` or `$` and add backticks
					if [ "$desc_str" != "" ]; then
						md_buffer+=(" ")
						desc_str=$(echo "$desc_str" | sed 's/  */ /g')
						md_buffer+=("$desc_str")
					fi
					sub_str=$(echo "$mk_desc" | tr -s ' '| sed 's#USAGE: ##g')
					mk_desc="**USAGE:**  \`$sub_str\`" 
					md_buffer+=(" ")
					md_buffer+=("$mk_desc")
				elif $(echo $mk_desc | grep -q "RETURN:"); then
					sub_str=$(echo "$mk_desc" | tr -s ' '| sed 's#RETURN: ##g')
					mk_desc="**RETURN:** \`$sub_str\`"
					md_buffer+=(" ")
					md_buffer+=("$mk_desc")
				else
					[ -z $desc_str ] && desc_str="$mk_desc" || desc_str="$desc_str $mk_desc" 
				fi
			fi
                done
        fi
        IFS=$IFSOLD
	if [ "$md" == "0" ]; then 
		athena.color.print_color "red" "    $3"
        fi

}

function list_functions()
{
	max_cnt=$(grep -R "function athena." $1 | sort -u | wc | awk '{ print $1 }')
	cnt=1
        IFSOLD=$IFS
        IFS=$'\n'
	for line in $(grep $1 -e "function athena." | sort -u)
	do
		name=$(echo $line | awk '{print $2}' | sed "s#(##g" | sed "s#)##g")
		# exclude internal functions (not to be used directly)
		# functions that start with underscore (excluding namespace)
		# e.g.: athena._pop_args
		if [[ "$name" != *"._"* ]]; then
			if [ "$md" == "0" ]; then 
				athena.color.print_color "cyan" "    |---- $name"
			else
				md_buffer+=(" ")
				md_buffer+=("#### \`$name\`")
			fi
			if [ "$cnt" -eq "$max_cnt" ]; then
				list_description "$1" "$line" " "
			else
				list_description "$1" "$line" "|"
			fi
		fi
		((cnt++))
	done
        IFS=$IFSOLD
}

function print_markdown()
{
        IFSOLD=$IFS
        IFS=$'\n'

	table_of_content=()
	cnt=0
        for l in ${md_buffer[@]}; do
                if [ "$(echo $l | cut -c1-1)" == "#" ]; then
			hash_cnt=$(echo $l | tr -d -c '#' | awk '{ print length; }')
			header=$(echo "$l" | cut -c $(expr $hash_cnt + 2)-)
			header_link=$(echo "$header" | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g' | sed 's/\*//g' | sed 's/`//g' | sed 's/\.//g' | sed 's/_//g')
			hira_str=""
			hash_str=""
			for i in `seq 1 $hash_cnt`;
        		do
				hira_str="  $hira_str"
				hash_str="#$hash_str"
        		done
			hira_str=$(echo "$hira_str" | cut -c 3-)
			table_of_content+=("$hira_str* [$header](#$header_link)")
			if $(echo "$header" | grep '_' -q) || $(echo "$header" | grep '\.' -q) ; then
				md_buffer[$cnt]="$hash_str <a name=\"$header_link\"></a>$header"
			fi 
		fi
		((cnt++))
	done
	
	# print table of content
        for l in ${table_of_content[@]}; do
		echo "$l"
	done
	echo

	# print document
        for l in ${md_buffer[@]}; do
		echo "$l"
	done
        IFS=$IFSOLD
}

if [ "$md" == "0" ]; then 
	echo
	athena.color.print_color "normal" "SHARED"
	athena.color.print_color "normal" "------"
else
	md_buffer+=("# Using CLI Functions")
	md_buffer+=(" ")
	md_buffer+=("## Shared Functions")
	md_buffer+=(" ")
	md_buffer+=("Function which are available in the host and container.")
fi
list "../bin/lib/shared"

if [ "$md" == "0" ]; then 
	athena.color.print_color "normal" "HOST ONLY"
	athena.color.print_color "normal" "---------"
else
	md_buffer+=(" ")
	md_buffer+=("## Host Functions")
	md_buffer+=(" ")
	md_buffer+=("Function which are available only in the host.")
fi
list "../bin/lib"

print_markdown
