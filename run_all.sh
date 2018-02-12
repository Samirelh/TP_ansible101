# !/bin/bash

echo "Clonage du repository git contenant le TP1"

git clone "https://github.com/mad97231/tp1_git" share

echo "Suppression des contenaires existant"

docker kill $(docker ps -a -q -f name="contenaire")
docker rm $(docker ps -a -q -f name="contenaire")

echo "Creation des builds"

docker build -f compile_code/Dockerfile -t compile_code:v1 compile_code/
docker build -f execute_code/Dockerfile -t execute_code:v1 execute_code/
docker build -f git_stat/Dockerfile -t git_stat:v1 git_stat/
docker build -f publish_stat/Dockerfile -t publish_stat:v1 publish_stat/

echo "Lancement des contenaires"

docker run -d --name contenaire_compile -v `pwd`/share/code/:/opt/code compile_code:v1
docker run -d --name contenaire_execute -v `pwd`/share/code/:/opt/code execute_code:v1
docker run -d --name contenaire_git -v `pwd`/share/code/:/opt/code git_stat:v1 
docker run -d --name contenaire_publish -v `pwd`/share/code/:/opt/code publish_stat:v1

echo "Creation du fichier hosts_list"

echo "[compile]" > hosts_list
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' contenaire_compile >> hosts_list
echo "[execute]" >> hosts_list
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' contenaire_execute >> hosts_list
echo "[git]" >> hosts_list
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' contenaire_git >> hosts_list
echo "[publish]" >> hosts_list
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' contenaire_publish >> hosts_list
