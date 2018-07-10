URL="http://www.google.com/search?q="
for var in $@
do
  URL=${URL}${var}+
done
w3m ${URL}
