# https://stackoverflow.com/questions/5143795/how-can-i-check-in-a-bash-script-if-my-local-git-repo-has-changes
if [[ `git status --porcelain` ]]; then
	  # changes
	  echo "Changes detected, rebuilding datasets"
else
	exit 0
fi

ruby data_set_transformation.rb dataset1.csv
ruby data_set_transformation.rb dataset2.csv
ruby data_set_transformation.rb dataset3.csv
ruby data_set_transformation.rb dataset4.csv
ruby data_set_transformation.rb dataset5.csv

cat ML_dataset2.csv >> ML_dataset1.csv
cat ML_dataset3.csv >> ML_dataset1.csv
cat ML_dataset4.csv >> ML_dataset1.csv
cat ML_dataset5.csv >> ML_dataset1.csv

