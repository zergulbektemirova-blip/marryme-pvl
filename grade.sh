#!/usr/bin/env bash
# Re-cuts every site clip from the originals with one shared cinematic grade, so phone footage
# from different days and cameras reads as one film.
# Usage: bash grade.sh [originals folder] [output folder] [graded]   (default: original colours)
set -e
SRC="${1:-/c/Users/Kabdulla/OneDrive/Documents/мэрри ми}"
OUT="${2:-media}"
cd "$(dirname "$0")"; mkdir -p "$OUT"
# denoise -> gentle contrast -> warm burgundy balance -> soft film curve -> vignette -> sharpen -> fine grain
GRADE="hqdn3d=1.5:1.5:3:3,eq=contrast=1.05:saturation=1.06,colorbalance=rs=.05:gs=-.01:bs=-.01:rm=.02:bm=-.02:rh=.03:gh=.01:bh=-.05,curves=master='0/0.04 0.25/0.235 0.75/0.78 1/0.96',vignette=PI/5,unsharp=5:5:0.5"
GRAIN="noise=alls=4:allf=t+u"
# the client chose original colours: clips are cut plain unless "graded" is passed
[ "$3" != graded ] && GRADE=null && GRAIN=null

clip() { # name source start duration width
  local dur=(); [ "$4" != "-" ] && dur=(-t "$4")
  ffmpeg -nostdin -v error -y -ss "$3" "${dur[@]}" -i "$SRC/$2" -an \
    -vf "scale=$5:-2:flags=lanczos,fps=30,$GRADE,$GRAIN" -c:v libx264 -crf 25 -preset slow -pix_fmt yuv420p -movflags +faststart "$OUT/$1.mp4"
  ffmpeg -nostdin -v error -y -ss "$(awk "BEGIN{print $3+1}")" -i "$SRC/$2" -frames:v 1 -vf "scale=$5:-2:flags=lanczos,$GRADE" -q:v 4 "$OUT/$1.jpg"
  echo -n "$1 "
}
while read -r n s ss t w; do [ -n "$n" ] && clip "$n" "$s" "$ss" "$t" "$w"; done <<'EOF'
aerial IMG_1684.MP4 0 - 720
proposal IMG_1682.MP4 19 6 540
birthday IMG_0249.MP4 8 6 540
mama IMG_8973.MP4 3 6 540
parents IMG_0481.MP4 6 6 540
roddom IMG_1692.MP4 4 6 540
s1 IMG_1697.MP4 3 5 540
s2 IMG_1698.MP4 8 5 540
s3 IMG_1700.MP4 8 6 540
s4 IMG_1691.MP4 32 6 540
g1 IMG_1685.MP4 32 5 540
g2 IMG_1696.MP4 22 5 540
g3 IMG_1706.MP4 12 5 540
g4 IMG_1709.MP4 14 5 540
g5 IMG_8606.MOV 0 3.5 540
g6 IMG_1694.MP4 60 5 540
g7 IMG_1699.MP4 30 5 540
g8 IMG_1693.MP4 20 5 540
h1 IMG_9694.MP4 10 6 540
h2 IMG_8088.MP4 5 6 540
h3 IMG_1701.MP4 20 6 540
h4 IMG_1704.MP4 25 6 540
h5 IMG_1705.MP4 10 6 540
h7 IMG_1707.MP4 30 6 540
h8 IMG_1695.MP4 60 6 540
table IMG_1702.MP4 11.5 5 540
EOF

# photos get the same grade (HEIC goes through png first)
for p in IMG_0262.JPG.jpeg IMG_5415.PNG IMG_5838.JPG.jpeg IMG_5840.JPG.jpeg IMG_0690.HEIC IMG_0932.HEIC IMG_2914.HEIC; do
  b=${p%%.*}; in="$SRC/$p"
  case "$p" in *.HEIC) ffmpeg -nostdin -v error -y -i "$in" -frames:v 1 "$OUT/_tmp.png"; in="$OUT/_tmp.png";; esac
  ffmpeg -nostdin -v error -y -i "$in" -vf "scale=900:-2:flags=lanczos,$GRADE" -q:v 3 "$OUT/$b.jpg"; echo -n "$b "
done
rm -f "$OUT/_tmp.png"
echo; du -sh "$OUT"
