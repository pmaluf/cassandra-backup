#!/bin/bash
#
# cassandra-backup.sh
# Created: Paulo Victor Maluf - 09/2015
#
# Parameters:
#
#   cassandra-backup.sh --help
#
#    Parameter           Short Description                                                        Default
#    ------------------- ----- ------------------------------------------------------------------ -------------------
#    --username             -u [OPTIONAL] Cassandra username                                      cassandra
#    --password             -p [OPTIONAL] Cassandra password                                      ******
#    --host                 -H [OPTIONAL] Cassandra hostname                                      ${HOSTNAME}
#    --help                 -h [OPTIONAL] help
#
#   Ex.: cassandra-backup.sh --username cassandra --password mypass
#
# Changelog:
#
# Date       Author               Description
# ---------- ------------------- ----------------------------------------------------
#====================================================================================

################################
# VARIABLE DECLARATION         #
################################
CASSANDRA_HOST=`hostname`
CASSANDRA_USER="cassandra"
CASSANDRA_PASS="cassandra"

################################
# GLOBAL VARIABLES             #
################################
SCRIPT_DIR=`pwd`
SCRIPT_NAME=$(basename `echo $0`)
SCRIPT_LOGDIR="${SCRIPT_DIR}/logs"
LOGFILE=${SCRIPT_NAME}.log
NODETOOL=`which nodetool`
MAIL_LST="dba@domain"

################################
# FUNCTIONS                    #
################################
help()
{
  head -21 $0 | tail -19
  exit
}

send_email(){
mail -s "[Cassandra Backup] ${HOSTNAME}" ${MAIL_LST} <<EOF
${1}
EOF
}

log (){
 if [ "$2." == "0." ]; then
   echo -ne "[`date '+%d%m%Y %T'`] $1 \t[\e[40;32mOK\e[40;37m]\n" | expand -t 70 | tee -a ${LOGFILE}
 elif [ "$2." == "1." ]; then
   echo -ne "[`date '+%d%m%Y %T'`] $1 \t[\e[40;31mNOK\e[40;37m]\n" | expand -t 70 | tee -a ${LOGFILE}
   send_email "${1}"
   exit 1
 else
     echo -ne "[`date '+%d%m%Y %T'`] $1 \n" | expand -t 70 | tee -a ${LOGFILE}
 fi
}

clearsnap(){
  log "Delete all existing snapshots.."
  ${NODETOOL} -h ${CASSANDRA_HOST} -u ${CASSANDRA_USER} -pw ${CASSANDRA_PASS} clearsnapshot ; RETVAL=$?
  if [ "${RETVAL}." == "0." ]
   then
    log "Snapshots removed successfully" 0
   else
    log "Failure in deleting snapshots" 1
  fi
}

takesnap(){
  log "Creating snapshot..."
  SNAPSHOT_NAME="snapshot_`date +"%Y%m%d_%H%M"`"
  ${NODETOOL} -h ${CASSANDRA_HOST} -u ${CASSANDRA_USER} -pw ${CASSANDRA_PASS} snapshot -t ${SNAPSHOT_NAME} ; RETVAL=$?
  if [ "${RETVAL}." == "0." ]
   then
    log "Snapshot created successfully" 0
   else
    log "Error occurred in creating snapshots" 1
  fi
}

for arg
do
    delim=""
    case "$arg" in
    #translate --gnu-long-options to -g (short options)
      --username)             args="${args}-u ";;
      --password)             args="${args}-p ";;
      --host)                 args="${args}-H ";;
      --help)                 args="${args}-h ";;
      #pass through anything else

      *) [[ "${arg:0:1}" == "-" ]] || delim="\""
         args="${args}${delim}${arg}${delim} ";;
    esac
done

eval set -- $args

while getopts ":h:u:p:b:H:" PARAMETER
do
    case $PARAMETER in
        h) help;;
        H) CASSANDRA_HOST=${OPTARG[@]};;
        u) CASSANDRA_USER=${OPTARG[@]};;
        p) CASSANDRA_PASS=${OPTARG[@]};;
        :) echo "Option -$OPTARG requires an argument."; exit 1;;
        *) echo $OPTARG is an unrecognized option ; echo $USAGE; exit 1;;
    esac
done

# Execution
clearsnap
takesnap

