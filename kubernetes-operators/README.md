> $ k get jobs                                                                                                                                                                                                                      [±kubernetes-templating ●]
NAME                         COMPLETIONS   DURATION   AGE
backup-mysql-instance-job    1/1           3s         91m
restore-mysql-instance-job   1/1           44s        90m

> $ kubectl exec -it $MYSQLPOD -- mysql -potuspassword -e "select * from test;" otus-database                                                                                                                                   
+----+-------------+
| id | name        |
+----+-------------+
|  1 | some data   |
|  2 | some data-2 |
+----+-------------+