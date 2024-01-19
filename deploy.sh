# /bin/bash


## Убираем всё из known_hosts, потому что не получилось сделать так,
## чтобы при выполнении ansible-playbook known_hosts не проверялся 
echo "" > ~/.ssh/known_hosts 

echo "Создаём виртуальные машину vagrant"
cd vagrant && vagrant up

sleep 60
vagrant snapshot push nfss
vagrant snapshot push nfsc

echo "Настраиваем сервер и клиент NFS"
cd ..
ansible-playbook ansible/playbooks/manage_nfss.yaml -i ansible/inventory/hosts --ssh-common-args='-o StrictHostKeyChecking=no' -b  -v
ansible-playbook ansible/playbooks/manage_nfsc.yaml -i ansible/inventory/hosts --ssh-common-args='-o StrictHostKeyChecking=no' -b  -v
ansible-playbook ansible/playbooks/test.yaml -i ansible/inventory/hosts --ssh-common-args='-o StrictHostKeyChecking=no' -b  -v --ask-become-pass
mv ansible/logfile_nfss/centos_nfss/tmp/logfile_nfss .
mv ansible/logfile_nfsc/centos_nfsc/tmp/logfile_nfsc .
mv ansible/logfile_test_client/centos_nfsc/tmp/logfile_test_client .
mv ansible/logfile_test_server/centos_nfss/tmp/logfile_test_server .

rm -rf ansible/logfile_nfsc
rm -rf ansible/logfile_nfss
rm -rf ansible/logfile_test_client
rm -rf ansible/logfile_test_server
echo "Файлы с логами находятся рядом со скриптом"