# Ce code permet de générer une vidéo à partir d'un ensemble d'image en appliquant, comme transition un fondu entre chaque image
# Auteur : chmanu@gmail.com

# répertoire où se trouvent les images à assembler
dir="/home/chmanu/list-img"
# extension de fichier à considérer
ext='jpg'
# nom du fichier vidéo en sortie
outputfile='list-img.mp4'

# Début du programme
idx=0
nbimg=$(ls $dir/*.$ext | wc -l )
stopidx=$(echo "$nbimg - 1" | bc )
filter2="[f0][f1]overlay[bg1];"

for img in `ls $dir/*.$ext ` ; do
        idxnext=$(echo "$idx + 1" | bc )
        startpts=$(echo "$idxnext*4" | bc)
        input="$input-loop 1 -t 5 -i $img "
        filter1="$filter1[$idx]scale=-2:720,pad=1280:720:(ow-iw)/2:(oh-ih)/2,setsar=1,fade=d=1:t=in:alpha=1,fade=t=out:st=4:d=1,setpts=PTS-STARTPTS+$startpts/TB[f$idx];"
        if [ $stopidx -eq $idxnext ]; then
                filter2="$filter2[bg$idx][f$idxnext]overlay,format=yuv420p[v]"
        else
                if [ $idx -gt 0 ] && [ $idx -lt $stopidx ]; then
                        filter2="$filter2[bg$idx][f$idxnext]overlay[bg$idxnext];"
                fi
        fi
        idx=$idxnext
done

cmd="ffmpeg \\ \n$input -filter_complex \"\n${filter1}${filter2}\" -map [v] -movflags +faststart -y out.mp4"
cmd="ffmpeg $input -filter_complex \"${filter1}${filter2}\" -map [v] -movflags +faststart -y $outputfile"

echo $cmd
eval $cmd

exit
