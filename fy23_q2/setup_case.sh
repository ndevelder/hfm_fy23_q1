
for i in "$@"; do
    case "$1" in
        -m=*|--machine=*)
            MACHINE="${i#*=}"
            shift # past argument=value
            ;;
        -w=*|--wind_speed=*)
            WIND_SPEED="${i#*=}"
            shift # past argument=value
            ;;
        -s=*|--submit=*)
            SUBMIT="${i#*=}"
            shift # past argument=value
            ;;
        -e=*|--email=*)
            EMAIL="${i#*=}"
            shift # past argument=value
            ;;
        --)
            shift
            break
            ;;
    esac
done
# must load things so that aprepro is active in the shell
# machine specific params i.e. mesh/restart/etc
aprepro_include=$(pwd)/${MACHINE}_aprepro.txt

source ${MACHINE}_setup_env.sh
target_dir=wind_speed_$WIND_SPEED
mkdir -p $target_dir
cp -R openfast_run/* $target_dir
cp -R fsi_run/* $target_dir
cd $target_dir
# text replace the wind speed and mesh location in these files
aprepro -qW --include ${aprepro_include} WIND_SPEED=$WIND_SPEED iea15mw-nalu-01.yaml iea15mw-nalu-01.yaml 
aprepro -qW --include ${aprepro_include} IEA-15-240-RWT-Monopile_ServoDyn.dat IEA-15-240-RWT-Monopile_ServoDyn.dat
aprepro -qW WIND_SPEED=$WIND_SPEED iea15mw-amr-01.inp iea15mw-amr-01.inp 
aprepro -qW WIND_SPEED=$WIND_SPEED inp.yaml inp.yaml  
aprepro -qW --include ${aprepro_include} WIND_SPEED=$WIND_SPEED EMAIL=$EMAIL ../run_case.sh.i run_case.sh
# submit case if submit flag given
if [ -n "${SUBMIT}" ]; then
sbatch run_case.sh
fi
