An assortment of `Dockerfiles`

Build a Dockerfile via `Podman` using `buildimage.sh` at root with the directory containing the `Dockerfile` as argv[1], i.e:

```bash
./buildimage.sh ubuntu24
```

Run the newly built image, for example:

Uses the previously built `ubuntu24` image corresponding to the local directory; mounts `pwd` at `/mydir`

```bash
./runcontainer.sh -i ubuntu24 -l `pwd` -v mydir
```

**NOTE** this defaults to running `/bin/bash` as the `-it` command.
