#!/bin/sh

export OMP_STACKSIZE=1024M
set -x

cd ${datapath2}

fh=${FHMIN}
while [ $fh -le $FHMAX ]; do

  charfhr="fhr`printf %02i $fh`"

  if [ $cleanup_ensmean == 'true' ] || ([ $cleanup_ensmean == 'false' ]  && [ ! -s ${datapath}/${analdate}/bfg_${analdate}_${charfhr}_ensmean ]); then
      echo "running  ${execdir}/getsfcensmeanp.x ${datapath2}/ bfg_${analdate}_${charfhr}_ensmean bfg_${analdate}_${charfhr} ${nanals}"
      /bin/rm -f ${datapath2}/bfg_${analdate}_${charfhr}_ensmean
      export PGM="${execdir}/getsfcensmeanp.x ${datapath2}/ bfg_${analdate}_${charfhr}_ensmean bfg_${analdate}_${charfhr} ${nanals}"
      ${enkfscripts}/runmpi
      if [ ! -s ${datapath}/${analdate}/bfg_${analdate}_${charfhr}_ensmean ]; then
         echo "getsfcensmeanp.x failed..."
         exit 1
      fi
  fi
  if [ $cleanup_ensmean == 'true' ] || ([ $cleanup_ensmean == 'false' ]  && [ ! -s ${datapath}/${analdate}/sfg_${analdate}_${charfhr}_ensmean ]); then
      /bin/rm -f ${datapath2}/sfg_${analdate}_${charfhr}_ensmean
      echo "running ${execdir}/getsigensmeanp_smooth.x ${datapath2}/ sfg_${analdate}_${charfhr}_ensmean sfg_${analdate}_${charfhr} ${nanals} sfg_${analdate}_${charfhr}_enssprd"
      if [ $fh -eq $ANALINC ]; then # just save spread at middle of window
         export PGM="${execdir}/getsigensmeanp_smooth.x ${datapath2}/ sfg_${analdate}_${charfhr}_ensmean sfg_${analdate}_${charfhr} ${nanals} sfg_${analdate}_${charfhr}_enssprd"
      else
         export PGM="${execdir}/getsigensmeanp_smooth.x ${datapath2}/ sfg_${analdate}_${charfhr}_ensmean sfg_${analdate}_${charfhr} ${nanals}"
      fi
      ${enkfscripts}/runmpi
      if [ ! -s ${datapath}/${analdate}/sfg_${analdate}_${charfhr}_ensmean ]; then
         echo "getsigensmeanp_smooth.x failed..."
         exit 1
      fi
  fi

  fh=$((fh+FHOUT))

done

if [ $nanals2 -gt 0 ]; then

fhrs=`ls ${datapath}/${analdate}/sfg2_${analdate}*mem001 | awk -F'fhr' '{print $2}' | cut -f1 -d"_"`
for fhr in $fhrs; do

  charfhr="fhr${fhr}"

  if [ $cleanup_ensmean == 'true' ] || ([ $cleanup_ensmean == 'false' ]  && [ ! -s ${datapath}/${analdate}/bfg2_${analdate}_${charfhr}_ensmean ]); then
      echo "running  ${execdir}/getsfcensmeanp.x ${datapath2}/ bfg2_${analdate}_${charfhr}_ensmean bfg2_${analdate}_${charfhr} ${nanals2}"
      /bin/rm -f ${datapath2}/bfg2_${analdate}_${charfhr}_ensmean
      export PGM="${execdir}/getsfcensmeanp.x ${datapath2}/ bfg2_${analdate}_${charfhr}_ensmean bfg2_${analdate}_${charfhr} ${nanals2}"
      ${enkfscripts}/runmpi
      if [ ! -s ${datapath}/${analdate}/bfg2_${analdate}_${charfhr}_ensmean ]; then
         echo "getsfcensmeanp.x failed..."
         exit 1
      fi
  fi
  if [ $cleanup_ensmean == 'true' ] || ([ $cleanup_ensmean == 'false' ]  && [ ! -s ${datapath}/${analdate}/sfg2_${analdate}_${charfhr}_ensmean ]); then
      /bin/rm -f ${datapath2}/sfg2_${analdate}_${charfhr}_ensmean
      echo "running ${execdir}/getsigensmeanp_smooth.x ${datapath2}/ sfg2_${analdate}_${charfhr}_ensmean sfg2_${analdate}_${charfhr} ${nanals2} sfg2_${analdate}_${charfhr}_enssprd"
      compute_spread=`python -c "from __future__ import print_function; print($fh % 6)"`
      if [ $compute_spread -eq 0 ]; then # just save spread at middle of window
         export PGM="${execdir}/getsigensmeanp_smooth.x ${datapath2}/ sfg2_${analdate}_${charfhr}_ensmean sfg2_${analdate}_${charfhr} ${nanals2} sfg2_${analdate}_${charfhr}_enssprd"
      else
         export PGM="${execdir}/getsigensmeanp_smooth.x ${datapath2}/ sfg2_${analdate}_${charfhr}_ensmean sfg2_${analdate}_${charfhr} ${nanals2}"
      fi
      ${enkfscripts}/runmpi
      if [ ! -s ${datapath}/${analdate}/sfg2_${analdate}_${charfhr}_ensmean ]; then
         echo "getsigensmeanp_smooth.x failed..."
         exit 1
      fi
  fi

done

fi

echo "all done `date`"
