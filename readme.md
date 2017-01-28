## sur le host : 
```
cat /$USER$/.ssh/id_rsa.pub > ssh/authorized_keys
```
## dans le container :
```
cd /root/
chown root .ssh
chmod 700 .ssh
chmod 600 .ssh/authorized_keys
```

### essayer de se connecter une premiere fois en ssh