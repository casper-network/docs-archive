
for i in theory/*.md; do
    pandoc $i -o ${i%.*}_converted.rst --wrap=preserve
done

for i in implementation/*.md; do
    pandoc $i -o ${i%.*}_converted.rst --wrap=preserve
done
