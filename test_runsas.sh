#!/bin/bash
################################################################################
# File:    test_runsas
# Author:  Matt Nizol
# Purpose: Test cases for runsas script.
################################################################################

scriptdir=$(dirname "$(readlink -f "$0")")
testdir=${scriptdir}/test_data
script=${scriptdir}/runsas.sh

# Assertion methods
assert_equals ()
{
	test=$1
	actual=$2
	expected=$3
	
    if [ "$actual" != "$expected" ]; then
	    echo "$test failed"
		echo "Actual result: $actual"
		echo "Expected result: $expected"
		exit 1
	else
		echo "$test passed"
	fi
}

# Test 1: Missing argument
actual="$( $script )"
expected=$( printf "Please provide a valid SAS program to run.\nUsage: $script [PROGRAM]" )
assert_equals "test 1" "$actual" "$expected"

# Test 2: Non-existent argument
actual="$( $script does_not_exist.sas )"
expected=$( printf "Please provide a valid SAS program to run.\nUsage: $script [PROGRAM]" )
assert_equals "test 2" "$actual" "$expected"

# Test 3: Valid SAS program, clean log
actual="$( $script ${testdir}/test_valid_sas_program.sas )"
expected=$( printf "${testdir}/test_valid_sas_program.sas completed with exit code 0\nLog is clean" )
assert_equals "test 3" "$actual" "$expected"

# Test 4: Valid SAS program, non-zero return
actual="$( $script ${testdir}/test_set_syscc.sas )"
expected=$( printf "${testdir}/test_set_syscc.sas completed with exit code 1\nLog is clean" )
assert_equals "test 4" "$actual" "$expected"

# Test 5: User-generated errors and warnings
actual="$( $script ${testdir}/test_user_warnings.sas )"
expected=$( printf "${testdir}/test_user_warnings.sas completed with exit code 0\nLog issues:\nERROR: issue in the code.\nWARNING: another issue.\nNOTE: Missing values found.\nERROR: Errors printed on page 1." )
assert_equals "test 5" "$actual" "$expected"

# Test 6: User-generated error in a macro with MPRINT turned on
actual="$( $script ${testdir}/test_mprint_error.sas )"
expected=$( printf "${testdir}/test_mprint_error.sas completed with exit code 0\nLog issues:\nERROR: macro error.\nERROR: Errors printed on page 1." )
assert_equals "test 6" "$actual" "$expected"

# Test 7: Syntax error in the code [exit code will be 1]
actual="$( $script ${testdir}/test_syntax_error.sas )"
expected=$( printf "${testdir}/test_syntax_error.sas completed with exit code 2\nLog issues:\nERROR 180-322: Statement is not valid or it is used out of proper order.\nNOTE: The SAS System stopped processing this step because of errors.\nERROR: Errors printed on page 1." )
assert_equals "test 7" "$actual" "$expected"