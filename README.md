## docker-ubuntu-vnc-desktop

Docker image to provide HTML5 VNC interface to access Ubuntu 16.04 LXDE desktop environment with added [netboot.xyz](https://netboot.xyz/) iso access in directory `/iso/netboot.xyz.iso`.

Quick Start
-------------------------

Run the docker container and access with port `6080`

```
docker run -p 6080:80 centminmod/docker-ubuntu-vnc-desktop
```

Browse http://127.0.0.1:6080/

<img src="https://raw.github.com/centminmod/docker-ubuntu-vnc-desktop/master/screenshots/lxde.png?v1" width=700/>


VNC Viewer
------------------

Forward VNC service port 5900 to host by

```
docker run -it --rm -p 6080:80 -p 5900:5900 centminmod/docker-ubuntu-vnc-desktop
```

Now, open the vnc viewer and connect to port 5900. If you would like to protect vnc service by password, set environment variable `VNC_PASSWORD`, for example

```
docker run -it --rm -p 6080:80 -p 5900:5900 -e VNC_PASSWORD=mypassword centminmod/docker-ubuntu-vnc-desktop
```

A prompt will ask password either in the browser or vnc viewer.

<img src="https://raw.github.com/centminmod/docker-ubuntu-vnc-desktop/master/screenshots/lxde2.png?v1" width=700/>

HTTP Base Authentication
---------------------------

This image provides base access authentication of HTTP via `HTTP_PASSWORD`

```
docker run -p 6080:80 -e HTTP_PASSWORD=mypassword centminmod/docker-ubuntu-vnc-desktop
```

SSL
--------------------

To connect with SSL, generate self signed SSL certificate first if you don't have it

```
mkdir -p ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ssl/nginx.key -out ssl/nginx.crt
```

Specify SSL port by `SSL_PORT`, certificate path to `/etc/nginx/ssl`, and forward it to 6081

```
docker run -p 6081:443 -e SSL_PORT=443 -v ${PWD}/ssl:/etc/nginx/ssl centminmod/docker-ubuntu-vnc-desktop
```

Screen Resolution
------------------

Resolution of virtual desktop adapts browser window size when first connecting the server. You may choose a fixed resolution by passing `RESOLUTION` environment variable, for example

```
docker run -p 6080:80 -p 5900:5900 -e VNC_PASSWORD=mypassword -e RESOLUTION=1920x1080 centminmod/docker-ubuntu-vnc-desktop
```

Default Desktop User
--------------------

The default user is `root`. You may change the user and password respectively by `USER` and `PASSWORD` environment variable, for example,

```
docker run -p 6080:80 -e USER=doro -e PASSWORD=password centminmod/docker-ubuntu-vnc-desktop
```

Sound (Preview version and Linux only)
-------------------

It only works in Linux. 

First of all, insert kernel module `snd-aloop` and specify `2` as the index of sound loop device

```
sudo modprobe snd-aloop index=2
```

Start the container

```
docker run -it --rm -p 6080:80 --device /dev/snd -e ALSADEV=hw:2,0 centminmod/docker-ubuntu-vnc-desktop
```

where `--device /dev/snd -e ALSADEV=hw:2,0` means to grant sound device to container and set basic ASLA config to use card 2.

Launch a browser with URL http://127.0.0.1:6080/#/?video, where `video` means to start with video mode. Now you can start Chromium in start menu (Internet -> Chromium Web Browser Sound) and try to play some video.

Following is the screen capture of these operations. Turn on your sound at the end of video!

[![demo video](http://img.youtube.com/vi/Kv9FGClP1-k/0.jpg)](http://www.youtube.com/watch?v=Kv9FGClP1-k)


## Dell iDRAC 6 IPMI Java Console Usage

Go into IcedTea web panel and lower the `Extended applet security` level for java applets

<img src="https://raw.github.com/centminmod/docker-ubuntu-vnc-desktop/master/screenshots/dell-idrac-console/docker-ubuntu-vnc-icedtea-web-panel-01.png?v1" width=700/>

<img src="https://raw.github.com/centminmod/docker-ubuntu-vnc-desktop/master/screenshots/dell-idrac-console/docker-ubuntu-vnc-icedtea-web-panel-02.png?v1" width=700/>

Launch Firefox browser and go to your IPMI web login and add a permenant exception for HTTPS based IPMI login

<img src="https://raw.github.com/centminmod/docker-ubuntu-vnc-desktop/master/screenshots/dell-idrac-console/docker-ubuntu-vnc-firefox-ipmi-01.png?v1" width=700/>

<img src="https://raw.github.com/centminmod/docker-ubuntu-vnc-desktop/master/screenshots/dell-idrac-console/docker-ubuntu-vnc-firefox-ipmi-02.png?v1" width=700/>

Launch console and open with `IceTea Java Web Start` + check trust publisher and content.

<img src="https://raw.github.com/centminmod/docker-ubuntu-vnc-desktop/master/screenshots/dell-idrac-console/docker-ubuntu-vnc-firefox-ipmi-03.png?v1" width=700/>

<img src="https://raw.github.com/centminmod/docker-ubuntu-vnc-desktop/master/screenshots/dell-idrac-console/docker-ubuntu-vnc-firefox-ipmi-04.png?v1" width=700/>

<img src="https://raw.github.com/centminmod/docker-ubuntu-vnc-desktop/master/screenshots/dell-idrac-console/docker-ubuntu-vnc-firefox-ipmi-05.png?v1" width=700/>

Answer yes to run java console applet

<img src="https://raw.github.com/centminmod/docker-ubuntu-vnc-desktop/master/screenshots/dell-idrac-console/docker-ubuntu-vnc-firefox-ipmi-06.png?v1" width=700/>

<img src="https://raw.github.com/centminmod/docker-ubuntu-vnc-desktop/master/screenshots/dell-idrac-console/docker-ubuntu-vnc-dell-kvm-virtualmedia-02.png?v1" width=700/>

<img src="https://raw.github.com/centminmod/docker-ubuntu-vnc-desktop/master/screenshots/dell-idrac-console/docker-ubuntu-vnc-centos7-01.png?v1" width=700/>

Troubleshooting


1. boot2docker connection issue, https://github.com/fcwu/docker-ubuntu-vnc-desktop/issues/2


## License

See the LICENSE file for details.
