# Hands on Guide

To understand this concept on a hands-on level, explore how Docker images are constructed using layers. You'll use the official Nginx image to understand.

## Viewing Image Layers

First, you need to pull the Nginx image for the hands-on:
```bash
docker pull nginx
```{{exec}}

To see all the layers that make up the Nginx image, use:

```bash
docker history nginx
```{{exec}}


### Example Output

```text
$ docker history nginx
IMAGE          CREATED        CREATED BY                                      SIZE      COMMENT
d261fd19cb63   32 hours ago   CMD ["nginx" "-g" "daemon off;"]                0B        buildkit.dockerfile.v0
<missing>      32 hours ago   STOPSIGNAL SIGQUIT                              0B        buildkit.dockerfile.v0
<missing>      32 hours ago   EXPOSE map[80/tcp:{}]                           0B        buildkit.dockerfile.v0
<missing>      32 hours ago   ENTRYPOINT ["/docker-entrypoint.sh"]            0B        buildkit.dockerfile.v0
<missing>      32 hours ago   COPY 30-tune-worker-processes.sh /docker-ent…   4.62kB    buildkit.dockerfile.v0
<missing>      32 hours ago   COPY 20-envsubst-on-templates.sh /docker-ent…   3.02kB    buildkit.dockerfile.v0
<missing>      32 hours ago   COPY 15-local-resolvers.envsh /docker-entryp…   389B      buildkit.dockerfile.v0
<missing>      32 hours ago   COPY 10-listen-on-ipv6-by-default.sh /docker…   2.12kB    buildkit.dockerfile.v0
<missing>      32 hours ago   COPY docker-entrypoint.sh / # buildkit          1.62kB    buildkit.dockerfile.v0
<missing>      32 hours ago   RUN /bin/sh -c set -x     && groupadd --syst…   73.2MB    buildkit.dockerfile.v0
<missing>      32 hours ago   ENV DYNPKG_RELEASE=1~trixie                     0B        buildkit.dockerfile.v0
<missing>      32 hours ago   ENV PKG_RELEASE=1~trixie                        0B        buildkit.dockerfile.v0
<missing>      32 hours ago   ENV NJS_RELEASE=1~trixie                        0B        buildkit.dockerfile.v0
<missing>      32 hours ago   ENV NJS_VERSION=0.9.4                           0B        buildkit.dockerfile.v0
<missing>      32 hours ago   ENV NGINX_VERSION=1.29.3                        0B        buildkit.dockerfile.v0
<missing>      32 hours ago   LABEL maintainer=NGINX Docker Maintainers <d…   0B        buildkit.dockerfile.v0
<missing>      40 hours ago   # debian.sh --arch 'amd64' out/ 'trixie' '@1…   78.6MB    debuerreotype 0.16
```

The explanation of the above output is.

* **Layers are listed in reverse order** - newest at the top, base layer at the bottom
* **`<missing>` entries** - These are intermediate build cache layers. Only the final complete image is stored locally
* **SIZE column** - Shows disk space each layer adds:
  - Large layers (73.2MB, 78.6MB): Base OS and Nginx installation
  - Small layers (4.62kB, 3.02kB): Configuration scripts
  - Zero-size layers (0B): Metadata like ENV, EXPOSE, CMD
* **CREATED BY column** - Shows the Dockerfile instruction that created the layer

---

## Inspect Image Details

Get detailed JSON information about the image:

```bash
docker inspect nginx
```{{exec}}

You'll see something like:

### Example Output

```json
{
  "Id": "sha256:d261fd19cb63...",
  "RepoTags": ["nginx:latest"],
  "Created": "2025-11-04T04:06:21Z",
  "Size": 151862173,

  "GraphDriver": {
    "Name": "overlay2",
    "Data": {
      "LowerDir": ".../diff:.../diff:.../diff:.../diff:.../diff:.../diff",
      "UpperDir": ".../diff",
      "MergedDir": ".../merged"
    }
  },

  "RootFS": {
    "Type": "layers",
    "Layers": [
      "sha256:36d06fe0cbc6...",
      "sha256:6e19587ac541...",
      "sha256:8feb164cd673...",
      "sha256:2ced4cd78a7b...",
      "sha256:99cd1b1b6a43...",
      "sha256:d81df94f8d07...",
      "sha256:d7217c60dca4..."
    ]
  }
}

```

## Explore Image Layers on Disk

Docker stores all image layers locally at `/var/lib/docker/overlay2`. Let's explore:

```bash
sudo ls -l /var/lib/docker/overlay2
```{{exec}}

You'll see directories like:

```text
drwx--x--- 4 root root 4096 Nov  5 10:30 018c7356f4553bf825e2a16fb437b5a8
drwx--x--- 4 root root 4096 Nov  5 10:30 6cd78b9c714d723b18c2ad24b90f421c
drwx--x--- 4 root root 4096 Nov  5 10:30 f5078d23c389f9480a98e9cb07fd1219
drwx--x--- 2 root root 4096 Nov  5 10:30 l
```

Each directory represents **one layer** of an image on your system.

### Inspect a Specific Layer

Pick one of the layer directories and examine its contents:

```bash
sudo ls -la /var/lib/docker/overlay2/$(sudo ls /var/lib/docker/overlay2 | head -1)
```{{exec}}

### Layer Directory Structure

```text
.
├── committed          # Marks this layer as finalized
├── diff/              # Contains actual file changes in this layer
│   └── docker-entrypoint.sh
├── link               # Short internal reference name
├── lower              # Points to parent layer dependencies
└── work/              # Temporary workspace for OverlayFS merging
```

**Key Components:**
- **diff/** - Contains actual file changes in this layer
- **link** - Short internal name Docker uses as a reference of this layer
- **lower** - Defines which parent layer is depend on this layer
- **work/** - Temorary workspace used by OverlayFS for the merging
- **committed** - Indicates that this layer is completed and saved as part of the final image
---

