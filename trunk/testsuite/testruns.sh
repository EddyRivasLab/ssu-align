################################################
# Process command-line
################################################
do1="0"
do2="0"
do3="0"
do4="0"
do5="0"
do6="0"
do7="0"
do8="0"
do9="0"
do10="0"

if [[ $# == 0 ]]; then
    do1="1"
    do2="1"
    do3="1"
    do4="1"
    do5="1"
    do6="1"
    do7="1"
    do8="1"
    do9="1"
    do10="1"
fi

for EL in $@
do
    if [[ $EL -eq "1" ]]; then
	do1="1"
    elif [[ $EL -eq "2" ]]; then
	do2="1"
    elif [[ $EL -eq "3" ]]; then
	do3="1"
    elif [[ $EL -eq "4" ]]; then
	do4="1"
    elif [[ $EL -eq "5" ]]; then
	do5="1"
    elif [[ $EL -eq "6" ]]; then
	do6="1"
    elif [[ $EL -eq "7" ]]; then
	do7="1"
    elif [[ $EL -eq "8" ]]; then
	do8="1"
    elif [[ $EL -eq "9" ]]; then
	do9="1"
    elif [[ $EL -eq "10" ]]; then
	do10="1"
    fi
done

################################################
# Functions
################################################
check_return_status()
{
    if [[ $? -ne 0 ]]; then 
	exit 1
    fi
    return
}

check_file_exists()
{
    if [ ! -f $1 ]; then
	echo "ERROR, file $1 does not exist."
	exit 1
    fi
    return
}

concatenate_files()
{
    NEWFILE=$1
    FILE1=$2
    check_file_exists $2
    cat $FILE1 > $NEWFILE
    shift; shift;
    for FILE in $@
    do
	check_file_exists $FILE
	cat $FILE >> $NEWFILE
    done
    return
}

################################################
# test 1
################################################
if [[ $do1 -eq "1" ]]; then
    echo "Performing test 1 ..."
    ssu-align -F seed-4.fa test1 > /dev/null
    check_return_status
    ssu-mask test1 > /dev/null
    check_return_status
    ssu-mask --stk2afa --key-out b test1 > /dev/null
    check_return_status
    ssu-draw test1 > /dev/null
    check_return_status
    concatenate_files test1.sum test1/test1.ssu-align.sum test1/test1.ssu-mask.sum test1/test1.b.ssu-mask.sum test1/test1.ssu-draw.sum 
    concatenate_files test1.log test1/test1.ssu-align.log test1/test1.ssu-mask.log test1/test1.b.ssu-mask.log test1/test1.ssu-draw.log 
    echo " complete. Examine test1.sum, test1.log"
fi
################################################


################################################
# test 2
################################################
if [[ $do2 -eq "1" ]]; then
    echo "Performing test 2 ..."
    ssu-align -F --aln-one archaea seed-4.fa test2 > /dev/null
    check_return_status
    concatenate_files test2.sum test2/test2.ssu-align.sum
    concatenate_files test2.log test2/test2.ssu-align.log
    echo " complete. Examine test2.sum, test2.log"
fi
################################################


################################################
# test 3
################################################
if [[ $do3 -eq "1" ]]; then
    echo "Performing test 3 ..."
    ssu-build -F -d archaea --trunc 40-500 > /dev/null
    check_return_status
    ssu-align -F -m archaea-0p1-sb.40-500.cm seed-4.fa test3 > /dev/null
    check_return_status
    ssu-mask -m archaea-0p1-sb.40-500.cm test3 > /dev/null
    check_return_status
    concatenate_files test3.sum archaea-0p1-sb.40-500.ssu-build.sum test3/test3.ssu-align.sum test3/test3.ssu-mask.sum 
    concatenate_files test3.log archaea-0p1-sb.40-500.ssu-build.log test3/test3.ssu-align.log test3/test3.ssu-mask.log 
    echo " complete [Examine test3.sum, test3.log]"
fi
################################################

################################################
# test 4
################################################
if [[ $do4 -eq "1" ]]; then
    echo "Performing test 4 ..."
    ssu-align --FF --prep-n 4 seed-15.fa test4 > /dev/null
    check_return_status
    cd test4; sh test4.sh > /dev/null
    check_return_status
    cd ../;   ssu-merge test4 > /dev/null
    check_return_status 
    ssu-mask test4 > /dev/null
    check_return_status 
    ssu-draw test4 > /dev/null
    check_return_status
    concatenate_files test4.sum test4/test4.ssu-align.prep.sum test4/test4.ssu-align.sum test4/test4.ssu-mask.sum test4/test4.ssu-draw.sum
    concatenate_files test4.log test4/test4.ssu-align.prep.log test4/test4.ssu-align.log test4/test4.ssu-mask.log test4/test4.ssu-draw.log
    echo " complete [Examine test4.sum, test4.log]"
fi
################################################


################################################
# Following tests use very small model, so they
# will run faster.
################################################


################################################
# test 6
################################################
if [[ $do6 -eq "1" ]]; then
    echo "Performing test 6 ..."
    ssu-build -F -d archaea --trunc 822-930 > /dev/null
    check_return_status
    ssu-align -F -m archaea-0p1-sb.822-930.cm seed-15.fa test6 > /dev/null
    check_return_status
    ssu-mask -m archaea-0p1-sb.822-930.cm --key-out 6 test6 > /dev/null
    check_return_status
    concatenate_files test6.sum archaea-0p1-sb.822-930.ssu-build.sum test6/test6.ssu-align.sum test6/test6.6.ssu-mask.sum
    concatenate_files test6.log archaea-0p1-sb.822-930.ssu-build.log test6/test6.ssu-build.sum test6/test6.ssu-align.log test6/test6.6.ssu-mask.log
    echo " complete [Examine test6.sum, test6.log]"
fi
################################################


################################################
# test 7
################################################
if [[ $do7 -eq "1" ]]; then
    echo "Performing test 7 ..."
    ssu-build -F -d archaea --trunc 822-930 > /dev/null
    check_return_status
    ssu-align -F -m archaea-0p1-sb.822-930.cm -1 --filter 0.95 -b 20 -l 30 seed-15.fa test7 > /dev/null
    check_return_status
    ssu-mask -a test7/test7.archaea-0p1-sb.822-930.stk > /dev/null
    check_return_status
    ssu-mask -m archaea-0p1-sb.822-930.cm test7 > /dev/null
    check_return_status
    ssu-mask --stk2afa -a test7/test7.archaea-0p1-sb.822-930.stk > /dev/null
    check_return_status
    ssu-mask --stk2afa -m archaea-0p1-sb.822-930.cm test7 > /dev/null
    check_return_status
    concatenate_files test7.sum archaea-0p1-sb.822-930.ssu-build.sum test7/test7.ssu-align.sum test7.archaea-0p1-sb.822-930.ssu-mask.sum test7/test7.ssu-mask.sum
    concatenate_files test7.log archaea-0p1-sb.822-930.ssu-build.sum test7/test7.ssu-align.log test7.archaea-0p1-sb.822-930.ssu-mask.log test7/test7.ssu-mask.log
    echo " complete [Examine test7.sum, test7.log]"
fi
################################################


