#!/bin/bash

echo -e "\n"
for word in $@
do
	python ~/Scripts/youdao.py $word
	echo -e "\n"
done
