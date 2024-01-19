#!/bin/bash

# В последних версия harbor нет возможности установки классического helm repo, так как chartmuseum - deprecated

read -p 'Username: ' uservar
read -sp 'Password: ' passvar

helm registry login -u $uservar -p $passvar harbor.ivanovskijma.ru

helm package ./hipster-shop/ -u
helm package ./frontend/

helm push frontend-0.1.0.tgz oci://harbor.ivanovskijma.ru/library/templating
helm push hipster-shop-0.1.0.tgz oci://harbor.ivanovskijma.ru/library/templating

helm upgrade --install hipster-shop --namespace hipster-shop --create-namespace oci://harbor.ivanovskijma.ru/library/templating/hipster-shop
