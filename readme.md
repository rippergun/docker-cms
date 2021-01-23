## build des images
```
sudo docker build -t rippergun/neonovis:8.0 .

cd neosocketio && sudo docker build -t neosocketio .
```

## envoyer sur le hub
```
docker push rippergun/neonovis:8.0
```

## sur le host : 
```
cat /$USER$/.ssh/id_rsa.pub > ssh/authorized_keys
chmod 700 .ssh
```
## dans le container :
```
cd /root/
chown root .ssh
chmod 700 .ssh
chmod 600 .ssh/authorized_keys
```

### essayer de se connecter une premiere fois en ssh