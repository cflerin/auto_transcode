auto_transcode
**************

Monitor a directory for new video files ending in (mov|MOV), transcode and normalize audio, moving the output to a new location.
Uses ``ionotifywait``,
`ffmpeg <http://ffmpeg.org/>`_,
and
`ffmpeg-normalize <https://github.com/slhck/ffmpeg-normalize>`_.

Docker container
----------------

To build the Docker image::

    docker build -t cflerin/autotranscode:latest . -f auto_transcode/Dockerfile


Directory structure within the container:

- ``/auto_transcode/input``: Monitor this directory.
- ``/auto_transcode/output``: Move the output file here.
- ``/auto_transcode/archive``: Move the original file here for archival purposes.
- ``/auto_transcode/logs``: Log file location.

Running
-------

To start the container as a service::

    docker run --rm \
        -v /path/to/watch_directory:/auto_transcode/input \
        -v /path/to/output:/auto_transcode/output \
        -v /path/to/archive/archive:/auto_transcode/archive \
        -v /path/to/logs:/auto_transcode/logs \
        -w $PWD \
        cflerin/autotranscode:latest \

With docker-compose::

    auto_transcode:
      container_name: auto_transcode
      image: cflerin/autotranscode:latest
      volumes:
        - /path/to/watch_directory:/auto_transcode/input
        - /path/to/output:/auto_transcode/output
        - /path/to/archive/archive:/auto_transcode/archive
        - /path/to/logs:/auto_transcode/logs
      working_dir: /path/to/auto_transcode
      restart: unless-stopped

