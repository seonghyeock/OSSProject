#!/bin/bash

echo "----------"
echo "User name : $(whoami)"
echo Student number : 12201804
echo "[ MENU ]"
echo "1. Get the data of the movie identified by a specific 'movie id' from 'u.item'"
echo "2. Get the data of ‘action’ genre movies from 'u.item’"
echo "3. Get the average 'rating’ of the movie identified by specific 'movie id' from 'u.data’"
echo "4. Delete the ‘IMDb URL’ from ‘u.item’"
echo "5. Get the data about users from 'u.user’"
echo "6. Modify the format of 'release date' in 'u.item’"
echo "7. Get the data of movies rated by a specific 'user id' from 'u.data'"
echo "8. Get the average 'rating' of movies rated byusers with 'age' between 20 and 29 and 'occupation' as 'programmer'"
echo "9. Exit"
echo "----------"

flag=0
until [ $flag -eq 9 ]
do
	read -p "Enter your choice [1-9] : " choice
	case $choice in
	1)
		read -p "Please enter the 'movie id’(1~1682) : " input
		cat u.item | awk -v id="$input" -F\| '$1 == id {print $0}'
		;;
	2)
		read -p "Do you want to get the data of ‘action’ genre movies from 'u.item’? (y/n) " yn
		if [ "$yn" = "n" ]
			then continue
		elif [ "$yn" = "y" ]
			then
				cat u.item | awk -F\| '$7 == "1"' | head -n 10 | awk -F\| '{print $1, $2}'
		fi
		;;
	3)
		read -p "Please enter the 'movie id’(1~1682) : " input
		sum=0
		cnt=0
		cat u.data | awk -v id="$input" '$2 == id {sum += $3; cnt++} END {printf("Average rating of %d : %.6g\n", id, sum/cnt)}'
		;;
	4)
	        read -p "Do you want to delete the ‘IMDb URL’ from ‘u.item’?(y/n) " yn
		if [ "$yn" = "n" ]
                        then continue
                elif [ "$yn" = "y" ]
			then 
				cat u.item | sed 's/http[^|]*|/|/g' | head -n 10
			fi
		;;
	5)
		read -p "Do you want to get the data about users from ‘u.user’?(y/n) " yn
		if [ "$yn" = "n" ]
                	then continue
                elif [ "$yn" = "y" ]
                        then
				cat u.user | head -n 10 | sed -E 's/F/female/g' | sed -E 's/M/male/g' | awk -F\| '{printf("user %d is %d years old %s %s\n", $1, $2, $3, $4)}'
		fi
		;;
	6)
		read -p "Do you want to Modify the format of ‘release data’ in ‘u.item’?(y/n) " yn
                if [ "$yn" = "n" ]
                        then continue
                elif [ "$yn" = "y" ]
                        then
				cat u.item | tail -n 10 | sed -E 's/([0-9]+)-Jan-([0-9]+)/\201\1/g; s/([0-9]+)-Feb-([0-9]+)/\202\1/g; s/([0-9]+)-Mar-([0-9]+)/\203\1/g; s/([0-9]+)-Apr-([0-9]+)/\204\1/g; s/([0-9]+)-May-([0-9]+)/\205\1/g; s/([0-9]+)-Jun-([0-9]+)/\206\1/g; s/([0-9]+)-Jul-([0-9]+)/\207\1/g; s/([0-9]+)-Aug-([0-9]+)/\208\1/g; s/([0-9]+)-Sep-([0-9]+)/\209\1/g; s/([0-9]+)-Oct-([0-9]+)/\210\1/g; s/([0-9]+)-Nov-([0-9]+)/\211\1/g; s/([0-9]+)-Dec-([0-9]+)/\212\1/g;'
		fi
		;;
	7)
		read -p "Please enter the ‘user id’(1~943) : " input
		data=$(cat u.data | awk -v id="$input" '$1 == id {print $2}' | sort -n)
		echo $data | sed 's/ /|/g'

		for id in $data
		do
			cat u.item | awk -v id="$id" -F\| '$1 == id {print $1"|"$2}'
		done | head -n 10
		;;
	8)
		read -p "Do you want to get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'?(y/n) " yn
                if [ "$yn" = "n" ]
                        then continue
                elif [ "$yn" = "y" ]
                        then
				target=$(cat u.user | awk -F\| '$4 == "programmer" && $2 >= 20 && $2 <= 29 {print $1}')
				list=$(for t in $target
				do
					cat u.data | awk -v t="$t" 't == $1 {print $2"_"$3}'
				done | sort -n)
				sum=0
				cnt=0
				prevMovie=$(echo $list | sed 's/_.*//')
				for i in $list
				do
					movie=$(echo $i | sed 's/_.*//')
					rate=$(echo $i | sed 's/.*_//')
					
					if [ "$prevMovie" = "$movie" ]
						then
							sum=$((sum + rate))
							cnt=$((cnt + 1))
					else
						if [ "$cnt" -ne 0 ]
						then
							echo $sum $cnt | awk -v movie="$prevMovie" '{printf("%d %.6g\n", movie, $1/$2)}'
						fi
						prevMovie="$movie"
						sum=$rate
						cnt=1
					fi
				done
				echo $sum $cnt | awk -v movie="$prevMovie" '{printf("%d %.6g\n", movie, $1/$2)}'
		fi
		;;
	9)
		echo "Bye!"
		flag=9
		;;
	esac
done
