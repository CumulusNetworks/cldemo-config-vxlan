ansible-playbook deploy-head-end-replication.yml
ssh server01 ping 172.16.2.101 -c 1
ansible-playbook deploy-service-node-replication.yml
ssh server01 ping 172.16.2.101 -c 1
