cd ../dataset
./merge_datasets.sh

cd ../ml
python3 machine_learning.py 1>>scores.txt 2>/dev/null
tail scores.txt
