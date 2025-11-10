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


## Explore Image Layers on Disk

Docker stores all image layers locally at `/var/lib/docker/overlay2`. Let's explore:

```bash
sudo ls -l /var/lib/docker/overlay2
```{{exec}}


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

